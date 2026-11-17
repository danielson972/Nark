extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	for i in 4: await process_frame
	var overlay = scene.get_node("Cabelos")
	assert(overlay.get_child_count() == 8)
	var original = overlay.get_node("HumanoMasculino/Modelo1")
	assert(original.position == Vector2(954,163))
	assert(original.scale.is_equal_approx(Vector2(0.43376628,0.39832208)))
	for gender in ["masculino","feminino"]:
		for race in ["humano","elfo","orc","anao"]:
			scene.select_gender(gender)
			scene.select_race(race)
			for style in range(1,17):
				scene.select_hair(style)
				await process_frame
				var visible_models := 0
				for group in overlay.get_children():
					assert(group.get_child_count() == 16)
					for model in group.get_children():
						assert(model.texture != null)
						if model.is_visible_in_tree(): visible_models += 1
				assert(visible_models == 1)
	scene.select_hair(0)
	await process_frame
	for group in overlay.get_children(): assert(not group.visible)
	scene.select_gender("masculino")
	scene.select_race("humano")
	scene.select_hair(1)
	for i in 3: await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/creation-hair-sprites.png")
	print("CREATION_HAIR_SPRITES_OK: 8 editable groups, 128 sprites, original transform preserved, switching and bald option")
	quit()
