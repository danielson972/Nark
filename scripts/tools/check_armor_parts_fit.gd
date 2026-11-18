extends Node

const Layers = preload("res://scripts/actors/armor_layer_catalog.gd")
const Preview = preload("res://scripts/ui/hero_preview.gd")

func _ready() -> void:
	check.call_deferred()

func check() -> void:
	get_window().size = Vector2i(1600, 1000)
	get_window().content_scale_size = Vector2i(1600, 1000)
	var background := ColorRect.new()
	background.color = Color("101410")
	background.size = Vector2(1600, 1000)
	add_child(background)
	for number: int in range(1, 101):
		var state := PlayerState.create("Teste", "humano", "guerreiro")
		for slot: String in GameData.ARMOR_PARTS:
			var id: String = "armadura_catalogo_%03d_%s" % [number, slot]
			state.add_item(id, 1, true)
			assert(state.equip(id).is_empty())
		var assembled: Node2D = Layers.instantiate(state)
		var source: Node2D = load("res://scenes/armor_parts/catalogo/armadura_%03d.tscn" % number).instantiate()
		for name: String in ["Peito", "Luvas", "Calca", "Botas"]:
			assert(assembled.get_node(name).transform == source.get_node(name).transform, "%03d:%s" % [number, name])
		assembled.free()
		source.free()
	for index: int in range(20):
		var basic_test: bool = "--basic" in OS.get_cmdline_user_args()
		var number: int = [1, 7, 21, 31, 51, 81, 99, 100][index % 8]
		var race: String = "humano" if index < 8 else ["humano", "elfo", "orc", "anao"][(index - 8) / 2 % 4]
		if basic_test: race = ["humano", "elfo", "orc", "anao"][index / 2 % 4]
		var state := PlayerState.create("Teste", race, "guerreiro")
		if (index >= 8 or basic_test) and index % 2 == 1: state.gender_id = "feminino"
		for slot: String in GameData.ARMOR_PARTS:
			if basic_test and (index < 8 or (index < 16 and slot != "luvas")): continue
			if index == 19 and slot == "peito": continue
			var piece_number: int = number if index < 16 or slot == "peito" else [1, 7, 21, 31, 81][GameData.ARMOR_PARTS.keys().find(slot)]
			var id: String = "armadura_catalogo_%03d_%s" % [piece_number, slot]
			state.add_item(id, 1, true)
			state.equip(id)
		var preview: Control = Preview.new()
		preview.state = state
		preview.position = Vector2(index % 10 * 160, index / 10 * 500 + 20)
		preview.size = Vector2(160, 450)
		add_child(preview)
		var label := Label.new()
		label.text = "%03d · %s" % [number, race]
		if index >= 16: label.text = "Misto · %s" % race
		if basic_test: label.text = "%s · %s" % [race, "Base" if index < 8 else "Luvas" if index < 16 else "Misto"]
		label.position = preview.position + Vector2(20, 450)
		add_child(label)
		# Exercise the world renderer with the same equipment, including mirroring.
		var hero := Hero.new()
		hero.bind_state(state)
		hero.setup(null, "", 150.0)
		hero.set_physics_process(false)
		add_child(hero)
		hero.hide()
		assert(hero.armor_parts != null)
		hero.sprite.flip_h = true
		hero._update_equipment_pose()
		assert(hero.armor_parts.scale.x < 0.0)
		for hand in hero.armor_parts.get_node("Luvas").get_children():
			if hand is Sprite2D: assert(is_equal_approx(hand.scale.x, hand.scale.y))
	await get_tree().process_frame
	await get_tree().process_frame
	if not "--headless" in OS.get_cmdline_args():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.runtime/armor-basic-fit.png" if "--basic" in OS.get_cmdline_user_args() else "res://.runtime/armor-fit.png")
		if "--closeup" in OS.get_cmdline_user_args():
			for child in get_children():
				if child is CanvasItem: child.hide()
			var state := PlayerState.create("Aurora", "humano", "guerreiro")
			for slot: String in GameData.ARMOR_PARTS:
				var id: String = "armadura_catalogo_001_%s" % slot
				state.add_item(id, 1, true)
				state.equip(id)
			var ui := GameUI.new()
			add_child(ui)
			ui.state = state
			ui.show_armor_parts_inventory()
			await get_tree().process_frame
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.runtime/armor-hand-closeup.png")
	print("PASS: 100 complete sets retain original part transforms")
	get_tree().quit()
