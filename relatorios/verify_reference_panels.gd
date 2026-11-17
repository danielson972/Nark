extends SceneTree
const REFERENCE = "res://assets/game/ui/inventory/equipment_inventory_gold.png"
func _initialize() -> void:
	call_deferred("_run")
func settle() -> void:
	for tick in 5: await process_frame
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Painéis")
	game._open_panel("inventory")
	await settle()
	var workspace = game.ui.equipment_workspace
	var inventory = game.ui.inventory_view
	var status = game.ui.status_view
	assert(inventory.visible and status.visible)
	assert(inventory.scene_file_path == "res://scenes/ui/inventory_panel.tscn")
	assert(status.scene_file_path == "res://scenes/ui/equipment_status_panel.tscn")
	for panel: Control in [inventory, status]:
		var texture: AtlasTexture = panel.get_node("ReferenceBackground").texture
		assert(texture.atlas.resource_path == REFERENCE)
		assert(texture.region.end.y == 1029, "Use the full new background height")
	var authored_slots: Array[Node] = inventory.bag_grid.get_children()
	assert(authored_slots.size() >= GameData.ITEMS.size())
	for id: String in GameData.ITEMS:
		game.state.add_item(id, 1, true)
	game.ui.refresh_equipment_panels()
	for category: String in ["all", "weapons", "armor", "materials", "consumables", "quest"]:
		inventory._change_filter(category)
		await settle()
		assert(inventory.bag_grid.get_children() == authored_slots)
		var matching: int = 0
		for entry: Dictionary in game.state.inventory:
			if inventory._matches_filter(str(entry.id)): matching += 1
		var bound: int = 0
		for key: String in inventory.slot_buttons:
			if key.begins_with("bag:"): bound += 1
		assert(bound == matching, "Every item must remain accessible, including the complete catalog")
	assert(not inventory.tab_buttons.has("items"))
	for available: Vector2 in [Vector2(1280, 720), Vector2(960, 540), Vector2(640, 360)]:
		game.ui.modal_layer.size = available
		await settle()
		for panel: Control in [inventory, status]:
			var rect: Rect2 = panel.get_global_rect()
			assert(Rect2(Vector2.ZERO, available).encloses(rect))
	status.get_node("%CloseStatus").pressed.emit()
	await settle()
	assert(inventory.visible and not status.visible and game.mode == "panel")
	game.ui.refresh_equipment_panels()
	assert(not status.visible)
	game.ui.show_inventory_panel()
	assert(status.visible)
	inventory.get_node("%CloseInventory").pressed.emit()
	await settle()
	assert(not is_instance_valid(status) and not is_instance_valid(inventory))
	assert(game.mode == "playing")
	assert(Controls.DEFAULT_BINDINGS.character_status == ["key:84"])
	Controls.apply(Controls.default_bindings())
	var hotkey := InputEventKey.new()
	hotkey.physical_keycode = KEY_T
	hotkey.keycode = KEY_T
	hotkey.pressed = true
	game._unhandled_input(hotkey)
	await settle()
	assert(game.ui.status_view.visible and not game.ui.inventory_view.visible)
	assert(game.ui.status_view.get_node_or_null("OpenInventory") == null)
	game._unhandled_input(hotkey)
	await settle()
	assert(game.mode == "playing")
	game._open_panel("inventory")
	await settle()
	assert(game.ui.status_view.visible and game.ui.inventory_view.visible)
	game.ui.inventory_view.get_node("%CloseInventory").pressed.emit()
	await settle()
	assert(game.mode == "playing" and not game.ui.modal_layer.visible)
	game.queue_free()
	await settle()
	print("REFERENCE_PANELS_OK: original background, separate editable scenes, full catalog, six filters, paired inventory close, standalone status via T and three window sizes")
	quit()
