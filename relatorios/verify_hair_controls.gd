extends SceneTree
var result: Array = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	assert(scene.get_node("%EscolhaCabelo").item_count == 17)
	assert(scene.get_node("%EscolhaCor").item_count == 7)
	root.add_child(scene)
	for i in 3: await process_frame
	for name in ["%EscolhaCabelo", "%EscolhaCor"]:
		var control: Control = scene.get_node(name)
		assert(control.is_visible_in_tree())
		assert(scene.get_viewport_rect().encloses(control.get_global_rect()), "Appearance selectors must be visible without scrolling")
	scene.get_node("%EscolhaCabelo").item_selected.emit(3)
	scene.get_node("%EscolhaCor").item_selected.emit(4)
	for gender in ["masculino","feminino"]:
		for race in ["humano","elfo","orc","anao"]:
			scene.select_gender(gender)
			scene.select_race(race)
			for i in 2: await process_frame
			assert(scene.hair_style == 3 and scene.hair_color == "branco")
			var count := 0
			for group in scene.get_node("Cabelos").get_children():
				for model in group.get_children():
					if model.is_visible_in_tree():
						count += 1
						assert(model.name == "Modelo3")
						assert(model.material.get_shader_parameter("hair_color") == scene.Custom.COLORS.branco)
			assert(count == 1)
			assert(not scene.preview.character_parts.hair.visible)
	scene.submitted.connect(func(r,c,n,h,color,g): result = [r,c,n,h,color,g])
	scene.submit()
	assert(result[3] == 3 and result[4] == "branco")
	var state := PlayerState.create("Teste","humano","guerreiro")
	state.set_hair(result[3],result[4])
	var restored := PlayerState.new()
	restored.from_dict(state.to_dict())
	assert(restored.hair_style == 3 and restored.hair_color == "branco")
	scene.select_hair(0)
	await process_frame
	assert(scene.get_node("%EscolhaCor").disabled)
	for group in scene.get_node("Cabelos").get_children(): assert(not group.visible)
	print("HAIR_CONTROLS_OK: saved child nodes, 17 hairstyles, seven colors, eight groups, no double hair, submit and save roundtrip")
	quit()
