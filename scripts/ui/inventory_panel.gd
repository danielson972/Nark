extends PanelContainer
## Inventory layout: equipment and attributes at left; only the bag scrolls.

signal action_requested(action: String, payload: Dictionary)

const PanelTheme = preload("res://scripts/ui/rpg_panel_theme.gd")
const Icon = preload("res://scripts/ui/inventory_icon.gd")
const INK = PanelTheme.INK
const GOLD = PanelTheme.GOLD
const BRIGHT = PanelTheme.BRIGHT
const CREAM = PanelTheme.CREAM
const MUTED = PanelTheme.MUTED

var state: PlayerState
var selected_id: String = ""
var selected_slot: String = ""
var scroll_position: int = 0
var bag_scroll: ScrollContainer
var slot_buttons: Dictionary = {}
var action_buttons: Dictionary = {}
var detail_icon: Control
var detail_title: Label
var detail_description: Label

func configure(player: PlayerState, item_id: String = "", equip_slot: String = "", scroll_y: int = 0) -> void:
	state = player
	selected_id = item_id
	selected_slot = equip_slot
	scroll_position = scroll_y
	if not selected_slot.is_empty():
		selected_id = str(state.equipment.get(selected_slot, {}).get("id", ""))
		if selected_id.is_empty():
			selected_slot = ""
	elif state.count_item(selected_id) == 0:
		selected_id = ""
	if selected_id.is_empty() and not state.inventory.is_empty():
		selected_id = str(state.inventory[0]["id"])

func _ready() -> void:
	name = "InventoryPanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_theme_stylebox_override("panel", _frame(INK, GOLD, 2, 12))
	_build()
	get_parent().resized.connect(_fit)
	_fit()
	_update_selection()
	_restore_scroll.call_deferred()

func _fit() -> void:
	var available: Vector2 = get_parent().size
	# A fixed compact footprint also prevents a huge panel in fullscreen.
	size = Vector2(minf(460, available.x - 28), minf(480, available.y - 28))
	position = (available - size) * 0.5
	queue_redraw()

func _draw() -> void:
	PanelTheme.draw_corners(self)

func _frame(fill: Color, border: Color, border_width: int = 2, padding: int = 8) -> StyleBoxFlat:
	return PanelTheme.frame(fill, border, border_width, padding)

func _text(caption: String, font_size: int = 13, color: Color = CREAM, heading: bool = false) -> Label:
	return PanelTheme.text(caption, font_size, color, heading)

func _line(vertical: bool = false) -> ColorRect:
	return PanelTheme.line(vertical)

func _build() -> void:
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	var title: Label = _text("Inventário", 22, CREAM, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var paused: Label = _text("Jogo pausado", 11, BRIGHT)
	header.add_child(paused)
	var close: Button = _button("[%s] Fechar" % Controls.describe("inventory", SaveGame.bindings))
	close.name = "CloseInventory"
	close.pressed.connect(func() -> void: action_requested.emit("close_panel", {}))
	header.add_child(close)
	column.add_child(_line())
	var body: HBoxContainer = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	column.add_child(body)
	_build_character(body)
	body.add_child(_line(true))
	_build_bag(body)
	column.add_child(_line())
	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 4)
	column.add_child(actions)
	for entry in [["equip", "Equipar"], ["unequip", "Desequipar"], ["use_item", "Usar"], ["store", "Guardar no baú"], ["drop_item", "Soltar"]]:
		var action: String = entry[0]
		var button: Button = _button(entry[1])
		button.name = "Action_" + action
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_stretch_ratio = 1.3 if action == "store" else 1.0
		button.pressed.connect(_perform.bind(action))
		actions.add_child(button)
		action_buttons[action] = button

