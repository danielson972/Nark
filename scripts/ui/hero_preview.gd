extends Control
## Uses the same body and weapon sources and attachment as the world character.

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ArmorLayers = preload("res://scripts/actors/armor_layer_catalog.gd")
const ItemArt = preload("res://scripts/ui/item_catalog.gd")
var state: PlayerState
@export var show_hair: bool = true
@export var draw_character: bool = true
var held_weapon: Sprite2D
var held_shield: Sprite2D
var held_hand: Sprite2D
var character_parts: Node2D
var armor_parts: Node2D
var armor_layer_path: String = ""

func _ready() -> void:
	var editor_base := get_node_or_null("BaseCarecaEditor")
	if editor_base != null:
		editor_base.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	material = Appearance.cutout_material()
	held_shield = Sprite2D.new()
	held_shield.visible = false
	held_shield.z_index = 2
	add_child(held_shield)
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
	if not draw_character:
		if is_instance_valid(armor_parts): armor_parts.hide()
		if is_instance_valid(character_parts): character_parts.hide()
		if is_instance_valid(held_shield): held_shield.hide()
		if is_instance_valid(held_weapon): held_weapon.hide()
		if is_instance_valid(held_hand): held_hand.hide()
		return
	if state == null:
		return
	var body: Texture2D = Appearance.body_texture(state)
	var body_material: ShaderMaterial = Appearance.body_material(state)
	if material != body_material:
		material = body_material
	held_hand.material = body_material
	var source_size: Vector2 = body.get_size()
	# Fit the complete bald base with a small portrait margin.
	var content := Rect2(Vector2.ZERO, source_size)
	content = content.grow(8.0)
	if not str(state.equipment.get("arma", {}).get("id", "")).is_empty():
		content = content.merge(Rect2(-96, -8, 360, 528))
	var factor: float = minf(size.x / (content.size.x * 1.15), size.y / content.size.y)
	factor *= 0.85 if state.race_id == "anao" else 1.0
	var destination_size: Vector2 = source_size * factor
	var origin: Vector2 = (size - content.size * factor) * 0.5 - content.position * factor
	_sync_armor_parts()
	if armor_parts != null:
		armor_parts.show()
		armor_parts.place(origin, Vector2.ONE * factor)
	else:
		draw_texture_rect(body, Rect2(origin, destination_size), false)
	character_parts.hair_enabled = show_hair and (armor_parts == null or not armor_parts.shows_helmet())
	character_parts.configure(state, origin, Vector2.ONE * factor)
	var shield_id: String = str(state.equipment.get("escudo", {}).get("id", ""))
	held_shield.visible = not shield_id.is_empty()
	if held_shield.visible:
		held_shield.texture = ItemArt.texture_for(shield_id, state.class_id)
		held_shield.material = Appearance.shield_material(shield_id, held_shield.texture)
		held_shield.position = origin + destination_size * Appearance.shield_anchor(state) + (armor_parts.part_offset("Peito") * factor if armor_parts != null else Vector2.ZERO)
		held_shield.scale = Vector2.ONE * destination_size.y * 0.28 / held_shield.texture.get_height()
	var weapon_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	held_weapon.visible = not weapon_id.is_empty()
	held_hand.visible = not weapon_id.is_empty()
	if weapon_id.is_empty():
		return
	var weapon: Texture2D = ItemArt.texture_for(weapon_id, state.class_id)
	if weapon == null:
		return
	var weapon_size: Vector2 = weapon.get_size()
	weapon_size *= destination_size.y * Appearance.weapon_height(state.class_id, weapon_id) / weapon_size.y
	var hand_delta: Vector2 = armor_parts.part_offset("Luvas") * factor if armor_parts != null else Vector2.ZERO
	var grip: Vector2 = origin + destination_size * Appearance.hand_position(state) + hand_delta
	held_weapon.texture = weapon
	held_weapon.material = Appearance.weapon_material(state, weapon)
	held_weapon.position = grip
	held_weapon.offset = -weapon.get_size() * Appearance.weapon_pivot(state.class_id, weapon_id)
	held_weapon.rotation = Appearance.weapon_rotation(state.class_id, weapon_id)
	held_weapon.z_index = Appearance.weapon_layer(state.class_id)
	held_weapon.scale = weapon_size / weapon.get_size()
	if held_hand.visible:
		var hand: Rect2 = Appearance.hand_rect(state)
		held_hand.texture = Appearance.hand_texture(state)
		held_hand.position = origin + hand.position * destination_size + hand_delta
		held_hand.scale = hand.size * destination_size / held_hand.texture.get_size()

func _sync_armor_parts() -> void:
	var path: String = ArmorLayers.scene_path(state)
	if path != armor_layer_path or (not path.is_empty() and not is_instance_valid(armor_parts)):
		if is_instance_valid(armor_parts):
			remove_child(armor_parts)
			armor_parts.queue_free()
		armor_parts = ArmorLayers.instantiate(state)
		armor_layer_path = path
		if armor_parts != null:
			armor_parts.name = "ArmaduraEmPartes"
			add_child(armor_parts)
	if armor_parts != null: armor_parts.configure(state)
