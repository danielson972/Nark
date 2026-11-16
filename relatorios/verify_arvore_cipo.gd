extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var world = load("res://floresta_aurora.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_process(false)
	world.hero.set_process(false)
	var tree = world.get_node("Arvore/Arvore1")
	tree.set_process(false)
	assert(tree is Enemy and tree.type_id == "arvore_cipo")
	assert(world.enemies.has(tree))
	assert(tree.max_hp == 180.0 and tree.defense == 8.0)
	assert(tree.get_node("NomeDoInimigo") != null)
	assert(tree.scale.is_equal_approx(Vector2.ONE * 1.6909091))
	assert(not world.can_actor_stand(world.hero, tree.global_position, world.hero.radius))
	world.hero.global_position = tree.global_position + Vector2(200, 0)
	tree.ai_state = "idle"
	tree.attack_timer = 999.0
	var before: Vector2 = tree.global_position
	tree._process(0.2)
	assert(tree.ai_state == "chase" and tree.global_position.x > before.x)
	world.hero.global_position = tree.global_position + Vector2(75, 0)
	world.hero.hp = 200.0
	world.hero.invulnerable = 0.0
	world.hero.dodge_time = 0.0
	tree.attack_timer = 0.0
	tree._process(0.01)
	assert(tree.windup_left > 0.0)
	tree._process(0.76)
	assert(world.hero.hp == 186.0)
	world.queue_free()
	await process_frame
	await process_frame
	print("TREE_ENEMY_OK: scene registration, authored sprite, 180 HP, collision, chase and 14-damage melee attack")
	quit()