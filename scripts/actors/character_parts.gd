extends Node2D
const Custom = preload("res://scripts/actors/character_customization.gd")
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
var head: Sprite2D
var hair: Sprite2D
var configuration_key: String = ""

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 3
	head = Sprite2D.new()
	head.centered = false
	head.show_behind_parent = true
	head.material = Appearance.cutout_material()
	add_child(head)
	hair = Sprite2D.new()
	hair.centered = false
	var color_material := ShaderMaterial.new()
	color_material.shader = preload("res://shaders/character_hair.gdshader")
	hair.material = color_material
	add_child(hair)

func _ready() -> void:
	# Draw behind the body at its own canvas depth, above map/UI backgrounds.
	_attach_head.call_deferred()

func _attach_head() -> void:
	if is_instance_valid(head) and is_instance_valid(get_parent()):
		head.reparent(get_parent())

func configure(state: PlayerState, origin: Vector2, scale_factor: Vector2, mirrored: bool = false) -> void:
	var key: String = "%s:%s:%s:%s:%s:%s:%s:%s" % [state.race_id, state.gender_id, Custom.armored(state), state.hair_style, state.hair_color, origin, scale_factor, mirrored]
	if key == configuration_key:
		return
	configuration_key = key
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
		_place(head, destination, origin, scale_factor, mirrored)
	hair.visible = state.hair_style > 0
	if hair.visible:
		hair.texture = Custom.hair_texture(state.hair_style)
		hair.material.set_shader_parameter("hair_color", Custom.COLORS.get(state.hair_color, Custom.COLORS.castanho))
		var hair_destination: Rect2 = Custom.hair_destination(state)
		_place(hair, hair_destination, origin, scale_factor, mirrored)
		# Occlude hair with the actual head silhouette rather than drawing a
		# rectangular face patch over it (which cut long styles at the neck).
		var body := Custom.bald_body(state.race_id, state.gender_id)
		var body_atlas_size: Vector2 = body.atlas.get_size()
		var hair_atlas_size: Vector2 = hair.texture.atlas.get_size()
		hair.material.set_shader_parameter("face_mask_enabled", true)
		hair.material.set_shader_parameter("bald_base", body.atlas)
		hair.material.set_shader_parameter("bald_region", Vector4(body.region.position.x / body_atlas_size.x, body.region.position.y / body_atlas_size.y, body.region.size.x / body_atlas_size.x, body.region.size.y / body_atlas_size.y))
		hair.material.set_shader_parameter("hair_region", Vector4(hair.texture.region.position.x / hair_atlas_size.x, hair.texture.region.position.y / hair_atlas_size.y, hair.texture.region.size.x / hair_atlas_size.x, hair.texture.region.size.y / hair_atlas_size.y))
		hair.material.set_shader_parameter("hair_destination", Vector4(hair_destination.position.x, hair_destination.position.y, hair_destination.size.x, hair_destination.size.y))
		hair.material.set_shader_parameter("head_source", Vector4(source.position.x, source.position.y, source.size.x, source.size.y))
		hair.material.set_shader_parameter("head_destination", Vector4(destination.position.x, destination.position.y, destination.size.x, destination.size.y))
		hair.material.set_shader_parameter("face_top", Custom.scalp_rect(state).position.y + 43.0)

func _place(part: Sprite2D, rect: Rect2, origin: Vector2, factor: Vector2, mirrored: bool) -> void:
	part.position = origin + rect.position * factor
	part.scale = rect.size * factor / part.texture.get_size()
	part.flip_h = mirrored
	if mirrored:
		part.position.x = origin.x + (256.0 - rect.end.x) * factor.x