func _build_character(parent: HBoxContainer) -> void:
	var left: VBoxContainer = VBoxContainer.new()
	left.name = "CharacterColumn"
	left.custom_minimum_size.x = 170
	left.add_theme_constant_override("separation", 4)
	parent.add_child(left)
	left.add_child(_text("Personagem", 17, CREAM, true))
	var portrait: HBoxContainer = HBoxContainer.new()
	portrait.add_theme_constant_override("separation", 8)
	left.add_child(portrait)
	var texture: TextureRect = TextureRect.new()
	var sprites: Dictionary = {"guerreiro": "warrior", "mago": "mage", "atirador": "archer", "assassino": "rogue", "tank": "tank", "cavaleiro": "knight"}
	texture.texture = load("res://assets/game/sprites/hero_%s.png" % sprites.get(state.class_id, "warrior"))
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.custom_minimum_size = Vector2(44, 46)
	portrait.add_child(texture)
	var identity: VBoxContainer = VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.alignment = BoxContainer.ALIGNMENT_CENTER
	portrait.add_child(identity)
	var hero_name: Label = _text(state.hero_name, 14, BRIGHT, true)
	hero_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identity.add_child(hero_name)
	identity.add_child(_text("%s · Nv. %d" % [state.class_data()["name"], state.level], 11, MUTED))
	identity.add_child(_text(str(state.race()["name"]), 11, MUTED))
	left.add_child(_line())
	for slot: String in PlayerState.EQUIP_SLOTS:
		var entry: Dictionary = state.equipment.get(slot, {})
		var item_id: String = str(entry.get("id", ""))
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		left.add_child(row)
		var slot_button: Button = _slot(item_id, 0, slot, 38)
		slot_button.name = "Equipment_" + slot
		slot_button.pressed.connect(_select.bind(item_id, slot))
		row.add_child(slot_button)
		slot_buttons["equip:" + slot] = slot_button
		var info: VBoxContainer = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 1)
		row.add_child(info)
		info.add_child(_text(str({"arma": "Arma", "armadura": "Armadura", "joia": "Joia" }[slot]), 12, BRIGHT, true))
		var item_name: Label = _text("Vazio" if item_id.is_empty() else str(GameData.item(item_id)["name"]), 12, MUTED if item_id.is_empty() else CREAM)
		item_name.tooltip_text = item_name.text
		item_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var item_line: HBoxContainer = HBoxContainer.new()
		info.add_child(item_line)
		item_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_line.add_child(item_name)
		if not entry.is_empty():
			item_line.add_child(_text("%d%%" % int(100 * float(entry["durability"]) / maxf(1, float(entry["max"]))), 11, BRIGHT))
		if not entry.is_empty():
			var durability: ProgressBar = UiKit.bar(BRIGHT, 7)
			durability.value = 100.0 * float(entry["durability"]) / maxf(1, float(entry["max"]))
			durability.tooltip_text = "Durabilidade: %d%%" % int(durability.value)
			info.add_child(durability)
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)
	var statistics: PanelContainer = PanelContainer.new()
	statistics.add_theme_stylebox_override("panel", _frame(Color("21180f"), GOLD.darkened(0.2), 1, 6))
	left.add_child(statistics)
	var stats: VBoxContainer = VBoxContainer.new()
	stats.add_theme_constant_override("separation", 3)
	statistics.add_child(stats)
	stats.add_child(_text("Estatísticas", 14, CREAM, true))
	stats.add_child(_line())
	_stat(stats, "Moedas", UiKit.money_text(state.coins))
	_stat(stats, "Fama", "%d / %d" % [int(state.fame), int(state.fame_cap())])
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	stats.add_child(grid)
	for caption in ["Dano  %d" % int(state.damage_power()), "Defesa  %d" % int(state.defense_power()), "Crítico  %d%%" % int(state.crit_physical() * 100), "Veloc.  %d" % int(state.move_speed())]:
		grid.add_child(_text(caption, 12, MUTED))

