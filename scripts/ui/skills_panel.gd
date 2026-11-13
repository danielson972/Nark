extends PanelContainer
## Compact skill book. It presents only the current class's actual abilities.

signal action_requested(action: String, payload: Dictionary)

const ThemeKit = preload("res://scripts/ui/rpg_panel_theme.gd")
const Catalog = preload("res://scripts/ui/skill_catalog.gd")
const SkillHover = preload("res://scripts/ui/skill_hover.gd")
const SkillIcon = preload("res://scripts/ui/skill_icon.gd")
const SLOT_SIZE = 38
const COLUMNS = 5

var state: PlayerState
var active_tab: String = "ativas"
var selected_id: String = ""
var scroll_position: int = 0
var skill_scroll: ScrollContainer
var skill_grid: GridContainer
var skill_buttons: Dictionary = {}
var tab_buttons: Dictionary = {}
var selections: Dictionary = {}
var scroll_positions: Dictionary = {}
var selected_name: Label
var selected_status: Label
var selected_description: Label
var selected_cost: Label
var selected_icon: Control
var assign_button: Button
var upgrade_button: Button

func configure(player: PlayerState, tab: String = "ativas", selection: String = "", scroll_y: int = 0) -> void:
	state = player
	active_tab = tab if tab in ["ativas", "passivas"] else "ativas"
	selected_id = selection
	scroll_position = scroll_y

func _ready() -> void:
	name = "SkillsPanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_theme_stylebox_override("panel", ThemeKit.frame(ThemeKit.INK, ThemeKit.GOLD, 2, 14))
	_build()
	get_parent().resized.connect(_fit)
	_fit()
	_populate()
	_restore_scroll.call_deferred()

func _fit() -> void:
	var available: Vector2 = get_parent().size
	size = Vector2(minf(300, available.x - 28), minf(480, available.y - 28))
	position = (available - size) * 0.5
	queue_redraw()

func _draw() -> void:
	ThemeKit.draw_corners(self)

