extends Node2D
## Child positions belong to the authored scene; configuration never rebuilds them.
const Custom = preload("res://scripts/actors/character_customization.gd")
@export var armor_id: String = ""
@export var reference_head: Rect2 = Rect2(85, 33.08, 84, 94.92)
var configuration_key: String = ""
var helmet_transform: Transform2D
var captured_helmet: bool = false

func _ready() -> void:
	var reference := get_node_or_null("ReferenciaCabeca")
	if reference != null: reference.hide()

func configure(state: PlayerState, world_antialiasing: bool = false) -> void:
	var key: String = "%s:%s:%s" % [state.race_id, state.gender_id, world_antialiasing]
	if key == configuration_key: return
	configuration_key = key
	for child in get_children():
		for hand in child.get_children():
			if hand is Sprite2D and hand.material is ShaderMaterial:
				hand.material.set_shader_parameter("world_antialiasing", world_antialiasing)
				hand.material.set_shader_parameter("orc_skin", _tint_skin(hand.material, state))
		if child is Sprite2D and child.material is ShaderMaterial:
			# Materials are local to each instance, including the inventory preview.
			child.material.set_shader_parameter("world_antialiasing", world_antialiasing)
			if child.name not in ["Elmo", "Pele", "ReferenciaCabeca"]:
				child.material.set_shader_parameter("orc_skin", _tint_skin(child.material, state))
	var helmet: Sprite2D = $Elmo
	if helmet.texture != null:
		if not captured_helmet:
			helmet_transform = helmet.transform
			captured_helmet = true
		var head: Rect2 = Custom.head_destination(state)
		var factor: float = head.size.x / reference_head.size.x
		helmet.transform = helmet_transform
		helmet.position = head.position + (helmet_transform.origin - reference_head.position) * factor
		helmet.scale = helmet_transform.get_scale() * factor

func shows_helmet() -> bool:
	return $Elmo.visible and $Elmo.texture != null

func _tint_skin(part_material: ShaderMaterial, state: PlayerState) -> bool:
	var native_head = part_material.get_shader_parameter("armor_skin_head")
	# Racial starter images already contain their proper skin color.
	if native_head is Vector4 and native_head.z > 0.0: return false
	return state.race_id == "orc"

func part_offset(part_name: String) -> Vector2:
	var part: Sprite2D = get_node(part_name)
	if part.has_meta("grip_delta"): return part.get_meta("grip_delta")
	return part.position - Vector2(part.get_meta("source_position", part.position))

func place(origin: Vector2, factor: Vector2, mirrored: bool = false) -> void:
	position = origin + Vector2(256.0 * factor.x if mirrored else 0.0, 0.0)
	scale = Vector2(-factor.x if mirrored else factor.x, factor.y)
