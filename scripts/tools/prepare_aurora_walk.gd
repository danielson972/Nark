extends SceneTree

func _initialize() -> void:
	var sources: Array[Image] = []
	for filename: String in ["aurora_walk_front_refined.png", "aurora_walk_front_inbetweens.png", "aurora_walk_back_refined.png", "aurora_walk_back_inbetweens.png"]:
		var image := Image.load_from_file("res://assets/game/sprites/colossos/aurora/" + filename)
		assert(image != null and image.get_size() == Vector2i(1536, 1024))
		image.convert(Image.FORMAT_RGBA8)
		sources.append(image)
	var atlas := Image.create(3072, 2048, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for row in 8:
		# Perfis esquerdos usam as mesmas poses nativas, espelhadas pelo Sprite2D.
		var source_row: int = [0, 1, 2, 3, 0, 3, 2, 1][row]
		for col in 12:
			# Alterna pose principal e intermediária: K0, I0, K1, I1 ... K5, I5.
			var source: Image = sources[(2 if row == 4 else 0) + col % 2]
			var cell := source.get_region(Rect2i((col / 2) * 256, source_row * 256, 256, 256))
			var bounds: Rect2i = _body_bounds(cell)
			var sprite := cell.get_region(bounds)
			# Preserva os pixels da fonte em escala 1:1, sem ampliação/interpolação.
			assert(sprite.get_width() <= 256 and sprite.get_height() <= 240)
			# Mantém o pivô horizontal da célula: o balanço dos braços não recentra o corpo.
			var destination := Vector2i(col * 256 + bounds.position.x, row * 256 + 240 - sprite.get_height())
			atlas.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), destination)
	assert(atlas.save_png("res://assets/game/sprites/colossos/aurora/aurora_walk_8dir.png") == OK)
	print("AURORA_ATLAS_OK: 96 frames, 12 poses per direction, native pixels, stable horizontal pivots")
	quit()

func _body_bounds(image: Image) -> Rect2i:
	var minimum := image.get_size()
	var maximum := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.2:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x)
				maximum.y = maxi(maximum.y, y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
