extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	var atlases: Dictionary = {}
	var count := 0
	for gender in ["masculino","feminino"]:
		for race in Custom.RACES:
			var state := PlayerState.create("Fitted",race,"guerreiro")
			state.gender_id = gender
			state.unequip("armadura")
			for style in range(1,17):
				state.hair_style = style
				var texture := Custom.fitted_hair_texture(state)
				var rect := Custom.fitted_hair_destination(state)
				assert(texture.atlas.get_size() == Vector2(1024,1536))
				assert(rect.size == texture.region.size, "Selection uses native fitted pixels")
				var image := texture.get_image()
				assert(image.get_used_rect().size == image.get_size(), "Crop must contain complete hair")
				assert(texture.atlas.resource_path.ends_with("fitted_%s_%s.png" % [race,gender]))
				atlases[texture.atlas.resource_path] = true
				count += 1
	assert(atlases.size() == 8)
	print("FITTED_HAIR_OK: eight distinct atlases, %d native-size hairstyle crops" % count)
	quit()
