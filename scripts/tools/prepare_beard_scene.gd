extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	var creation = load("res://scenes/character_creation.tscn").instantiate()
	var names := {"humano":"Humano","elfo":"Elfo","orc":"Orc","anao":"Anao"}
	var text := "[gd_scene load_steps=23 format=3]\n\n[ext_resource type=\"Shader\" path=\"res://shaders/character_beard.gdshader\" id=\"shader\"]\n"
	for style in range(1,21):
		text += "[ext_resource type=\"Texture2D\" path=\"res://assets/game/sprites/herois/barbas/Modelo%d.png\" id=\"beard_%d\"]\n" % [style,style]
	text += "\n[sub_resource type=\"ShaderMaterial\" id=\"BeardMaterial\"]\nshader = ExtResource(\"shader\")\n\n[node name=\"Barbas\" type=\"Node2D\"]\nz_index = 4\n"
	for gender: String in ["masculino","feminino"]:
		for race: String in Custom.RACES:
			var name: String = names[race]+("Masculino" if gender == "masculino" else "Feminino")
			var source_group: Node2D = creation.get_node("Cabelos/"+name)
			var base: Sprite2D = source_group.get_node("BaseCareca")
			var group_transform: Transform2D = creation.get_node("Cabelos").transform*source_group.transform
			text += "\n[node name=\"%s\" type=\"Node2D\" parent=\".\"]\nvisible = false\nposition = Vector2(%s,%s)\nrotation = %s\nscale = Vector2(%s,%s)\n" % [name,group_transform.origin.x,group_transform.origin.y,group_transform.get_rotation(),group_transform.get_scale().x,group_transform.get_scale().y]
			var state := PlayerState.create("Barba",race,"guerreiro")
			state.gender_id = gender
			state.unequip("armadura")
			for style in range(1,21):
				state.set_beard(style)
				var rect: Rect2 = Custom.beard_destination(state)
				var texture: Texture2D = Custom.beard_texture(style)
				var position: Vector2 = base.transform*(rect.get_center()-base.texture.get_size()*0.5)
				var scale: Vector2 = base.scale*rect.size/texture.get_size()
				text += "\n[node name=\"Modelo%d\" type=\"Sprite2D\" parent=\"%s\"]\nvisible = false\ntexture_filter = 1\nmaterial = SubResource(\"BeardMaterial\")\nposition = Vector2(%s,%s)\nrotation = %s\nscale = Vector2(%s,%s)\ntexture = ExtResource(\"beard_%d\")\n" % [style,name,position.x,position.y,base.rotation,scale.x,scale.y,style]
	var file := FileAccess.open("res://scenes/character_beards.tscn",FileAccess.WRITE)
	file.store_string(text)
	creation.free()
	print("BEARD_SCENE_OK: 160 editable Sprite2D nodes; existing body transforms preserved")
	quit()
