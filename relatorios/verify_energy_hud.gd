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
	assert(ui.energy_gauge.capacity_width < 120.0)
	assert(ui.energy_usage_text.text.contains("Esquiva pronta"))
	var width: float = ui.energy_gauge.capacity_width
	state.level = 10
	assert(state.max_energy() == 73.0)
	hero.energy = 17.0
	ui.refresh(state, game.world, hero, {})
	assert(ui.energy_gauge.capacity_width > width)
	assert(ui.energy_usage_text.text.contains("energia insuficiente"))
	assert(ui.energy_bar.value == 17.0)
	var saved: Dictionary = state.to_dict()
	saved["energy"] = 999.0
	var loaded := PlayerState.new()
	loaded.from_dict(saved)
	assert(loaded.energy == loaded.max_energy())
	game.queue_free()
	await process_frame
	print("ENERGY_HUD_OK: half initial reserve, level growth, shorter growing gauge, dodge budget, low-energy indicator and save clamp")
	quit()
