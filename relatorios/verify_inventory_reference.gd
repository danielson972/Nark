extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func settle() -> void:
	for tick in 4:
		await process_frame

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Inventário")
	game.state.add_item("hero", 1, true)
	game.state.add_item("gosma", 2, true)
	game.state.add_item("selo_entrada", 1, true)
	game._open_panel("inventory")
	await settle()
	var panel = game.ui.inventory_view
	assert(panel.slot_buttons.has("equip:aura"))
	assert(panel.slot_buttons["equip:aura"].get_meta("item_slot") == "hero")
	panel._select("", "aura")
	assert(panel.detail_title.text == "Slot Hero" and panel.action_buttons["unequip"].disabled)
	var original: Array = game.state.inventory.duplicate(true)
	for category: String in ["all", "equipment", "consumables", "materials", "quest"]:
		panel._change_filter(category)
		assert(panel.tab_buttons[category].button_pressed)
		for key: String in panel.slot_buttons:
			if not key.begins_with("bag:"): continue
			assert(panel._matches_filter(key.trim_prefix("bag:")))
		assert(game.state.inventory == original, "Filtering must never mutate the inventory")
	panel._change_filter("equipment")
	assert(panel.slot_buttons.has("bag:hero"))
	panel._select("hero", "")
	assert(not panel.action_buttons["equip"].disabled)
	panel.action_buttons["equip"].pressed.emit()
	await settle()
	panel = game.ui.inventory_view
	assert(game.state.equipment.aura.id == "hero" and panel.filter_tab == "equipment")
	panel._select("hero", "aura")
	assert(panel.detail_type.text == "Visual Hero" and not panel.detail_properties.text.contains("Durabilidade"))
	panel.action_buttons["unequip"].pressed.emit()
	await settle()
	panel = game.ui.inventory_view
	assert(game.state.equipment.aura.is_empty() and game.state.count_item("hero") == 1)
	panel._change_filter("consumables")
	panel._select("pocao_cura", "")
	var potions: int = game.state.count_item("pocao_cura")
	game.world.hero.hp = 10.0
	game.state.hp = 10.0
	panel.action_buttons["use_item"].pressed.emit()
	await settle()
	assert(game.state.count_item("pocao_cura") == potions - 1 and game.world.hero.hp > 10.0)
	panel = game.ui.inventory_view
	assert(panel.filter_tab == "consumables")
	panel._change_filter("materials")
	panel._select("gosma", "")
	panel.action_buttons["drop_item"].pressed.emit()
	await settle()
	assert(game.state.count_item("gosma") == 1)
	panel = game.ui.inventory_view
	assert(panel.filter_tab == "materials")
	panel._select("gosma", "")
	panel.action_buttons["store"].pressed.emit()
	await settle()
	assert(game.state.count_item("gosma") == 0 and game.state.stored[0].id == "gosma")
	panel = game.ui.inventory_view
	assert(panel.filter_tab == "materials" and panel.selected_id.is_empty())
	assert(panel.action_buttons["store"].disabled and panel.bag_count.text.contains("Nenhum"))
	print("INVENTORY_BOUNDS ", root.size, " viewport ", root.get_visible_rect(), " parent ", panel.get_parent().size, " rect ", panel.get_global_rect(), " scale ", panel.scale)
	assert(root.get_visible_rect().encloses(panel.get_global_rect()), "Inventory must fit initial viewport")
	root.size = Vector2i(960, 540)
	await settle()
	assert(root.get_visible_rect().encloses(panel.get_global_rect()), "Inventory must fit smaller PC windows")
	game.queue_free()
	await process_frame
	print("INVENTORY_REFERENCE_OK: filters, Hero empty/equip/unequip, use/drop/store, category persistence, initial and resized layout")
	quit()
