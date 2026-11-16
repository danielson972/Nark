extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func check_world(world) -> void:
	assert(world.hero != null)
	assert(world.camera.get_parent() == world.hero)
	assert(world.find_children("*", "Camera2D", true, false).size() == 1)
	var previous: Vector2 = world.camera.global_position
	world.hero.global_position += Vector2(48,32)
	world._update_camera(0.1)
	assert(world.camera.global_position == world.hero.global_position)
	assert(world.camera.global_position != previous)
	assert(world.get_viewport().get_camera_2d() == world.camera)
func _run() -> void:
	for path in ["res://floresta_aurora.tscn", "res://scenes/Aurora.tscn"]:
		var world = load(path).instantiate()
		root.add_child(world)
		await process_frame
		world.set_paused(true)
		check_world(world)
		world.queue_free()
		await process_frame
		await process_frame
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Câmera")
	check_world(game.world)
	game._enter_developer_room()
	check_world(game.world)
	game._leave_developer_room()
	check_world(game.world)
	game.queue_free()
	await process_frame
	print("HERO_CAMERA_OK: forest/Aurora/main/secret room, one camera per hero, position following and active camera")
	quit()