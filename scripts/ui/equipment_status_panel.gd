extends Control
signal action_requested(action: String, payload: Dictionary)
signal equipment_selected(item_id: String, slot: String)
const SLOT_NAMES = {"armadura": "Traje antigo", "arma": "Arma", "escudo": "Escudo", "anel": "Anel", "colar": "Colar", "talisma": "Talismã", "aura": "Hero", "elmo": "Elmo", "peito": "Peitoral", "luvas": "Luvas", "calca": "Calça", "botas": "Botas"}
var state: PlayerState
var slot_buttons: Dictionary = {}
var portrait: Control
var origin_label: Label
var stats: Label
func configure(player: PlayerState) -> void:
 state = player
func _ready() -> void:
 if state == null: state = PlayerState.create("Herói", "humano", "guerreiro")
 var panel := PanelContainer.new()
 panel.add_theme_stylebox_override("panel", preload("res://scripts/ui/rpg_panel_theme.gd").frame(Color("211b16"), Color("bfa369"), 2, 8))
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(panel)
 var margin := MarginContainer.new()
 for edge: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 16)
 panel.add_child(margin)
 var content := VBoxContainer.new()
 content.add_theme_constant_override("separation", 8)
 margin.add_child(content)
 var header := HBoxContainer.new()
 content.add_child(header)
 origin_label = Label.new()
 origin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 header.add_child(origin_label)
 var close := Button.new()
 close.text = "×"
 close.pressed.connect(func(): action_requested.emit("close_status", {}))
 header.add_child(close)
 portrait = preload("res://scripts/ui/hero_preview.gd").new()
 portrait.state = state
 portrait.custom_minimum_size = Vector2(0, 240)
 portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
 content.add_child(portrait)
 var grid := GridContainer.new()
 grid.columns = 6
 grid.add_theme_constant_override("h_separation", 6)
 grid.add_theme_constant_override("v_separation", 8)
 content.add_child(grid)
 for slot: String in ["elmo", "peito", "luvas", "calca", "botas", "escudo", "arma", "anel", "colar", "talisma", "aura", "armadura"]:
  var cell := VBoxContainer.new()
  grid.add_child(cell)
  var button := Button.new()
  button.custom_minimum_size = Vector2(64, 60)
  cell.add_child(button)
  var icon := preload("res://scripts/ui/inventory_icon.gd").new()
  icon.name = "Icon"
  icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  button.add_child(icon)
  var label := Label.new()
  label.text = SLOT_NAMES[slot]
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.add_theme_font_size_override("font_size", 12)
  cell.add_child(label)
  slot_buttons["equip:" + slot] = button
  button.pressed.connect(_select.bind(slot))
  button.gui_input.connect(_slot_input.bind(slot, button))
 stats = Label.new()
 stats.add_theme_font_size_override("font_size", 15)
 content.add_child(stats)
 refresh_data()
func _select(slot: String) -> void:
 equipment_selected.emit(str(state.equipment.get(slot, {}).get("id", "")), slot)
func _slot_input(event: InputEvent, slot: String, button: Button) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
  if not state.equipment.get(slot, {}).is_empty():
   button.accept_event()
   action_requested.emit.call_deferred("unequip", {"slot": slot})
func refresh_data() -> void:
 origin_label.text = "%s · Nv. %d · %s" % [state.hero_name, state.level, state.race().name]
 stats.text = "HP %d/%d   MP %d/%d   EP %d/%d\nAtaque %d   Defesa %d   Velocidade %d\nCrítico %d%%   Crítico mágico %d%%   Fama %d   Moedas %d" % [state.hp, state.max_hp(), state.mp, state.max_mp(), state.energy, state.max_energy(), state.damage_power(), state.defense_power(), state.move_speed(), state.crit_physical()*100, state.crit_magical()*100, state.fame, state.coins]
 for slot: String in PlayerState.EQUIP_SLOTS:
  var button: Button = slot_buttons["equip:" + slot]
  var id: String = str(state.equipment.get(slot, {}).get("id", ""))
  button.get_node("Icon").item_id = id
  button.get_node("Icon").class_id = state.class_id
  button.tooltip_text = SLOT_NAMES[slot]
  if not id.is_empty(): button.tooltip_text += "\n%s\nDuplo clique para desequipar." % GameData.item(id).get("name", id)
 portrait.queue_redraw()
