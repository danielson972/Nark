extends PanelContainer
## An input-transparent description card, shared by the skill book and hotbar.

const Catalog = preload("res://scripts/ui/skill_catalog.gd")
const SkillIcon = preload("res://scripts/ui/skill_icon.gd")

var state: PlayerState
var definition: Dictionary = {}
var title_label: Label
var status_label: Label
var description_label: Label
var cost_label: Label
var icon: Control

func configure(player: PlayerState, skill: Dictionary) -> void:
	state = player
	definition = skill
	if is_node_ready():
		_refresh()
		reset_size()

func _ready() -> void:
	name = "SkillTooltip"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = 280
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.005, 0.005, 0.005, 0.88)
	style.border_color = Color(0.52, 0.43, 0.28, 0.8)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(12)
	style.shadow_size = 5
	style.shadow_color = Color(0, 0, 0, 0.35)
	add_theme_stylebox_override("panel", style)
	var column: VBoxContainer = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 7)
	add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 9)
	column.add_child(header)
	icon = SkillIcon.new()
	icon.custom_minimum_size = Vector2(42, 42)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(icon)
	var info: VBoxContainer = VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(info)
	title_label = _label(14, Color("f2c768"), 205)
	title_label.add_theme_font_override("font", UiKit.display_font())
	info.add_child(title_label)
	status_label = _label(11, Color("b6aa94"), 205)
	info.add_child(status_label)
	var divider: ColorRect = ColorRect.new()
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.color = Color(0.58, 0.45, 0.24, 0.55)
	divider.custom_minimum_size.y = 1
	column.add_child(divider)
	description_label = _label(13, Color("f0e7d3"))
	column.add_child(description_label)
	cost_label = _label(11, Color("c2b598"))
	column.add_child(cost_label)
	_refresh()

func _label(font_size: int, color: Color, width: float = 256) -> Label:
	var label: Label = UiKit.label("", font_size, color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.custom_minimum_size.x = width
	label.size.x = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _refresh() -> void:
	title_label.text = str(definition.get("name", ""))
	status_label.text = Catalog.status_text(state, definition)
	description_label.text = str(definition.get("desc", ""))
	cost_label.text = Catalog.cost_text(definition)
	icon.definition = definition
	icon.learned = Catalog.is_learned(state, definition)
