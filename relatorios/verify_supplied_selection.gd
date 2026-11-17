extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1200,650)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	var bg := ColorRect.new()
	bg.size = Vector2(1200,650)
	bg.color = Color("1b1711")
	root.add_child(bg)
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	for i in 4:
		scene.select_race(["humano","elfo","anao","orc"][i])
		for class_id in GameData.CLASS_ORDER:
			scene.select_class(class_id)
			assert(not scene.Custom.armored(scene.preview.state))
		var view = load("res://scripts/ui/hero_preview.gd").new()
		view.state = scene.preview.state
		view.position = Vector2(i*300,40)
		view.size = Vector2(300,580)
		root.add_child(view)
		var label := Label.new()
		label.text = ["Humano","Elfo","Anão","Orc"][i]
		label.position = Vector2(i*300+110,15)
		root.add_child(label)
	scene.hide()
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://relatorios/supplied-character-selection.png")
	print("SUPPLIED_SELECTION_OK: four complete bases, six classes each, no head replacement")
	quit()
