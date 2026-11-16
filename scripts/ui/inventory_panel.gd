extends PanelContainer
## Reference-inspired inventory: character, filtered backpack and item details.
signal action_requested(action: String, payload: Dictionary)

const PanelTheme = preload("res://scripts/ui/rpg_panel_theme.gd")
const Icon = preload("res://scripts/ui/inventory_icon.gd")
const INK = Color("0c100f")
const GOLD = Color("997440")
const BRIGHT = Color("f0c76b")
const CREAM = Color("efe2c5")
const MUTED = Color("aaa596")
const DESIGN_SIZE = Vector2(1160, 748)
const FILTERS = [["all", "Todos"], ["equipment", "Equipamentos"], ["consumables", "Consumíveis"], ["materials", "Materiais"], ["quest", "Missão"]]
const SLOT_NAMES = {"arma": "Arma", "armadura": "Armadura", "joia": "Joia", "aura": "Hero"}
const TYPE_NAMES = {"arma": "Arma", "armadura": "Armadura", "joia": "Joia", "aura": "Visual Hero", "consumivel": "Consumível", "material": "Material", "chave": "Missão", "livro": "Livro"}

var state: PlayerState
var selected_id: String = ""
var selected_slot: String = ""
var filter_tab: String = "all"
var scroll_position: int = 0
var bag_scroll: ScrollContainer
var slot_buttons: Dictionary = {}
var action_buttons: Dictionary = {}
var tab_buttons: Dictionary = {}
var detail_icon: Control
var detail_title: Label
var detail_description: Label
var detail_grade: Label
var detail_type: Label
var detail_weight: Label
var detail_value: Label
var detail_properties: Label
var bag_grid: GridContainer
var bag_count: Label

func configure(player: PlayerState, item_id: String = "", equip_slot: String = "", scroll_y: int = 0, category: String = "all") -> void:
	state = player
	selected_id = item_id
	selected_slot = equip_slot
	filter_tab = category if category in ["all", "equipment", "consumables", "materials", "quest"] else "all"
	scroll_position = scroll_y
	if not selected_slot.is_empty():
		selected_id = str(state.equipment.get(selected_slot, {}).get("id", ""))
	elif state.count_item(selected_id) == 0:
		selected_id = ""
	if selected_id.is_empty() and selected_slot.is_empty() and not state.inventory.is_empty():
		selected_id = str(state.inventory[0]["id"])

func _ready() -> void:
	name = "InventoryPanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_theme_stylebox_override("panel", _frame(INK, GOLD, 2, 12))
	_build()
	get_parent().resized.connect(_fit)
	minimum_size_changed.connect(func() -> void: _fit.call_deferred())
	_fit()
	_fit.call_deferred()
	_update_selection()
	_restore_scroll.call_deferred()

func _fit() -> void:
	if not is_inside_tree() or is_queued_for_deletion() or get_parent() == null:
		return
	var available: Vector2 = get_parent().size
	size = DESIGN_SIZE.max(get_combined_minimum_size())
	var factor: float = minf(1.0, minf((available.x - 24.0) / size.x, (available.y - 24.0) / size.y))
	scale = Vector2.ONE * maxf(0.1, factor)
	position = ((available - size * scale) * 0.5).floor()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2(5, 5), size - Vector2(10, 10)), Color("332c20"), false, 1.0)
	PanelTheme.draw_corners(self)

func _frame(fill: Color, border: Color, width: int = 2, padding: int = 8) -> StyleBoxFlat:
	var style: StyleBoxFlat = PanelTheme.frame(fill, border, width, padding)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	return style

func _text(caption: String, font_size: int = 13, color: Color = CREAM, heading: bool = false) -> Label:
	return PanelTheme.text(caption, font_size, color, heading)

func _line() -> ColorRect:
	var line := ColorRect.new()
	line.color = Color("514532")
	line.custom_minimum_size.y = 1
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