func _build() -> void:
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	var title: Label = ThemeKit.text("Skills", 22, ThemeKit.CREAM, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close: Button = ThemeKit.button("[%s] Fechar" % Controls.describe("skill_menu", SaveGame.bindings))
	close.name = "CloseSkills"
	close.pressed.connect(func() -> void: action_requested.emit("close_panel", {}))
	header.add_child(close)
	column.add_child(ThemeKit.line())
	var identity: HBoxContainer = HBoxContainer.new()
	identity.add_theme_constant_override("separation", 8)
	column.add_child(identity)
	var portrait: TextureRect = TextureRect.new()
	var sprites: Dictionary = {"guerreiro": "warrior", "mago": "mage", "atirador": "archer", "assassino": "rogue", "tank": "tank", "cavaleiro": "knight"}
	portrait.texture = load("res://assets/game/sprites/hero_%s.png" % sprites.get(state.class_id, "warrior"))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(28, 28)
	identity.add_child(portrait)
	var class_label: Label = ThemeKit.text("%s · %s" % [state.class_data()["name"], UiKit.grade_name(state.level)], 12, ThemeKit.BRIGHT)
	class_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	class_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identity.add_child(class_label)
	identity.add_child(ThemeKit.text("Nv. %d" % state.level, 11, ThemeKit.MUTED))
	var tabs: HBoxContainer = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 5)
	column.add_child(tabs)
	for tab: String in ["ativas", "passivas"]:
		var button: Button = ThemeKit.button("Ativas" if tab == "ativas" else "Passivas")
		button.name = "Tab_" + tab
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_switch_tab.bind(tab))
		tabs.add_child(button)
		tab_buttons[tab] = button
	skill_scroll = ScrollContainer.new()
	skill_scroll.name = "SkillsScroll"
	skill_scroll.custom_minimum_size.y = 64
	skill_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	skill_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	skill_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	skill_scroll.follow_focus = true
	column.add_child(skill_scroll)
	var scrollbar: VScrollBar = skill_scroll.get_v_scroll_bar()
	scrollbar.custom_minimum_size.x = 10
	scrollbar.add_theme_stylebox_override("scroll", ThemeKit.frame(Color("100c09"), Color("493520"), 1, 2))
	scrollbar.add_theme_stylebox_override("grabber", ThemeKit.frame(Color("98703b"), ThemeKit.BRIGHT, 1, 3))
	scrollbar.add_theme_stylebox_override("grabber_highlight", ThemeKit.frame(ThemeKit.BRIGHT, ThemeKit.CREAM, 1, 3))
	scrollbar.add_theme_stylebox_override("grabber_pressed", ThemeKit.frame(ThemeKit.BRIGHT, ThemeKit.CREAM, 1, 3))
	var inset: MarginContainer = MarginContainer.new()
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inset.add_theme_constant_override("margin_right", 16)
	skill_scroll.add_child(inset)
	skill_grid = GridContainer.new()
	skill_grid.name = "SkillsGrid"
	skill_grid.columns = COLUMNS
	skill_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skill_grid.add_theme_constant_override("h_separation", 6)
	skill_grid.add_theme_constant_override("v_separation", 6)
	inset.add_child(skill_grid)
	column.add_child(ThemeKit.line())
	var selected: HBoxContainer = HBoxContainer.new()
	selected.add_theme_constant_override("separation", 8)
	column.add_child(selected)
	selected_icon = SkillIcon.new()
	selected_icon.custom_minimum_size = Vector2(38, 38)
	selected.add_child(selected_icon)
	var summary: VBoxContainer = VBoxContainer.new()
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected.add_child(summary)
	selected_name = ThemeKit.text("", 14, ThemeKit.CREAM, true)
	selected_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	summary.add_child(selected_name)
	selected_status = ThemeKit.text("", 11, ThemeKit.MUTED)
	selected_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_child(selected_status)
	selected_description = ThemeKit.text("", 12, ThemeKit.CREAM)
	selected_description.custom_minimum_size.y = 48
	selected_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_description.max_lines_visible = 3
	column.add_child(selected_description)
	selected_cost = ThemeKit.text("", 11, ThemeKit.MUTED)
	selected_cost.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_cost.custom_minimum_size.y = 28
	selected_cost.max_lines_visible = 2
	column.add_child(selected_cost)
	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 5)
	column.add_child(actions)
	assign_button = ThemeKit.button("Para a hotbar")
	assign_button.name = "AssignHotbar"
	assign_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	assign_button.pressed.connect(_perform.bind("assign_hotbar"))
	actions.add_child(assign_button)
	upgrade_button = ThemeKit.button("Usar livro (0)")
	upgrade_button.name = "UpgradeSkill"
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.pressed.connect(_perform.bind("upgrade_skill"))
	actions.add_child(upgrade_button)

func _definitions() -> Array:
	var definitions: Array = (state.class_data()[active_tab] as Array).duplicate()
	if active_tab == "ativas":
		definitions.append(GameData.UNIVERSAL_AURA)
		definitions.append(GameData.UNIVERSAL_DESPERTAR)
	else:
		definitions.append_array(Catalog.GRADE_BONUSES)
	return definitions

func _populate() -> void:
	for child in skill_grid.get_children():
		skill_grid.remove_child(child)
		child.queue_free()
	skill_buttons.clear()
	var definitions: Array = _definitions()
	var selection_exists: bool = false
	for definition: Dictionary in definitions:
		if str(definition["id"]) == selected_id:
			selection_exists = true
	if not selection_exists:
		selected_id = str(definitions[0]["id"]) if not definitions.is_empty() else ""
	for index in maxi(30, ceili(float(definitions.size()) / COLUMNS) * COLUMNS):
		var definition: Dictionary = definitions[index] if index < definitions.size() else {}
		var button: Button = Button.new()
		button.name = "SkillSlot_%d" % index
		button.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		button.add_theme_stylebox_override("normal", ThemeKit.frame(Color("251a11"), Color("8c6b43")))
		button.add_theme_stylebox_override("hover", ThemeKit.frame(Color("392916"), ThemeKit.BRIGHT))
		button.add_theme_stylebox_override("pressed", ThemeKit.frame(Color("453116"), ThemeKit.BRIGHT, 3))
		button.add_theme_stylebox_override("focus", ThemeKit.frame(Color(0, 0, 0, 0), ThemeKit.BRIGHT, 2))
		button.add_theme_stylebox_override("disabled", ThemeKit.frame(Color("1c1510"), Color("5f4931")))
		skill_grid.add_child(button)
		if definition.is_empty():
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
			continue
		var skill_id: String = str(definition["id"])
		var learned: bool = Catalog.is_learned(state, definition)
		var icon: Control = SkillIcon.new()
		icon.definition = definition
		icon.learned = learned
		button.add_child(icon)
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 3
		icon.offset_top = 3
		icon.offset_right = -3
		icon.offset_bottom = -3
		var badge: Label = ThemeKit.text(("+" if definition.has("grade_bonus") else str(maxi(1, state.skill_level(skill_id)))) if learned else str(definition["unlock"]), 10, ThemeKit.CREAM if learned else ThemeKit.MUTED)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_color_override("font_shadow_color", Color.BLACK)
		badge.add_theme_constant_override("shadow_offset_x", 1)
		badge.add_theme_constant_override("shadow_offset_y", 1)
		button.add_child(badge)
		badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		badge.offset_right = -3
		badge.offset_bottom = -2
		var hover: Node = SkillHover.new()
		hover.configure(state, definition)
		button.add_child(hover)
		button.pressed.connect(_select.bind(skill_id))
		skill_buttons[skill_id] = button
	_update_selection()

