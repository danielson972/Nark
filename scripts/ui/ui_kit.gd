class_name UiKit
extends RefCounted


const BG: = Color(0.055, 0.05, 0.06, 1.0)
const PANEL: = Color(0.11, 0.09, 0.07, 0.96)
const PANEL_SOFT: = Color(0.15, 0.12, 0.09, 0.96)
const GOLD: = Color(0.85, 0.7, 0.31)
const GOLD_SOFT: = Color(0.62, 0.51, 0.26)
const PARCHMENT: = Color(0.92, 0.86, 0.72)
const MUTED: = Color(0.68, 0.63, 0.55)
const BLUE: = Color(0.35, 0.52, 0.86)
const HP: = Color(0.75, 0.24, 0.2)
const MP: = Color(0.28, 0.45, 0.82)
const ENERGY: = Color(0.88, 0.66, 0.24)
const GOOD: = Color(0.55, 0.78, 0.5)
const BAD: = Color(0.88, 0.42, 0.35)

static var _display: Font = null


static func display_font() -> Font:
	if _display == null:
		if ResourceLoader.exists("res://assets/fonts/Cinzel-SemiBold.ttf"):
			_display = load("res://assets/fonts/Cinzel-SemiBold.ttf")
		else:
			_display = ThemeDB.fallback_font
	return _display


static func panel_style(fill: Color = PANEL, border: Color = GOLD_SOFT, width: int = 2) -> StyleBoxFlat:
	var style: = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(6)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 10
	return style


static func apply_panel(control: Control, fill: Color = PANEL, border: Color = GOLD_SOFT) -> void :
	control.add_theme_stylebox_override("panel", panel_style(fill, border))


static func panel() -> PanelContainer:
	var node: = PanelContainer.new()
	apply_panel(node)
	return node


static func label(text: String, size: int = 16, color: Color = PARCHMENT) -> Label:
	var node: = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	return node


static func title(text: String, size: int = 34, color: Color = GOLD) -> Label:
	var node: = label(text, size, color)
	node.add_theme_font_override("font", display_font())
	node.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.02, 0.9))
	node.add_theme_constant_override("outline_size", 4)
	return node


static func rich(text: String, size: int = 15, color: Color = PARCHMENT) -> RichTextLabel:
	var node: = RichTextLabel.new()
	node.bbcode_enabled = true
	node.fit_content = true
	node.scroll_active = false
	node.text = text
	node.add_theme_font_size_override("normal_font_size", size)
	node.add_theme_color_override("default_color", color)
	return node


static func button(text: String, minimum: Vector2 = Vector2(190, 40), accent: bool = false) -> Button:
	var node: = Button.new()
	node.text = text
	node.custom_minimum_size = minimum
	node.focus_mode = Control.FOCUS_ALL
	node.add_theme_font_size_override("font_size", 16)
	node.add_theme_color_override("font_color", PARCHMENT if not accent else Color(0.12, 0.09, 0.05))
	node.add_theme_color_override("font_hover_color", Color(1, 1, 1) if not accent else Color(0.08, 0.06, 0.03))
	node.add_theme_color_override("font_disabled_color", Color(0.45, 0.42, 0.38))
	var normal: = panel_style(Color(0.16, 0.13, 0.1, 0.98) if not accent else GOLD, GOLD_SOFT)
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover: = panel_style(Color(0.24, 0.19, 0.13, 0.98) if not accent else Color(0.95, 0.82, 0.45), GOLD)
	hover.content_margin_top = 8
	hover.content_margin_bottom = 8
	node.add_theme_stylebox_override("normal", normal)
	node.add_theme_stylebox_override("hover", hover)
	node.add_theme_stylebox_override("pressed", hover)
	node.add_theme_stylebox_override("focus", hover)
	node.add_theme_stylebox_override("disabled", panel_style(Color(0.1, 0.09, 0.08, 0.9), Color(0.3, 0.27, 0.22)))
	return node


static func bar(color: Color, height: float = 18.0) -> ProgressBar:
	var node: = ProgressBar.new()
	node.show_percentage = false
	node.custom_minimum_size = Vector2(0, height)
	node.max_value = 100.0
	node.value = 100.0
	var background: = StyleBoxFlat.new()
	background.bg_color = Color(0.06, 0.05, 0.05, 0.92)
	background.border_color = Color(0.3, 0.25, 0.18)
	background.set_border_width_all(1)
	background.set_corner_radius_all(3)
	var fill: = StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	node.add_theme_stylebox_override("background", background)
	node.add_theme_stylebox_override("fill", fill)
	return node


static func divider() -> ColorRect:
	var node: = ColorRect.new()
	node.color = Color(0.4, 0.34, 0.22, 0.7)
	node.custom_minimum_size = Vector2(0, 1)
	return node


static func spacer(height: float) -> Control:
	var node: = Control.new()
	node.custom_minimum_size = Vector2(0, height)
	return node


static func money_text(coins: int) -> String:
	var gold: = coins / 10000
	var silver: = (coins / 100) % 100
	var bronze: = coins % 100
	if gold > 0:
		return "%d ouro %d prata" % [gold, silver]
	if silver > 0:
		return "%d prata %d bronze" % [silver, bronze]
	return "%d bronze" % bronze


static func grade_name(level: int) -> String:
	return str(GameData.grade_for_level(level)["name"])
