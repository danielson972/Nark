extends "res://scripts/tools/prepare_character_builder.gd"
func _initialize() -> void:
	var clean := Image.load_from_file(FOLDER + "hair_pixel_source_v2.png")
	var atlas := Image.create(2048, 2048, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var bounds_data: Array = []
	for index in 16:
		var cell_size := Vector2i(clean.get_width()/4, clean.get_height()/4)
		var cell := clean.get_region(Rect2i(Vector2i(index%4,index/4)*cell_size,cell_size))
		var hair := cell.get_region(largest_shape_bounds(cell))
		var origin := Vector2i((512-hair.get_width())/2,8)
		atlas.blit_rect(hair,Rect2i(Vector2i.ZERO,hair.get_size()),Vector2i(index%4*512,index/4*512)+origin)
		bounds_data.append([origin.x,origin.y,hair.get_width(),hair.get_height()])
	atlas.save_png(FOLDER+"hair_models_v2.png")
	var file := FileAccess.open(FOLDER+"hair_layout_v2.gd",FileAccess.WRITE)
	file.store_string("extends RefCounted\nconst RECTS = "+JSON.stringify(bounds_data)+"\n")
	quit()
