extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var genders := ["masculino","feminino"]
	var races := ["humano","elfo","orc","anao"]
	for number in range(1,101):
		var state := PlayerState.create("Equipamento",races[(number-1)%4],"guerreiro")
		state.gender_id = genders[((number-1)/4)%2]
		var armor := "armadura_catalogo_%03d" % number
		state.add_item(armor,1,true)
		assert(state.equip(armor).is_empty())
		var weapon: String = "arsenal_001" if number%2 else "arsenal_089"
		state.add_item(weapon,1,true)
		assert(state.equip(weapon).is_empty())
		var hero = load("res://scenes/hero.tscn").instantiate()
		hero.bind_state(state)
		hero.setup(null,"",92.0)
		assert(hero.sprite.texture.atlas.resource_path.ends_with("armadura_%03d.png" % number))
		assert(hero.weapon_sprite.visible and hero.weapon_sprite.texture != null)
		assert(not hero.weapon_sprite.material.get_shader_parameter("trim_grip"))
		var grip: Vector2 = Appearance.hand_position(state)
		assert(grip.x > 0.1 and grip.x < 0.45 and grip.y > 0.4 and grip.y < 0.7)
		hero.free()
	print("ALL_WORN_WORLD_OK: 100 equips, eight race/sex profiles, swords, shields and calibrated grips")
	quit()
