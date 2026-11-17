extends "res://scripts/tools/prepare_character_builder.gd"

func _initialize() -> void:
	var old := Image.load_from_file("res://assets/game/sprites/herois/bases/anao_masculino.png")
	var target := opaque_bounds(old)
	var supplied := Image.load_from_file(FOLDER + "dwarf_shaved_reference.png")
	var dwarf := supplied.get_region(opaque_bounds(supplied))
	# Keep both the authored 256x512 canvas and the existing visible footprint.
	dwarf.resize(target.size.x, target.size.y, Image.INTERPOLATE_NEAREST)
	var frame := Image.create(256,512,false,Image.FORMAT_RGBA8)
	frame.fill(Color.TRANSPARENT)
	frame.blit_rect(dwarf,Rect2i(Vector2i.ZERO,dwarf.get_size()),target.position)
	assert(frame.save_png("res://assets/game/sprites/herois/bases/anao_masculino_sem_barba.png") == OK)
	var bodies := Image.load_from_file(FOLDER + "bald_races_supplied.png")
	bodies.fill_rect(Rect2i(768,0,256,512),Color.TRANSPARENT)
	bodies.blit_rect(frame,Rect2i(0,0,256,512),Vector2i(768,0))
	assert(bodies.save_png(FOLDER + "bald_races_beards.png") == OK)
	var beards := Image.load_from_file(FOLDER + "beards_reference.png")
	var column_rows := [[10,280,510,735,970,1219],[10,280,510,735,970,1219],[0,285,475,720,975,1219],[10,270,485,730,970,1219]]
	var rows := [0,325,610,950,1290]
	var sizes: Array = []
	for index in 20:
		var column: int = index % 5
		var row: int = index / 5
		var columns: Array = column_rows[row]
		var cell := beards.get_region(Rect2i(columns[column], rows[row], columns[column+1]-columns[column],rows[row+1]-rows[row]))
		# Keep separate mustaches, goatees and paired sideburns; reject labels.
		var bounds := beard_bounds(cell)
		var beard := cell.get_region(bounds)
		assert(beard.save_png("res://assets/game/sprites/herois/barbas/Modelo%d.png" % (index+1)) == OK)
		sizes.append([beard.get_width(),beard.get_height()])
	var armor_rects: Array = []
	for batch in 10:
		var path := "res://assets/game/sprites/Armaduras_RPG/pranchas/%03d-%03d.png" % [batch*10+1,batch*10+10]
		var armor_sheet := Image.load_from_file(path)
		for index in 10:
			var x0: int = roundi((0.05 + (index%5)*0.18) * armor_sheet.get_width())
			var x1: int = roundi((0.23 + (index%5)*0.18) * armor_sheet.get_width())
			var y0: int = 0 if index < 5 else roundi(0.475*armor_sheet.get_height())
			var y1: int = roundi((0.414 if index < 5 else 0.915)*armor_sheet.get_height())
			var cell := Rect2i(x0,y0,x1-x0,y1-y0)
			var bounds := opaque_bounds(armor_sheet.get_region(cell))
			bounds.position += cell.position
			armor_rects.append([bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y])
	var layout := FileAccess.open("res://assets/game/ui/items/armor_icon_layout.gd",FileAccess.WRITE)
	layout.store_string("extends RefCounted\nconst RECTS = " + JSON.stringify(armor_rects) + "\n")
	print("BEARDS_DWARF_ARMOR_OK: preserved dwarf footprint ",target,"; 20 beards ",sizes,"; 100 armor icon bounds")
	quit()

func beard_bounds(image: Image) -> Rect2i:
	var width: int = image.get_width()
	var mask := PackedByteArray()
	mask.resize(width*image.get_height())
	for y in image.get_height():
		for x in width:
			mask[y*width+x] = 1 if image.get_pixel(x,y).a >= 0.75 else 0
	var result := Rect2i()
	var components: Array = []
	for start in mask.size():
		if mask[start] == 0: continue
		var queue := PackedInt32Array([start])
		mask[start] = 0
		var cursor: int = 0
		var minimum := Vector2i(width,image.get_height())
		var maximum := Vector2i.ZERO
		while cursor < queue.size():
			var current: int = queue[cursor]
			cursor += 1
			var p := Vector2i(current%width,current/width)
			minimum = Vector2i(mini(minimum.x,p.x),mini(minimum.y,p.y))
			maximum = Vector2i(maxi(maximum.x,p.x),maxi(maximum.y,p.y))
			for delta: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				var next := p+delta
				if next.x < 0 or next.x >= width or next.y < 0 or next.y >= image.get_height(): continue
				var key: int = next.y*width+next.x
				if mask[key] == 1:
					mask[key] = 0
					queue.append(key)
		var bounds := Rect2i(minimum,maximum-minimum+Vector2i.ONE)
		if queue.size() >= 40: components.append({"bounds":bounds,"area":queue.size()})
		if queue.size() >= 600:
			result = bounds if result.size == Vector2i.ZERO else result.merge(bounds)
	var main := result
	for part: Dictionary in components:
		var bounds: Rect2i = part.bounds
		if part.area < 600 and bounds.position.y < main.end.y and bounds.intersects(main.grow(20)):
			result = result.merge(bounds)
	assert(result.size.x > 20 and result.size.y > 20)
	return result
