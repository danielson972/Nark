extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func own_nodes(node: Node, scene: Node) -> void:
	for child in node.get_children():
		child.owner = scene
		if child != scene.preview:
			own_nodes(child,scene)
func mark(node: Node, title: String, scene: Node) -> void:
	node.name = title
	node.owner = scene
	node.unique_name_in_owner = true
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	own_nodes(scene,scene)
	mark(scene.preview,"Personagem",scene)
	mark(scene.name_field,"Nome",scene)
	mark(scene.summary,"Resumo",scene)
	mark(scene.race_description,"DescricaoRaca",scene)
	mark(scene.class_description,"DescricaoClasse",scene)
	for id in scene.gender_buttons: mark(scene.gender_buttons[id],"Modelo_"+id,scene)
	for id in scene.race_buttons: mark(scene.race_buttons[id],"Raca_"+id,scene)
	for id in scene.class_buttons: mark(scene.class_buttons[id],"Classe_"+id,scene)
	var back = scene.find_children("*","Button",true,false).filter(func(button): return button.text == "Voltar")[0]
	mark(back,"Voltar",scene)
	var start = scene.find_child("Concluir",true,false)
	mark(start,"Concluir",scene)
	var editor_preview := TextureRect.new()
	editor_preview.name = "BaseCarecaEditor"
	editor_preview.texture = load("res://scripts/actors/character_customization.gd").bald_body("humano")
	editor_preview.material = load("res://scripts/actors/hero_appearance.gd").cutout_material()
	editor_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	editor_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	editor_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	editor_preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	editor_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene.preview.add_child(editor_preview)
	editor_preview.owner = scene
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
	print("EDITABLE_CREATION_SCENE_SAVED")
	quit()
