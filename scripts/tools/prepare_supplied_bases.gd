extends "res://scripts/tools/prepare_character_builder.gd"
func _initialize() -> void:
	var source := Image.load_from_file(FOLDER+"supplied_bald_characters.png")
	var atlas := Image.load_from_file(FOLDER+"bald_races.png")
	var cells := [Rect2i(120,0,280,598), Rect2i(540,0,280,598), Rect2i(1320,0,340,598), Rect2i(900,0,350,598), Rect2i(1770,0,300,598)]
	var data: Array = []
	for i in 5:
		var cell := source.get_region(cells[i])
		var bounds := opaque_bounds(cell)
		var body := cell.get_region(bounds)
		var factor := minf(482.0/body.get_height(),232.0/body.get_width())
		body.resize(roundi(body.get_width()*factor),roundi(body.get_height()*factor),Image.INTERPOLATE_NEAREST)
		var origin := Vector2i((256-body.get_width())/2,502-body.get_height())
		if i < 4:
			atlas.fill_rect(Rect2i(i*256,0,256,512),Color.TRANSPARENT)
			atlas.blit_rect(body,Rect2i(Vector2i.ZERO,body.get_size()),origin+Vector2i(i*256,0))
		else:
			var alternate := Image.create(256,512,false,Image.FORMAT_RGBA8)
			alternate.blit_rect(body,Rect2i(Vector2i.ZERO,body.get_size()),origin)
			alternate.save_png(FOLDER+"supplied_human_alternate.png")
		data.append({"bounds":bounds,"origin":origin,"factor":factor})
	atlas.save_png(FOLDER+"bald_races_supplied.png")
	print(data)
	quit()
