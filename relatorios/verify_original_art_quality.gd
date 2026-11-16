extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	assert(root.get_node_or_null("PixelArtStyle") == null, "Global pixel reduction must be disabled")
	var boss = load("res://scenes/enemies/colossal.tscn").instantiate()
	root.add_child(boss)
	await process_frame
	assert(boss.material == null, "Colossal must render original pixels without a reduction shader")
	assert(boss.texture.resource_path.ends_with("aurora_idle.png"))
	boss._set_motion(true)
	assert(boss.texture.resource_path.ends_with("aurora_walk_8dir.png"))
	assert(boss.texture.get_size() == Vector2(3072, 2048))
	assert(boss.hframes == 12 and boss.vframes == 8 and boss.material == null)
	assert(is_equal_approx(12.0 / boss.walk_fps, 1.5))
	boss.queue_free()
	var catalog = load("res://scripts/ui/item_catalog.gd")
	assert(catalog.ATLAS_PATH == "res://assets/game/ui/items/items_atlas.png")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Qualidade")
	for tick in 4: await process_frame
	for tile in game.world.find_children("*", "TileMapLayer", true, false):
		assert(tile.material == null, "Map source detail must be preserved")
	assert(game.world.camera.zoom == Vector2(0.65, 0.65))
	var icon = load("res://scripts/ui/inventory_icon.gd").new()
	icon.item_id = "pocao_cura"
	icon.size = Vector2(100,100)
	root.add_child(icon)
	for tick in 2: await process_frame
	assert(icon.material == null, "Inventory must display the original icon without palette reduction")
	icon.queue_free()
	game.queue_free()
	await process_frame
	print("ORIGINAL_ART_QUALITY_OK: native Colossal idle/walk, original item atlas, unfiltered tiles/icons, unchanged cadence and closer camera")
	quit()
