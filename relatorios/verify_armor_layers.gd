extends SceneTree
const Layers = preload("res://scripts/actors/armor_layer_catalog.gd")
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const PARTS = ["Peito", "Luvas", "Calca", "Botas"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/armor_parts/manifest.json"))
	assert(manifest.size() == 132)
	var helmets: int = 0
	var samples: int = 0
	for path: String in manifest:
		var scene: PackedScene = load(Layers.ROOT + path)
		var parts: Node2D = scene.instantiate()
		var other: Node2D = scene.instantiate()
		assert(parts.get_node("Elmo") is Sprite2D)
		assert(not parts.get_node("Elmo").visible)
		if parts.get_node("Elmo").texture != null: helmets += 1
		var region: Rect2 = parts.get_meta("source_region")
		var source: Texture2D = load(parts.get_meta("source_body"))
		var image: Image = source.get_image().get_region(Rect2i(region))
		for part_name: String in PARTS:
			var part: Sprite2D = parts.get_node(part_name)
			assert(part.texture is AtlasTexture and not part.centered)
			assert(part.texture.atlas == source)
			assert(part.material != other.get_node(part_name).material)
			assert(part.material.resource_local_to_scene)
		# Every visible original pixel has exactly one owning layer and lies inside its crop.
		var material: ShaderMaterial = parts.get_node("Peito").material
		var head: Vector4 = material.get_shader_parameter("armor_skin_head")
		var glove_a: Vector4 = material.get_shader_parameter("armor_glove_a")
		var glove_b: Vector4 = material.get_shader_parameter("armor_glove_b")
		var cutoff: float = material.get_shader_parameter("head_cutoff")
		var waist: float = material.get_shader_parameter("armor_waist_y")
		var boots: float = material.get_shader_parameter("armor_boots_y")
		for y: int in range(image.get_height()):
			for x: int in range(image.get_width()):
				if image.get_pixel(x, y).a < 0.75: continue
				var uv := Vector2(x + 0.5, y + 0.5) / Vector2(image.get_size())
				if uv.y < cutoff and uv.x > 0.26 and uv.x < 0.74: continue
				var owner: String = "Peito"
				if _inside(uv, head): owner = "Pele"
				elif _inside(uv, glove_a) or _inside(uv, glove_b): owner = "Luvas"
				elif uv.y >= boots: owner = "Botas"
				elif uv.y >= waist: owner = "Calca"
				var part: Sprite2D = parts.get_node(owner)
				assert(part.texture.region.has_point(Vector2(x, y) + region.position), "%s: %s crop loses (%d,%d)" % [path, owner, x, y])
				samples += 1
		parts.free()
		other.free()
	assert(helmets == 100)
	var state := PlayerState.create("Camadas", "humano", "guerreiro")
	state.add_item("armadura_catalogo_038", 1, true)
	assert(state.equip("armadura_catalogo_038").is_empty())
	var hero = load("res://scenes/hero.tscn").instantiate()
	hero.bind_state(state)
	hero.setup(null, "", 92.0)
	root.add_child(hero)
	await process_frame
	assert(hero.armor_parts != null and hero.sprite.self_modulate.a == 0)
	assert(hero.sprite.texture == Appearance.body_texture(state))
	assert(not hero.armor_parts.get_node("ReferenciaCabeca").visible)
	var preview = load("res://scripts/ui/hero_preview.gd").new()
	preview.state = state
	preview.size = Vector2(330, 400)
	root.add_child(preview)
	preview._sync_armor_parts()
	assert(preview.armor_parts.get_node("Peito").material != hero.armor_parts.get_node("Peito").material)
	assert(hero.armor_parts.get_node("Peito").material.get_shader_parameter("world_antialiasing"))
	assert(not preview.armor_parts.get_node("Peito").material.get_shader_parameter("world_antialiasing"))
	var chest: Sprite2D = hero.armor_parts.get_node("Peito")
	var gloves: Sprite2D = hero.armor_parts.get_node("Luvas")
	var boots_position: Vector2 = hero.armor_parts.get_node("Botas").position
	var chest_position: Vector2 = chest.position
	chest.position.y -= 5
	gloves.position.y -= 3
	hero._update_equipment_pose()
	var weapon_position: Vector2 = hero.weapon_sprite.position
	gloves.position.y += 3
	hero._update_equipment_pose()
	assert(is_equal_approx(hero.weapon_sprite.position.y, weapon_position.y + 3))
	for direction: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]:
		hero.facing = direction
		hero.velocity = direction * 100
		hero._update_hero_animation(1.0 / 60.0)
		hero._update_equipment_pose()
		assert(chest.position == chest_position - Vector2(0,5))
		assert(hero.armor_parts.get_node("Botas").position == boots_position)
		assert((hero.armor_parts.scale.x < 0) == hero.sprite.flip_h)
	hero.armor_parts.get_node("Elmo").show()
	hero._update_equipment_pose()
	assert(not hero.character_parts.hair_enabled)
	state.unequip("armadura")
	assert(hero.armor_parts == null and hero.sprite.self_modulate.a == 1)
	assert(state.equip("roupa_basica").is_empty())
	assert(hero.armor_parts != null and not hero.character_parts.head.visible)
	var restored := PlayerState.new()
	restored.from_dict(state.to_dict())
	assert(restored.equipment == state.equipment)
	hero.queue_free()
	preview.queue_free()
	await process_frame
	print("ARMOR_LAYERS_OK: 132 native scenes, 100 optional helmets, %d original pixels covered, independent materials, editable offsets, eight directions and single-item saves" % samples)
	quit()

func _inside(point: Vector2, rect: Vector4) -> bool:
	return rect.z > 0 and Rect2(rect.x, rect.y, rect.z, rect.w).has_point(point)
