extends SceneTree
func _initialize() -> void:
	var path := "res://scenes/character_creation.tscn"
	var scene = load(path).instantiate()
	var text := FileAccess.get_file_as_string(path)
	var resources := ""
	var nodes := ""
	for gender in ["masculino","feminino"]:
		var male: bool = gender == "masculino"
		var group := "OrcMasculino" if male else "OrcFeminino"
		var source := Image.load_from_file("res://assets/game/sprites/herois/bases/orc_"+gender+".png")
		var base: Sprite2D = scene.get_node("Cabelos/"+group+"/BaseCareca")
		for part in ["Orelha","DenteEsquerdo"]:
			var rect := Rect2i(138,46,44,42)
			var polygon := PackedVector2Array([Vector2(140,63),Vector2(178,47),Vector2(180,56),Vector2(149,86),Vector2(138,82)])
			if not male:
				polygon = PackedVector2Array([Vector2(143,66),Vector2(176,54),Vector2(178,61),Vector2(149,84),Vector2(141,80)])
			if part == "DenteEsquerdo":
				rect = Rect2i(81,81,13,15) if male else Rect2i(95,77,12,13)
				polygon = PackedVector2Array([Vector2(85,82),Vector2(88,86),Vector2(92,90),Vector2(90,94),Vector2(84,93),Vector2(82,87)]) if male else PackedVector2Array([Vector2(98,78),Vector2(101,81),Vector2(104,84),Vector2(103,88),Vector2(98,87),Vector2(96,83)])
			var image := Image.create(rect.size.x,rect.size.y,false,Image.FORMAT_RGBA8)
			image.fill(Color.TRANSPARENT)
			for y in rect.size.y:
				for x in rect.size.x:
					var point := rect.position+Vector2i(x,y)
					if Geometry2D.is_point_in_polygon(Vector2(point)+Vector2(0.5,0.5),polygon):
						var color := source.get_pixelv(point)
						if color.a >= 0.75: image.set_pixel(x,y,color)
			var file: String = "res://assets/game/sprites/herois/bases/"+("orelha" if part == "Orelha" else "dente_esquerdo")+"_orc_"+gender+".png"
			image.save_png(file)
			var id: String = part+group
			resources += '[ext_resource type="Texture2D" path="%s" id="%s"]\n' % [file,id]
			var position := base.position+(Vector2(rect.position)+Vector2(rect.size)*0.5-Vector2(128,256))*base.scale
			nodes += '\n[node name="%s" type="Sprite2D" parent="Cabelos/%s"]\nz_index = 1\ntexture_filter = 1\nposition = %s\nscale = %s\ntexture = ExtResource("%s")\n' % [part,group,var_to_str(position),var_to_str(base.scale),id]
	text = text.insert(text.find('[sub_resource '),resources+'\n')+nodes
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string(text)
	scene.free()
	quit()
