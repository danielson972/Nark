extends "res://scripts/tools/prepare_character_builder.gd"
const WORN = "res://assets/game/sprites/herois/armaduras_vestidas/"
func _initialize() -> void:
	var all_hands: Dictionary = {}
	var layout_path: String = WORN + "worn_layout.json"
	if FileAccess.file_exists(layout_path):
		all_hands = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	var packed := 0
	for batch in 10:
		var first: int = batch*10+1
		var range_name: String = "%03d-%03d" % [first,first+9]
		var source_path: String = WORN+"source_sheet_"+range_name+".png"
		if not FileAccess.file_exists(source_path): continue
		var source := Image.load_from_file(source_path)
		var cell_size := Vector2i(source.get_width()/5, source.get_height()/2)
		for index in 10:
			var number: int = first+index
			var output: String = WORN+"armadura_%03d.png" % number
			# The previously approved single sprites remain intact.
			if FileAccess.file_exists(output): continue
			var cell := source.get_region(Rect2i(Vector2i(index%5,index/5)*cell_size,cell_size))
			cell.convert(Image.FORMAT_RGBA8)
			for y in cell.get_height():
				for x in cell.get_width():
					var color := cell.get_pixel(x,y)
					if color.a < 0.95: cell.set_pixel(x,y,Color.TRANSPARENT)
			var bounds := largest_shape_bounds(cell)
			var body := cell.get_region(bounds)
			var factor: float = minf(482.0/body.get_height(),232.0/body.get_width())
			body.resize(roundi(body.get_width()*factor),roundi(body.get_height()*factor),Image.INTERPOLATE_NEAREST)
			var image := Image.create(256,512,false,Image.FORMAT_RGBA8)
			image.fill(Color.TRANSPARENT)
			image.blit_rect(body,Rect2i(Vector2i.ZERO,body.get_size()),Vector2i((256-body.get_width())/2,502-body.get_height()))
			assert(image.save_png(output) == OK)
			# Find the exposed near hand, rather than applying the old class pose
			# to outfits whose cuffs and hands were drawn at different heights.
			var sum := Vector2.ZERO
			var count := 0
			for y in range(220,340):
				for x in range(25,105):
					var color := image.get_pixel(x,y)
					if color.a > 0.95 and color.r > 0.65 and color.b > 0.32 and color.r > color.g*1.13 and color.r < color.g*1.6 and color.b > color.g*0.64:
						sum += Vector2(x,y)
						count += 1
			var hand := sum/float(count)/Vector2(256,512) if count >= 12 else Vector2(0.25,0.56)
			all_hands[str(number)] = [snappedf(hand.x,0.001),snappedf(hand.y,0.001)]
			packed += 1
	var f := FileAccess.open(layout_path,FileAccess.WRITE)
	f.store_string(JSON.stringify(all_hands,"\t"))
	var gd := FileAccess.open(WORN+"worn_layout.gd",FileAccess.WRITE)
	gd.store_string("extends RefCounted\nconst HANDS = "+JSON.stringify(all_hands)+"\n")
	print("WORN_SHEETS_PACK_OK: ",packed," new complete sprites")
	quit()
