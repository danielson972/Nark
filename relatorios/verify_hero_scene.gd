extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://scenes/hero.tscn")
	var count: int = 0
	for race_id: String in GameData.RACES:
		for class_id: String in GameData.CLASS_ORDER:
			var state = PlayerState.create("Cena", race_id, class_id)
			var hero = scene.instantiate()
			var body = hero.get_node("Sprite2D")
			var weapon = body.get_node("ArmaEquipada")
			hero.bind_state(state)
			hero.setup(null, "", 92.0)
			assert(hero is Sprite2D)
			assert(hero.sprite == body and hero.weapon_sprite == weapon)
			assert(body.get_child_count() == 2)
			assert(hero.state.race_id == race_id and hero.state.class_id == class_id)
			assert(hero.max_hp == state.max_hp())
			assert(body.texture == hero.Appearance.body_texture(state))
			assert(weapon.texture != null and weapon.visible)
			state.unequip("arma")
			assert(not weapon.visible)
			assert(state.equip("arma_basica").is_empty())
			assert(weapon.visible)
			hero.free()
			count += 1
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Cena")
	assert(game.world.hero.scene_file_path == "res://scenes/hero.tscn")
	assert(game.world.hero.get_parent() == game.world.actors_layer)
	game.queue_free()
	await process_frame
	print("HERO_SCENE_OK: %d race/class combinations, scene nodes reused, equipment signals and world instantiation" % count)
	quit()