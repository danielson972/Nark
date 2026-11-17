extends PanelContainer
## Editable 2D skill book. Layout lives in scenes/ui/skills_panel.tscn.

signal action_requested(action: String, payload: Dictionary)

const ThemeKit = preload("res://scripts/ui/rpg_panel_theme.gd")
const Catalog = preload("res://scripts/ui/skill_catalog.gd")
const SkillHover = preload("res://scripts/ui/skill_hover.gd")
const SkillIcon = preload("res://scripts/ui/skill_icon.gd")

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
	# Every visible control is authored in the scene and can be edited in 2D.
	skill_scroll = %SkillsScroll
	skill_grid = %SkillsGrid
	selected_name = %SelectedName
	selected_status = %SelectedStatus
	selected_description = %SelectedDescription
	selected_cost = %SelectedCost
	selected_icon = %SelectedIcon
	assign_button = %AssignHotbar
	upgrade_button = %UpgradeSkill
	%CloseSkills.pressed.connect(func() -> void: action_requested.emit("close_panel", {}))
	assign_button.pressed.connect(_perform.bind("assign_hotbar"))
	upgrade_button.pressed.connect(_perform.bind("upgrade_skill"))
	for tab: String in ["ativas", "passivas"]:
		var button: Button = get_node("%Tab_" + tab)
		tab_buttons[tab] = button
		button.pressed.connect(_switch_tab.bind(tab))
	for card: Button in skill_grid.get_children():
		card.pressed.connect(_select_card.bind(card))
	get_parent().resized.connect(_fit)
	minimum_size_changed.connect(func() -> void: _fit.call_deferred())
	if state == null:
		state = PlayerState.create("Herói", "humano", "guerreiro")
	%ClassIdentity.text = "%s · Nível %d" % [state.class_data()["name"], state.level]
	_populate()
	_fit.call_deferred()
	_restore_scroll.call_deferred()

func _fit() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var available: Vector2 = get_parent().size
	size = custom_minimum_size.max(get_combined_minimum_size())
	var factor: float = clampf(minf((available.x - 24.0) / size.x, (available.y - 24.0) / size.y), 0.1, 1.0)
	scale = Vector2.ONE * factor
	position = ((available - size * factor) * 0.5).floor()
	queue_redraw()

func _select_card(card: Button) -> void:
	_select(str(card.get_meta("skill_id", "")))

func _definitions() -> Array:
	var definitions: Array = (state.class_data()[active_tab] as Array).duplicate()
	if active_tab == "ativas":
		definitions.append(GameData.UNIVERSAL_AURA)
		definitions.append(GameData.UNIVERSAL_DESPERTAR)
	else:
		definitions.append_array(Catalog.GRADE_BONUSES)
	return definitions

func _populate() -> void:
	skill_buttons.clear()
	var definitions: Array = _definitions()
	var selection_exists: bool = false
	for definition: Dictionary in definitions:
		if str(definition["id"]) == selected_id:
			selection_exists = true
	if not selection_exists:
		selected_id = str(definitions[0]["id"]) if not definitions.is_empty() else ""
	var cards: Array[Node] = skill_grid.get_children()
	assert(definitions.size() <= cards.size(), "Add skill cards in scenes/ui/skills_panel.tscn for the new class abilities.")
	for index in cards.size():
		var card: Button = cards[index]
		var definition: Dictionary = definitions[index] if index < definitions.size() else {}
		card.visible = not definition.is_empty()
		card.get_node("SkillHover").configure(state, definition)
		if definition.is_empty():
			card.set_meta("skill_id", "")
			continue
		var skill_id: String = str(definition["id"])
		var learned: bool = Catalog.is_learned(state, definition)
		card.set_meta("skill_id", skill_id)
		var icon: Control = card.get_node("Content/Icon")
		icon.definition = definition
		icon.learned = learned
		var title: Label = card.get_node("Content/Text/Name")
		title.text = str(definition["name"])
		card.get_node("Content/Text/Level").text = ("Nv. %d" % maxi(1, state.skill_level(skill_id))) if learned and not definition.has("grade_bonus") else ("Bônus ativo" if learned else "Requer Nv. %d" % int(definition["unlock"]))
		card.get_node("Content/Text/Cost").text = _card_cost(definition)
		card.tooltip_text = "%s\n%s\n%s" % [title.text, _status(definition), Catalog.cost_text(definition)]
		skill_buttons[skill_id] = card
	_update_selection()

func _card_cost(definition: Dictionary) -> String:
	if str(definition.get("type", "")) == "passiva" or definition.has("grade_bonus"):
		return "Sempre ativa" if Catalog.is_learned(state, definition) else "Passiva"
	var costs: Array[String] = []
	var cost: Dictionary = definition.get("cost", {})
	if cost.has("mana"):
		costs.append("MP: %d" % int(cost["mana"]))
	if cost.has("energia"):
		costs.append("Energia: %d" % int(cost["energia"]))
	if definition.has("cd"):
		costs.append(("Recarga: %s s" % str(float(definition["cd"]))).replace(".", ","))
	return " · ".join(costs)

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
		tab_buttons[tab].set_pressed_no_signal(tab == active_tab)
	for skill_id: String in skill_buttons:
		skill_buttons[skill_id].set_pressed_no_signal(skill_id == selected_id)
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
