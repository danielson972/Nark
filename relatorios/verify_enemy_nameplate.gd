extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Nome legível")
	var world = game.world
	world.set_paused(true)
	var slime = world.spawn_enemy("gosma", Vector2(1000, 900))
	for factor: float in [0.1, 0.25, 0.5, 1.0, 2.0]:
		slime.scale = Vector2(factor, factor * 0.8)
		slime.rotation = 0.2
		slime._update_nameplate()
		assert(slime.nameplate.get_global_transform().get_scale().is_equal_approx(Vector2.ONE))
		assert(is_zero_approx(slime.nameplate.get_global_transform().get_rotation()))
		assert(slime.nameplate.get_theme_font_size("font_size") == 14)
		var old: Vector2 = slime.nameplate.global_position
		slime.global_position += Vector2(40, 30)
		slime._update_nameplate()
		assert(slime.nameplate.global_position.is_equal_approx(old + Vector2(40, 30)))
	print("ENEMY_NAMEPLATE_OK: fixed readable size, 5 scales, nonuniform scale, rotation and movement")
	game.queue_free()
	await process_frame
	quit()