func _stat(parent: Control, caption: String, value: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	parent.add_child(row)
	var label: Label = _text(caption, 12, MUTED)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(_text(value, 12))

func _build_bag(parent: HBoxContainer) -> void:
	var right: VBoxContainer = VBoxContainer.new()
	right.name = "BackpackColumn"
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	parent.add_child(right)
	var heading: HBoxContainer = HBoxContainer.new()
	right.add_child(heading)
	var title: Label = _text("Mochila", 17, CREAM, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(_text("%d %s" % [state.inventory.size(), "tipo" if state.inventory.size() == 1 else "tipos"], 12, MUTED))
	bag_scroll = ScrollContainer.new()
	bag_scroll.name = "ItemsScroll"
	bag_scroll.custom_minimum_size.y = 72
	bag_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bag_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	bag_scroll.follow_focus = true
	right.add_child(bag_scroll)
	var scrollbar: VScrollBar = bag_scroll.get_v_scroll_bar()
	scrollbar.custom_minimum_size.x = 10
	scrollbar.add_theme_stylebox_override("scroll", _frame(Color("100c09"), Color("493520"), 1, 2))
	scrollbar.add_theme_stylebox_override("grabber", _frame(Color("98703b"), BRIGHT, 1, 3))
	scrollbar.add_theme_stylebox_override("grabber_highlight", _frame(BRIGHT, CREAM, 1, 3))
	scrollbar.add_theme_stylebox_override("grabber_pressed", _frame(BRIGHT, CREAM, 1, 3))
	var grid: GridContainer = GridContainer.new()
	grid.name = "ItemsGrid"
	grid.columns = 5
	grid.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	var inset: MarginContainer = MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 16)
	bag_scroll.add_child(inset)
	inset.add_child(grid)
	var slot_count: int = maxi(30, ceili(float(state.inventory.size()) / 5.0) * 5)
	for index in slot_count:
		var entry: Dictionary = state.inventory[index] if index < state.inventory.size() else {}
		var item_id: String = str(entry.get("id", ""))
		var button: Button = _slot(item_id, int(entry.get("qty", 0)), "", 38)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		button.name = "BagSlot_%d" % index
		if not item_id.is_empty():
			button.pressed.connect(_select.bind(item_id, ""))
			slot_buttons["bag:" + item_id] = button
		else:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
		grid.add_child(button)
	right.add_child(_line())
	var details: HBoxContainer = HBoxContainer.new()
	details.name = "SelectedItem"
	details.custom_minimum_size.y = 60
	details.add_theme_constant_override("separation", 10)
	right.add_child(details)
	detail_icon = Icon.new()
	detail_icon.custom_minimum_size = Vector2(40, 40)
	details.add_child(detail_icon)
	var text: VBoxContainer = VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.add_theme_constant_override("separation", 4)
	details.add_child(text)
	detail_title = _text("", 14, CREAM, true)
	detail_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text.add_child(detail_title)
	detail_description = _text("", 12, MUTED)
	detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description.max_lines_visible = 2
	text.add_child(detail_description)
	right.add_child(_line())
	var weight: Label = _text("Peso  %s / %s kg" % [_decimal(state.carried_weight()), _decimal(state.weight_capacity())], 14, BRIGHT, true)
	right.add_child(weight)
	var bar: ProgressBar = UiKit.bar(GOLD, 5)
	bar.value = 100 * state.carried_weight() / maxf(1, state.weight_capacity())
	right.add_child(bar)
	right.add_child(_text("Equipados não contam no peso.", 11, MUTED))

func _slot(item_id: String, quantity: int, equip_slot: String, side: int) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(side, side)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.clip_contents = true
	button.add_theme_stylebox_override("normal", _frame(Color("251a11"), Color("8c6b43")))
	button.add_theme_stylebox_override("hover", _frame(Color("392916"), BRIGHT))
	button.add_theme_stylebox_override("pressed", _frame(Color("453116"), BRIGHT, 3))
	button.add_theme_stylebox_override("focus", _frame(Color(0, 0, 0, 0), BRIGHT, 2))
	button.add_theme_stylebox_override("disabled", _frame(Color("1c1510"), Color("5f4931")))
	if not item_id.is_empty():
		var data: Dictionary = GameData.item(item_id)
		button.tooltip_text = "%s\n%s\nPeso: %s kg" % [data.get("name", item_id), data.get("desc", ""), _decimal(float(data.get("weight", 0)))]
	var icon: Control = Icon.new()
	icon.item_id = item_id
	icon.empty_slot = equip_slot
	button.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 6
	icon.offset_top = 5
	icon.offset_right = -6
	icon.offset_bottom = -5
	if quantity > 0:
		var count: Label = _text("×%d" % quantity, 11, CREAM)
		count.add_theme_color_override("font_shadow_color", Color.BLACK)
		count.add_theme_constant_override("shadow_offset_x", 2)
		count.add_theme_constant_override("shadow_offset_y", 2)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(count)
		count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		count.offset_right = -4
		count.offset_bottom = -2
	return button

func _button(caption: String) -> Button:
	return PanelTheme.button(caption)

func _select(item_id: String, equip_slot: String) -> void:
	selected_id = item_id
	selected_slot = equip_slot
	_update_selection()

func _update_selection() -> void:
	for key: String in slot_buttons:
		var button: Button = slot_buttons[key]
		var selected: bool = key == ("bag:" + selected_id if selected_slot.is_empty() else "equip:" + selected_slot)
		button.add_theme_stylebox_override("normal", _frame(Color("443017") if selected else Color("251a11"), BRIGHT if selected else Color("8c6b43"), 3 if selected else 2))
	var item: Dictionary = GameData.item(selected_id) if not selected_id.is_empty() else {}
	var in_bag: bool = selected_slot.is_empty() and state.count_item(selected_id) > 0
	var item_type: String = str(item.get("type", ""))
	action_buttons["equip"].disabled = not (in_bag and item_type in PlayerState.EQUIP_SLOTS)
	action_buttons["unequip"].disabled = selected_slot.is_empty() or selected_id.is_empty()
	action_buttons["use_item"].disabled = not (in_bag and item_type == "consumivel")
	action_buttons["store"].disabled = not in_bag
	action_buttons["drop_item"].disabled = not in_bag
	detail_icon.item_id = selected_id
	detail_icon.empty_slot = selected_slot
	detail_icon.queue_redraw()
	if item.is_empty():
		detail_title.text = "Selecione um item"
		detail_description.text = "Escolha um espaço na mochila ou um equipamento."
		return
	var quantity: String = " ×%d" % state.count_item(selected_id) if in_bag else ""
	detail_title.text = str(item.get("name", selected_id)) + quantity
	detail_title.tooltip_text = detail_title.text
	var properties: Array[String] = []
	for property in [["damage", "+%d dano"], ["defense", "+%d defesa"], ["hp", "+%d HP"]]:
		if item.has(property[0]):
			properties.append(property[1] % int(item[property[0]]))
	if item.has("crit"):
		properties.append("+%d%% crítico" % int(float(item["crit"]) * 100))
	var suffix: String = " · ".join(properties)
	detail_description.text = str(item.get("desc", "")) + ("\n" + suffix if not suffix.is_empty() else "")
	if not selected_slot.is_empty():
		var entry: Dictionary = state.equipment[selected_slot]
		detail_description.text += "\nDurabilidade: %d%%" % int(100 * float(entry["durability"]) / maxf(1, float(entry["max"])))
	detail_description.tooltip_text = detail_description.text

func _perform(action: String) -> void:
	if action_buttons[action].disabled:
		return
	if action == "unequip":
		action_requested.emit(action, {"slot": selected_slot})
	else:
		action_requested.emit(action, {"id": selected_id})

func _restore_scroll() -> void:
	bag_scroll.scroll_vertical = scroll_position

func _decimal(value: float) -> String:
	return ("%.1f" % value).replace(".", ",")
