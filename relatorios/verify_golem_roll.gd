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
	world.hero.global_position = Vector2(1400, 900)
	world.hero.hp = 200.0
	world.hero.invulnerable = 0.0
	world.hero.dodge_time = 0.0
	world.hero.blocking = false
	var hp_before: float = world.hero.hp
	golem._process(0.016)
	assert(golem.roll_state == "windup" and golem.ball.visible)
	assert(golem.ball.texture != null)
	for index in 30:
		golem._process(0.016)
	assert(golem.roll_state == "rolling" and golem.self_modulate.a == 0.0)
	world.set_paused(true)
	var paused_position: Vector2 = golem.global_position
	golem._process(0.2)
	assert(golem.global_position == paused_position)
	world.set_paused(false)
	for index in 60:
		if golem.roll_state == "recover":
			break
		golem._process(0.016)
	assert(golem.roll_state == "recover")
	assert(world.hero.hp == hp_before - golem.roll_damage)
	assert(not golem.ball.visible and golem.self_modulate.a == 1.0)
	golem._process(0.1)
	assert(world.hero.hp == hp_before - golem.roll_damage)
	golem._process(0.5)
	assert(golem.roll_state.is_empty())
	assert(golem.roll_cooldown_left > 0.0)
	# Repete a investida com uma tocha no caminho: deve parar antes dela.
	golem.global_position = Vector2(1200, 900)
	world.hero.global_position = Vector2(1450, 900)
	var torch = world.get_node("Toxa/Toxa2")
	torch.global_position = Vector2(1300, 874.375)
	await physics_frame
	await physics_frame
	golem.roll_cooldown_left = 0.0
	golem._process(0.016)
	for index in 90:
		golem._process(0.016)
		if golem.roll_state == "recover":
			break
	assert(golem.roll_state == "recover")
	assert(golem.global_position.x < torch.global_position.x)
	world.queue_free()
	await process_frame
	await process_frame
	print("GOLEM_ROLL_OK: windup, sphere visual, forward roll, one hit, recovery, cooldown, pause and torch collision")
	quit()