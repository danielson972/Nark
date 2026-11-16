extends SceneTree

const Catalog = preload("res://scripts/ui/item_catalog.gd")
const Icon = preload("res://scripts/ui/inventory_icon.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var texture: Texture2D = load(Catalog.ATLAS_PATH)
	assert(texture != null)
	assert(texture.get_image().detect_alpha() != Image.ALPHA_NONE)
	var used_cells: Dictionary = {}
	for class_id: String in GameData.CLASS_ORDER:
		for item_id: String in GameData.ITEMS:
			var icon_texture: AtlasTexture = Catalog.texture_for(item_id, class_id)
			assert(icon_texture != null)
			var source_size: Vector2 = icon_texture.atlas.get_size()
			var cell: Vector2i = Catalog.cell_for(item_id, class_id)
			assert(cell.x >= 0 and cell.x < 8 and cell.y >= 0 and cell.y < 8)
			var rect: Rect2 = Catalog.atlas_rect(item_id, class_id, source_size)
			assert(rect.has_area() and Rect2(Vector2.ZERO, source_size).encloses(rect))
			used_cells["%s:%s" % [icon_texture.atlas.get_instance_id(), cell]] = true
	assert(used_cells.size() == 71)
	assert(Catalog.cell_for("unknown") == Vector2i(-1, -1))
	assert(Catalog.atlas_rect("unknown", "mago", texture.get_size()) == Rect2())
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "mago", "Artes")
	game.world.set_paused(true)
	for item_id: String in GameData.ITEMS:
		game.state.add_item(item_id, 1, true)
	for class_id: String in GameData.CLASS_ORDER:
		game.state.class_id = class_id
		game.ui.show_inventory_panel()
		await process_frame
		assert(game.ui.inventory_view.detail_icon.class_id == class_id)
		for button: Button in game.ui.inventory_view.slot_buttons.values():
			for child in button.get_children():
				if child.get_script() == Icon:
					assert(child.class_id == class_id)
	game.state.class_id = "mago"
	game.ui.show_inventory_panel()
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/item-art-inventory.png")
	for panel: String in ["chest", "forge", "dev_items"]:
		match panel:
			"chest": game.ui.show_chest_panel()
			"forge": game.ui.show_forge_panel()
			_: game.ui.show_developer_shop(panel)
		await process_frame
	game.ui.hide()
	game.world.hide()
	var gallery_layer: CanvasLayer = CanvasLayer.new()
	root.add_child(gallery_layer)
	var gallery: Control = Control.new()
	gallery_layer.add_child(gallery)
	var background: ColorRect = ColorRect.new()
	background.color = Color("1c1510")
	background.size = Vector2(1280, 720)
	gallery.add_child(background)
	for row in 8:
		var label: Label = Label.new()
		label.text = ["Atirador", "Mago", "Guerreiro", "Assassino", "Tank", "Cavaleiro", "Materiais", "Joias / extras"][row]
		label.position = Vector2(20, 30 + row * 85)
		gallery.add_child(label)
		for column in 8:
			var cell: Vector2i = Vector2i(column, row)
			var icon = Icon.new()
			if row < 6:
				icon.class_id = GameData.CLASS_ORDER[row]
				icon.item_id = Catalog.EQUIPMENT_COLUMNS.keys()[column]
			else:
				for id: String in Catalog.ITEM_CELLS:
					if Catalog.ITEM_CELLS[id] == cell:
						icon.item_id = id
				for id: String in Catalog.EXTRA_CELLS:
					if Catalog.EXTRA_CELLS[id] == cell:
						icon.item_id = id
			icon.position = Vector2(170 + column * 130, 10 + row * 85)
			icon.size = Vector2(80, 80)
			gallery.add_child(icon)
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/item-art-gallery.png")
	print("ITEM_ART_OK: 21 items, 6 classes, 71 distinct mapped icons, 5 extras, alpha, inventory, chest, forge and developer shop")
	game.queue_free()
	gallery_layer.queue_free()
	await process_frame
	quit()
