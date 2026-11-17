extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440, 1000)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	var bg := ColorRect.new()
	bg.color = Color("1b1711")
	bg.size = Vector2(1440,1000)
	root.add_child(bg)
	for i in 8:
		var state := PlayerState.create("Teste", ["humano","elfo","orc","anao"][i%4], "guerreiro")
		state.gender_id = "feminino" if i >= 4 else "masculino"
		state.equipment.erase("armadura")
		state.equipment.erase("arma")
		state.set_hair([13,8,1,2,7,8,10,12][i], "castanho")
		var preview = load("res://scripts/ui/hero_preview.gd").new()
		preview.state = state
		preview.position = Vector2(i%4*360, floori(i/4.0)*500)
		preview.size = Vector2(350,490)
		root.add_child(preview)
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://relatorios/character-races-v2.png")
	quit()
