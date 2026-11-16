extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func click(panel, key: String, double_click: bool = true, mouse_button: int = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = mouse_button
	event.pressed = true
	event.double_click = double_click
	panel.slot_buttons[key].gui_input.emit(event)
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Duplo clique")
	game.state.add_item("hero", 1, true)
	game.ui.show_inventory_panel()
	await process_frame
	click(game.ui.inventory_view, "bag:hero", false)
	await process_frame
	assert(game.state.equipment.aura.is_empty())
	click(game.ui.inventory_view, "bag:hero", true, MOUSE_BUTTON_RIGHT)
	await process_frame
	assert(game.state.equipment.aura.is_empty())
	click(game.ui.inventory_view, "bag:hero")
	await process_frame
	await process_frame
	assert(game.state.equipment.aura.id == "hero")
	assert(game.world.hero.aura_effect.visible)
	click(game.ui.inventory_view, "equip:aura")
	await process_frame
	await process_frame
	assert(game.state.equipment.aura.is_empty() and game.state.count_item("hero") == 1)
	assert(not game.world.hero.aura_effect.visible)
	var count: int = game.state.count_item("pocao_cura")
	click(game.ui.inventory_view, "bag:pocao_cura")
	await process_frame
	assert(game.state.count_item("pocao_cura") == count)
	click(game.ui.inventory_view, "equip:arma")
	await process_frame
	await process_frame
	assert(game.state.equipment.arma.is_empty())
	click(game.ui.inventory_view, "bag:arma_basica")
	await process_frame
	await process_frame
	assert(game.state.equipment.arma.id == "arma_basica")
	game.queue_free()
	await process_frame
	print("INVENTORY_DOUBLE_CLICK_OK: equip/unequip cosmetic and weapon; single/right clicks and consumables ignored")
	quit()