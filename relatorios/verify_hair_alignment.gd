extends SceneTree
func _initialize() -> void:
	var custom = load("res://scripts/actors/character_customization.gd")
	var checked: int = 0
	var holes: int = 0
	for gender: String in ["masculino", "feminino"]:
		for race: String in custom.RACES:
			var state := PlayerState.create("Teste", race, "guerreiro")
			state.gender_id = gender
			for style in range(1, 17):
				state.set_hair(style, "castanho")
				var scalp: Rect2 = custom.scalp_rect(state)
				var source: Rect2 = custom.head_rect(state)
				var destination: Rect2 = custom.head_destination(state)
				var factor: float = destination.size.x / source.size.x
				scalp = Rect2(destination.position + (scalp.position - source.position) * factor, scalp.size * factor)
				var rect: Rect2 = custom.hair_destination(state)
				var texture: AtlasTexture = custom.hair_texture(style)
				var image: Image = texture.get_image()
				var point := Vector2(scalp.get_center().x, scalp.position.y + 10 * factor)
				var sample := Vector2i((point - rect.position) / rect.size * Vector2(image.get_size()))
				var covered: bool = Rect2i(Vector2i.ZERO, image.get_size()).has_point(sample) and image.get_pixelv(sample).a >= 0.75
				if not covered:
					print("CROWN_HOLE ", race, " ", gender, " style ", style)
					holes += 1
				checked += 1
	assert(holes == 0, "Every hairstyle must cover the calibrated skull crown")
	print("HAIR_ALIGNMENT_OK: ", checked, " race/model/style crown samples; no uncovered scalp")
	quit()
