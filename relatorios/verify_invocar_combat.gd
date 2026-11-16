extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var world = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_paused(true)
	var boss = world.get_node("Aurora_boss")
	world.hero.global_position = boss.global_position + Vector2(0, 200)
	boss.attack_timer = 0.0
	assert(boss.hp == boss.max_hp)
	var before: int = world.enemies.size()
	world.set_paused(false)
	boss._process(0.016)
	assert(boss.awakened and boss.action == "invocar" and boss.windup_left > 0.0)
	assert(world.enemies.size() == before)
	for index in 80:
		boss._process(0.016)
	assert(world.enemies.size() == before + 2)
	for golem in world.enemies.slice(before):
		assert(golem.type_id == "golem_pedra" and golem.summoned)
	for attack in 3:
		boss.action = ""
		boss.windup_left = 0.0
		boss.attack_timer = 0.0
		boss._process(0.016)
		assert(boss.action != "invocar")
	boss.action = ""
	boss.windup_left = 0.0
	boss.attack_timer = 0.0
	boss._process(0.016)
	assert(boss.action == "invocar")
	world.queue_free()
	await process_frame
	await process_frame
	print("INVOCAR_COMBAT_OK: full-health wake, first cast, windup, exactly two golems, repeat after three attacks")
	quit()