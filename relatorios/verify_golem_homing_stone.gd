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
	world.hero.global_position = Vector2(1400, 900)
	golem.roll_cooldown_left = 0.0
	golem._process(0.016)
	for index in 30:
		golem._process(0.016)
	assert(golem.roll_state == "rolling")
	world.hero.global_position = Vector2(1400, 1050)
	golem._process(0.016)
	assert(golem.roll_direction.y > 0.0 and golem.global_position.y > 900.0)
	golem._finish_roll()
	golem.roll_state = ""
	golem.global_position = Vector2(1200, 900)
	world.hero.global_position = Vector2(1400, 900)
	world.hero.hp = 200.0
	world.hero.invulnerable = 0.0
	world.hero.dodge_time = 0.0
	world.hero.blocking = false
	golem.roll_cooldown_left = 5.0
	golem.stone_cooldown_left = 0.0
	golem._process(0.016)
	assert(golem.stone_cast_left > 0.0)
	golem._process(0.41)
	var stone = world.effects_layer.get_children().filter(func(node): return node is Projectile and node.kind == "stone")[0]
	stone.set_process(false)
	for index in 60:
		if stone.is_queued_for_deletion():
			break
		stone._process(0.016)
	assert(stone.is_queued_for_deletion())
	assert(world.hero.hp == 190.0)
	assert(world.hero.has_status("stun") and is_equal_approx(world.hero.status_time("stun"), 1.0))
	assert(not world.hero.can_act())
	Input.action_press("move_right")
	var position_before: Vector2 = world.hero.global_position
	world.hero._handle_input(0.1)
	assert(world.hero.global_position == position_before and world.hero.velocity == Vector2.ZERO)
	Input.action_release("move_right")
	world.hero._update_statuses(1.01)
	assert(not world.hero.has_status("stun") and world.hero.can_act())
	world.hero.invulnerable = 1.0
	var immune_stone = load("res://scripts/combat/golem_stone.gd").new()
	immune_stone.world = world
	world.effects_layer.add_child(immune_stone)
	immune_stone._impact(world.hero)
	assert(not world.hero.has_status("stun") and world.hero.hp == 190.0)
	world.queue_free()
	await process_frame
	await process_frame
	print("GOLEM_HOMING_STONE_OK: curves toward moving hero, cast/projectile, 10 damage, 1-second stun, movement locked, expiry and invulnerability")
	quit()