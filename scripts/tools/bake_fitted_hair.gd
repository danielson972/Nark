extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256,384)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var metadata: Dictionary = {}
	for gender in ["masculino","feminino"]:
		for race in Custom.RACES:
			var atlas := Image.create(1024,1536,false,Image.FORMAT_RGBA8)
			atlas.fill(Color.TRANSPARENT)
			var bounds: Array = []
			for style in range(1,17):
				var state := PlayerState.create("Bake",race,"guerreiro")
				state.gender_id = gender
				state.unequip("armadura")
				state.set_hair(style,"castanho")
				var parts = load("res://scripts/tools/hair_fitting_source.gd").new()
				viewport.add_child(parts)
				parts.configure(state,Vector2(0,32),Vector2.ONE)
				parts.hair.material.set_shader_parameter("bake_source",true)
				for i in 3: await process_frame
				await RenderingServer.frame_post_draw
				var frame := viewport.get_texture().get_image()
				var rect := frame.get_used_rect()
				assert(rect.size.x > 0 and rect.position.x > 0 and rect.end.x < 256 and rect.position.y > 0 and rect.end.y < 384, "Fitted hair must not touch frame edges")
				atlas.blit_rect(frame,Rect2i(0,0,256,384),Vector2i((style-1)%4*256,(style-1)/4*384))
				bounds.append([rect.position.x,rect.position.y,rect.size.x,rect.size.y])
				parts.head.queue_free()
				parts.queue_free()
				await process_frame
			var key: String = race+"_"+gender
			atlas.save_png("res://assets/game/character_builder/fitted_"+key+".png")
			metadata[key] = bounds
	var f := FileAccess.open("res://assets/game/character_builder/fitted_layout.gd",FileAccess.WRITE)
	f.store_string("extends RefCounted\nconst RECTS = "+JSON.stringify(metadata)+"\n")
	print("FITTED_HAIR_BAKE_OK: eight transparent atlases, 128 fitted hairstyles, no clipped frame edges")
	quit()
