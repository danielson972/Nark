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
	state.xp = 0
	ui.refresh(state, game.world, game.world.hero, {})
	assert(ui.xp_bar.value == 0)
	state.add_xp(GameData.xp_to_next(state.level) + 10)
	ui.refresh(state, game.world, game.world.hero, {})
	assert(state.level == 2)
	assert(ui.xp_bar.value == 10)
	assert(ui.xp_bar.max_value == GameData.xp_to_next(2))
	assert(ui.hud.get_node("StatusHUD").get_theme_stylebox("panel") is StyleBoxEmpty)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://relatorios/hud-experience-preview.png")
	state.level = 100
	state.xp = 0
	ui.refresh(state, game.world, game.world.hero, {})
	assert(ui.xp_bar.value == ui.xp_bar.max_value)
	assert(ui.xp_text.text == "XP · Nível máximo")
	print("HUD_XP_OK: transparent status panel, zero XP, level-up remainder, next threshold and maximum level")
	game.queue_free()
	await process_frame
	quit()
