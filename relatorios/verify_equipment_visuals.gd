extends SceneTree

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ARMORS = ["", "roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
const WEAPONS = ["", "arma_basica", "arma_ng", "arma_d", "arma_c", "arma_b"]
var combinations: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _wear(state: PlayerState, slot: String, id: String) -> void:
	if id.is_empty():
		state.unequip(slot)
	else:
		state.add_item(id, 1, true)
		assert(state.equip(id).is_empty())

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Equipamentos")
	game.world.set_paused(true)
	var hero: Hero = game.world.hero
	for class_id: String in GameData.CLASS_ORDER:
		game.state.class_id = class_id
		for armor: String in ARMORS:
			for weapon: String in WEAPONS:
				_wear(game.state, "armadura", armor)
				_wear(game.state, "arma", weapon)
				# Changing equipment updates visuals immediately via the state signal.
				var frame: AtlasTexture = hero.sprite.texture
				assert(frame == Appearance.body_texture(game.state))
				assert(hero.weapon_sprite.visible == not weapon.is_empty())
				assert(hero.grip_hand_sprite.visible == (not weapon.is_empty()))
				if hero.grip_hand_sprite.visible:
					assert(hero.grip_hand_sprite.z_index > hero.weapon_sprite.z_index)
				assert((hero.weapon_sprite.texture == null) == weapon.is_empty())
				assert(hero.hp <= game.state.max_hp())
				if weapon.is_empty():
					assert(game.state.attack_range() == 52.0)
				else:
					assert(game.state.attack_range() == float(game.state.class_data()["range"]))
				combinations += 1
		_wear(game.state, "armadura", "roupa_basica")
		_wear(game.state, "arma", "arma_basica")
		var right: Vector2 = hero.weapon_sprite.position
		hero.sprite.flip_h = true
		hero._update_equipment_pose()
		assert(is_equal_approx(hero.weapon_sprite.position.x, -right.x))
		assert(hero.weapon_sprite.flip_h)
		hero.sprite.flip_h = false
		hero._update_equipment_pose()
		var loaded: PlayerState = PlayerState.new()
		loaded.from_dict(game.state.to_dict())
		assert(loaded.equipment == game.state.equipment)
		var starter: PlayerState = PlayerState.create("Teste", "humano", class_id)
		assert(starter.equipment["armadura"]["id"] == "roupa_basica")
		assert(starter.equipment["arma"]["id"] == "arma_basica")
		# Exercise both real inventory actions, including the remove path.
		game.ui.show_inventory_panel()
		await process_frame
		game._on_panel_action("unequip", {"slot": "arma"})
		assert(not hero.weapon_sprite.visible)
		game._on_panel_action("unequip", {"slot": "armadura"})
		assert(hero.sprite.texture == Appearance.Custom.bald_body("humano"))
		game._on_panel_action("equip", {"id": "roupa_basica"})
		game._on_panel_action("equip", {"id": "arma_basica"})
		assert(hero.weapon_sprite.visible)
		assert(hero.sprite.texture == Appearance.Custom.bald_body("humano"))
		await process_frame
	# An old save with the old starter IDs retains its equipment and renders it.
	_wear(game.state, "armadura", "armadura_ng")
	_wear(game.state, "arma", "arma_ng")
	var legacy: PlayerState = PlayerState.new()
	legacy.from_dict(game.state.to_dict())
	assert(legacy.equipment["armadura"]["id"] == "armadura_ng")
	assert(Appearance.body_texture(legacy) == Appearance.human_frame(legacy.class_id, 2))
	game.state.class_id = "guerreiro"
	_wear(game.state, "armadura", "roupa_basica")
	_wear(game.state, "arma", "arma_basica")
	game.state.inventory.clear()
	for id: String in GameData.ITEMS:
		game.state.add_item(id, 1, true)
	game.ui.toasts.hide()
	game.ui.show_inventory_panel()
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/equipment-inventory.png")
	game.ui.hide()
	game.world.hide()
	var layer: CanvasLayer = CanvasLayer.new()
	root.add_child(layer)
	var background: ColorRect = ColorRect.new()
	background.color = Color("1c1918")
	background.size = Vector2(1280, 720)
	layer.add_child(background)
	var headings: Array = ["Sem itens", "Só roupa básica", "Kit inicial", "Só arma", "Couro · NG", "Aço · D", "Runas · C", "Colosso · B"]
	var outfits: Array = ["", "roupa_basica", "roupa_basica", "", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
	var weapons: Array = ["", "", "arma_basica", "arma_ng", "arma_ng", "arma_d", "arma_c", "arma_b"]
	for column in 8:
		var heading: Label = Label.new()
		heading.text = headings[column]
		heading.position = Vector2(145 + column * 138, 16)
		heading.add_theme_font_size_override("font_size", 14)
		layer.add_child(heading)
	for row in 6:
		var class_id: String = GameData.CLASS_ORDER[row]
		var caption: Label = Label.new()
		caption.text = str(GameData.character_class(class_id)["name"])
		caption.position = Vector2(16, 85 + row * 104)
		layer.add_child(caption)
		for column in 8:
			var state: PlayerState = PlayerState.create("Teste", "humano", class_id)
			_wear(state, "armadura", outfits[column])
			_wear(state, "arma", weapons[column])
			var mannequin: Hero = Hero.new()
			mannequin.bind_state(state)
			mannequin.setup(null, "", 92.0)
			mannequin.position = Vector2(183 + column * 138, 143 + row * 104)
			layer.add_child(mannequin)
			mannequin.set_process(false)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/equipment-visual-gallery.png")
	print("EQUIPMENT_VISUALS_OK: %d combinations, 6 classes, starters, remove/equip UI, independent weapons, mirroring and save compatibility" % combinations)
	game.queue_free()
	layer.queue_free()
	await process_frame
	quit()
