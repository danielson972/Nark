extends Control
## Pixel silhouettes for skill slots; colors also distinguish combat roles.

var definition: Dictionary = {}
var learned: bool = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if definition.is_empty():
		return
	var handler: String = str(definition.get("handler", ""))
	var skill_id: String = str(definition.get("id", ""))
	var category: String = "blade"
	if handler in ["projectile", "cone_shot", "arrow_rain"] or "tiro" in skill_id or "flecha" in skill_id:
		category = "arrow"
	elif handler in ["dash", "dash_strike", "teleport"] or "passo" in skill_id or "investida" in skill_id or "carga" in skill_id:
		category = "movement"
	elif "gel" in skill_id:
		category = "ice"
	elif "arcano" in skill_id or "cometa" in skill_id:
		category = "magic"
	elif "escudo" in skill_id or "guarda" in skill_id or "bastiao" in skill_id or "juramento" in skill_id:
		category = "shield"
	elif handler in ["buff", "banner"] or "aura" in skill_id or "impeto" in skill_id:
		category = "aura"
	elif str(definition.get("type", "")) == "passiva":
		category = "eye"
	var shapes: Dictionary = {
		"blade": ["............ee..", "...........elle.", "..........elle..", ".........elle...", "........elle....", ".......elle.....", "......elle......", ".....elle.......", "..e.elle........", "..ceelle........", "...ccce.........", "...ecce.........", "..ece.ce........", ".ece..e.........", ".ce.............", "..e............."],
		"arrow": ["................", ".......e........", "......ece.......", ".....eclce......", "....eclllce.....", "...ecllll lce...", ".....eclce......", "......el e......", "......el e......", "......el e......", ".....eclce......", "....eclllce.....", "...ecllel lce...", ".....eclce......", "......eee.......", "................"],
		"movement": ["................", "........e.......", ".......ece......", "......ecce......", "..eeeeccce......", ".eclllccce......", "..eeeeccce......", "......ecce......", ".......ece......", "........e.......", "...eeee.........", "..eclce.........", "...eccllee......", "...ecccccle.....", "....eeeeeee.....", "................"],
		"shield": ["................", "...eeeeeeeeee...", "..ecllllllllce..", "..elcccclcccle..", "..elcccclcccle..", "..elllllllllle..", "..elcccclcccle..", "..elcccclcccle..", "...elccclccle...", "...elccclccle...", "....elcclcle....", ".....elclle.....", "......elle......", ".......ee.......", "................", "................"],
		"magic": ["................", "......eeee......", ".....ecclle.....", "....ecccllle....", "...eccclllcce...", "..ecccclllccce..", "..eccccllcccce..", "...ecccllccce...", "....ecllccce....", ".....ecllce.....", "......elle......", ".....ecllce.....", "....eclllcce....", ".....eeeeee.....", "................", "................"],
		"ice": [".......e........", "...e...le...e...", "....e..le..e....", ".....eclece.....", "......cllc......", ".ee...cllc...ee.", "..clllcllclllc..", "...cllllllllc...", "..clllcllclllc..", ".ee...cllc...ee.", "......cllc......", ".....eclece.....", "....e..le..e....", "...e...le...e...", ".......e........", "................"],
		"aura": [".......e........", "......ele.......", "......ece.......", "...e..ece..e....", "....eccccce.....", "....eclllce.....", ".eeecclllcceee..", "elcccclllccc cle.", ".eeecclllcceee..", "....eclllce.....", "....eccccce.....", "...e..ece..e....", "......ece.......", "......ele.......", ".......e........", "................"],
		"eye": ["................", "................", ".....eeeeee.....", "...eeccllccee...", "..eclllllll lce..", ".ecllleeellllce.", "eclllecccellllce", ".ecllleeellllce.", "..ecllllllllce..", "...eeccllccee...", ".....eeeeee.....", "................", ".......ee.......", "......ecce......", ".......ee.......", "................"],
	}
	var colors: Dictionary = {"blade": Color("e6b657"), "arrow": Color("9fc9b1"), "movement": Color("72b8ba"), "shield": Color("c3a56d"), "magic": Color("b494db"), "ice": Color("87cde2"), "aura": Color("efd879"), "eye": Color("b0be88")}
	var color: Color = colors[category]
	var unit: float = maxf(1, floorf(minf(size.x, size.y) / 16.0))
	var origin: Vector2 = (size - Vector2(16, 16) * unit) * 0.5
	var pixels: Array = shapes[category]
	for y in pixels.size():
		for x in mini(str(pixels[y]).length(), 16):
			var symbol: String = pixels[y][x]
			if symbol not in ["e", "c", "l"]:
				continue
			var ink: Color = Color("392316") if symbol == "e" else (Color("fff0b1") if symbol == "l" else color)
			if not learned:
				ink = ink.lerp(Color("332b24"), 0.7)
			draw_rect(Rect2(origin + Vector2(x, y) * unit, Vector2.ONE * unit), ink)
