extends Control
## Illustrated item atlas, with the original pixel art for empty/unknown slots.

const Catalog = preload("res://scripts/ui/item_catalog.gd")

var item_id: String = "":
	set(value):
		item_id = value
		if item_id == "hero":
			var glow := ShaderMaterial.new()
			glow.shader = preload("res://shaders/hero_aura.gdshader")
			material = glow
		else:
			material = null
		queue_redraw()
var class_id: String = "guerreiro":
	set(value):
		class_id = value
		queue_redraw()
var empty_slot: String = ""

const GOLD = Color("e6b657")
const LIGHT = Color("fff0b1")
const EDGE = Color("392316")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	resized.connect(queue_redraw)

func _draw() -> void:
	if not item_id.is_empty():
		var texture: Texture2D = Catalog.texture_for(item_id, class_id)
		if texture != null:
			var side: float = minf(size.x, size.y)
			var destination: Rect2 = Rect2(((size - Vector2.ONE * side) * 0.5).floor(), Vector2.ONE * side)
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
