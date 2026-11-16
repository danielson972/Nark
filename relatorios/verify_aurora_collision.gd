extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(world)
	world.set_paused(true)
	await physics_frame
	await physics_frame
	for torch_name in ["Toxa1", "Toxa2", "Toxa3"]:
		var body = world.get_node("Toxa/" + torch_name + "/Colisao")
		assert(not world.can_actor_stand(world.hero, body.global_position, world.hero.radius))
		assert(world.can_actor_stand(world.hero, body.global_position + Vector2(50, 0), world.hero.radius))
	var boss = world.get_node("Aurora_boss")
	assert(not world.can_actor_stand(world.hero, boss.global_position, world.hero.radius))
	assert(world.can_actor_stand(boss, boss.global_position, boss.radius))
	var torch_body = world.get_node("Toxa/Toxa2/Colisao")
	assert(not world.can_actor_stand(boss, torch_body.global_position, boss.radius))
	var point: Vector2 = torch_body.global_position
	world.hero.global_position = point + Vector2(40, 0)
	var before: Vector2 = world.hero.global_position
	world.hero.move_desired(Vector2(-25, 0), 1.0)
	assert(world.hero.global_position == before)
	world.knockback(world.hero, Vector2.LEFT, 40.0)
	assert(world.hero.global_position == before)
	world.queue_free()
	await process_frame
	print("AURORA_COLLISION_OK: three torch bases, colossal, self exclusion, movement and knockback")
	quit()