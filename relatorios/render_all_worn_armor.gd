extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1500,1100)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	for batch in 10:
		var stage := Node2D.new()
		root.add_child(stage)
		var bg := ColorRect.new()
		bg.size = Vector2(1500,1100)
		bg.color = Color("1b1711")
		stage.add_child(bg)
		for index in 10:
			var id := "armadura_catalogo_%03d" % (batch*10+index+1)
			var state := PlayerState.create("Armadura","humano","guerreiro")
			state.unequip("armadura")
			state.unequip("arma")
			state.add_item(id,1,true)
			assert(state.equip(id).is_empty())
			state.set_hair(1,"castanho",false)
			state.add_item("arma_basica",1,true)
			state.equip("arma_basica")
			var preview = load("res://scripts/ui/hero_preview.gd").new()
			preview.state = state
			preview.position = Vector2(index%5*300, index/5*550+36)
			preview.size = Vector2(300,510)
			stage.add_child(preview)
			var label := Label.new()
			label.text = "%03d · %s" % [batch*10+index+1,GameData.item(id).name]
			label.position = Vector2(index%5*300+16, index/5*550+10)
			stage.add_child(label)
		for i in 4: await process_frame
		await RenderingServer.frame_post_draw
		var first: int = batch*10+1
		root.get_texture().get_image().save_png("res://relatorios/worn-armors-%03d-%03d.png" % [first,first+9])
		stage.queue_free()
		await process_frame
	print("ALL_WORN_RENDER_OK: 100 outfits, ten in-engine contact sheets with weapons")
	quit()
