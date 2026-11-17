extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	for gender in ["masculino","feminino"]:
		for race in Custom.RACES:
			var stage := Node2D.new()
			root.add_child(stage)
			var bg := ColorRect.new()
			bg.size = Vector2(1280,960)
			bg.color = Color("1b1711")
			stage.add_child(bg)
			for i in 16:
				var state := PlayerState.create("Teste",race,"guerreiro")
				state.gender_id = gender
				state.unequip("armadura")
				state.set_hair(i+1,"castanho")
				var base := Custom.bald_body(race,gender)
				var offset := Vector2(0,55 if race == "anao" and gender == "masculino" else 0)
				var texture := AtlasTexture.new()
				texture.atlas = base.atlas
				texture.region = Rect2(base.region.position+offset,Vector2(256,180))
				var sprite := Sprite2D.new()
				sprite.centered = false
				sprite.texture = texture
				sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				sprite.material = load("res://scripts/actors/hero_appearance.gd").cutout_material()
				sprite.position = Vector2(i%4*320+32,i/4*240+24)
				stage.add_child(sprite)
				var parts = load("res://scripts/actors/character_parts.gd").new()
				stage.add_child(parts)
				parts.configure(state,sprite.position-offset,Vector2.ONE)
				var label := Label.new()
				label.text = "%02d" % (i+1)
				label.position = Vector2(i%4*320+145,i/4*240+214)
				stage.add_child(label)
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://relatorios/hair-fit-%s-%s.png" % [race,gender])
			stage.queue_free()
			await process_frame
	print("HAIR_FIT_RENDER_OK: 128 race/model/style previews")
	quit()
