extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	var path := "res://scenes/character_creation.tscn"
	var text := FileAccess.get_file_as_string(path)
	var resources := ""
	for style in range(2,17):
		resources += '[ext_resource type="Texture2D" path="res://assets/game/sprites/herois/cabelos/Modelo%d.png" id="hair_%d"]\n' % [style,style]
	text = text.replace('[sub_resource type="Theme"', resources+'\n[sub_resource type="Theme"')
	var tail := ""
	var reference_origin := Vector2(841.272727,136.045455)
	var reference_factor := 0.880681818
	var names := {"humano":"Humano","elfo":"Elfo","orc":"Orc","anao":"Anao"}
	for gender in ["masculino","feminino"]:
		for race in Custom.RACES:
			var group: String = names[race]+("Masculino" if gender == "masculino" else "Feminino")
			if group != "HumanoMasculino":
				tail += '\n[node name="%s" type="Sprite2D" parent="Cabelos"]\nvisible = false\n' % group
			for style in range(1,17):
				if group == "HumanoMasculino" and style == 1: continue
				var state := PlayerState.create("",race,"guerreiro")
				state.gender_id = gender
				state.unequip("armadura")
				state.hair_style = style
				var rect := Custom.hair_destination(state)
				var image := Image.load_from_file("res://assets/game/sprites/herois/cabelos/Modelo%d.png" % style)
				var bounds := image.get_used_rect()
				var factor: float = reference_factor * (0.85 if race == "anao" else 1.0)
				var origin := reference_origin + Vector2(256,512)*reference_factor*(1.0-(0.85 if race == "anao" else 1.0))*0.5
				var position := origin + rect.get_center()*factor
				var scale := rect.size*factor/Vector2(bounds.size)
				if style == 1:
					var scalp := Custom.scalp_rect(state)
					var ratio: float = scalp.size.x/81.0
					position = origin + Vector2(scalp.get_center().x,scalp.position.y+10.6)*factor
					scale = Vector2(0.43376628,0.39832208)*ratio*(factor/reference_factor)
					tail += '\n[node name="Modelo1" type="Sprite2D" parent="Cabelos/%s"]\nposition = %s\nscale = %s\ntexture = ExtResource("9_h36os")\n' % [group,var_to_str(position),var_to_str(scale)]
				else:
					tail += '\n[node name="Modelo%d" type="Sprite2D" parent="Cabelos/%s"]\nvisible = false\nposition = %s\nscale = %s\ntexture = ExtResource("hair_%d")\nregion_enabled = true\nregion_rect = Rect2(%d, %d, %d, %d)\n' % [style,group,var_to_str(position),var_to_str(scale),style,bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]
	text += tail
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string(text)
	quit()
