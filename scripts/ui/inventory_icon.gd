extends Control
## Illustrated item atlas, with the original pixel art for empty/unknown slots.

const Catalog = preload("res://scripts/ui/item_catalog.gd")

var item_id: String = "":
	set(value):
		item_id = value
		queue_redraw()
var class_id: String = "guerreiro":
	set(value):
		class_id = value
		queue_redraw()
var empty_slot: String = ""
# Slots reserve a few pixels around the art; extend only the backdrop into them.
var background_padding: Vector2 = Vector2.ZERO

const GOLD = Color("e6b657")
const LIGHT = Color("fff0b1")
const EDGE = Color("392316")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)

func _draw() -> void:
	if not item_id.is_empty():
		var is_armor: bool = str(GameData.item(item_id).get("type", "")) == "armadura"
		var filtering: int = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS if is_armor else CanvasItem.TEXTURE_FILTER_NEAREST
		if texture_filter != filtering:
			texture_filter = filtering
		_draw_item_background()
		var texture: Texture2D = Catalog.icon_texture_for(item_id, class_id)
		if texture != null:
			var side: float = minf(size.x, size.y)
			var destination: Rect2 = Rect2(((size - Vector2.ONE * side) * 0.5).floor(), Vector2.ONE * side)
			if str(GameData.item(item_id).get("type","")) == "armadura":
				var factor: float = maxf(side-8,1.0)/maxf(texture.get_width(),texture.get_height())
				var drawn_size: Vector2 = texture.get_size()*factor
				destination = Rect2((size-drawn_size)*0.5,drawn_size)
			draw_texture_rect(texture, destination, false)
			return
	var kind: String = str(GameData.item(item_id).get("type", "")) if not item_id.is_empty() else empty_slot
	var color: Color = GOLD
	if item_id.ends_with("_d"):
		color = Color("bdc9d5")
	elif item_id.ends_with("_c"):
		color = Color("99b7e5")
	elif item_id.ends_with("_b"):
		color = Color("d19bdb")
	if item_id.is_empty():
		color = Color("65503a")
	var pixels: Array[String] = []
	match kind:
		"arma":
			pixels = [".............ee.", "............elle", "...........elle.", "..........elle..", ".........elle...", "........elle....", ".......elle.....", "......elle......", "..e..elle.......", "..ceelle........", "...ccce.........", "...ecce.........", "..ece.ce........", ".ece..e.........", ".ce.............", "..e............."]
		"armadura":
			pixels = ["................", "...ee......ee...", "..ecceeeeecce...", ".ecccceeecccce..", "eccclccccclccce.", "ecccclccclcccce.", ".eeccclllcccee..", "...eccclccce....", "...ecccclcce....", "...eccccc cce...", "...eeeeeeeee....", "...eccccccce....", "...ecccclcce....", "..eccccclccce...", "..eeeeeeeeeee...", "................"]
		"joia":
			pixels = ["................", "......eeee......", ".....ecllce.....", "......ecce......", "....eeeeeeee....", "...ecllllllce...", "..eclceeecllce..", "..eclce..eclce..", "..eclce..eclce..", "..eclce..eclce..", "..eclceeecllce..", "...ecllllllce...", "....eeeeeeee....", "................", "................", "................"]
		"consumivel":
			color = Color("509de8") if item_id == "pocao_mana" else (Color("e9c34e") if item_id == "pocao_energia" else Color("ca3150"))
			pixels = ["......eeee......", ".....ecccce.....", ".....elllle.....", "......ecce......", "......elle......", ".....el..le.....", "....el....le....", "...elccccccle...", "..elclccccccle..", "..elclccccccce..", "..elclccccccce..", "..elccccccccce..", "...ecccccccce...", "....eeeeeeee....", "................", "................"]
		"livro":
			color = Color("81a1c2")
			pixels = ["................", "...eeeeeeeee....", "..elccccccce....", "..elccllccce....", "..elcllll cce...", "..elccllccce....", "..elccccccce....", "..elccccccce....", "..elccccccce....", "..elccccccce....", "..elccccccce....", "..elllllllle....", "...eeeeeeeee....", "................", "................", "................"]
		"chave":
			pixels = ["................", ".....eeeeee.....", "....ecllllce....", "....elceecle....", "....elceecle....", "....ecllllce....", ".....eclle......", "......elle......", "......elle......", "......elllle....", "......elleee....", "......elllle....", "......eeeee.....", "................", "................", "................"]
		_:
			if item_id.contains("cristal") or item_id.contains("essencia"):
				color = Color("88c9cf")
			elif item_id == "gosma":
				color = Color("95b66c")
			elif item_id == "sucata_ferro":
				color = Color("a9b3bb")
			pixels = ["................", "................", ".......ee.......", "......ecle......", ".....ecccle.....", "....ecccclle....", "...ecccccllle...", "..ecccccccllle..", "..ecccccccclle..", "...ecccccccle...", "....ecccccle....", ".....ecccle.....", "......eeee......", "................", "................", "................"]
	if item_id.is_empty() and empty_slot.is_empty():
		return
	var unit: float = maxf(1.0, floorf(minf(size.x, size.y) / 18.0))
	var origin: Vector2 = (size - Vector2(16, 16) * unit) * 0.5
	for y in pixels.size():
		for x in mini(pixels[y].length(), 16):
			var symbol: String = pixels[y][x]
			if symbol not in ["e", "c", "l"]:
				continue
			var ink: Color = EDGE if symbol == "e" else (LIGHT if symbol == "l" else color)
			if item_id.is_empty():
				ink = Color("65503a") if symbol != "e" else Color("30271e")
			draw_rect(Rect2(origin + Vector2(x, y) * unit, Vector2.ONE * unit), ink)

