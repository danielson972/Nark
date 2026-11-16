extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Níveis")
	var world = game.world
	world.set_paused(true)
	for id: String in Enemy.TYPES:
		var enemy = world.spawn_enemy(id, Vector2(1000, 900))
		assert(enemy.level >= 1)
		assert(enemy.display_name().contains("Nv. %d" % enemy.level))
	var tree = world.spawn_enemy("arvore_cipo", Vector2(1200, 900))
	assert(tree.level == 20 and tree.max_hp == 480.0 and tree.defense == 28.0)
	tree._update_nameplate()
	assert(tree.nameplate.text == tree.display_name())
	print("ENEMY_LEVELS_OK: all enemy levels, level-20 tree stats, name and level only")
	game.queue_free()
	await process_frame
	quit()
