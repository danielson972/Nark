extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(world)
	world.set_paused(true)
	var boss = world.get_node("Aurora_boss")
	var torch = world.get_node("Toxa/Toxa2")
	world.get_node("Toxa/Toxa1").position = Vector2(1500, 1500)
	world.get_node("Toxa/Toxa3").position = Vector2(1700, 1500)
	torch.position = Vector2(470, 480)
	boss.global_position = Vector2(300, 500)
	world.hero.global_position = Vector2(760, 500)
	boss.attack_timer = 999.0
	await physics_frame
	await physics_frame
	assert(not boss._path_is_clear(Vector2.RIGHT, 150.0))
	var steered: Vector2 = boss._avoid_obstacles(Vector2.RIGHT * 96.0, 1.0 / 60.0)
	assert(absf(steered.y) > 1.0)
	var max_detour: float = 0.0
	for index in 500:
		boss._boss_logic(1.0 / 60.0, world.hero, boss.global_position.distance_to(world.hero.global_position))
		max_detour = maxf(max_detour, absf(boss.global_position.y - 500.0))
		assert(boss.global_position.distance_to(torch.get_node("Colisao").global_position) >= boss.radius + 12.0 * torch.scale.x - 1.0)
		await physics_frame
	assert(max_detour > 30.0)
	assert(boss.global_position.distance_to(world.hero.global_position) < 140.0)
	boss.global_position = Vector2(1100, 800)
	world.hero.global_position = Vector2(1150, 800)
	await physics_frame
	await physics_frame
	assert(boss._path_is_clear(Vector2.RIGHT, 100.0))
	assert(not world.can_actor_stand(boss, world.hero.global_position, boss.radius))
	world.queue_free()
	await process_frame
	print("COLOSSAL_AVOIDANCE_OK: torch detour, no overlap, reaches hero, hero ignored only for steering")
	quit()