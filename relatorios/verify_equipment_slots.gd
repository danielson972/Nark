extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
func _initialize() -> void: call_deferred("_run")
func settle() -> void:
	for tick in 4: await process_frame
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Slots")
	game._open_panel("inventory")
	await settle()
	var inventory = game.ui.inventory_view
	var status = game.ui.status_view
	assert(status.slot_buttons.size() == 7)
	for slot: String in PlayerState.EQUIP_SLOTS:
		var cell: Button = status.slot_buttons["equip:" + slot]
		var ghost: TextureRect = cell.get_node("EmptyIcon")
		assert(ghost.texture != null and ghost.modulate.a > 0 and ghost.modulate.a < 1.0)
		assert(ghost.visible == game.state.equipment[slot].is_empty())
		assert(ghost.texture is AtlasTexture)
		assert(ghost.texture.atlas.resource_path.ends_with("slot_guides_supplied.png"))
		if game.state.equipment[slot].is_empty():
			assert(cell.tooltip_text == status.SLOT_NAMES[slot])
		else:
			assert(cell.tooltip_text.begins_with(status.SLOT_NAMES[slot] + "\n"))
	var items: Dictionary = {"escudo":"arsenal_089", "anel":"joia_ng", "colar":"colar_simples", "talisma":"talisma_simples"}
	for slot: String in items:
		var id: String = items[slot]
		game.state.add_item(id, 1, true)
		game.ui.refresh_equipment_panels()
		inventory._select(id, "")
		assert(not inventory.action_buttons.equip.disabled)
		inventory.action_buttons.equip.pressed.emit()
		await settle()
		assert(game.state.equipment[slot].id == id)
		assert(status.slot_buttons["equip:" + slot].tooltip_text.begins_with(status.SLOT_NAMES[slot] + "\n"))
		assert(not status.slot_buttons["equip:" + slot].get_node("EmptyIcon").visible)
	assert(game.state.equipment.arma.id == "arma_basica", "The shield must not replace the weapon")
	assert(game.world.hero.shield_sprite.visible and game.world.hero.weapon_sprite.visible)
	assert(Appearance.shield_anchor(game.state).x > 0.5)
	for direction: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]:
		var hero: Hero = game.world.hero
		hero.facing = direction.normalized()
		hero.velocity = direction * 100
		hero._update_hero_animation(0.016)
		hero._update_equipment_pose()
		assert(hero.shield_sprite.position.x * (-1 if hero.sprite.flip_h else 1) > 0, "The shield must remain on the anatomical left arm")
		assert(hero.shield_sprite.flip_h == hero.sprite.flip_h)
	var loaded := PlayerState.new()
	loaded.from_dict(game.state.to_dict())
	assert(loaded.equipment == game.state.equipment)
	var old: Dictionary = game.state.to_dict()
	old.equipment.erase("anel")
	old.equipment.erase("escudo")
	old.equipment["joia"] = {"id":"joia_d", "durability":42, "max":140}
	old.equipment["arma"] = {"id":"arsenal_090", "durability":75, "max":100}
	loaded.from_dict(old)
	assert(loaded.equipment.anel.id == "joia_d" and loaded.equipment.anel.durability == 42)
	assert(loaded.equipment.escudo.id == "arsenal_090" and loaded.equipment.arma.is_empty())
	assert(not loaded.equipment.has("joia"))
	for slot: String in items:
		game._on_panel_action("unequip", {"slot": slot})
		await settle()
		assert(game.state.equipment[slot].is_empty())
		assert(status.slot_buttons["equip:" + slot].get_node("EmptyIcon").visible)
		assert(status.slot_buttons["equip:" + slot].tooltip_text == status.SLOT_NAMES[slot])
	assert(not game.world.hero.shield_sprite.visible)
	game._on_panel_action("unequip", {"slot":"arma"})
	game.state.add_item("arsenal_091", 1, true)
	game._on_panel_action("equip", {"id":"arsenal_091"})
	assert(game.world.hero.shield_sprite.visible and not game.world.hero.weapon_sprite.visible)
	game.queue_free()
	await settle()
	print("EQUIPMENT_SLOTS_OK: seven native slots, transparent empty icons, four new equipment types, shield plus weapon, eight directions, old saves and unequip")
	quit()
