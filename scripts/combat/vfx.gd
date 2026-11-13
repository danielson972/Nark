class_name Vfx
extends Node2D


var mode: = "burst"
var life: = 0.6
var elapsed: = 0.0
var color: = Color.WHITE
var parts: Array = []
var label: Label = null
var rise: = 52.0


static func floating_text(world: Node, pos: Vector2, text: String, tint: Color, big: bool = false) -> Vfx:
	var node: = Vfx.new()
	node.mode = "text"
	node.color = tint
	node.life = 0.95 if big else 0.8
	node.position = pos
	var caption: = Label.new()
	caption.text = text
	caption.add_theme_font_size_override("font_size", 30 if big else 22)
	caption.add_theme_color_override("font_color", tint)
	caption.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.06, 0.95))
	caption.add_theme_constant_override("outline_size", 6)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.position = Vector2(-70, -14)
	caption.size = Vector2(140, 32)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(caption)
	node.label = caption
	node.z_index = 30
	world.add_child(node)
	return node


static func burst(world: Node, pos: Vector2, tint: Color, count: int = 8, power: float = 120.0) -> Vfx:
	var node: = Vfx.new()
	node.mode = "burst"
	node.color = tint
	node.life = 0.42
	node.position = pos
	node.z_index = 25
	for index in count:
		var angle: = TAU * float(index) / float(maxi(1, count)) + randf_range(-0.2, 0.2)
		node.parts.append({
			"dir": Vector2(cos(angle), sin(angle)), 
			"speed": randf_range(power * 0.5, power), 
			"size": randf_range(2.5, 5.5), 
		})
	world.add_child(node)
	return node


func _process(delta: float) -> void :
	elapsed += delta
	var progress: = clampf(elapsed / maxf(0.01, life), 0.0, 1.0)
	if mode == "text":
		if label != null:
			label.position.y = -14.0 - rise * progress
			label.modulate.a = 1.0 - maxf(0.0, progress - 0.55) / 0.45
	else:
		queue_redraw()
	if progress >= 1.0:
		queue_free()


func _draw() -> void :
	if mode != "burst":
		return
	var progress: = clampf(elapsed / maxf(0.01, life), 0.0, 1.0)
	for part: Dictionary in parts:
		var offset: Vector2 = part["dir"] * float(part["speed"]) * elapsed * (1.0 - progress * 0.45)
		var alpha: = 1.0 - progress
		draw_circle(offset, float(part["size"]) * (1.0 - progress * 0.6), Color(color.r, color.g, color.b, alpha))
