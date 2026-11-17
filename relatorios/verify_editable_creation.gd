extends SceneTree
var submitted_args: Array = []
var back_seen := false
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	assert(scene.find_child("PainelIdentidade",true,false) != null)
	assert(scene.find_child("BaseCarecaEditor",true,false) != null)
	var count: int = scene.find_children("*","Button",true,false).size()
	assert(count == 14, "All 14 buttons must exist in the saved scene")
	root.add_child(scene)
	await process_frame
	assert(scene.find_children("*","Button",true,false).size() == count, "Ready must not create UI")
	scene.name_field.text = "Luna"
	scene.name_field.text_changed.emit("Luna")
	scene.gender_buttons.feminino.pressed.emit()
	scene.race_buttons.orc.pressed.emit()
	scene.class_buttons.mago.pressed.emit()
	assert(scene.preview.state.gender_id == "feminino" and scene.preview.state.race_id == "orc" and scene.preview.state.class_id == "mago")
	assert(scene.preview.state.hair_style == 0)
	scene.submitted.connect(func(r,c,n,h,color,g): submitted_args = [r,c,n,h,color,g])
	scene.back_requested.connect(func(): back_seen = true)
	scene.get_node("%Concluir").pressed.emit()
	scene.get_node("%Voltar").pressed.emit()
	assert(submitted_args == ["orc","mago","Luna",0,"castanho","feminino"] and back_seen)
	for i in 3: await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/editable-character-creation.png")
	print("EDITABLE_CREATION_OK: saved UI nodes, 14 buttons, no duplicate UI, selection, submit and back")
	quit()
