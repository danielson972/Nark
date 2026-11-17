extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1000, 720)
	var bg := ColorRect.new()
	bg.color = Color("1b1711")
	bg.size = Vector2(1000,720)
	root.add_child(bg)
	for i in 3:
		var state := PlayerState.create("Teste", "humano", "guerreiro")
		state.set_hair(5 if i < 2 else 8, "branco")
		if i > 0:
			state.add_item("armadura_ng", 1, true)
			state.equip("armadura_ng")
		var preview = load("res://scripts/ui/hero_preview.gd").new()
		preview.state = state
		preview.position = Vector2(20+i*320,30)
		preview.size = Vector2(300,650)
		root.add_child(preview)
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://relatorios/character-alignment.png")
	quit()
