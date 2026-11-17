extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	var poses: Dictionary = {}
	for group in ["ElfoMasculino","ElfoFeminino"]:
		var ear: Sprite2D = scene.get_node("Cabelos/"+group+"/Orelha")
		assert(ear.z_index == 1 and ear.visible)
		poses[group] = ear.transform
	root.add_child(scene)
	for gender in ["masculino","feminino"]:
		scene.select_race("elfo")
		scene.select_gender(gender)
		for style in range(1,17):
			scene.select_hair(style)
			scene.select_color("azul")
			for i in 2: await process_frame
			var name := "ElfoMasculino" if gender == "masculino" else "ElfoFeminino"
			var group = scene.get_node("Cabelos/"+name)
			var ear: Sprite2D = group.get_node("Orelha")
			assert(ear.is_visible_in_tree() and ear.material == null and ear.transform == poses[name])
			assert(ear.z_index > group.get_node("Modelo%d" % style).z_index)
		var state := PlayerState.create("Elf","elfo","guerreiro")
		state.gender_id = gender
		state.set_hair(8,"azul")
		var parts = load("res://scripts/actors/character_parts.gd").new()
		for mirrored in [false,true]:
			parts.configure(state,Vector2.ZERO,Vector2.ONE,mirrored)
			assert(parts.ear.visible and parts.ear.flip_h == mirrored and parts.ear.z_index > parts.hair.z_index)
		parts.free()
	scene.select_gender("masculino")
	scene.select_hair(8)
	for i in 3: await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/elf-ear-front.png")
	print("ELF_EAR_OK: both sexes, 16 hairstyles, editor transforms preserved at runtime, skin color and mirrored world layers")
	quit()
