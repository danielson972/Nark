extends SceneTree
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1200,1000)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	var bg := ColorRect.new()
	bg.size = Vector2(1200,1000)
	bg.color = Color("1b1711")
	root.add_child(bg)
	var hashes: Dictionary = {}
	for i in 8:
		var state := PlayerState.create("Gear","humano","guerreiro")
		state.unequip("arma")
		state.unequip("armadura")
		var armor := "armadura_catalogo_%03d" % ([22,39,40,8][i%4])
		var weapon: String = (["arsenal_001", "arsenal_015"][i%2] if i < 4 else ["arsenal_089", "arsenal_100"][i%2])
		state.add_item(armor,1,true)
		assert(state.equip(armor).is_empty())
		state.add_item(weapon,1,true)
		assert(state.equip(weapon).is_empty())
		hashes[Appearance.body_texture(state).get_image().get_data().hex_encode().sha256_text()] = true
		var preview = load("res://scripts/ui/hero_preview.gd").new()
		preview.state = state
		preview.position = Vector2(i%4*300,i/4*500)
		preview.size = Vector2(300,490)
		root.add_child(preview)
	assert(hashes.size() == 4, "Each catalog armor must have its own worn pixels")
	for i in 5: await process_frame
	for child in root.get_children():
		if child.get_script() == load("res://scripts/ui/hero_preview.gd"):
			assert(child.held_weapon.visible and child.held_weapon.texture != null)
			assert(not child.held_weapon.material.get_shader_parameter("trim_grip"))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://relatorios/catalog-equipment-fixed.png")
	print("CATALOG_EQUIPMENT_OK: four distinct armor appearances, swords and shields")
	quit()
