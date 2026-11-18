extends RefCounted
## Compose the base outfit with independently equipped, authored visual layers.
const ROOT = "res://scenes/armor_parts/"
const CLASSIC_IDS = ["armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
static var scenes: Dictionary = {}

static func scene_path(state: PlayerState) -> String:
	var id: String = str(state.equipment.get("armadura", {}).get("id", ""))
	if id == "roupa_basica":
		return ROOT + "basicos/%s_%s.tscn" % [state.race_id, state.gender_id]
	if id.begins_with("armadura_catalogo_"):
		var number: int = int(str(GameData.item(id).get("catalog_art", "")).trim_prefix("armadura_"))
		return ROOT + "catalogo/armadura_%03d.tscn" % number
	if id in CLASSIC_IDS:
		return ROOT + "classes/%s/%s.tscn" % [state.class_id, id]
	return ""

static func configuration_key(state: PlayerState) -> String:
	var key: String = scene_path(state)
	for slot: String in GameData.ARMOR_PARTS:
		var id: String = str(state.equipment.get(slot, {}).get("id", ""))
		if not id.is_empty(): key += ":" + slot + "=" + id
	return key

static func _load_scene(path: String) -> Node2D:
	if path.is_empty() or not ResourceLoader.exists(path): return null
	if not scenes.has(path): scenes[path] = load(path)
	return scenes[path].instantiate()

static func instantiate(state: PlayerState) -> Node2D:
	var path: String = scene_path(state)
	var visual_id: String = GameData.visual_armor_id(state.equipment)
	var base: Node2D = _load_scene(path)
	var reference: Node2D = null
	if visual_id.begins_with("armadura_catalogo_"):
		reference = _load_scene(ROOT + "catalogo/%s.tscn" % visual_id.replace("armadura_catalogo_", "armadura_"))
	if reference == null: reference = base
	if reference == null:
		reference = _load_scene(ROOT + "basicos/%s_%s.tscn" % [state.race_id, state.gender_id])
	if reference == null: return null
	var result: Node2D = reference
	for slot: String in GameData.ARMOR_PARTS:
		var definition: Dictionary = GameData.item(str(state.equipment.get(slot, {}).get("id", "")))
		var source: Node2D = null
		var selected: bool = definition.has("armor_set")
		if selected:
			var number: int = int(str(definition["catalog_art"]).trim_prefix("armadura_"))
			source = _load_scene(ROOT + "catalogo/armadura_%03d.tscn" % number)
		elif base != null and base != result:
			source = base
		if source == null: continue
		var layer_name: String = GameData.ARMOR_PARTS[slot]
		var layer: Sprite2D = source.get_node(layer_name).duplicate()
		var previous: Sprite2D = result.get_node(layer_name)
		if slot != "elmo" and source.armor_id != result.armor_id:
			_fit_section(layer, previous, slot)
		var index: int = previous.get_index()
		result.remove_child(previous)
		previous.free()
		result.add_child(layer)
		result.move_child(layer, index)
		if selected: layer.visible = true
		if slot == "elmo" and selected: result.reference_head = source.reference_head
		if source != base: source.free()
	if base != null and base != result: base.free()
	return result

static func _fit_section(layer: Sprite2D, target: Sprite2D, slot: String) -> void:
	if layer.texture == null or target.texture == null: return
	# Align shared anatomical boundaries, not each cutout's outer silhouette.
	# Hands must align independently: scaling the whole two-hand rectangle also
	# stretches its empty middle and leaves rectangular holes at the wrists.
	var source_mat: ShaderMaterial = layer.material
	var target_mat: ShaderMaterial = target.material
	var source_top: float = 128.0
	var target_top: float = 128.0
	var source_bottom: float = float(source_mat.get_shader_parameter("armor_waist_y")) * 512.0
	var target_bottom: float = float(target_mat.get_shader_parameter("armor_waist_y")) * 512.0
	if slot == "calca":
		source_top = source_bottom
		target_top = target_bottom
		source_bottom = float(source_mat.get_shader_parameter("armor_boots_y")) * 512.0
		target_bottom = float(target_mat.get_shader_parameter("armor_boots_y")) * 512.0
	elif slot == "botas":
		source_top = float(source_mat.get_shader_parameter("armor_boots_y")) * 512.0
		target_top = float(target_mat.get_shader_parameter("armor_boots_y")) * 512.0
		source_bottom = 508.0
		target_bottom = 508.0
	elif slot == "luvas":
		_fit_hands(layer, target)
		return
	var factor: float = (target_bottom - target_top) / maxf(source_bottom - source_top, 1.0)
	layer.position.y = target_top + (layer.position.y - source_top) * factor
	layer.scale.y *= factor
	if slot in ["calca", "botas"]:
		var original_x: float = Vector2(layer.get_meta("source_position", layer.position)).x
		var destination: Rect2 = target.transform * target.get_rect()
		var width_factor: float = destination.size.x / layer.texture.get_width()
		layer.position.x = destination.position.x + (layer.position.x - original_x) * width_factor
		layer.scale.x *= width_factor

static func _fit_hands(layer: Sprite2D, target: Sprite2D) -> void:
	var source_material: ShaderMaterial = layer.material
	var target_material: ShaderMaterial = target.material
	var original: AtlasTexture = layer.texture
	for key: String in ["armor_glove_a", "armor_glove_b"]:
		var a: Vector4 = source_material.get_shader_parameter(key)
		var b: Vector4 = target_material.get_shader_parameter(key)
		var source_box := Rect2(a.x * 256, a.y * 512, a.z * 256, a.w * 512)
		var target_box := Rect2(b.x * 256, b.y * 512, b.z * 256, b.w * 512)
		if not source_box.has_area() or not target_box.has_area(): continue
		var hand := Sprite2D.new()
		hand.name = "PunhoEsquerdo" if key == "armor_glove_a" else "PunhoDireito"
		hand.centered = false
		var cropped := AtlasTexture.new()
		cropped.atlas = original.atlas
		var region: Vector4 = source_material.get_shader_parameter("texture_region")
		var dimensions: Vector2 = original.atlas.get_size()
		cropped.region = Rect2(Vector2(region.x, region.y) * dimensions + source_box.position / Vector2(256, 512) * Vector2(region.z, region.w) * dimensions, source_box.size / Vector2(256, 512) * Vector2(region.z, region.w) * dimensions)
		cropped.filter_clip = true
		hand.texture = cropped
		hand.material = source_material.duplicate()
		var factor: float = minf(target_box.size.x / cropped.get_width(), target_box.size.y / cropped.get_height())
		hand.scale = Vector2.ONE * factor
		hand.position = Vector2(target_box.get_center().x - cropped.get_width() * factor * 0.5, target_box.position.y)
		layer.add_child(hand)
	layer.texture = null
	layer.position = Vector2.ZERO
	layer.scale = Vector2.ONE
	layer.set_meta("source_position", Vector2.ZERO)
