extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var world = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_process(false)
	world.hero.set_process(false)
	for enemy in world.enemies:
		enemy.set_process(false)
	var golem = world.spawn_enemy("golem_pedra", Vector2(1200, 900))
	golem.set_process(false)
	golem.summoned = true
	golem.roll_cooldown_left = 0.0
	world.hero.global_position = Vector2(1600, 900)
	golem._process(0.26)
	assert(golem.roll_state == "rolling")
	assert(golem.ball.hframes == 4 and golem.ball.vframes == 2 and golem.ball.texture != null)
	var seen: Dictionary = {}
	for index in 20:
		var previous: Vector2 = golem.global_position
		golem._process(0.016)
		assert(absf(golem.global_position.distance_to(previous) - golem.roll_speed * 0.016) < 0.001)
		assert(golem.ball.rotation == 0.0)
		seen[golem.ball.frame] = true
	assert(seen.size() >= 6)
	golem._finish_roll()
	golem._process(0.19)
	assert(golem.roll_state.is_empty())
	world.queue_free()
	await process_frame
	await process_frame
	print("GOLEM_ROLL_SMOOTH_OK: short transitions, constant travel per frame, eight-frame sheet synced to distance, no texture rotation")
	quit()