func _status(definition: Dictionary) -> String:
	return Catalog.status_text(state, definition)


func _select(skill_id: String) -> void:
	selected_id = skill_id
	_update_selection()

func _switch_tab(tab: String) -> void:
	if tab == active_tab:
		return
	selections[active_tab] = selected_id
	scroll_positions[active_tab] = skill_scroll.scroll_vertical
	active_tab = tab
	selected_id = str(selections.get(tab, ""))
	scroll_position = int(scroll_positions.get(tab, 0))
	_populate()
	_restore_scroll.call_deferred()

func _update_selection() -> void:
	for tab: String in tab_buttons:
		tab_buttons[tab].add_theme_stylebox_override("normal", ThemeKit.frame(Color("443017") if tab == active_tab else Color("332416"), ThemeKit.BRIGHT if tab == active_tab else ThemeKit.GOLD, 2, 5))
	for skill_id: String in skill_buttons:
		skill_buttons[skill_id].add_theme_stylebox_override("normal", ThemeKit.frame(Color("443017") if skill_id == selected_id else Color("251a11"), ThemeKit.BRIGHT if skill_id == selected_id else Color("8c6b43"), 3 if skill_id == selected_id else 2))
	var definition: Dictionary = {}
	for candidate: Dictionary in _definitions():
		if str(candidate["id"]) == selected_id:
			definition = candidate
	var learned: bool = Catalog.is_learned(state, definition)
	assign_button.disabled = not learned or str(definition.get("type", "")) != "ativa" or state.hotbar_has(selected_id) or not state.hotbar_has_free_slot()
	assign_button.text = "Na hotbar" if learned and state.hotbar_has(selected_id) and definition.get("type", "") == "ativa" else "Para a hotbar"
	assign_button.tooltip_text = "As habilidades passivas ficam sempre ativas." if definition.get("type", "") == "passiva" else ("Não há espaço livre na hotbar." if not state.hotbar_has_free_slot() and not state.hotbar_has(selected_id) else "Adiciona ao primeiro espaço livre.")
	var books: int = state.count_item("livro_skill")
	upgrade_button.text = "Usar livro (%d)" % books
	upgrade_button.disabled = not learned or books <= 0 or state.skill_level(selected_id) >= state.skill_cap() or not state.skill_levels.has(selected_id)
	upgrade_button.tooltip_text = "Cada livro aumenta um nível, até o limite %d da grade atual." % state.skill_cap()
	selected_icon.definition = definition
	selected_icon.learned = learned
	selected_icon.queue_redraw()
	selected_name.text = str(definition.get("name", "Selecione uma skill"))
	selected_name.tooltip_text = selected_name.text
	selected_status.text = _status(definition) if not definition.is_empty() else ""
	selected_status.add_theme_color_override("font_color", ThemeKit.MUTED if learned else Color("cf9c78"))
	selected_description.text = str(definition.get("desc", ""))
	selected_description.tooltip_text = selected_description.text
	selected_cost.text = Catalog.cost_text(definition)
	selected_cost.tooltip_text = selected_cost.text


func _perform(action: String) -> void:
	if action == "assign_hotbar" and assign_button.disabled:
		return
	if action == "upgrade_skill" and upgrade_button.disabled:
		return
	action_requested.emit(action, {"id": selected_id})

func _restore_scroll() -> void:
	skill_scroll.scroll_vertical = scroll_position
