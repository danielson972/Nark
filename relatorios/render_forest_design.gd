extends SceneTree
func _initialize() -> void:
	call_deferred("_render")
func _render() -> void:
	root.size = Vector2i(1280, 1024)
	var forest = load("res://scenes/forest.tscn").instantiate()
	root.add_child(forest)
	var camera := Camera2D.new()
	camera.position = Vector2(1728, 1344)
	camera.zoom = Vector2(0.25, 0.25)
	root.add_child(camera)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(forest.get_node("ChaoETrilhas").get_used_cells().size() == 2268)
	root.get_texture().get_image().save_png("res://relatorios/forest-design-preview.png")
	print("FOREST_DESIGN_OK: 2268 authored tiles; no runtime layout script")
	quit()
