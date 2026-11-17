extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var checked: int = 0
	for gender: String in ["masculino", "feminino"]:
		for race: String in GameData.RACE_ORDER:
			for job: String in GameData.CLASS_ORDER:
				var player := PlayerState.create("Proporções", race, job)
				player.gender_id = gender
				player.set_hair(1, "castanho")
				player.set_beard(1)
				var hero = load("res://scenes/hero.tscn").instantiate()
				hero.bind_state(player)
				hero.setup(null, "", 92.0)
				root.add_child(hero)
				await process_frame
				var base: Texture2D = Custom.bald_body(race, gender)
				assert(hero.sprite.texture == base)
				assert(player.equipment.armadura.id == "roupa_basica")
				assert(not hero.character_parts.head.visible)
				assert(Custom.head_destination(player) == Custom.head_rect(player))
				assert(Appearance.body_material(player).get_shader_parameter("head_cutoff") == 0.0)
				var outfit_stats: Array = [player.max_hp(), player.defense_power(), player.damage_power()]
				for hairstyle: int in [0, 1, 10, 12, 16]:
					player.set_hair(hairstyle, "castanho")
					var hair_position: Vector2 = hero.character_parts.hair.position
					var hair_scale: Vector2 = hero.character_parts.hair.scale
					player.unequip("armadura")
					assert(hero.sprite.texture == base)
					assert(hero.character_parts.hair.position == hair_position and hero.character_parts.hair.scale == hair_scale)
					assert(player.equip("roupa_basica").is_empty())
					assert(hero.sprite.texture == base and not hero.character_parts.head.visible)
					assert(hero.character_parts.hair.position == hair_position and hero.character_parts.hair.scale == hair_scale)
					assert([player.max_hp(), player.defense_power(), player.damage_power()] == outfit_stats)
				player.add_item("armadura_d", 1, true)
				assert(player.equip("armadura_d").is_empty())
				assert(hero.character_parts.head.visible and Custom.armored(player))
				assert(player.equip("roupa_basica").is_empty())
				assert(hero.sprite.texture == base and not hero.character_parts.head.visible)
				var loaded := PlayerState.new()
				loaded.from_dict(player.to_dict())
				assert(Appearance.body_texture(loaded) == base)
				hero.queue_free()
				await process_frame
				checked += 1
	print("STARTER_OUTFIT_OK: %d race/model/class variants, five hairstyles, stable body/head/hair, armor transitions, equipped bonuses and save round-trip" % checked)
	quit()
