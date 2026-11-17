extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	var bg := ColorRect.new()
	bg.size = Vector2(1280,960)
	bg.color = Color("1b1711")
	root.add_child(bg)
	var attachments: Array = []
	for i in 16:
		var state := PlayerState.create("Teste","humano","guerreiro")
		state.unequip("armadura")
		state.set_hair(i+1,"castanho")
		var base = load("res://scripts/actors/character_customization.gd").bald_body("humano")
		var texture := AtlasTexture.new()
		texture.atlas = base.atlas
		texture.region = Rect2(base.region.position,Vector2(256,180))
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.material = load("res://scripts/actors/hero_appearance.gd").cutout_material()
		sprite.position = Vector2(i%4*320+32,i/4*240+24)
		root.add_child(sprite)
		var parts = load("res://scripts/actors/character_parts.gd").new()
		root.add_child(parts)
		parts.configure(state,sprite.position,Vector2.ONE)
		attachments.append(parts)
		var label := Label.new()
		label.text = "%02d" % (i+1)
		label.position = Vector2(i%4*320+145,i/4*240+214)
		root.add_child(label)
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	var masked := root.get_texture().get_image()
	masked.save_png("res://relatorios/hair-fringes-fixed.png")
	for parts in attachments:
		parts.hair.material.set_shader_parameter("face_mask_enabled", false)
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var unmasked := root.get_texture().get_image()
	for i in 16:
		var origin := Vector2i(i%4*320+32,i/4*240+24)
		for y in range(49, 60):
			for x in range(88, 149):
				var pixel := origin + Vector2i(x,y)
				assert(masked.get_pixelv(pixel) == unmasked.get_pixelv(pixel), "Mask must preserve forehead and fringe pixels")
	print("FRINGE_RENDER_OK: 16 styles retain every forehead pixel with masking enabled")
	quit()
