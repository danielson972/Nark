extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://scenes/Aurora.tscn")
	var world = scene.instantiate()
	world.hero_race = "elfo"
	world.hero_class = "mago"
	root.add_child(world)
	await process_frame
	assert(world.hero == world.get_node("Hero"))
	assert(world.hero.state.race_id == "elfo")
	assert(world.hero.state.class_id == "mago")
	assert(world.hero.world == world and world.is_playing())
	assert(world.enemies.size() == 1)
	assert(not world.enemies[0].awakened)
	assert(world.hero.global_position.distance_to(world.get_node("InicioJogador").global_position) < 1.0)
	for i in 10:
		await process_frame
	assert(not world.enemies[0].awakened)
	world.queue_free()
	await process_frame
	var existing = PlayerState.create("Existente", "orc", "tank")
	world = scene.instantiate()
	world.state = existing
	root.add_child(world)
	await process_frame
	assert(world.hero.state == existing)
	assert(world.hero.max_hp == existing.max_hp())
	world.queue_free()
	await process_frame
	print("AURORA_HERO_OK: editor instance, standalone race/class, world integration, dormant boss, existing state")
	quit()