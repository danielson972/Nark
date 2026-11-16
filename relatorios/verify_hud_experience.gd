extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "HUD")
	game.world.set_paused(true)
	var ui = game.ui
	var state = game.state
	var hero = game.world.hero
	hero.hp = 68.0
	hero.mp = 12.0
	hero.energy = 17.0
	state.xp = 0
	ui.refresh(state, game.world, game.world.hero, {})
	assert(ui.name_label.text == "HUD" and ui.level_label.text == "Nv. 1")
	assert(ui.hp_text.text == "68 / 100" and ui.mp_text.text == "12 / 35")
	assert(ui.energy_text.text == "17 / 55")
	for pair in [[ui.hp_bar, ui.hp_text], [ui.mp_bar, ui.mp_text], [ui.energy_bar, ui.energy_text], [ui.xp_bar, ui.xp_text]]:
		assert(pair[1].get_parent() == pair[0])
	assert(ui.xp_bar.value == 0)
	state.add_xp(GameData.xp_to_next(state.level) + 10)
	ui.refresh(state, game.world, game.world.hero, {})
	assert(state.level == 2)
	assert(ui.xp_bar.value == 10)
	assert(ui.xp_bar.max_value == GameData.xp_to_next(2))
	assert(ui.xp_text.text == "10 / %d" % int(ui.xp_bar.max_value))
	assert(ui.hud.get_node("StatusHUD").get_theme_stylebox("panel") is StyleBoxEmpty)
	await process_frame
	assert(ui.energy_bar.size.y == 10 and ui.xp_bar.size.y == 10)
	assert(ui.hp_bar.size.y == 12 and ui.mp_bar.size.y == 12)
	assert(ui.hud.get_node("StatusHUD").size.x == 170)
	await RenderingServer.frame_post_draw
	if DisplayServer.get_name() != "headless":
		root.get_texture().get_image().save_png("res://.work/hud-experience-preview.png")
	state.level = 100
	state.xp = 0
	ui.refresh(state, game.world, game.world.hero, {})
	assert(ui.xp_bar.value == ui.xp_bar.max_value)
	assert(ui.xp_text.text == "Nível máximo")
	print("HUD_XP_OK: transparent status panel, zero XP, level-up remainder, next threshold and maximum level")
	game.queue_free()
	await process_frame
	quit()
