extends Control
## Uses the same body and weapon sources and attachment as the world character.

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ItemArt = preload("res://scripts/ui/item_catalog.gd")
var state: PlayerState
var held_weapon: Sprite2D
var held_hand: Sprite2D
var character_parts: Node2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	material = Appearance.cutout_material()
	held_weapon = Sprite2D.new()
	held_weapon.centered = false
	held_weapon.z_index = 1
	add_child(held_weapon)
	held_hand = Sprite2D.new()
	held_hand.centered = false
	held_hand.z_index = 2
	add_child(held_hand)
	character_parts = preload("res://scripts/actors/character_parts.gd").new()
	add_child(character_parts)
	resized.connect(queue_redraw)
	if state != null:
		state.equipment_changed.connect(queue_redraw)

func _draw() -> void:
	if state == null:
		return
	var body: Texture2D = Appearance.body_texture(state)
	var body_material: ShaderMaterial = Appearance.body_material(state)
	if material != body_material:
		material = body_material
	held_hand.material = body_material
	var source_size: Vector2 = body.get_size()
	var factor: float = minf(size.x / (source_size.x * 1.15), size.y / source_size.y)
	factor *= 0.85 if state.race_id == "anao" else 1.0
	var destination_size: Vector2 = source_size * factor
	var origin: Vector2 = (size - destination_size) * 0.5
	draw_texture_rect(body, Rect2(origin, destination_size), false)
	character_parts.configure(state, origin, Vector2.ONE * factor)
	var weapon_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	held_weapon.visible = not weapon_id.is_empty()
	held_hand.visible = not weapon_id.is_empty()
	if weapon_id.is_empty():
		return
	var weapon: Texture2D = ItemArt.texture_for(weapon_id, state.class_id)
	if weapon == null:
		return
	var weapon_size: Vector2 = weapon.get_size()
	weapon_size *= destination_size.y * Appearance.weapon_height(state.class_id) / weapon_size.y
	var grip: Vector2 = origin + destination_size * Appearance.hand_position(state)
	held_weapon.texture = weapon
	held_weapon.material = Appearance.weapon_material(state, weapon)
	held_weapon.position = grip
	held_weapon.offset = -weapon.get_size() * Appearance.weapon_pivot(state.class_id, weapon_id)
	held_weapon.rotation = Appearance.weapon_rotation(state.class_id)
	held_weapon.z_index = Appearance.weapon_layer(state.class_id)
	held_weapon.scale = weapon_size / weapon.get_size()
	if held_hand.visible:
		var hand: Rect2 = Appearance.hand_rect(state)
		held_hand.texture = Appearance.hand_texture(state)
		held_hand.position = origin + hand.position * destination_size
		held_hand.scale = hand.size * destination_size / held_hand.texture.get_size()
