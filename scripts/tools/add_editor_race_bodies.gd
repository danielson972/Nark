extends SceneTree
func _initialize() -> void:
	var path := "res://scenes/character_creation.tscn"
	var text := FileAccess.get_file_as_string(path)
	var resources := ""
	var nodes := ""
	var race_names := ["Humano","Elfo","Orc","Anao"]
	for gender_index in 2:
		for race_index in 4:
			var group: String = race_names[race_index]+("Masculino" if gender_index == 0 else "Feminino")
			var id: String = "EditorBase_"+group
			resources += '\n[sub_resource type="AtlasTexture" id="%s"]\natlas = ExtResource("8_rcxrn")\nregion = Rect2(%d, %d, 256, 512)\nfilter_clip = true\n' % [id,race_index*256,gender_index*512]
			var factor: float = 0.880681818*(0.85 if race_index == 3 else 1.0)
			var center := Vector2(841.272727,136.045455)+Vector2(128,256)*0.880681818
			nodes += '\n[node name="BaseCareca" type="Sprite2D" parent="Cabelos/%s"]\nz_index = -1\ntexture_filter = 1\nposition = %s\nscale = %s\nmaterial = SubResource("ShaderMaterial_n5lcl")\ntexture = SubResource("%s")\n' % [group,var_to_str(center),var_to_str(Vector2.ONE*factor),id]
	var index := text.find('[node name="MontagemPersonagem"')
	text = text.insert(index,resources+'\n')
	var start := text.find('[node name="BaseCarecaEditor"')
	var end := text.find('\n',start)
	text = text.insert(end+1,'visible = false\n')
	text += nodes
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string(text)
	quit()
