extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var world = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_paused(true)
	await physics_frame
	await physics_frame
	var placed = world.get_node("Golens/Golens")
	assert(placed.type_id == "golem_pedra" and world.enemies.has(placed))
	assert(placed.get_node("Colisao/CollisionShape2D") != null)
	var boss = world.get_node("Aurora_boss")
	assert(boss.SUMMON_SKILL_NAME == "Invocar")
	var before: int = world.enemies.size()
	boss.action = "invocar"
	boss._boss_release(world.hero)
	assert(world.enemies.size() == before + 2)
	var summoned: Array = world.enemies.slice(before)
	for golem in summoned:
		assert(golem.type_id == "golem_pedra" and golem.summoned)
		assert(golem is Sprite2D and golem.hframes == 4 and golem.vframes == 2)
		assert(golem.get_node("Colisao/CollisionShape2D") != null)
		assert(world.can_stand(golem.global_position, golem.radius))
	assert(summoned[0].global_position.distance_to(summoned[1].global_position) >= 36.0)
	boss.hp = boss.max_hp * 0.4
	boss.attack_timer = 999.0
	boss._boss_logic(0.0, world.hero, 0.0)
	assert(world.enemies.size() == before + 4)
	var moving = summoned[0]
	moving.global_position = Vector2(1200, 900)
	world.hero.global_position = Vector2(1400, 900)
	moving.attack_timer = 999.0
	world.set_paused(false)
	moving._process(0.2)
	assert(moving.global_position.x > 1200.0 and moving.frame == 1)
	world.set_paused(true)
	moving._process(0.2)
	assert(moving.frame == 0)
	await physics_frame
	await physics_frame
	assert(not world.can_actor_stand(world.hero, moving.global_position, world.hero.radius))
	assert(world.can_actor_stand(moving, moving.global_position, moving.radius))
	var torch = world.get_node("Toxa/Toxa2/Colisao")
	assert(not world.can_actor_stand(moving, torch.global_position, moving.radius))
	world.queue_free()
	await process_frame
	await process_frame
	print("INVOCAR_OK: named skill, two golems, phase transition, placed golem, pursuit, eight-frame walk, hero/torch collisions and no self collision")
	quit()