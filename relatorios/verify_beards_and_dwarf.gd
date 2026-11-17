extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
func _initialize() -> void: call_deferred("run")
func opaque_bounds(image: Image) -> Rect2i:
	var minimum := image.get_size()
	var maximum := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a >= 0.75:
				minimum = Vector2i(mini(minimum.x,x),mini(minimum.y,y))
				maximum = Vector2i(maxi(maximum.x,x),maxi(maximum.y,y))
	return Rect2i(minimum,maximum-minimum+Vector2i.ONE)
func run() -> void:
	var original: Image = load("res://assets/game/sprites/herois/bases/anao_masculino.png").get_image()
	var replacement: Image = load("res://assets/game/sprites/herois/bases/anao_masculino_sem_barba.png").get_image()
	assert(original.get_size() == replacement.get_size())
	assert(opaque_bounds(original) == opaque_bounds(replacement), "Dwarf visible size and grounding must remain unchanged")
	var parts = load("res://scripts/actors/character_parts.gd").new()
	var checked: int = 0
	for gender: String in ["masculino","feminino"]:
		for race: String in Custom.RACES:
			var state := PlayerState.create("Barbas",race,"guerreiro")
			state.gender_id = gender
			state.unequip("armadura")
			var before := [state.max_hp(),state.damage_power(),state.defense_power(),state.move_speed()]
			for style in range(1,21):
				state.set_beard(style,"original")
				parts.configure(state,Vector2(-128,-502),Vector2.ONE)
				assert(parts.beard is Sprite2D and parts.beard.visible and parts.beard.texture == Custom.beard_texture(style))
				var position: Vector2 = parts.beard.position
				parts.configure(state,Vector2(-128,-502),Vector2.ONE,true)
				assert(parts.beard.flip_h)
				assert(is_equal_approx(parts.beard.position.x,-position.x-parts.beard.texture.get_width()*parts.beard.scale.x))
				var restored := PlayerState.new()
				restored.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
				assert(restored.beard_style == style and restored.beard_color == "original")
				assert(before == [state.max_hp(),state.damage_power(),state.defense_power(),state.move_speed()])
				checked += 1
			state.set_beard(0)
			parts.configure(state,Vector2.ZERO,Vector2.ONE)
			assert(not parts.beard.visible)
	parts.free()
	var sideburns := Custom.beard_texture(19).get_image()
	assert(sideburns.get_pixel(sideburns.get_width()/2,sideburns.get_height()/2).a < 0.1, "Paired sideburns must keep both pieces and their central gap")
	var old := PlayerState.create("Anterior","anao","guerreiro").to_dict()
	old.erase("beard_style")
	old.erase("beard_color")
	var restored := PlayerState.new()
	restored.from_dict(old)
	assert(restored.beard_style == 0 and restored.beard_color == "original")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.ui.show_creation()
	await process_frame
	var scene = game.ui.overlay.get_child(game.ui.overlay.get_child_count()-1)
	scene.select_race("anao")
	scene.select_gender("masculino")
	assert(scene.get_node("%EscolhaBarba").item_count == 21)
	assert(scene.get_node("Barbas/AnaoMasculino").get_child_count() == 20)
	var base: Sprite2D = scene.get_node("Cabelos/AnaoMasculino/BaseCareca")
	var authored_transform := base.transform
	scene.get_node("%EscolhaBarba").item_selected.emit(12)
	scene.get_node("%CorBarba").item_selected.emit(3)
	for i in 3: await process_frame
	assert(base.transform == authored_transform)
	assert(scene.get_node("Barbas/AnaoMasculino/Modelo12").is_visible_in_tree())
	assert(scene.beard_color == "ruivo")
	scene.submit()
	for i in 3: await process_frame
	assert(game.state.beard_style == 12 and game.state.beard_color == "ruivo")
	assert(game.world.hero.character_parts.beard.visible)
	game._open_panel("inventory")
	for i in 3: await process_frame
	var found: bool = false
	for node in game.ui.inventory_view.find_children("*","Control",true,false):
		if node.get_script() == load("res://scripts/ui/hero_preview.gd"):
			assert(node.state == game.state and node.character_parts.beard.visible)
			found = true
	assert(found)
	game.queue_free()
	await process_frame
	print("BEARDS_DWARF_OK: %d cosmetic variants, dwarf footprint, authored transforms, 20 Sprite2D styles, sideburn pair, colors, mirroring, saves and full creation/inventory flow" % checked)
	quit()
