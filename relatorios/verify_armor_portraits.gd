extends SceneTree
const Catalog = preload("res://scripts/ui/item_catalog.gd")
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const Portraits = preload("res://scripts/ui/armor_portrait_catalog.gd")
func _initialize() -> void: call_deferred("_run")
func check(id: String, job: String) -> void:
	var icon: AtlasTexture = Catalog.icon_texture_for(id,job)
	assert(icon != null and icon.atlas.resource_path.contains("armor_portraits/"),id)
	var image: Image = icon.get_image()
	assert(image.detect_alpha() != Image.ALPHA_NONE,id+" must have alpha")
	var transparent: int = 0
	var visible: int = 0
	for y in image.get_height():
		for x in image.get_width():
			var alpha: float = image.get_pixel(x,y).a
			if alpha <= 0.01: transparent += 1
			if alpha >= 0.5: visible += 1
	var pixels: int = image.get_width()*image.get_height()
	assert(transparent > pixels*0.12,id+" has opaque background")
	assert(visible > pixels*0.20,id+" is too faint")
	var aspect: float = float(image.get_width())/image.get_height()
	assert(aspect > 0.65 and aspect < 1.65,id+" must be a compact torso")
	var player := PlayerState.create("Ícones","humano",job)
	player.add_item(id,1,true)
	player.equip(id)
	assert(not Appearance.body_texture(player).atlas.resource_path.contains("armor_portraits/"),"Do not replace the worn body with an inventory icon")
func _run() -> void:
	var count: int = 0
	for index in range(1,101):
		check("armadura_catalogo_%03d" % index,"guerreiro")
		count += 1
	for job: String in GameData.CLASS_ORDER:
		for id: String in Portraits.LEGACY_IDS:
			check(id,job)
			count += 1
	assert(Catalog.icon_texture_for("arsenal_001") == Catalog.texture_for("arsenal_001"))
	assert(Catalog.icon_texture_for("pocao_cura") == Catalog.texture_for("pocao_cura"))
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano","guerreiro","Ícones")
	for id: String in GameData.ITEMS: game.state.add_item(id,1,true)
	game._open_panel("inventory")
	for tick in 5: await process_frame
	game.ui.inventory_view._change_filter("armor")
	for tick in 3: await process_frame
	assert(game.ui.inventory_view.slot_buttons.has("bag:armadura_catalogo_100"))
	game.ui.inventory_view._select("armadura_catalogo_038","")
	game.ui.inventory_view.action_buttons.equip.pressed.emit()
	for tick in 3: await process_frame
	assert(game.state.equipment.armadura.id == "armadura_catalogo_038")
	var equipped_icon: Control = game.ui.status_view.get_node("%Equipment_armadura/Icon")
	assert(equipped_icon.item_id == "armadura_catalogo_038")
	game.queue_free()
	for tick in 3: await process_frame
	print("ARMOR_PORTRAITS_OK: %d torso icons, alpha, compact framing, all class variants, original worn bodies, unchanged weapons/consumables, catalog filtering and equip flow" % count)
	quit()
