extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano","guerreiro","Render")
	game.world.set_paused(true)
	var hero: Hero = game.world.hero
	var camera_zoom: Vector2 = game.world.camera.zoom
	var checked: int = 0
	for gender: String in ["masculino","feminino"]:
		for race: String in ["humano","elfo","orc","anao"]:
			for job: String in GameData.CLASS_ORDER:
				var state := PlayerState.create("Render",race,job)
				state.gender_id = gender
				state.set_hair(1,"castanho")
				state.set_beard(1)
				hero.bind_state(state)
				for armor: String in ["roupa_basica","armadura_d","armadura_catalogo_100"]:
					state.add_item(armor,1,true)
					assert(state.equip(armor).is_empty())
					hero.refresh_appearance()
					var ui_body: ShaderMaterial = Appearance.body_material(state)
					assert(hero.sprite.material != ui_body)
					assert(hero.sprite.material.get_shader_parameter("world_antialiasing") == true)
					assert(ui_body.get_shader_parameter("world_antialiasing") != true,"World rendering must not mutate creation/inventory materials")
					assert(hero.sprite.material.get_shader_parameter("texture_region") == ui_body.get_shader_parameter("texture_region"))
					assert(hero.character_parts.world_antialiasing)
					for layer: Sprite2D in [hero.character_parts.head,hero.character_parts.hair,hero.character_parts.beard]:
						assert(layer.material.get_shader_parameter("world_antialiasing") == true)
					if race in ["elfo","orc"]:
						assert(hero.character_parts.ear.material.get_shader_parameter("world_antialiasing") == true)
					if race == "orc":
						assert(hero.character_parts.tooth.material.get_shader_parameter("world_antialiasing") == true)
					var ui_weapon: ShaderMaterial = Appearance.weapon_material(state,hero.weapon_sprite.texture)
					assert(hero.weapon_sprite.material != ui_weapon and ui_weapon.get_shader_parameter("world_antialiasing") != true)
					assert(hero.weapon_sprite.material.get_shader_parameter("world_antialiasing") == true)
					var expected_height: float = 92.0*(.85 if race == "anao" else 1.0)
					assert(is_equal_approx(hero.base_scale*512.0*(Appearance.FOOT_Y-Appearance.HEAD_Y),expected_height))
					for direction: Vector2 in [Vector2.LEFT,Vector2.RIGHT]:
						hero.facing = direction
						hero.velocity = direction*100
						hero._update_hero_animation(1.0/60.0)
						hero._update_equipment_pose()
						assert(hero.character_parts.hair.flip_h == hero.sprite.flip_h)
						assert(hero.character_parts.beard.flip_h == hero.sprite.flip_h)
					checked += 1
	assert(game.world.camera.zoom == camera_zoom)
	game.queue_free()
	await process_frame
	print("WORLD_HERO_RENDERING_OK: %d race/model/class/outfit variants; filtered body, head, weapon, hair, beard, ears/tusks; isolated UI materials; preserved world size, camera and mirrored attachments" % checked)
	quit()
