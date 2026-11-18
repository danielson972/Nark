extends Control
## Native editable inventory, with the supplied image as its background.
signal action_requested(action: String, payload: Dictionary)

const FILTERS = [["all", "Todos"], ["weapons", "Armas"], ["armor", "Armaduras"], ["materials", "Materiais"], ["consumables", "Consumíveis"], ["quest", "Missões"]]
const TYPE_NAMES = {"arma": "Arma", "armadura": "Armadura", "elmo": "Elmo", "peito": "Peitoral", "luvas": "Luvas", "calca": "Calça", "botas": "Botas", "anel": "Anel", "colar": "Colar", "talisma": "Talismã", "escudo": "Escudo", "aura": "Visual Hero", "consumivel": "Consumível", "material": "Material", "chave": "Missão", "livro": "Livro"}

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
	filter_tab = category if category in ["all", "weapons", "armor", "consumables", "materials", "quest"] else "all"
	scroll_position = scroll_y
	if not selected_slot.is_empty():
		selected_id = str(state.equipment.get(selected_slot, {}).get("id", ""))
	elif state.count_item(selected_id) == 0:
		selected_id = ""
	if selected_id.is_empty() and selected_slot.is_empty() and not state.inventory.is_empty():
		selected_id = str(state.inventory[0]["id"])

func _ready() -> void:
	if state == null:
		state = PlayerState.create("Herói", "humano", "guerreiro")
	bag_scroll = %ItemsScroll
	bag_grid = %ItemsGrid
	bag_count = %BagCount
	detail_icon = %SelectedItemArt
	detail_icon.class_id = state.class_id
	for property: String in ["detail_title", "detail_description", "detail_grade", "detail_type", "detail_weight", "detail_value", "detail_properties"]:
		set(property, get_node("%" + property))
	%CloseInventory.pressed.connect(func() -> void: action_requested.emit("close_inventory", {}))
	%ShowDetails.pressed.connect(func() -> void: %DetailsPanel.show())
	%CloseDetails.pressed.connect(func() -> void: %DetailsPanel.hide())
	for entry: Array in FILTERS:
		var id: String = str(entry[0])
		var button: Button = get_node("%Filter_" + id)
		tab_buttons[id] = button
		button.pressed.connect(_change_filter.bind(id))
	for action: String in ["equip", "unequip", "use_item", "store", "drop_item"]:
		var button: Button = get_node("%Action_" + action)
		action_buttons[action] = button
		button.pressed.connect(_perform.bind(action))
	for button: Button in bag_grid.get_children():
		button.pressed.connect(_select_button.bind(button))
		button.gui_input.connect(_slot_input.bind(button))
	_populate_bag()
	_update_selection()
	_restore_scroll.call_deferred()

func _select_button(button: Button) -> void:
	_select(str(button.get_meta("item_id", "")), "")

func _slot_input(event: InputEvent, button: Button) -> void:
	_on_slot_gui_input(event, str(button.get_meta("item_id", "")), "", button)

func refresh_data() -> void:
	configure(state, selected_id, selected_slot, bag_scroll.scroll_vertical, filter_tab)
	_populate_bag()
	_update_selection()
	_restore_scroll.call_deferred()

func _populate_bag() -> void:
	for key: String in slot_buttons.keys():
		if key.begins_with("bag:"):
			slot_buttons.erase(key)
	var entries: Array = state.inventory.filter(func(entry: Dictionary) -> bool: return _matches_filter(str(entry["id"])))
	if selected_slot.is_empty() and (selected_id.is_empty() or not _matches_filter(selected_id)):
		selected_id = str(entries[0]["id"]) if not entries.is_empty() else ""
	while bag_grid.get_child_count() < entries.size():
		# Extend the authored cell layout only when the bag needs more rows.
		var extra: Button = bag_grid.get_child(0).duplicate(Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANTIATION)
		extra.name = "BagSlot_%d" % bag_grid.get_child_count()
		bag_grid.add_child(extra)
		extra.pressed.connect(_select_button.bind(extra))
		extra.gui_input.connect(_slot_input.bind(extra))
	var cells: Array[Node] = bag_grid.get_children()
	var visible_count: int = maxi(64, ceili(float(entries.size()) / 8.0) * 8)
	for index in cells.size():
		var button: Button = cells[index]
		var entry: Dictionary = entries[index] if index < entries.size() else {}
		var id: String = str(entry.get("id", ""))
		button.visible = index < visible_count
		button.disabled = id.is_empty()
		button.set_meta("item_id", id)
		button.get_node("Icon").item_id = id
		button.get_node("Icon").class_id = state.class_id
		button.get_node("Quantity").text = str(entry.get("qty", 1)) if not id.is_empty() else ""
		button.tooltip_text = ""
		if not id.is_empty():
			var data: Dictionary = GameData.item(id)
			button.tooltip_text = "%s\n%s\nPeso: %s kg\nDuplo clique para equipar." % [data.get("name", id), data.get("desc", ""), _decimal(float(data.get("weight", 0)))]
			slot_buttons["bag:" + id] = button
	bag_count.text = "%d tipos" % entries.size()
	%WeightText.text = "PESO: %s / %s kg" % [_decimal(state.carried_weight()), _decimal(state.weight_capacity())]
	%WeightBar.value = 100.0 * state.carried_weight() / maxf(1.0, state.weight_capacity())
	for id: String in tab_buttons:
		tab_buttons[id].set_pressed_no_signal(id == filter_tab)

func _matches_filter(item_id: String) -> bool:
	var kind: String = str(GameData.item(item_id).get("type", ""))
	match filter_tab:
		"weapons": return kind in ["arma", "escudo"]
		"armor": return kind in ["armadura", "elmo", "peito", "luvas", "calca", "botas", "escudo"]
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
		button.set_pressed_no_signal(selected)
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
