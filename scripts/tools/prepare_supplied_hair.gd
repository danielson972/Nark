extends "res://scripts/tools/prepare_character_builder.gd"
func _initialize() -> void:
	var main := Image.load_from_file(FOLDER+"hair_supplied_twelve.png")
	var colors := Image.load_from_file(FOLDER+"hair_supplied_colors.png")
	var atlas := Image.create(2048,2048,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var data: Array = []
	for i in 16:
		var source := main if i < 12 else colors
		var cell: Image
		if i < 12:
			cell = source.get_region(Rect2i(80+(i%4)*320, [35,340,660][i/4], 320, [245,280,350][i/4]))
		else:
			cell = source.get_region(Rect2i(80+(i%4)*320,890,320,150))
		if i == 12:
			cell = Image.load_from_file(FOLDER+"hair_supplied_short.png")
		var hair := cell.get_region(largest_shape_bounds(cell))
		var origin := Vector2i((512-hair.get_width())/2,8)
		atlas.blit_rect(hair,Rect2i(Vector2i.ZERO,hair.get_size()),Vector2i(i%4*512,i/4*512)+origin)
		data.append([origin.x,origin.y,hair.get_width(),hair.get_height()])
	atlas.save_png(FOLDER+"hair_models_supplied.png")
	var f := FileAccess.open(FOLDER+"hair_layout_supplied.gd",FileAccess.WRITE)
	f.store_string("extends RefCounted\nconst RECTS = "+JSON.stringify(data)+"\n")
	quit()
