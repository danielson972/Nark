extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Scripts de monstros")
	var world = game.world
	world.set_paused(true)
	var catalog = load("res://scripts/actors/enemy_catalog.gd")
	assert(catalog.definitions().size() == 7)
	var initial_count: int = world.enemies.size()
	var container := Node2D.new()
	container.position = Vector2(90, 130)
	world.props_layer.add_child(container)
	for id: String in catalog.SCRIPTS:
		var summoned = world.spawn_enemy(id, Vector2(1600, 1200))
		assert(summoned.get_script().resource_path == catalog.SCRIPTS[id])
		assert(summoned.type_id == id)
		assert(summoned.max_hp == float(catalog.definitions()[id]["hp"]))
		var placed = Sprite2D.new()
		placed.set_script(load(catalog.SCRIPTS[id]))
		placed.texture = load(catalog.definitions()[id]["sprite"])
		placed.scale = Vector2(0.7, 0.8)
		placed.offset = Vector2(3, -10)
		placed.position = Vector2(200, 250)
		container.add_child(placed)
		var original_texture = placed.texture
		var original_scale: Vector2 = placed.scale
		var original_offset: Vector2 = placed.offset
		var original_position: Vector2 = placed.global_position
		world._register_map_enemies(container)
		assert(placed.type_id == id)
		assert(placed.sprite == placed)
		assert(placed.texture == original_texture)
		assert(placed.scale == original_scale)
		assert(placed.offset == original_offset)
		assert(placed.get_node_or_null("Sprite2D") == null)
		assert(placed.global_position == original_position)
		assert(placed.spawn_point == original_position)
		assert(placed.max_hp == summoned.max_hp)
		var count: int = world.enemies.size()
		world._register_map_enemies(container)
		assert(world.enemies.size() == count)
		assert(placed.get_node("NomeDoInimigo") != null)
	assert(world.enemies.size() == initial_count + 14)
	print("ENEMY_SCRIPTS_OK: 7 specific scripts, direct Sprite2D attachment, attributes, authored textures and transforms, summons and idempotent registration")
	game.queue_free()
	await process_frame
	quit()
