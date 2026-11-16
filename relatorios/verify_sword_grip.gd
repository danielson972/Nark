extends SceneTree

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const IconArt = preload("res://scripts/ui/item_catalog.gd")
const SWORDS = ["arma_basica", "arma_ng", "arma_d", "arma_c", "arma_b"]
const OUTFITS = ["", "roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	root.add_child(layer)
	var background: ColorRect = ColorRect.new()
	background.color = Color("201d1b")
	background.size = Vector2(1280, 720)
	layer.add_child(background)
	var checks: int = 0
	for column in SWORDS.size():
		var heading: Label = Label.new()
		heading.text = ["Treino", "Bronze", "Aço", "Runas", "Colosso"][column]
		heading.position = Vector2(150 + column * 230, 12)
		layer.add_child(heading)
		for row in OUTFITS.size():
			var state: PlayerState = PlayerState.create("Teste", "humano", "guerreiro")
			state.unequip("armadura")
			if not OUTFITS[row].is_empty():
				state.add_item(OUTFITS[row], 1, true)
				state.equip(OUTFITS[row])
			state.add_item(SWORDS[column], 1, true)
			state.equip(SWORDS[column])
			var hero: Hero = Hero.new()
			hero.bind_state(state)
			hero.setup(null, "", 92.0)
			layer.add_child(hero)
			hero.set_process(false)
			for mirrored: bool in [false, true]:
				hero.facing = Vector2.UP if mirrored else Vector2.DOWN
				for swing: float in [0.0, 0.045, 0.09, 0.135, 0.18]:
					hero.sprite.flip_h = mirrored
					hero.attack_swing = swing
					hero._update_equipment_pose()
					# An upward mouse attack must not put the weapon behind the legs.
					assert(hero.weapon_sprite.z_index > hero.sprite.z_index)
					var pivot: Vector2 = Appearance.weapon_pivot("guerreiro", SWORDS[column])
					var grip: Vector2 = (pivot - Vector2.ONE * 0.5) * hero.weapon_sprite.texture.get_size()
					if mirrored:
						grip.x = -grip.x
					grip += hero.weapon_sprite.offset
					var hand: Vector2 = hero.sprite.to_global(hero.weapon_sprite.position)
					# The actual hilt stays fixed to the hand through rotation and reflection.
					assert(hero.weapon_sprite.to_global(grip).distance_to(hand) < 0.001)
					checks += 1
			hero.sprite.flip_h = row >= 3
			hero.attack_swing = 0.09 if row == 2 or row == 5 else 0.0
			hero._update_equipment_pose()
			hero.position = Vector2(165 + column * 230, 142 + row * 108)
		var isolated: TextureRect = TextureRect.new()
		isolated.texture = IconArt.texture_for(SWORDS[column], "guerreiro")
		isolated.position = Vector2(20 + column * 230, 53)
		isolated.size = Vector2(80, 80)
		isolated.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		isolated.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		isolated.size = Vector2(80, 80)
		isolated.material = Appearance.cutout_material()
		layer.add_child(isolated)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/sword-grip-gallery.png")
	print("SWORD_GRIP_OK: %d hilt attachments across 5 swords, 6 outfits, both directions and attack phases" % checks)
	layer.queue_free()
	await process_frame
	quit()
