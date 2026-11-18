extends Node

@onready var root: Window = get_tree().root

const Layers = preload("res://scripts/actors/armor_layer_catalog.gd")
const Icons = preload("res://scripts/ui/armor_part_icon.gd")

func _ready() -> void:
	call_deferred("check")

func check() -> void:
	var state: PlayerState = PlayerState.create("Teste", "humano", "guerreiro")
	var count: int = 0
	for id: String in GameData.ITEMS:
		if not GameData.item(id).has("armor_part"): continue
		count += 1
		assert(state.add_item(id, 1, true))
		if not "--quick" in OS.get_cmdline_user_args():
			var icon: Texture2D = Icons.texture_for(id)
			assert(icon != null and icon.get_image().get_used_rect().has_area(), id)
	assert(count == 500)
	var number: int = 1
	for slot: String in GameData.ARMOR_PARTS:
		assert(state.equip("armadura_catalogo_%03d_%s" % [number, slot]).is_empty())
		number += 1
	var old_key: String = Layers.configuration_key(state)
	assert(state.equip("armadura_catalogo_006_peito").is_empty())
	assert(state.count_item("armadura_catalogo_002_peito") == 1)
	assert(old_key != Layers.configuration_key(state))
	var restored := PlayerState.new()
	restored.from_dict(state.to_dict())
	assert(restored.equipment == state.equipment)
	var legacy: Dictionary = state.to_dict()
	for slot: String in GameData.ARMOR_PARTS: legacy["equipment"].erase(slot)
	restored.from_dict(legacy)
	for slot: String in GameData.ARMOR_PARTS: assert(restored.equipment.has(slot))
	for race: String in ["humano", "elfo", "orc", "anao"]:
		for gender: String in ["masculino", "feminino"]:
			state.race_id = race
			state.gender_id = gender
			var parts: Node2D = Layers.instantiate(state)
			root.add_child(parts)
			parts.configure(state)
			assert(parts.shows_helmet())
			parts.free()
	state.race_id = "humano"
	state.gender_id = "masculino"
	var panels: Control = load("res://scenes/ui/equipment_panels.tscn").instantiate()
	panels.get_node("InventoryPanel").configure(state)
	panels.get_node("StatusPanel").configure(state)
	var container := Control.new()
	container.size = get_viewport().get_visible_rect().size
	root.add_child(container)
	container.add_child(panels)
	assert(panels.get_node("StatusPanel").slot_buttons.size() == PlayerState.EQUIP_SLOTS.size())
	assert(panels.get_node("InventoryPanel").bag_grid.get_child_count() >= state.inventory.size())
	assert(not panels.get_node("StatusPanel/Equipment_elmo").visible)
	var parts_inventory: Control = load("res://scenes/ui/armor_parts_inventory.tscn").instantiate()
	parts_inventory.get_node("InventoryPanel").configure(state)
	parts_inventory.get_node("StatusPanel").configure(state)
	container.add_child(parts_inventory)
	assert(parts_inventory.get_node("StatusPanel/Equipment_elmo").visible)
	for slot: String in GameData.ARMOR_PARTS:
		var button: Control = parts_inventory.get_node("StatusPanel/Equipment_" + slot)
		assert(Rect2(Vector2.ZERO, parts_inventory.get_node("StatusPanel").size).encloses(button.get_rect()))
	assert(parts_inventory.get_node("InventoryPanel")._matches_filter("armadura_catalogo_001_peito"))
	assert(parts_inventory.get_node("InventoryPanel")._matches_filter("arma_basica"))
	assert(not parts_inventory.get_node("InventoryPanel")._matches_filter("pocao_cura"))
	for slot: String in ["arma", "escudo", "anel", "colar", "talisma", "aura"]:
		var button: Control = parts_inventory.get_node("StatusPanel/Equipment_" + slot)
		assert(button.visible and Rect2(Vector2.ZERO, parts_inventory.get_node("StatusPanel").size).encloses(button.get_rect()))
	parts_inventory.hide()
	var room := RegionMap.new()
	room.generate_developer_room()
	assert(room.props.any(func(prop: Dictionary) -> bool: return prop["kind"] == "dev_armor_parts"))
	var ui := GameUI.new()
	root.add_child(ui)
	ui.state = state
	ui.show_developer_shop("dev_armor_parts")
	var selector: OptionButton = ui.root.find_child("ArmorSetSelector", true, false)
	assert(selector != null and selector.item_count == 100)
	selector.select(99)
	selector.item_selected.emit(99)
	assert(ui.root.find_child("ArmorSetPieces", true, false).get_child_count() == 5)
	ui.panel_action.connect(func(action: String, payload: Dictionary) -> void:
		if action == "dev_item": state.add_item(payload["id"], payload["qty"], true)
	)
	var receive_row: Control = ui.root.find_child("ShopItem_armadura_catalogo_100_elmo", true, false)
	var row: Node = receive_row.get_child(0)
	var before: int = state.count_item("armadura_catalogo_100_elmo")
	row.get_child(row.get_child_count() - 1).pressed.emit()
	assert(state.count_item("armadura_catalogo_100_elmo") == before + 10)
	await get_tree().process_frame
	await get_tree().process_frame
	if "--visual" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.runtime/armor-parts-shop.png")
		ui.close_modal()
		panels.hide()
		parts_inventory.show()
		parts_inventory.open_inventory()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.runtime/armor-parts-inventory.png")
	for slot: String in GameData.ARMOR_PARTS:
		state.unequip(slot)
		assert(state.equipment[slot].is_empty())
	var controller: Control = preload("res://scripts/main.gd").new()
	root.add_child(controller)
	controller.set_process(false)
	controller.state = state
	controller.ui.state = state
	controller.world = WorldView.new()
	controller.mode = "playing"
	var shortcut := InputEventKey.new()
	shortcut.keycode = KEY_I
	shortcut.ctrl_pressed = true
	shortcut.pressed = true
	controller._input(shortcut)
	assert(controller.mode == "playing" and controller.ui.current_panel != "armor_parts")
	controller.developer_active = true
	controller._input(shortcut)
	assert(controller.mode == "panel" and controller.ui.current_panel == "armor_parts")
	assert(controller.ui.inventory_view.parts_only)
	assert(controller.ui.status_view.show_armor_parts)
	controller._input(shortcut)
	assert(controller.mode == "playing")
	var normal := InputEventAction.new()
	normal.action = "inventory"
	normal.pressed = true
	controller._unhandled_input(normal)
	assert(controller.ui.current_panel == "inventory")
	assert(not controller.ui.inventory_view.parts_only)
	assert(not controller.ui.status_view.show_armor_parts)
	controller._input(shortcut)
	assert(controller.ui.current_panel == "armor_parts")
	controller._unhandled_input(normal)
	assert(controller.ui.current_panel == "inventory" and not controller.ui.inventory_view.parts_only)
	controller.world.free()
	controller.world = null
	print("PASS: 500 pieces, independent equipment, replacement, save, eight bodies, inventory and ordered shop")
	print("PASS: Ctrl+I restricted to secret room, toggling and independent normal inventory")
	await get_tree().process_frame
	await get_tree().process_frame
	ui.queue_free()
	container.queue_free()
	controller.queue_free()
	await get_tree().process_frame
	get_tree().quit()
