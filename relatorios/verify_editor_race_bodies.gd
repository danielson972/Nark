extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	var names := ["Humano","Elfo","Orc","Anao"]
	for gender in 2:
		for race in 4:
			var group: String = names[race]+("Masculino" if gender == 0 else "Feminino")
			var body: Sprite2D = scene.get_node("Cabelos/"+group+"/BaseCareca")
			assert(body.visible and body.texture.get_size() == Vector2(256,512))
			assert(body.texture.resource_path.ends_with(names[race].to_lower()+"_"+("masculino" if gender == 0 else "feminino")+".png"))
	assert(not scene.find_child("BaseCarecaEditor",true,false).visible)
	root.add_child(scene)
	for i in 3: await process_frame
	for group in scene.get_node("Cabelos").get_children():
		assert(not group.get_node("BaseCareca").visible)
	print("EDITOR_RACE_BASES_OK: eight editable Sprite2D bodies with correct atlas regions; no duplicated runtime bodies")
	quit()
