extends SceneTree
const FOLDER = "res://assets/game/sprites/herois/bases/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var source := Image.load_from_file("res://assets/game/character_builder/bald_races_supplied.png")
	var scene_path := "res://scenes/character_creation.tscn"
	var scene := FileAccess.get_file_as_string(scene_path)
	var resources := ""
	var names := ["Humano","Elfo","Orc","Anao"]
	for gender in 2:
		for race in 4:
			var suffix := "masculino" if gender == 0 else "feminino"
			var key: String = names[race].to_lower()+"_"+suffix
			var image := source.get_region(Rect2i(race*256,gender*512,256,512))
			assert(image.save_png(FOLDER+key+".png") == OK)
			var group: String = names[race]+("Masculino" if gender == 0 else "Feminino")
			resources += '[ext_resource type="Texture2D" path="%s%s.png" id="Base_%s"]\n' % [FOLDER,key,group]
			var pattern := RegEx.new()
			pattern.compile('(?s)\\[sub_resource type="AtlasTexture" id="EditorBase_'+group+'"\\]\\n.*?(?=\\n\\[)')
			scene = pattern.sub(scene,"",true)
			scene = scene.replace('texture = SubResource("EditorBase_'+group+'")','texture = ExtResource("Base_'+group+'")')
	var index := scene.find('[sub_resource ')
	scene = scene.insert(index,resources+'\n')
	var f := FileAccess.open(scene_path,FileAccess.WRITE)
	f.store_string(scene)
	print("SEPARATE_RACE_SPRITES_OK: eight 256x512 PNG files and scene references")
	quit()
