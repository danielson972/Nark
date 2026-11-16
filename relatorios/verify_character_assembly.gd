extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
const Appearance = preload("res://scripts/actors/hero_appearance.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bodies: Dictionary = {}
	var combinations: int = 0
	for gender_id: String in ["masculino", "feminino"]:
		for race_id: String in GameData.RACE_ORDER:
			for class_id: String in GameData.CLASS_ORDER:
				var state := PlayerState.create("Montagem", race_id, class_id)
				state.gender_id = gender_id
				assert(state.hair_style == 0, "Every new character starts bald")
				var hero = load("res://scenes/hero.tscn").instantiate()
				hero.bind_state(state)
				hero.setup(null, "", 92.0)
				for armor: String in ["", "roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]:
					state.unequip("armadura")
					if not armor.is_empty():
						state.add_item(armor, 1, true)
						assert(state.equip(armor).is_empty())
					assert(hero.sprite.texture == Appearance.body_texture(state))
					assert(hero.grip_hand_sprite.texture.atlas == hero.sprite.texture.atlas)
					var hand: Rect2 = Appearance.hand_rect(state)
					assert(hero.grip_hand_sprite.texture.region == Rect2(hero.sprite.texture.region.position + hand.position * hero.sprite.texture.region.size, hand.size * hero.sprite.texture.region.size))
					assert(hero.character_parts.head.visible == Custom.armored(state))
					var stats := [state.max_hp(), state.damage_power(), state.defense_power(), state.move_speed()]
					state.set_hair(10, "loiro")
					assert(hero.character_parts.hair.visible and hero.character_parts.hair.material.get_shader_parameter("face_mask_enabled"))
					assert(stats == [state.max_hp(), state.damage_power(), state.defense_power(), state.move_speed()])
					var loaded := PlayerState.new()
					loaded.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
					assert(loaded.hair_style == 10 and loaded.hair_color == "loiro" and loaded.gender_id == gender_id and loaded.race_id == race_id)
					assert(loaded.equipment == state.equipment)
					state.set_hair(0, "castanho")
					assert(not hero.character_parts.hair.visible)
					combinations += 1
				bodies[str(Custom.bald_body(race_id, gender_id).region)] = true
				for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT]:
					hero.facing = direction
					hero._update_hero_animation(0.1)
					assert(hero.sprite.flip_h == (direction.x > 0.0))
				hero.free()
	assert(bodies.size() == 8, "Each race and model needs its own body")
	for style in range(1, 17):
		var texture: AtlasTexture = Custom.hair_texture(style)
		assert(texture != null and texture.region.size.x > 100 and texture.region.size.y > 100)
	var old := PlayerState.create("Anterior", "humano", "guerreiro").to_dict()
	old.erase("hair_style")
	old.erase("hair_color")
	old.erase("gender_id")
	var legacy := PlayerState.new()
	legacy.from_dict(old)
	assert(legacy.hair_style == 0 and legacy.gender_id == "masculino")
	legacy.set_hair(999, "inválida")
	assert(legacy.hair_style == 16 and legacy.hair_color == "castanho")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.ui.show_creation()
	await process_frame
	var scene = game.ui.overlay.get_child(game.ui.overlay.get_child_count() - 1)
	assert(scene.hair_style == 0 and scene.hair_buttons.size() == 17)
	scene.name_field.text = "Luna"
	scene.select_gender("feminino")
	scene.select_race("orc")
	scene.select_class("mago")
	scene.select_hair(12)
	scene.select_color("ruivo")
	assert(scene.name_field.text == "Luna", "Changing choices must preserve the entered name")
	scene.submit()
	for tick in 4: await process_frame
	assert(game.state.hero_name == "Luna" and game.state.gender_id == "feminino" and game.state.race_id == "orc")
	assert(game.state.hair_style == 12 and game.state.hair_color == "ruivo")
	assert(game.world.hero.character_parts.hair.visible)
	assert(game.world.hero.character_parts.head.get_parent() == game.world.hero.sprite)
	game._open_panel("inventory")
	for tick in 4: await process_frame
	var portraits: Array = game.ui.inventory_view.find_children("*", "Control", true, false)
	var found: bool = false
	for portrait in portraits:
		if portrait.get_script() == load("res://scripts/ui/hero_preview.gd"):
			assert(portrait.state == game.state)
			found = true
	assert(found, "Inventory must use the customized character state")
	game.queue_free()
	await process_frame
	print("CHARACTER_ASSEMBLY_OK: %d race/model/class/outfit combinations, 16 hairs, bald default, stats, legacy/JSON saves, mirroring, full creation flow and inventory" % combinations)
	quit()
