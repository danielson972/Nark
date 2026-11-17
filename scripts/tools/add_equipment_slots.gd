extends SceneTree
const SLOT_POSITIONS = {"armadura": Rect2(44,100,74,168), "anel": Rect2(44,292,66,66), "arma": Rect2(44,394,66,66), "colar": Rect2(198,100,66,66), "talisma": Rect2(282,100,66,66), "aura": Rect2(368,292,66,66), "escudo": Rect2(368,394,66,66)}
const NAMES = {"armadura":"TRAJE", "anel":"ANEL", "arma":"ARMA", "colar":"COLAR", "talisma":"TALISMÃ", "aura":"HERO", "escudo":"ESCUDO"}
func _initialize() -> void: call_deferred("_run")
func own(node: Node, root: Node) -> void:
	node.owner = root
	for child in node.get_children(): own(child, root)
func _run() -> void:
	var path := "res://scenes/ui/equipment_status_panel.tscn"
	var panel: Control = load(path).instantiate()
	var ring: Button = panel.get_node_or_null("Equipment_joia")
	if ring == null: ring = panel.get_node("Equipment_anel")
	ring.name = "Equipment_anel"
	if panel.has_node("Caption_joia"):
		panel.get_node("Caption_joia").name = "Caption_anel"
	for id: String in PlayerState.EQUIP_SLOTS:
		var cell: Button = panel.get_node_or_null("Equipment_" + id)
		if cell == null:
			cell = ring.duplicate()
			cell.name = "Equipment_" + id
			panel.add_child(cell)
			own(cell, panel)
			cell.unique_name_in_owner = true
		var rect: Rect2 = SLOT_POSITIONS[id]
		cell.position = rect.position
		cell.size = rect.size
		for old: String in ["EmptyMarker", "EmptyIcon"]:
			var child := cell.get_node_or_null(old)
			if child != null: child.free()
		var empty := TextureRect.new()
		empty.name = "EmptyIcon"
		empty.texture = load("res://assets/game/ui/equipment_slots/guides/%s.tres" % id)
		empty.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		empty.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		empty.modulate.a = 0.75
		empty.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(empty)
		empty.owner = panel
		empty.position = Vector2(10,10)
		empty.size = rect.size - Vector2(20,20)
		var caption: Label = panel.get_node_or_null("Caption_" + id)
		if id == "armadura": caption = panel.get_node("OutfitCaption")
		if caption == null:
			caption = panel.get_node("Caption_anel").duplicate()
			caption.name = "Caption_" + id
			panel.add_child(caption)
			caption.owner = panel
		caption.text = NAMES[id]
		caption.position = rect.position - Vector2(0,24)
		caption.size = Vector2(rect.size.x,22)
		caption.add_theme_font_size_override("font_size", 11)
	panel.get_node("Portrait").size.x = 246
	var packed := PackedScene.new()
	assert(packed.pack(panel) == OK)
	assert(ResourceSaver.save(packed, path) == OK)
	panel.free()
	var inventory_path := "res://scenes/ui/inventory_panel.tscn"
	var inventory: Control = load(inventory_path).instantiate()
	var grid: GridContainer = inventory.get_node("%ItemsGrid")
	var target_count: int = ceili(GameData.ITEMS.size() / 8.0) * 8
	while grid.get_child_count() < target_count:
		var cell: Button = grid.get_child(grid.get_child_count() - 1).duplicate()
		cell.name = "BagSlot_%03d" % grid.get_child_count()
		grid.add_child(cell)
		own(cell, inventory)
	assert(packed.pack(inventory) == OK)
	assert(ResourceSaver.save(packed, inventory_path) == OK)
	inventory.free()
	print("EQUIPMENT_SLOTS_AUTHORED")
	quit()
