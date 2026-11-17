extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	var transforms: Dictionary = {}
	var overlay = scene.get_node("Cabelos")
	transforms[NodePath("Cabelos")] = overlay.transform
	for group in overlay.get_children():
		transforms[NodePath("Cabelos/"+str(group.name))] = group.transform
		for sprite in group.get_children(): transforms[NodePath("Cabelos/"+str(group.name)+"/"+str(sprite.name))] = sprite.transform
	root.add_child(scene)
	for gender in ["masculino","feminino"]:
		for race in ["humano","elfo","orc","anao"]:
			scene.select_gender(gender)
			scene.select_race(race)
			for style in [0,1,8,16]:
				scene.select_hair(style)
				for i in 2: await process_frame
				var count := 0
				for group in overlay.get_children():
					if group.get_node("BaseCareca").is_visible_in_tree(): count += 1
					for sprite in group.get_children():
						var local_path: NodePath = NodePath("Cabelos/"+str(group.name)+"/"+str(sprite.name))
						assert(sprite.transform == transforms[local_path])
				assert(count == 1 and not scene.preview.draw_character)
	scene.select_race("humano")
	scene.select_gender("masculino")
	scene.select_hair(1)
	for i in 3: await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/creation-editor-runtime-match.png")
	print("EDITOR_RUNTIME_MATCH_OK: authored transforms preserved, eight bodies, four styles each, one body drawn, bald option")
	quit()
