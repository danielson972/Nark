extends RefCounted
## Shared dark-and-gold presentation for inventory and skills.

const INK = Color("19120e")
const GOLD = Color("b98a45")
const BRIGHT = Color("f2c768")
const CREAM = Color("f4e3ba")
const MUTED = Color("a28d70")

static func frame(fill: Color, border: Color, border_width: int = 2, padding: int = 8) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(2)
	style.corner_detail = 1
	style.set_content_margin_all(padding)
	return style

static func text(caption: String, font_size: int = 13, color: Color = CREAM, heading: bool = false) -> Label:
	var label: Label = UiKit.label(caption, font_size, color)
	if heading:
		label.add_theme_font_override("font", UiKit.display_font())
	return label

static func line(vertical: bool = false) -> ColorRect:
	var line: ColorRect = ColorRect.new()
	line.color = GOLD.darkened(0.22)
	line.custom_minimum_size = Vector2(1, 0) if vertical else Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

static func button(caption: String) -> Button:
	var button: Button = Button.new()
	button.text = caption
	button.custom_minimum_size.y = 30
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_font_override("font", UiKit.display_font())
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("75634f"))
	button.add_theme_stylebox_override("normal", frame(Color("332416"), GOLD, 2, 5))
	button.add_theme_stylebox_override("hover", frame(Color("50391b"), BRIGHT, 2, 5))
	button.add_theme_stylebox_override("pressed", frame(Color("62431c"), BRIGHT, 2, 5))
	button.add_theme_stylebox_override("focus", frame(Color(0, 0, 0, 0), BRIGHT, 2, 5))
	button.add_theme_stylebox_override("disabled", frame(Color("211b15"), Color("55432e"), 2, 5))
	return button

static func draw_corners(panel: Control) -> void:
	# Stepped corner ornaments mirror the reference without raster scaling.
	for corner in [Vector2(7, 7), Vector2(panel.size.x - 7, 7), Vector2(7, panel.size.y - 7), panel.size - Vector2(7, 7)]:
		var sx: float = 1.0 if corner.x < panel.size.x * 0.5 else -1.0
		var sy: float = 1.0 if corner.y < panel.size.y * 0.5 else -1.0
		panel.draw_line(corner, corner + Vector2(19 * sx, 0), BRIGHT, 2)
		panel.draw_line(corner, corner + Vector2(0, 19 * sy), BRIGHT, 2)
		panel.draw_polyline(PackedVector2Array([corner + Vector2(5 * sx, 15 * sy), corner + Vector2(5 * sx, 5 * sy), corner + Vector2(15 * sx, 5 * sy), corner + Vector2(15 * sx, 10 * sy), corner + Vector2(10 * sx, 10 * sy)]), GOLD, 2)
