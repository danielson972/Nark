extends SceneTree
const Design = preload("res://scripts/actors/nark_design.gd")
var failures: int = 0
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var count: int = 0
	for race: String in ["humano", "elfo", "orc", "anao", "elarim"]:
		for gender: String in ["masculino", "feminino"]:
			for body: String in ["magro", "medio", "forte"]:
				var state := PlayerState.create("Teste", race, "guerreiro")
				state.gender_id = gender
				state.body_type = body
				state.hair_style = 7
				state.beard_style = 3
				for row in 8:
					for frame in 6:
						check(Design.body(state, row, frame, true, true).get_size() == Vector2(64, 64), "Invalid frame")
						count += 1
				var restored := PlayerState.new()
				restored.from_dict(state.to_dict())
				check(restored.body_type == body and restored.race_id == race, "Appearance save failed")
	var player := PlayerState.create("Teste", "humano", "guerreiro")
	var pieces: int = 0
	for id: String in GameData.ITEMS:
		var data: Dictionary = GameData.item(id)
		if not data.has("sprite_path"): continue
		check(Design.icon(id, player.class_id) != null, "Missing icon: " + id)
		player.add_item(id, 1, true)
		check(player.equip(id).is_empty(), "Equip failed: " + id)
		check(str(player.equipment[data.type].get("id", "")) == id, "Wrong armor slot")
		Design.body(player)
		player.unequip(data.type)
		pieces += 1
	for i in range(1, 101):
		check(Design.icon("arsenal_%03d" % i, "guerreiro") != null, "Missing weapon/shield")
	var legacy := PlayerState.new()
	legacy.from_dict({"hero_name": "Antigo", "race_id": "orc", "class_id": "mago"})
	check(legacy.body_type == "medio", "Old save body default")
	for direction: Vector2 in [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]:
		check(Design.direction_row(direction) == [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT].find(direction) * 2, "Direction row")
	for job: String in GameData.CLASSES:
		var hero = load("res://scripts/actors/hero.gd").new()
		var hero_state := PlayerState.create("Teste", "elfo", job)
		hero.bind_state(hero_state)
		hero.setup(null, "", 92.0)
		root.add_child(hero)
		hero.set_process(false)
		for direction: Vector2 in [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]:
			hero.facing = direction
			hero.velocity = direction * 150.0
			hero._update_hero_animation(0.15)
			hero.attack_swing = 0.09
			hero._update_equipment_pose()
			check(hero.sprite.texture.get_size() == Vector2(64, 64), "World animation")
			check(hero.weapon_sprite.visible, "World weapon missing")
			check(absf(hero.weapon_sprite.rotation) > 0.35, "Attack weapon swing missing")
		hero_state.add_item("arsenal_089", 1, true)
		hero_state.equip("arsenal_089")
		check(hero.shield_sprite.visible, "World shield missing")
		hero_state.unequip("arma")
		check(not hero.weapon_sprite.visible, "Unequipped weapon visible")
		hero.queue_free()
	await process_frame
	var creation = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(creation)
	await process_frame
	check(creation.preview.state != null, "Creation preview not initialized")
	creation.queue_free()
	var status = load("res://scenes/ui/equipment_status_panel.tscn").instantiate()
	status.configure(player)
	root.add_child(status)
	await process_frame
	check(status.slot_buttons.size() == 12, "Equipment UI slots")
	status.queue_free()
	await process_frame
	print("NEW_DESIGN frames=%d pieces=%d weapons=100 failures=%d" % [count, pieces, failures])
	quit(0 if failures == 0 else 1)

