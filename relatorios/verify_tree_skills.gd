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
	world.hero.global_position = Vector2(1500, 1000)
	var tree = world.spawn_enemy("arvore_cipo", Vector2(1300, 1000))
	tree.set_process(false)
	tree.ai_state = "chase"
	tree.root_timer = 0.0
	tree.attack_timer = 99.0
	tree._process(0.016)
	var trap = world.effects_layer.get_children().filter(func(node): return node.get_script() != null and node.get_script().resource_path.ends_with("tree_root_trap.gd"))[0]
	trap.set_process(false)
	assert(trap.global_position == world.hero.global_position)
	trap._process(0.4)
	assert(not world.hero.has_status("root"))
	world.hero.invulnerable = 0.0
	world.hero.dodge_time = 0.0
	trap._process(0.51)
	assert(world.hero.has_status("root") and world.hero.status_time("root") == 2.0)
	var before: Vector2 = world.hero.global_position
	world.hero.move_desired(Vector2.RIGHT * 200, 0.1)
	assert(world.hero.global_position == before)
	world.hero._try_dodge(Vector2.RIGHT)
	assert(world.hero.dodge_time == 0.0)
	world.hero._update_statuses(2.01)
	assert(not world.hero.has_status("root"))
	var missed = load("res://scripts/combat/tree_root_trap.gd").new()
	missed.world = world
	missed.position = world.hero.global_position - Vector2(200, 0)
	world.effects_layer.add_child(missed)
	missed.set_process(false)
	missed._process(1.0)
	assert(not world.hero.has_status("root"))
	tree.spell_left = 0.0
	tree.root_timer = 99.0
	tree.seed_timer = 0.0
	tree._process(0.016)
	assert(tree.preparing_seed)
	tree._process(0.46)
	var seed = world.effects_layer.get_children().filter(func(node): return node is Projectile and node.kind == "seed")[0]
	seed.set_process(false)
	world.hero.hp = 200.0
	var count: int = world.enemies.size()
	for index in 120:
		if seed.is_queued_for_deletion():
			break
		seed._process(0.016)
	assert(seed.is_queued_for_deletion() and world.hero.hp == 190.0)
	assert(world.enemies.size() == count)
	assert(not Enemy.TYPES.has("mini_daninha"))
	world.queue_free()
	await process_frame
	await process_frame
	print("TREE_SKILLS_OK: fixed ground warning, 2-second root, movement/dodge blocked, expiry, dodgeable area, seed projectile damage, safe future weed hook")
	quit()