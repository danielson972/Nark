extends Control
## Equipment and status remain a separate, visually editable scene.
signal action_requested(action: String, payload: Dictionary)
signal equipment_selected(item_id: String, slot: String)
const SLOT_NAMES = {"armadura": "Traje", "arma": "Arma", "escudo": "Escudo", "anel": "Anel", "colar": "Colar", "talisma": "Talismã", "aura": "Hero"}
var state: PlayerState
var slot_buttons: Dictionary = {}

func configure(player: PlayerState) -> void:
	state = player

func _ready() -> void:
	if state == null:
		state = PlayerState.create("Herói", "humano", "guerreiro")
	%Portrait.state = state
	%CloseStatus.pressed.connect(func() -> void: action_requested.emit("close_status", {}))
	for slot: String in PlayerState.EQUIP_SLOTS:
		var button: Button = get_node("%Equipment_" + slot)
		slot_buttons["equip:" + slot] = button
		button.pressed.connect(_select.bind(slot))
		button.gui_input.connect(_slot_input.bind(slot, button))
	refresh_data()

func _select(slot: String) -> void:
	var id: String = str(state.equipment.get(slot, {}).get("id", ""))
	equipment_selected.emit(id, slot)

func _slot_input(event: InputEvent, slot: String, button: Button) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if not state.equipment.get(slot, {}).is_empty():
			button.accept_event()
			action_requested.emit.call_deferred("unequip", {"slot": slot})

func refresh_data() -> void:
	%HeroName.text = state.hero_name
	%HeroOrigin.text = "%s · Nv. %d · %s" % [state.class_data()["name"], state.level, state.race()["name"]]
	var values: Dictionary = {
		"hp": "%d / %d" % [state.hp, state.max_hp()],
		"mp": "%d / %d" % [state.mp, state.max_mp()],
		"energy": "%d / %d" % [state.energy, state.max_energy()],
		"attack": "%d" % state.damage_power(),
		"defense": "%d" % state.defense_power(),
		"speed": "%d" % state.move_speed(),
		"crit": "%d%%" % (state.crit_physical() * 100),
		"magic_crit": "%d%%" % (state.crit_magical() * 100),
		"fame": "%d" % state.fame,
		"coins": "%d" % state.coins,
	}
	for id: String in values:
		get_node("%Stat_" + id).text = values[id]
	for slot: String in PlayerState.EQUIP_SLOTS:
		var button: Button = slot_buttons["equip:" + slot]
		var id: String = str(state.equipment.get(slot, {}).get("id", ""))
		button.get_node("EmptyIcon").visible = id.is_empty()
		button.get_node("Icon").empty_slot = ""
		button.get_node("Icon").item_id = id
		button.get_node("Icon").class_id = state.class_id
		button.tooltip_text = SLOT_NAMES[slot]
		if not id.is_empty():
			var item: Dictionary = GameData.item(id)
			button.tooltip_text += "\n%s\n%s\nDuplo clique para desequipar." % [item.get("name", id), item.get("desc", "")]
	%Portrait.queue_redraw()
