extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Teste")
	await process_frame
	var original = game.state
	var original_data: Dictionary = original.to_dict()
	var original_position: Vector2 = game.world.hero.global_position
	game._enter_developer_room()
	await process_frame
	assert(game.developer_active)
	assert(game.world.region.developer_room)
	for removed_npc: String in ["mestre", "bencao", "teleporte"]:
		assert(not game.world.prop_nodes.has(removed_npc))
	for service in ["estatua", "forja", "bau", "mural", "dev_arena", "arena_console"]:
		assert(game.world.prop_nodes.has(service))
	game.world.hero.global_position = game.world.region.world_position(Vector2i(8, 14))
	game.world._update_interaction()
	game.world.use_interaction()
	assert(game.ui.current_panel == "dev_quests")
	game._on_panel_action("dev_complete_quests", {})
	assert(game.state.flags["colossal_defeated"] and game.state.flags["class_quest_done"])
	for quest: Dictionary in GameData.CONTRACTS:
		var entry: Dictionary = game.state.contract_state(quest["id"])
		assert(entry["done"] and entry["claimed"] and entry["progress"] == quest["count"])
	game._close_panel()
	assert(game.world.enemies_alive().is_empty())
	assert(game.world.can_stand(game.world.hero.global_position, 17.0))
	for kind: String in ["dev_items", "dev_skills", "dev_tools", "dev_arena"]:
		game._open_developer_shop(kind)
		await process_frame
		game._close_panel()
	for id: String in GameData.ITEMS:
		game._developer_action("dev_item", {"id": id, "qty": 10})
		assert(game.state.count_item(id) >= 10)
	for id: String in GameData.CLASS_ORDER:
		game._developer_action("dev_class", {"id": id})
		assert(game.state.class_id == id)
		for skill: Dictionary in GameData.all_skills(id):
			assert(game.state.is_skill_learned(str(skill["id"])))
		for skill: Dictionary in game.state.class_data()["ativas"]:
			assert(not game.world.hero._definition_for(str(skill["id"])).is_empty())
	game._developer_action("dev_restore", {})
	assert(game.world.hero.hp == game.state.max_hp())
	for id: String in Enemy.TYPES:
		game._developer_action("dev_enemy", {"id": id})
		assert(not game.world.enemies_alive().is_empty())
		assert(game.world.hero.global_position == game.world.region.world_position(RegionMap.DEV_ARENA_ENTRY))
		assert(game.world.can_stand(game.world.enemies_alive()[0].global_position, game.world.enemies_alive()[0].radius))
		game._developer_action("dev_clear", {})
		await process_frame
	game._developer_action("dev_arena_return", {})
	assert(game.world.hero.global_position == game.world.region.world_position(RegionMap.DEV_ARENA_GATE))
	assert(game.world.enemies_alive().is_empty())
	assert(game.world.respawn_queue.is_empty())
	game._save_game(true)
	game._leave_developer_room()
	assert(game.state == original)
	assert(game.state.to_dict() == original_data)
	assert(game.world.hero.global_position == original_position)
	assert(game.world.is_playing())
	game._enter_developer_room()
	await process_frame
	game._leave_developer_room()
	await process_frame
	print("DEVELOPER_ROOM_OK: shops, all items, six classes, enemies, restore, isolation and reentry")
	game.queue_free()
	await process_frame
	quit()
