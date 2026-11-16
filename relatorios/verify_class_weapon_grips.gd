extends SceneTree

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const WEAPONS = ["arma_basica", "arma_ng", "arma_d", "arma_c", "arma_b", "arsenal_001", "arsenal_016", "arsenal_031", "arsenal_046", "arsenal_061", "arsenal_076", "arsenal_089"]
const ARMORS = ["", "roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var checks: int = 0
	for class_id: String in GameData.CLASS_ORDER:
		var state: PlayerState = PlayerState.create("Grip test", "humano", class_id)
		var hero: Hero = Hero.new()
		hero.bind_state(state)
		hero.setup(null, "", 92.0)
		root.add_child(hero)
		hero.set_process(false)
		for armor: String in ARMORS:
			state.unequip("armadura")
			if not armor.is_empty():
				state.add_item(armor, 1, true)
				state.equip(armor)
			for weapon: String in WEAPONS:
				state.add_item(weapon, 1, true)
				state.equip(weapon)
				for mirrored: bool in [false, true]:
					for swing: float in [0.0, 0.045, 0.09, 0.135, 0.18]:
						hero.sprite.flip_h = mirrored
						hero.attack_swing = swing
						hero._update_equipment_pose()
						var pivot: Vector2 = Appearance.weapon_pivot(class_id, weapon)
						var grip: Vector2 = (pivot - Vector2.ONE * 0.5) * hero.weapon_sprite.texture.get_size()
						if mirrored:
							grip.x *= -1.0
						grip += hero.weapon_sprite.offset
						var hand: Vector2 = hero.sprite.to_global(hero.weapon_sprite.position)
						assert(hero.weapon_sprite.to_global(grip).distance_to(hand) < 0.001)
						assert(hero.grip_hand_sprite.visible)
						assert(hero.grip_hand_sprite.to_global(Vector2.ZERO).distance_to(hand) < 0.001)
						assert(hero.grip_hand_sprite.flip_h == mirrored)
						assert(hero.grip_hand_sprite.z_index > hero.weapon_sprite.z_index)
						checks += 1
		hero.queue_free()
	await process_frame
	print("CLASS_WEAPON_GRIPS_OK: %d poses, 6 classes, 5 weapons, 6 outfits, both directions and 5 attack phases" % checks)
	quit()