func _button(caption: String) -> Button:
	var button: Button = PanelTheme.button(caption)
	button.add_theme_stylebox_override("normal", _frame(Color("171c19"), Color("655b46"), 2, 7))
	button.add_theme_stylebox_override("hover", _frame(Color("343223"), BRIGHT, 2, 7))
	button.add_theme_stylebox_override("pressed", _frame(Color("40341d"), BRIGHT, 2, 7))
	button.add_theme_stylebox_override("disabled", _frame(Color("101411"), Color("383c32"), 2, 7))
	button.add_theme_color_override("font_color", CREAM)
	return button

func _section(parent: Control, heading: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _frame(Color("101512"), Color("544a36"), 2, 10))
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	column.add_child(_text(heading, 18, CREAM, true))
	column.add_child(_line())
	return column

func _build() -> void:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	add_child(column)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 44
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)
	var chest := TextureRect.new()
	chest.texture = load("res://assets/game/sprites/cenarios/aurora/prop_chest.png")
	chest.custom_minimum_size = Vector2(42, 42)
	chest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(chest)
	var title := _text("INVENTÁRIO", 27, CREAM, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	for entry: Array in FILTERS:
		var tab := _button(str(entry[1]).to_upper())
		tab.name = "Filter_" + str(entry[0])
		tab.toggle_mode = true
		tab.button_pressed = filter_tab == str(entry[0])
		tab.add_theme_font_size_override("font_size", 12)
		tab.pressed.connect(_change_filter.bind(str(entry[0])))
		header.add_child(tab)
		tab_buttons[str(entry[0])] = tab
	var close := _button("×")
	close.name = "CloseInventory"
	close.custom_minimum_size = Vector2(42, 42)
	close.add_theme_font_size_override("font_size", 28)
	close.add_theme_stylebox_override("normal", _frame(Color("44221b"), GOLD, 2, 4))
	close.tooltip_text = "[%s] Fechar inventário" % Controls.describe("inventory", SaveGame.bindings)
	close.pressed.connect(func() -> void: action_requested.emit("close_panel", {}))
	header.add_child(close)
	column.add_child(_line())
	var body := HBoxContainer.new()
	body.name = "InventoryColumns"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	column.add_child(body)
	_build_character(body)
	_build_bag(body)
	_build_details(body)
	column.add_child(_line())
	_build_footer(column)

func _build_character(parent: HBoxContainer) -> void:
	var left := VBoxContainer.new()
	left.name = "CharacterColumn"
	left.custom_minimum_size.x = 300
	left.add_theme_constant_override("separation", 10)
	parent.add_child(left)
	var character := _section(left, "PERSONAGEM")
	character.get_parent().size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var equipment_row := HBoxContainer.new()
	equipment_row.add_theme_constant_override("separation", 6)
	character.add_child(equipment_row)
	var left_slots := VBoxContainer.new()
	left_slots.add_theme_constant_override("separation", 10)
	equipment_row.add_child(left_slots)
	_equipment_slot(left_slots, "armadura")
	_equipment_slot(left_slots, "joia")
	var portrait_frame := PanelContainer.new()
	portrait_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait_frame.add_theme_stylebox_override("panel", _frame(Color("0b100e"), Color("2b3027"), 1, 2))
	equipment_row.add_child(portrait_frame)
	var portrait = preload("res://scripts/ui/hero_preview.gd").new()
	portrait.state = state
	portrait.custom_minimum_size = Vector2(118, 174)
	portrait_frame.add_child(portrait)
	var right_slots := VBoxContainer.new()
	right_slots.add_theme_constant_override("separation", 10)
	equipment_row.add_child(right_slots)
	_equipment_slot(right_slots, "arma")
	_equipment_slot(right_slots, "aura")
	var identity := _text(state.hero_name, 21, BRIGHT, true)
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	character.add_child(identity)
	var origin := _text("%s · Nível %d · %s" % [state.class_data()["name"], state.level, state.race()["name"]], 12, CREAM)
	origin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	origin.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	character.add_child(origin)
	var stats := _section(left, "ESTATÍSTICAS")
	stats.add_theme_constant_override("separation", 5)
	_stat(stats, "Vida (PV)", "%d / %d" % [state.hp, state.max_hp()], Color("df8074"))
	_stat(stats, "Mana (PM)", "%d / %d" % [state.mp, state.max_mp()], Color("84acdc"))
	_stat(stats, "Energia", "%d / %d" % [state.energy, state.max_energy()], BRIGHT)
	_stat(stats, "Ataque", "%d" % state.damage_power())
	_stat(stats, "Defesa", "%d" % state.defense_power())
	_stat(stats, "Velocidade", "%d" % state.move_speed())
	_stat(stats, "Crítico", "%d%%" % (state.crit_physical() * 100.0))
	_stat(stats, "Fama", "%d / %d" % [state.fame, state.fame_cap()])

func _equipment_slot(parent: VBoxContainer, slot: String) -> void:
	var id: String = str(state.equipment.get(slot, {}).get("id", ""))
	var button := _slot(id, 0, slot, 62)
	button.name = "Equipment_" + slot
	button.tooltip_text = str(SLOT_NAMES[slot]) + (" · Vazio" if id.is_empty() else "\n" + button.tooltip_text)
	button.pressed.connect(_select.bind(id, slot))
	parent.add_child(button)
	slot_buttons["equip:" + slot] = button
	if slot == "aura":
		button.name = "Equipment_aura"
		button.set_meta("item_slot", "hero")
		if id.is_empty():
			var star := _text("✦", 30, GOLD)
			star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			star.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			star.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(star)
			star.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var label := _text(str(SLOT_NAMES[slot]), 11, BRIGHT if slot == "aura" else MUTED, slot == "aura")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	if not id.is_empty() and slot != "aura":
		var entry: Dictionary = state.equipment[slot]
		var durability: ProgressBar = UiKit.bar(GOLD, 3)
		durability.custom_minimum_size.y = 3
		durability.value = 100.0 * float(entry.get("durability", 0)) / maxf(1.0, float(entry.get("max", 100)))
		durability.tooltip_text = "Durabilidade: %d%%" % durability.value
		parent.add_child(durability)

func _stat(parent: Control, caption: String, value: String, color: Color = MUTED) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var label := _text(caption, 13, color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var number := _text(value, 13, CREAM)
	row.add_child(number)
	return number

func _build_bag(parent: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.name = "BackpackColumn"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _frame(Color("101512"), Color("544a36"), 2, 10))
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var heading := HBoxContainer.new()
	column.add_child(heading)
	var title := _text("MOCHILA", 18, CREAM, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(_text("Peso  %s / %s kg" % [_decimal(state.carried_weight()), _decimal(state.weight_capacity())], 11, MUTED))
	var weight: ProgressBar = UiKit.bar(GOLD, 3)
	weight.value = 100.0 * state.carried_weight() / maxf(1.0, state.weight_capacity())
	column.add_child(weight)
	bag_scroll = ScrollContainer.new()
	bag_scroll.name = "ItemsScroll"
	bag_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bag_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	bag_scroll.follow_focus = true
	column.add_child(bag_scroll)
	var scrollbar: VScrollBar = bag_scroll.get_v_scroll_bar()
	scrollbar.custom_minimum_size.x = 10
	scrollbar.add_theme_stylebox_override("scroll", _frame(Color("0a0e0b"), Color("36372b"), 1, 1))
	for style_name: String in ["grabber", "grabber_highlight", "grabber_pressed"]:
		scrollbar.add_theme_stylebox_override(style_name, _frame(GOLD if style_name == "grabber" else BRIGHT, Color("443c28"), 1, 1))
	var inset := MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 8)
	bag_scroll.add_child(inset)
	bag_grid = GridContainer.new()
	bag_grid.name = "ItemsGrid"
	bag_grid.columns = 5
	bag_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bag_grid.add_theme_constant_override("h_separation", 6)
	bag_grid.add_theme_constant_override("v_separation", 6)
	inset.add_child(bag_grid)
	bag_count = _text("", 11, MUTED)
	column.add_child(bag_count)
	_populate_bag()

func _matches_filter(item_id: String) -> bool:
	var kind: String = str(GameData.item(item_id).get("type", ""))
	match filter_tab:
		"equipment": return kind in PlayerState.EQUIP_SLOTS
		"consumables": return kind == "consumivel"
		"materials": return kind == "material"
		"quest": return kind in ["chave", "livro"]
	return true

func _change_filter(category: String) -> void:
	filter_tab = category
	scroll_position = 0
	selected_slot = ""
	selected_id = ""
	_populate_bag()
	_update_selection()
	bag_scroll.scroll_vertical = 0

func _populate_bag() -> void:
	for key: String in slot_buttons.keys():
		if key.begins_with("bag:"):
			slot_buttons.erase(key)
	for child in bag_grid.get_children():
		bag_grid.remove_child(child)
		child.queue_free()
	var entries: Array = state.inventory.filter(func(entry: Dictionary) -> bool: return _matches_filter(str(entry["id"])))
	if selected_slot.is_empty() and (selected_id.is_empty() or not _matches_filter(selected_id)):
		selected_id = str(entries[0]["id"]) if not entries.is_empty() else ""
	var slot_count: int = maxi(35, ceili(float(entries.size()) / 5.0) * 5)
	for index in slot_count:
		var entry: Dictionary = entries[index] if index < entries.size() else {}
		var id: String = str(entry.get("id", ""))
		var button := _slot(id, int(entry.get("qty", 0)), "", 76)
		button.name = "BagSlot_%d" % index
		button.set_meta("item_id", id)
		if not id.is_empty():
			button.pressed.connect(_select.bind(id, ""))
			slot_buttons["bag:" + id] = button
		else:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
		bag_grid.add_child(button)
	bag_count.text = "%d tipos · Equipados não contam no peso" % entries.size() if not entries.is_empty() else "Nenhum item nesta categoria"
	for key: String in tab_buttons:
		tab_buttons[key].set_pressed_no_signal(key == filter_tab)

func _build_details(parent: HBoxContainer) -> void:
	var column := _section(parent, "DETALHES DO ITEM")
	column.get_parent().name = "ItemDetailsColumn"
	column.get_parent().custom_minimum_size.x = 320
	var art_center := CenterContainer.new()
	art_center.custom_minimum_size.y = 120
	column.add_child(art_center)
	var art_frame := PanelContainer.new()
	art_frame.add_theme_stylebox_override("panel", _frame(Color("0a0e0c"), Color("665a43"), 2, 5))
	art_center.add_child(art_frame)
	detail_icon = Icon.new()
	detail_icon.name = "SelectedItemArt"
	detail_icon.class_id = state.class_id
	detail_icon.custom_minimum_size = Vector2(106, 106)
	art_frame.add_child(detail_icon)
	detail_title = _text("", 21, CREAM, true)
	detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_title.max_lines_visible = 2
	column.add_child(detail_title)
	detail_grade = _text("", 12, BRIGHT)
	column.add_child(detail_grade)
	detail_description = _text("", 13, CREAM)
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description.max_lines_visible = 4
	detail_description.custom_minimum_size.y = 48
	column.add_child(detail_description)
	column.add_child(_line())
	detail_type = _stat(column, "Tipo", "")
	detail_weight = _stat(column, "Peso unitário", "")
	detail_value = _stat(column, "Valor", "")
	detail_value.add_theme_color_override("font_color", BRIGHT)
	column.add_child(_line())
	detail_properties = _text("", 12, MUTED)
	detail_properties.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_properties.max_lines_visible = 3
	column.add_child(detail_properties)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var primary := VBoxContainer.new()
	column.add_child(primary)
	for entry: Array in [["equip", "EQUIPAR"], ["unequip", "DESEQUIPAR"], ["use_item", "USAR"]]:
		var action: String = str(entry[0])
		var button := _button(str(entry[1]))
		button.name = "Action_" + action
		button.custom_minimum_size.y = 38
		button.add_theme_stylebox_override("normal", _frame(Color("244b2c"), Color("7a9e45"), 2, 8))
		button.add_theme_stylebox_override("hover", _frame(Color("356538"), Color("b5cf73"), 2, 8))
		button.pressed.connect(_perform.bind(action))
		primary.add_child(button)
		action_buttons[action] = button
	var secondary := HBoxContainer.new()
	secondary.add_theme_constant_override("separation", 6)
	column.add_child(secondary)
	for entry: Array in [["store", "GUARDAR NO BAÚ"], ["drop_item", "SOLTAR"]]:
		var action: String = str(entry[0])
		var button := _button(str(entry[1]))
		button.name = "Action_" + action
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_perform.bind(action))
		secondary.add_child(button)
		action_buttons[action] = button
	column.add_child(_text("Duplo clique para equipar ou desequipar.", 10, MUTED))

func _build_footer(parent: VBoxContainer) -> void:
	var footer := HBoxContainer.new()
	footer.custom_minimum_size.y = 28
	footer.add_theme_constant_override("separation", 12)
	parent.add_child(footer)
	var motto := _text("Grandes jornadas começam com pequenos itens.", 12, MUTED)
	motto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(motto)
	for entry: Array in [[state.coins / 10000, Color("e8b653"), "Ouro"], [(state.coins / 100) % 100, Color("c4ced0"), "Prata"], [state.coins % 100, Color("bb7946"), "Bronze"]]:
		var coin := _text("●", 23, entry[1])
		coin.tooltip_text = str(entry[2])
		footer.add_child(coin)
		var value := _text(str(entry[0]), 17, CREAM)
		value.tooltip_text = str(entry[2])
		footer.add_child(value)

func _slot(item_id: String, quantity: int, equip_slot: String, side: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(side, side)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.clip_contents = true
	button.add_theme_stylebox_override("normal", _frame(Color("151b17"), Color("665d49"), 2, 0))
	button.add_theme_stylebox_override("hover", _frame(Color("303126"), BRIGHT, 2, 0))
	button.add_theme_stylebox_override("pressed", _frame(Color("393723"), BRIGHT, 3, 0))
	button.add_theme_stylebox_override("focus", _frame(Color.TRANSPARENT, BRIGHT, 2, 0))
	button.add_theme_stylebox_override("disabled", _frame(Color("101611"), Color("3d4337"), 2, 0))
	if not item_id.is_empty():
		var data: Dictionary = GameData.item(item_id)
		button.tooltip_text = "%s\n%s\nPeso: %s kg" % [data.get("name", item_id), data.get("desc", ""), _decimal(float(data.get("weight", 0)))]
		if not equip_slot.is_empty():
			button.tooltip_text += "\nDuplo clique para desequipar."
		elif str(data.get("type", "")) in PlayerState.EQUIP_SLOTS:
			button.tooltip_text += "\nDuplo clique para equipar."
	button.gui_input.connect(_on_slot_gui_input.bind(item_id, equip_slot, button))
	var icon: Control = Icon.new()
	icon.item_id = item_id
	icon.class_id = state.class_id
	icon.empty_slot = "" if equip_slot == "aura" else equip_slot
	icon.background_padding = Vector2(3, 3)
	button.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 5
	icon.offset_top = 5
	icon.offset_right = -5
	icon.offset_bottom = -5
	if quantity > 0:
		var count := _text(str(quantity), 15, CREAM)
		count.add_theme_color_override("font_shadow_color", Color.BLACK)
		count.add_theme_constant_override("shadow_offset_x", 2)
		count.add_theme_constant_override("shadow_offset_y", 2)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(count)
		count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		count.offset_right = -5
		count.offset_bottom = -2
	return button

func _on_slot_gui_input(event: InputEvent, item_id: String, equip_slot: String, button: Button) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed or not event.double_click or item_id.is_empty():
		return
	if equip_slot.is_empty() and str(GameData.item(item_id).get("type", "")) not in PlayerState.EQUIP_SLOTS:
		return
	button.accept_event()
	_select(item_id, equip_slot)
	_activate_equipment_slot.call_deferred(item_id, equip_slot)

func _activate_equipment_slot(item_id: String, equip_slot: String) -> void:
	if equip_slot.is_empty():
		if state.count_item(item_id) > 0:
			action_requested.emit("equip", {"id": item_id})
	elif str(state.equipment.get(equip_slot, {}).get("id", "")) == item_id:
		action_requested.emit("unequip", {"slot": equip_slot})

func _select(item_id: String, equip_slot: String) -> void:
	selected_id = item_id
	selected_slot = equip_slot
	_update_selection()

func _update_selection() -> void:
	for key: String in slot_buttons:
		var button: Button = slot_buttons[key]
		var selected: bool = key == ("bag:" + selected_id if selected_slot.is_empty() else "equip:" + selected_slot)
		var hero_slot: bool = key == "equip:aura"
		button.add_theme_stylebox_override("normal", _frame(Color("44391f") if selected else (Color("292519") if hero_slot else Color("151b17")), BRIGHT if selected else (GOLD if hero_slot else Color("665d49")), 3 if selected else 2, 0))
	var item: Dictionary = GameData.item(selected_id) if not selected_id.is_empty() else {}
	var in_bag: bool = selected_slot.is_empty() and state.count_item(selected_id) > 0
	var kind: String = str(item.get("type", ""))
	action_buttons["equip"].disabled = not (in_bag and kind in PlayerState.EQUIP_SLOTS)
	action_buttons["unequip"].disabled = selected_slot.is_empty() or selected_id.is_empty()
	action_buttons["use_item"].disabled = not (in_bag and kind == "consumivel")
	action_buttons["store"].disabled = not in_bag
	action_buttons["drop_item"].disabled = not in_bag
	action_buttons["equip"].visible = kind in PlayerState.EQUIP_SLOTS and selected_slot.is_empty()
	action_buttons["unequip"].visible = not selected_slot.is_empty() and not selected_id.is_empty()
	action_buttons["use_item"].visible = kind == "consumivel"
	detail_icon.item_id = selected_id
	detail_icon.empty_slot = ""
	if item.is_empty():
		detail_title.text = "Slot Hero" if selected_slot == "aura" else "Selecione um item"
		detail_description.text = "Equipe o item Hero aqui para ativar seu visual cosmético." if selected_slot == "aura" else "Escolha um item da mochila ou um equipamento para ver seus detalhes."
		detail_grade.text = "Visual cosmético" if selected_slot == "aura" else ""
		detail_type.text = "Visual Hero" if selected_slot == "aura" else "—"
		detail_weight.text = "—"
		detail_value.text = "—"
		detail_properties.text = "Sem bônus de atributos." if selected_slot == "aura" else ""
		return
	detail_title.text = str(item.get("name", selected_id))
	detail_title.tooltip_text = detail_title.text
	detail_grade.text = ("Visual cosmético" if kind == "aura" else "Grau " + str(item.get("grade", "NG"))) + (" · %d na mochila" % state.count_item(selected_id) if in_bag else " · Equipado")
	detail_description.text = str(item.get("desc", ""))
	detail_description.tooltip_text = detail_description.text
	detail_type.text = str(TYPE_NAMES.get(kind, kind.capitalize()))
	detail_weight.text = _decimal(float(item.get("weight", 0))) + " kg"
	detail_value.text = _money(int(item.get("value", 0)))
	var properties: Array[String] = []
	for property: Array in [["damage", "+%d ataque"], ["defense", "+%d defesa"], ["hp", "+%d vida"]]:
		if item.has(property[0]):
			properties.append(property[1] % int(item[property[0]]))
	if item.has("crit"):
		properties.append("+%d%% crítico" % int(float(item["crit"]) * 100))
	if not selected_slot.is_empty() and selected_slot != "aura":
		var entry: Dictionary = state.equipment[selected_slot]
		properties.append("Durabilidade: %d%%" % int(100 * float(entry.get("durability", 0)) / maxf(1, float(entry.get("max", 100)))))
	detail_properties.text = " · ".join(properties) if not properties.is_empty() else ("Sem bônus de atributos." if kind == "aura" else "Cada item conta na sua jornada.")
	detail_properties.tooltip_text = detail_properties.text

func _perform(action: String) -> void:
	if action_buttons[action].disabled:
		return
	action_requested.emit(action, {"slot": selected_slot} if action == "unequip" else {"id": selected_id})

func _restore_scroll() -> void:
	bag_scroll.scroll_vertical = scroll_position

func _decimal(value: float) -> String:
	return ("%.1f" % value).replace(".", ",")

func _money(value: int) -> String:
	var parts: Array[String] = []
	if value >= 10000: parts.append("%d ouro" % (value / 10000))
	if value >= 100 and (value / 100) % 100 > 0: parts.append("%d prata" % ((value / 100) % 100))
	if value % 100 > 0 or parts.is_empty(): parts.append("%d bronze" % (value % 100))
	return " · ".join(parts)
