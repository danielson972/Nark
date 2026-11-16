extends SceneTree
## Packs supplied modular hair and generated bald bodies without painting pixels.
const FOLDER = "res://assets/game/character_builder/"

func _initialize() -> void:
	var sources: Array[Image] = [Image.load_from_file(FOLDER + "bald_races_source.png"), Image.load_from_file(FOLDER + "bald_races_female_source.png")]
	var atlas := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var metadata: Dictionary = {}
	var races := ["humano", "elfo", "orc", "anao"]
	for entry in 8:
		var index: int = entry % 4
		var variant: int = entry / 4
		var source: Image = sources[variant]
		var cell := source.get_region(Rect2i(index % 2 * 512, index / 2 * 768, 512, 768))
		var bounds := opaque_bounds(cell)
		var body := cell.get_region(bounds)
		var factor: float = minf(482.0 / body.get_height(), 232.0 / body.get_width())
		body.resize(roundi(body.get_width() * factor), roundi(body.get_height() * factor), Image.INTERPOLATE_NEAREST)
		var origin := Vector2i((256 - body.get_width()) / 2, 502 - body.get_height())
		atlas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), origin + Vector2i(index * 256, variant * 512))
		metadata[str(races[index]) + ("_female" if variant == 1 else "")] = {"bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "origin": [origin.x, origin.y], "factor": factor}
	assert(atlas.save_png(FOLDER + "bald_races.png") == OK)
	var hair_atlas := Image.create(2048, 2048, false, Image.FORMAT_RGBA8)
	hair_atlas.fill(Color.TRANSPARENT)
	var clean := Image.load_from_file(FOLDER + "hair_clean_source.png")
	var hair_bounds_data: Array = []
	for index in 16:
		var column: int = index % 4
		var row: int = index / 4
		var cell_size := Vector2i(clean.get_width() / 4, clean.get_height() / 4)
		var cell := clean.get_region(Rect2i(Vector2i(column, row) * cell_size, cell_size))
		# Long styles in the preceding row can extend into this cell's margin.
		# Measure the main connected silhouette rather than every opaque pixel.
		var hair := cell.get_region(largest_shape_bounds(cell))
		hair_atlas.blit_rect(hair, Rect2i(Vector2i.ZERO, hair.get_size()), Vector2i(column * 512 + (512 - hair.get_width()) / 2, row * 512 + 8))
		hair_bounds_data.append([int((512 - hair.get_width()) / 2), 8, hair.get_width(), hair.get_height()])
	assert(hair_atlas.save_png(FOLDER + "hair_models.png") == OK)
	var file := FileAccess.open(FOLDER + "packing.json", FileAccess.WRITE)
	metadata["hair"] = hair_bounds_data
	file.store_string(JSON.stringify(metadata, "\t"))
	var layout := FileAccess.open(FOLDER + "hair_layout.gd", FileAccess.WRITE)
	layout.store_string("extends RefCounted\nconst RECTS = " + JSON.stringify(hair_bounds_data) + "\n")
	print("CHARACTER_ASSETS_OK: 8 bald bases and 16 modular hairstyles")
	quit()

func opaque_bounds(image: Image) -> Rect2i:
	var minimum := image.get_size()
	var maximum := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a >= 0.75:
				minimum = Vector2i(mini(minimum.x, x), mini(minimum.y, y))
				maximum = Vector2i(maxi(maximum.x, x), maxi(maximum.y, y))
	assert(maximum.x > minimum.x and maximum.y > minimum.y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)

func largest_shape_bounds(image: Image) -> Rect2i:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var mask := PackedByteArray()
	mask.resize(width * height)
	for y in height:
		for x in width:
			mask[y * width + x] = 1 if image.get_pixel(x, y).a >= 0.75 else 0
	var best_size: int = 0
	var best := Rect2i()
	for start in mask.size():
		if mask[start] == 0:
			continue
		var queue := PackedInt32Array([start])
		mask[start] = 0
		var cursor: int = 0
		var minimum := Vector2i(width, height)
		var maximum := Vector2i.ZERO
		while cursor < queue.size():
			var current: int = queue[cursor]
			cursor += 1
			var point := Vector2i(current % width, current / width)
			minimum = Vector2i(mini(minimum.x, point.x), mini(minimum.y, point.y))
			maximum = Vector2i(maxi(maximum.x, point.x), maxi(maximum.y, point.y))
			for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next := point + offset
				if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
					continue
				var key: int = next.y * width + next.x
				if mask[key] != 0:
					mask[key] = 0
					queue.append(key)
		if queue.size() > best_size:
			best_size = queue.size()
			best = Rect2i(minimum, maximum - minimum + Vector2i.ONE)
	assert(best_size > 1000)
	return best

