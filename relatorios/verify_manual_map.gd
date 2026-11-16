extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Mapa manual")
	await process_frame
	var world = game.world
	assert(world.hero != null)
	assert(world.props_layer.get_child_count() == 1)
	assert(world.prop_nodes.is_empty())
	assert(world.region.props.is_empty())
	assert(world.region.monster_spawns.is_empty())
	assert(world.enemies_alive().is_empty())
	assert(world.respawn_queue.is_empty())
	var map: Node2D = world.props_layer.get_child(0)
	assert(map.name == "Mapa")
	assert(world.hero.global_position == map.get_node("InicioJogador").global_position)
	assert(map.get_node("NPCs").get_child_count() == 0)
	assert(map.get_node("Monstros").get_child_count() == 0)
	assert(map.get_node("Terreno").get_child_count() == 0)
	game.ui.show_inventory_panel()
	await process_frame
	assert(game.ui.current_panel == "inventory")
	game._close_panel()
	game.queue_free()
	await process_frame
	print("MANUAL_MAP_OK: empty authored scene, player, inventory, no generated terrain, props or enemies")
	quit()
