extends SceneTree
## Mechanical export of supplied human and generated outfit variants.
const FOLDER = "res://assets/game/sprites/herois/humano/"
const CELL = Vector2i(256, 512)

func _initialize() -> void:
	var reference := Image.load_from_file("res://assets/game/pixel_art/style_human.png")
	assert(reference != null)
	var base := reference.get_region(_body_bounds(reference))
	# Only the supplied high-resolution reference needs downsampling for the game.
	_resize_to_fit(base)
	var sources: Array[Image] = []
	for filename: String in ["outfits_ranged_mage_pixel.png", "outfits_warrior_assassin_pixel.png", "outfits_tank_knight_pixel.png"]:
		var source := Image.load_from_file("res://assets/game/pixel_art/" + filename)
		assert(source != null and source.get_size() == Vector2i(1536, 1024))
		sources.append(source)
	var atlas := Image.create(1536, 3072, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for row in 6:
		for column in 6:
			var body: Image = base
			if column >= 2:
				var source: Image = sources[row / 2]
				var cell := source.get_region(Rect2i((column - 2) * 384, (row % 2) * 512, 384, 512))
				body = cell.get_region(_body_bounds(cell))
				_resize_to_fit(body)
			var destination := Vector2i(column * CELL.x + (CELL.x - body.get_width()) / 2, row * CELL.y + 502 - body.get_height())
			atlas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), destination)
	var result: Error = atlas.save_png(FOLDER + "human_equipment_atlas_pixel.png")
	if result != OK:
		push_error("Não foi possível salvar o atlas humano: %s" % error_string(result))
		quit(1)
		return
	print("HUMAN_ATLAS_OK: supplied base, 6 classes x 6 outfits, 256x512 frames, grounded feet")
	quit()

func _resize_to_fit(image: Image) -> void:
	var factor: float = minf(482.0 / image.get_height(), 224.0 / image.get_width())
	if factor < 1.0:
		image.resize(roundi(image.get_width() * factor), roundi(image.get_height() * factor), Image.INTERPOLATE_NEAREST)
	image.convert(Image.FORMAT_RGBA8)

func _body_bounds(image: Image) -> Rect2i:
	var minimum := image.get_size()
	var maximum := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a >= 0.75:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x)
				maximum.y = maxi(maximum.y, y)
	assert(maximum.x > minimum.x and maximum.y > minimum.y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
