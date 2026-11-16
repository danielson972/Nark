extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "HP monstros")
	game.world.set_paused(true)
	for id: String in Enemy.TYPES:
		var enemy = game.world.spawn_enemy(id, Vector2(1600,1200))
		if enemy.is_boss():
			assert(enemy.health_bar == null)
			continue
		assert(enemy.health_bar != null and enemy.health_bar.visible)
		assert(enemy.health_bar.max_value == enemy.max_hp and enemy.health_bar.value == enemy.hp)
		assert(enemy.health_bar.top_level and enemy.health_bar.get_global_transform().get_scale().is_equal_approx(Vector2.ONE))
		assert(enemy.nameplate.global_position.y + enemy.nameplate.size.y < enemy.health_bar.global_position.y)
		enemy.take_damage(10.0)
		assert(enemy.health_bar.value == enemy.hp)
		var previous: Vector2 = enemy.health_bar.global_position
		enemy.global_position += Vector2(50,20)
		enemy._update_nameplate()
		assert(enemy.health_bar.global_position.is_equal_approx(previous + Vector2(50,20)))
	game.queue_free()
	await process_frame
	print("ENEMY_HP_UI_OK: all non-colossal types, full/current HP, instant damage update, head tracking, fixed scale, no duplicate boss bar")
	quit()
