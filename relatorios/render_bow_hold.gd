extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	root.add_child(layer)
	var background: ColorRect = ColorRect.new()
	background.color = Color("3c352c")
	background.size = Vector2(1280, 720)
	layer.add_child(background)
	var swords: Array = ["arma_basica", "arma_ng", "arma_d", "arma_c", "arma_b"]
	for column in swords.size():
		var title: Label = Label.new()
		title.text = ["Treino", "Bronze", "Aço", "Runas", "Colosso"][column]
		title.position = Vector2(175 + column * 230, 16)
		layer.add_child(title)
		for row in 3:
			var state: PlayerState = PlayerState.create("Teste", "humano", "atirador")
			state.add_item(swords[column], 1, true)
			state.equip(swords[column])
			var hero: Hero = Hero.new()
			hero.bind_state(state)
			hero.setup(null, "", 178.0)
			hero.position = Vector2(190 + column * 230, 229 + row * 230)
			layer.add_child(hero)
			hero.set_process(false)
			hero.sprite.flip_h = row == 2
			hero.facing = Vector2.UP
			hero.attack_swing = 0.09 if row == 1 else 0.0
			hero._update_equipment_pose()
	for row in 3:
		var caption: Label = Label.new()
		caption.text = ["Parado", "Atacando", "Virado"][row]
		caption.position = Vector2(10, 120 + row * 230)
		layer.add_child(caption)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/bow-hold-closeup.png")
	print("BOW_HOLD_RENDER_OK: five bows, visible fingers, idle, attack and mirrored poses")
	layer.queue_free()
	await process_frame
	quit()
