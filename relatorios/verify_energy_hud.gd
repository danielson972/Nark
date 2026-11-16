extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Energia")
	game.world.set_paused(true)
	var state = game.state
	var hero = game.world.hero
	var ui = game.ui
	assert(state.max_energy() == 55.0 and hero.energy == 55.0)
	ui.refresh(state, game.world, hero, {})
	assert(ui.energy_bar.max_value == 55.0 and ui.energy_bar.value == 55.0)
	await process_frame
	assert(ui.energy_bar.size.y < ui.hp_bar.size.y)
	assert(ui.energy_bar.size.x == ui.hp_bar.size.x)
	assert(ui.energy_bar.tooltip_text.contains("Esquiva pronta"))
	var width: float = ui.energy_bar.size.x
	state.level = 10
	assert(state.max_energy() == 73.0)
	hero.energy = 17.0
	ui.refresh(state, game.world, hero, {})
	assert(ui.energy_bar.size.x == width)
	assert(ui.energy_bar.tooltip_text.contains("energia insuficiente"))
	assert(ui.energy_bar.value == 17.0)
	var saved: Dictionary = state.to_dict()
	saved["energy"] = 999.0
	var loaded := PlayerState.new()
	loaded.from_dict(saved)
	assert(loaded.energy == loaded.max_energy())
	game.queue_free()
	await process_frame
	print("ENERGY_HUD_OK: level growth, fixed-width thin EP bar, dodge tooltip, low-energy indicator and save clamp")
	quit()
