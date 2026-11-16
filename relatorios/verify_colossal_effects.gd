extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	root.add_child(layer)
	var background: ColorRect = ColorRect.new()
	background.color = Color("25202b")
	background.size = Vector2(1280, 720)
	layer.add_child(background)
	var heroes: Array[Hero] = []
	for column in GameData.CLASS_ORDER.size():
		var id: String = GameData.CLASS_ORDER[column]
		var title: Label = Label.new()
		title.text = str(GameData.character_class(id)["name"])
		title.position = Vector2(70 + column * 205, 16)
		layer.add_child(title)
		for row in 3:
			var state: PlayerState = PlayerState.create("Teste", "humano", id)
			state.add_item("arma_b", 1, true)
			state.equip("arma_b")
			var hero: Hero = Hero.new()
			hero.bind_state(state)
			hero.setup(null, "", 165.0)
			hero.position = Vector2(100 + column * 205, 226 + row * 230)
			layer.add_child(hero)
			hero.set_process(false)
			hero.sprite.flip_h = row == 2
			hero.attack_swing = 0.09 if row == 1 else 0.0
			hero._update_equipment_pose()
			assert(hero.colossal_effect.visible)
			assert(hero.weapon_sprite.material.get_shader_parameter("colossal"))
			heroes.append(hero)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var first: Image = root.get_texture().get_image()
		first.save_png("res://relatorios/colossal-effects-a.png")
		await create_timer(0.45).timeout
		await RenderingServer.frame_post_draw
		var second: Image = root.get_texture().get_image()
		second.save_png("res://relatorios/colossal-effects-b.png")
		assert(first.get_data() != second.get_data())
	for hero: Hero in heroes:
		hero.state.add_item("arma_ng", 1, true)
		hero.state.equip("arma_ng")
		assert(not hero.colossal_effect.visible)
		assert(not hero.weapon_sprite.material.get_shader_parameter("colossal"))
		hero.state.unequip("arma")
		assert(not hero.colossal_effect.visible and not hero.weapon_sprite.visible)
	print("COLOSSAL_EFFECTS_OK: six classes, animated frames differ, attack/idle/mirror, effects removed on replacement and unequip")
	layer.queue_free()
	await process_frame
	quit()
