extends SceneTree

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ARMORS = ["", "roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tested: int = 0
	for race: String in GameData.RACES:
		for job: String in GameData.CLASS_ORDER:
			var state := PlayerState.create("Humano", race, job)
			var hero = load("res://scenes/hero.tscn").instantiate()
			root.add_child(hero)
			hero.bind_state(state)
			hero.setup(null, "", 92.0)
			hero.set_process(false)
			for armor: String in ARMORS:
				state.unequip("armadura")
				if not armor.is_empty():
					state.add_item(armor, 1, true)
					assert(state.equip(armor).is_empty())
				var body: AtlasTexture = hero.sprite.texture
				assert(body == Appearance.body_texture(state))
				if race == "humano":
					assert(body.get_size() == Vector2(256, 512))
					assert(is_equal_approx(hero.sprite.scale.y * body.get_height() * (Appearance.FOOT_Y - Appearance.HEAD_Y), 92.0))
					assert(body.get_image().get_pixel(0,0).a < 0.1)
				assert(hero.weapon_sprite.visible and hero.grip_hand_sprite.texture != null)
				assert(hero.grip_hand_sprite.texture.atlas == body.atlas, "Hand patch cache must not mix old and new race atlases")
				tested += 1
			for direction: Vector2 in [Vector2.RIGHT, Vector2.LEFT]:
				hero.facing = direction
				hero.velocity = direction * 100.0
				hero._update_hero_animation(0.1)
				assert(hero.sprite.flip_h == (direction.x > 0.0))
			state.add_item("hero", 1, true)
			assert(state.equip("hero").is_empty())
			assert(hero.aura_effect.visible)
			var saved := state.to_dict()
			var loaded := PlayerState.new()
			loaded.from_dict(saved)
			assert(loaded.equipment == state.equipment and loaded.race_id == race)
			assert(Appearance.body_texture(loaded) == Appearance.body_texture(state))
			hero.queue_free()
			await process_frame
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Humano")
	game._open_panel("inventory")
	await process_frame
	assert(game.world.hero.sprite.texture == Appearance.Custom.bald_body("humano"))
	game.queue_free()
	await process_frame
	print("HUMAN_APPEARANCE_OK: %d race/class/outfit combinations, modular racial bodies, hand cache, facing, Hero aura, saves and inventory" % tested)
	quit()
