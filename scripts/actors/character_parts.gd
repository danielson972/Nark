extends Node2D
const Custom = preload("res://scripts/actors/character_customization.gd")
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
var head: Sprite2D
var hair: Sprite2D
var ear: Sprite2D
var tooth: Sprite2D
var beard: Sprite2D
var configuration_key: String = ""
var hair_enabled: bool = true
var world_antialiasing: bool = false

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 3
	head = Sprite2D.new()
	head.centered = false
	head.show_behind_parent = true
	var head_material := ShaderMaterial.new()
	head_material.shader = Appearance.CUTOUT_SHADER
	head.material = head_material
	add_child(head)
	hair = Sprite2D.new()
	hair.centered = false
	hair.visible = false
	add_child(hair)
	ear = Sprite2D.new()
	ear.name = "Orelha"
	ear.centered = false
	ear.z_index = 1
	ear.visible = false
	add_child(ear)
	tooth = Sprite2D.new()
	tooth.name = "DenteEsquerdo"
	tooth.centered = false
	tooth.z_index = 1
	tooth.visible = false
	add_child(tooth)
	beard = Sprite2D.new()
	beard.name = "Barba"
	beard.centered = false
	beard.z_index = 2
	beard.visible = false
	var beard_material := ShaderMaterial.new()
	beard_material.shader = preload("res://shaders/character_beard.gdshader")
	beard.material = beard_material
	add_child(beard)

func _ready() -> void:
	# Draw behind the body at its own canvas depth, above map/UI backgrounds.
	_attach_head.call_deferred()

func _attach_head() -> void:
	if is_instance_valid(head) and is_instance_valid(get_parent()):
		head.reparent(get_parent())

func configure(state: PlayerState, origin: Vector2, scale_factor: Vector2, mirrored: bool = false) -> void:
	var key: String = "%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s" % [state.race_id, state.gender_id, Custom.armored(state), state.hair_style, state.hair_color, origin, scale_factor, mirrored, hair_enabled, state.beard_style, state.beard_color, world_antialiasing]
	if key == configuration_key:
		return
	configuration_key = key
	head.material.set_shader_parameter("world_antialiasing",world_antialiasing)
	beard.material.set_shader_parameter("world_antialiasing",world_antialiasing)
	beard.visible = state.beard_style > 0
	if beard.visible:
		beard.texture = Custom.beard_texture(state.beard_style)
		beard.material.set_shader_parameter("original_color",state.beard_color == "original")
		beard.material.set_shader_parameter("beard_color",Custom.COLORS.get(state.beard_color,Custom.COLORS.castanho))
		_place(beard,Custom.beard_destination(state),origin,scale_factor,mirrored)
	var source: Rect2 = Custom.head_rect(state)
	var destination: Rect2 = Custom.head_destination(state)
	head.visible = Custom.armored(state)
	if head.visible:
		var patch := AtlasTexture.new()
		var body := Custom.bald_body(state.race_id, state.gender_id)
		patch.atlas = body.atlas
		patch.region = Rect2(body.region.position + source.position, source.size)
		patch.filter_clip = true
		head.texture = patch
		var atlas_size: Vector2 = body.atlas.get_size()
		head.material.set_shader_parameter("texture_region", Vector4(patch.region.position.x / atlas_size.x, patch.region.position.y / atlas_size.y, patch.region.size.x / atlas_size.x, patch.region.size.y / atlas_size.y))
		head.material.set_shader_parameter("attachment_size", destination.size.round())
		_place(head, destination, origin, scale_factor, mirrored)
	hair.visible = hair_enabled and state.hair_style > 0
	if hair.visible:
		hair.texture = Custom.fitted_hair_texture(state)
		if hair.material == null:
			var color_material := ShaderMaterial.new()
			color_material.shader = preload("res://shaders/fitted_hair.gdshader")
			hair.material = color_material
		hair.material.set_shader_parameter("hair_color", Custom.COLORS[state.hair_color])
		hair.material.set_shader_parameter("world_antialiasing",world_antialiasing)
		var atlas_size: Vector2 = hair.texture.atlas.get_size()
		var region: Rect2 = hair.texture.region
		hair.material.set_shader_parameter("texture_region",Vector4(region.position.x/atlas_size.x,region.position.y/atlas_size.y,region.size.x/atlas_size.x,region.size.y/atlas_size.y))
		_place(hair, Custom.fitted_hair_destination(state), origin, scale_factor, mirrored)
	ear.visible = hair.visible and state.race_id in ["elfo", "orc"]
	if ear.visible:
		ear.texture = load("res://assets/game/sprites/herois/bases/orelha_%s_%s.png" % [state.race_id, state.gender_id])
		_world_accessory(ear)
		var head_factor: float = destination.size.x / source.size.x
		var ear_origin := Vector2(138, 46) if state.race_id == "orc" else Vector2(140, 50)
		var ear_rect := Rect2(destination.position + (ear_origin - source.position) * head_factor, ear.texture.get_size() * head_factor)
		_place(ear, ear_rect, origin, scale_factor, mirrored)
	tooth.visible = hair.visible and state.race_id == "orc"
	if tooth.visible:
		tooth.texture = load("res://assets/game/sprites/herois/bases/dente_esquerdo_orc_%s.png" % state.gender_id)
		_world_accessory(tooth)
		var tooth_origin := Vector2(81, 81) if state.gender_id == "masculino" else Vector2(95, 77)
		var head_factor: float = destination.size.x / source.size.x
		var tooth_rect := Rect2(destination.position + (tooth_origin - source.position) * head_factor, tooth.texture.get_size() * head_factor)
		_place(tooth, tooth_rect, origin, scale_factor, mirrored)

func _world_accessory(part: Sprite2D) -> void:
	if not world_antialiasing: return
	if part.material == null:
		var material := ShaderMaterial.new()
		material.shader = Appearance.CUTOUT_SHADER
		material.set_shader_parameter("world_antialiasing",true)
		part.material = material

func _place(part: Sprite2D, rect: Rect2, origin: Vector2, factor: Vector2, mirrored: bool) -> void:
	part.position = origin + rect.position * factor
	part.scale = rect.size * factor / part.texture.get_size()
	part.flip_h = mirrored
	if mirrored:
		part.position.x = origin.x + (256.0 - rect.end.x) * factor.x
