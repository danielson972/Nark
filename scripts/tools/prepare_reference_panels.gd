extends SceneTree
## Initial authoring utility. The saved .tscn files are the editable source of truth.
const Kit = preload("res://scripts/ui/rpg_panel_theme.gd")
const Art = preload("res://scripts/ui/inventory_icon.gd")
const BACKGROUND = "res://assets/game/ui/inventory/equipment_inventory_gold.png"
var scene_root: Control
var image: Texture2D

func _initialize() -> void:
	call_deferred("_run")

func add(parent: Node, child: Node, title: String, unique: bool = false) -> Node:
	child.name = title
	parent.add_child(child)
	child.owner = scene_root
	child.unique_name_in_owner = unique
	return child

func place(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size

func atlas(region: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = image
	texture.region = region
	texture.filter_clip = true
	return texture

func backdrop(parent: Node, title: String, rect: Rect2, texture: Texture2D) -> TextureRect:
	var control := TextureRect.new()
	control.texture = texture
	control.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add(parent, control, title)
	place(control, rect)
	return control

func cover(parent: Node, title: String, rect: Rect2) -> void:
	var backing := ColorRect.new()
	backing.color = Color("10110e")
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add(parent, backing, title + "Backing")
	place(backing, rect)
	backdrop(parent, title, rect, atlas(Rect2(205, 270, 340, 465)))

func text(parent: Node, title: String, caption: String, rect: Rect2, font_size: int = 13, unique: bool = false) -> Label:
	var control := Kit.text(caption, font_size, Color("e0d8bd"))
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add(parent, control, title, unique)
	place(control, rect)
	return control

func button(parent: Node, title: String, caption: String, rect: Rect2) -> Button:
	var control := Kit.button(caption)
	control.custom_minimum_size = Vector2.ZERO
	control.add_theme_font_size_override("font_size", 11)
	control.add_theme_stylebox_override("normal", Kit.frame(Color("2c2c20"), Color("706447"), 1, 3))
	control.add_theme_stylebox_override("pressed", Kit.frame(Color("4a4127"), Color("c5ae74"), 1, 3))
	add(parent, control, title, true)
	place(control, rect)
	return control

func icon(parent: Node, title: String, rect: Rect2, unique: bool = false) -> Control:
	var control: Control = Art.new()
	add(parent, control, title, unique)
	place(control, rect)
	return control

func slot(parent: Node, title: String, rect: Rect2, unique: bool = false) -> Button:
	var control := Button.new()
	control.toggle_mode = true
	control.clip_contents = true
	control.custom_minimum_size = rect.size
	for style: String in ["normal", "disabled"]:
		control.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	control.add_theme_stylebox_override("hover", Kit.frame(Color("313126"), Color("afa078"), 1, 0))
	control.add_theme_stylebox_override("pressed", Kit.frame(Color("3d3824"), Color("e6c777"), 2, 0))
	control.add_theme_stylebox_override("focus", Kit.frame(Color.TRANSPARENT, Color("e6c777"), 1, 0))
	add(parent, control, title, unique)
	place(control, rect)
	var background := backdrop(control, "SlotBackground", Rect2(Vector2.ZERO, rect.size), atlas(Rect2(794, 210, 78, 78)))
	background.show_behind_parent = true
	icon(control, "Icon", Rect2(4, 4, rect.size.x - 8, rect.size.y - 8))
	return control

func save_scene(path: String) -> void:
	var packed := PackedScene.new()
	assert(packed.pack(scene_root) == OK)
	assert(ResourceSaver.save(packed, path) == OK)
	scene_root.free()

func create_status() -> void:
	scene_root = Control.new()
	scene_root.name = "StatusPanel"
	scene_root.size = Vector2(480, 646)
	backdrop(scene_root, "ReferenceBackground", Rect2(0, 0, 480, 646), atlas(Rect2(0, 0, 755, 1029)))
	cover(scene_root, "ClearExampleContent", Rect2(30, 70, 422, 542))
	button(scene_root, "CloseStatus", "×", Rect2(426, 27, 26, 24))
	var suit := slot(scene_root, "Equipment_armadura", Rect2(44, 100, 74, 168), true)
	suit.get_node("Icon").empty_slot = "armadura"
	text(scene_root, "OutfitCaption", "TRAJE", Rect2(44, 76, 74, 22), 12).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for entry: Array in [["joia", "JOIA", Vector2(210, 100)], ["aura", "HERO", Vector2(310, 100)], ["arma", "ARMA", Vector2(44, 394)]]:
		var point: Vector2 = entry[2]
		var cell := slot(scene_root, "Equipment_" + str(entry[0]), Rect2(point, Vector2(66, 66)), true)
		cell.get_node("Icon").empty_slot = str(entry[0])
		if entry[0] == "aura":
			var marker := text(cell, "EmptyMarker", "H", Rect2(0, 0, 66, 66), 28)
			marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cell.set_meta("item_slot", "hero" if entry[0] == "aura" else entry[0])
		text(scene_root, "Caption_" + str(entry[0]), str(entry[1]), Rect2(point - Vector2(0, 24), Vector2(66, 22)), 12).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var portrait: Control = load("res://scripts/ui/hero_preview.gd").new()
	add(scene_root, portrait, "Portrait", true)
	place(portrait, Rect2(122, 172, 290, 278))
	var preview := TextureRect.new()
	preview.texture = load("res://assets/game/sprites/herois/bases/humano_masculino.png")
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add(portrait, preview, "BaseCarecaEditor")
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text(scene_root, "HeroName", "Herói", Rect2(128, 444, 278, 22), 14, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text(scene_root, "HeroOrigin", "Humano · Guerreiro · Nv. 1", Rect2(128, 466, 278, 18), 11, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var stats: Array = [["hp", "PV", "100/100"], ["mp", "MP", "100/100"], ["energy", "Energia", "100/100"], ["attack", "Ataque", "0"], ["defense", "Defesa", "0"], ["speed", "Velocidade", "180"], ["crit", "Crít. físico", "0%"], ["magic_crit", "Crít. mágico", "0%"], ["fame", "Fama", "0"], ["coins", "Moedas", "0"]]
	for index in stats.size():
		var entry: Array = stats[index]
		var x: float = 46 if index < 5 else 254
		var y: float = 496 + (index % 5) * 21
		text(scene_root, "Caption_" + str(entry[0]), str(entry[1]), Rect2(x, y, 95, 20), 12)
		text(scene_root, "Stat_" + str(entry[0]), str(entry[2]), Rect2(x + 96, y, 91, 20), 12, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	scene_root.set_script(load("res://scripts/ui/equipment_status_panel.gd"))
	save_scene("res://scenes/ui/equipment_status_panel.tscn")

func create_inventory() -> void:
	scene_root = Control.new()
	scene_root.name = "InventoryPanel"
	scene_root.size = Vector2(478, 646)
	backdrop(scene_root, "ReferenceBackground", Rect2(0, 0, 478, 646), atlas(Rect2(755, 0, 756, 1029)))
	cover(scene_root, "ClearExampleContent", Rect2(18, 72, 438, 546))
	button(scene_root, "CloseInventory", "×", Rect2(426, 27, 26, 24))
	var tabs: Array = [["all", "TODOS"], ["weapons", "ARMAS"], ["armor", "ARMADURAS"], ["materials", "MATERIAIS"], ["consumables", "CONSUMÍVEIS"], ["quest", "MISSÕES"]]
	for index in tabs.size():
		var entry: Array = tabs[index]
		var tab := button(scene_root, "Filter_" + str(entry[0]), str(entry[1]), Rect2(24 + (index % 3) * 141, 78 + (index / 3) * 32, 136, 27))
		tab.toggle_mode = true
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	add(scene_root, scroll, "ItemsScroll", true)
	place(scroll, Rect2(24, 148, 432, 416))
	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	add(scroll, grid, "ItemsGrid", true)
	var count: int = maxi(64, ceili(GameData.ITEMS.size() / 8.0) * 8)
	for index in count:
		var cell := slot(grid, "BagSlot_%03d" % index, Rect2(0, 0, 49, 49))
		cell.visible = index < 64
		var quantity := text(cell, "Quantity", "", Rect2(1, 27, 44, 20), 12)
		quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity.add_theme_color_override("font_shadow_color", Color.BLACK)
		quantity.add_theme_constant_override("shadow_offset_x", 1)
		quantity.add_theme_constant_override("shadow_offset_y", 1)
	for entry: Array in [["equip", "EQUIPAR"], ["unequip", "RETIRAR"], ["use_item", "USAR"]]:
		button(scene_root, "Action_" + str(entry[0]), str(entry[1]), Rect2(24, 576, 98, 28))
	button(scene_root, "ShowDetails", "DETALHES", Rect2(128, 576, 100, 28))
	button(scene_root, "Action_store", "GUARDAR", Rect2(234, 576, 100, 28))
	button(scene_root, "Action_drop_item", "SOLTAR", Rect2(340, 576, 100, 28))
	text(scene_root, "BagCount", "0 tipos", Rect2(26, 608, 100, 22), 11, true)
	text(scene_root, "WeightText", "PESO: 0,0 / 65,0 kg", Rect2(130, 608, 310, 22), 11, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var weight: ProgressBar = UiKit.bar(Kit.GOLD, 4)
	add(scene_root, weight, "WeightBar", true)
	place(weight, Rect2(130, 632, 310, 4))
	var details := Panel.new()
	details.add_theme_stylebox_override("panel", Kit.frame(Color("141710"), Color("9e8b5d"), 2, 10))
	add(scene_root, details, "DetailsPanel", true)
	place(details, Rect2(22, 150, 420, 414))
	details.visible = false
	icon(details, "SelectedItemArt", Rect2(18, 18, 70, 70), true)
	var title := text(details, "detail_title", "Selecione um item", Rect2(104, 18, 270, 50), 18, true)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text(details, "detail_grade", "", Rect2(104, 72, 270, 20), 12, true)
	var description := text(details, "detail_description", "Descrição do item", Rect2(18, 108, 380, 100), 13, true)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index in 3:
		var caption: String = ["Tipo", "Peso unitário", "Valor"][index]
		var id: String = ["detail_type", "detail_weight", "detail_value"][index]
		text(details, "Caption_" + id, caption, Rect2(18, 218 + index * 26, 120, 22), 12)
		text(details, id, "—", Rect2(142, 218 + index * 26, 250, 22), 12, true)
	var properties := text(details, "detail_properties", "", Rect2(18, 302, 380, 50), 12, true)
	properties.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button(details, "CloseDetails", "VOLTAR AOS ITENS", Rect2(100, 370, 220, 28))
	scene_root.set_script(load("res://scripts/ui/inventory_panel.gd"))
	save_scene("res://scenes/ui/inventory_panel.tscn")

func create_workspace() -> void:
	scene_root = Control.new()
	scene_root.name = "EquipmentPanels"
	scene_root.size = Vector2(974, 646)
	scene_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var status: Control = load("res://scenes/ui/equipment_status_panel.tscn").instantiate()
	add(scene_root, status, "StatusPanel")
	var inventory: Control = load("res://scenes/ui/inventory_panel.tscn").instantiate()
	add(scene_root, inventory, "InventoryPanel")
	inventory.position = Vector2(494, 0)
	scene_root.set_script(load("res://scripts/ui/equipment_panels.gd"))
	save_scene("res://scenes/ui/equipment_panels.tscn")

func _run() -> void:
	image = load(BACKGROUND)
	create_status()
	create_inventory()
	create_workspace()
	print("REFERENCE_PANELS_AUTHORED")
	quit()
