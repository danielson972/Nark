extends SceneTree
func _initialize() -> void:
	var path := "res://scenes/character_creation.tscn"
	var scene = load(path).instantiate()
	var text := FileAccess.get_file_as_string(path)
	var resources := ""
	var nodes := ""
	for gender in ["masculino","feminino"]:
		var group := "ElfoMasculino" if gender == "masculino" else "ElfoFeminino"
		var source := Image.load_from_file("res://assets/game/sprites/herois/bases/elfo_"+gender+".png")
		var origin := Vector2i(140,50)
		var ear := Image.create(48,42,false,Image.FORMAT_RGBA8)
		ear.fill(Color.TRANSPARENT)
		var polygon := PackedVector2Array([Vector2(143,66),Vector2(185,50),Vector2(188,57),Vector2(153,88),Vector2(142,86)])
		if gender == "feminino":
			polygon = PackedVector2Array([Vector2(144,66),Vector2(181,52),Vector2(184,57),Vector2(153,86),Vector2(143,84)])
		for y in 42:
			for x in 48:
				var point := origin+Vector2i(x,y)
				if Geometry2D.is_point_in_polygon(Vector2(point)+Vector2(0.5,0.5),polygon):
					var color := source.get_pixelv(point)
					if color.a >= 0.75: ear.set_pixel(x,y,color)
		var file: String = "res://assets/game/sprites/herois/bases/orelha_elfo_"+gender+".png"
		ear.save_png(file)
		resources += '[ext_resource type="Texture2D" path="%s" id="Ear_%s"]\n' % [file,group]
		var base: Sprite2D = scene.get_node("Cabelos/"+group+"/BaseCareca")
		var position := base.position+(Vector2(origin)+Vector2(24,21)-Vector2(128,256))*base.scale
		nodes += '\n[node name="Orelha" type="Sprite2D" parent="Cabelos/%s"]\nz_index = 1\ntexture_filter = 1\nposition = %s\nscale = %s\ntexture = ExtResource("Ear_%s")\n' % [group,var_to_str(position),var_to_str(base.scale),group]
	text = text.insert(text.find('[sub_resource '),resources+'\n')+nodes
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string(text)
	scene.free()
	quit()
