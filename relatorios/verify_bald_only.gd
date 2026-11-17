extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for gender in ["masculino","feminino"]:
		for race in ["humano","elfo","orc","anao"]:
			var state := PlayerState.create("Careca",race,"guerreiro")
			state.gender_id = gender
			state.set_hair(12,"ruivo")
			assert(state.hair_style == 0)
			var saved := state.to_dict()
			saved["hair_style"] = 16
			state.from_dict(saved)
			assert(state.hair_style == 0)
			state.hair_style = 9
			var parts = load("res://scripts/actors/character_parts.gd").new()
			parts.configure(state,Vector2.ZERO,Vector2.ONE)
			assert(not parts.hair.visible)
			parts.free()
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	assert(scene.hair_buttons.is_empty() and scene.color_buttons.is_empty())
	assert(scene.preview.state.hair_style == 0)
	print("BALD_ONLY_OK: eight bases, legacy saves, hair layers hidden and hair controls removed")
	quit()