func _background_color() -> Color:
	var data: Dictionary = GameData.item(item_id)
	# Higher equipment grades share a palette across weapons, armor and jewelry.
	match str(data.get("grade", "NG")):
		"D": return Color("44566a")
		"C": return Color("244f70")
		"B": return Color("59355f")
		"A": return Color("80602f")
		"S": return Color("9a6b26")
	match item_id:
		"hero": return Color("73602b")
		"pocao_cura": return Color("652f36")
		"pocao_mana": return Color("284b76")
		"pocao_energia": return Color("726024")
		"gosma": return Color("355239")
		"cristal_aurora", "essencia_errante": return Color("26585d")
		"sucata_ferro", "carapaca_branca": return Color("49514c")
	match str(data.get("type", "")):
		"arma": return Color("614333")
		"armadura": return Color("355044")
		"joia", "chave": return Color("6a542c")
		"livro": return Color("45365e")
		"material": return Color("4e4936")
	return Color("364c49")

func _draw_item_background() -> void:
	var area := Rect2(-background_padding, size + background_padding * 2.0)
	if area.size.x < 2.0 or area.size.y < 2.0:
		return
	var base: Color = _background_color()
	# Crisp horizontal bands avoid introducing a filtered texture or changing the art.
	var rows: int = maxi(1, ceili(area.size.y))
	for y in rows:
		var t: float = float(y) / maxf(1.0, float(rows - 1))
		var glow: float = 1.0 - absf(t - 0.38) / 0.62
		var ink: Color = base.darkened(0.58).lerp(base, clampf(glow, 0.0, 1.0) * 0.78)
		draw_rect(Rect2(area.position + Vector2(0, y), Vector2(area.size.x, minf(1.0, area.size.y - y))), ink)
	draw_rect(area, base.darkened(0.72), false, 1.0)
	var highlight: Color = base.lightened(0.25)
	highlight.a = 0.45
	draw_line(area.position + Vector2.ONE, area.position + Vector2(area.size.x - 2, 1), highlight, 1.0)
