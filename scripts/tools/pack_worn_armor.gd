extends SceneTree
func _initialize() -> void:
	var folder := "res://assets/game/sprites/herois/armaduras_vestidas/"
	for id in ["022","039","040"]:
		var image := Image.load_from_file(folder+"source_"+id+".png")
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x,y).a < 0.95: image.set_pixel(x,y,Color.TRANSPARENT)
		var body := image.get_region(image.get_used_rect())
		var factor := minf(482.0/body.get_height(),232.0/body.get_width())
		body.resize(roundi(body.get_width()*factor),roundi(body.get_height()*factor),Image.INTERPOLATE_NEAREST)
		var result := Image.create(256,512,false,Image.FORMAT_RGBA8)
		result.fill(Color.TRANSPARENT)
		result.blit_rect(body,Rect2i(Vector2i.ZERO,body.get_size()),Vector2i((256-body.get_width())/2,502-body.get_height()))
		assert(result.save_png(folder+"armadura_"+id+".png") == OK)
	print("WORN_ARMOR_PACK_OK: complete sprites 22, 39 and 40")
	quit()
