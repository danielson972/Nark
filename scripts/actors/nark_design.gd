extends RefCounted
## New supplied 64px assets. Shared composition for creation, world and portrait.
const ROOT = "res://assets/game/sprites/"
const DIRECTIONS = ["s", "so", "o", "no", "n", "ne", "l", "se"]
const HAIRS = ["", "curto_de_lado", "ondas_curtas", "franja_lisa", "moicano", "curto_lilas", "ondas_longas", "longo_liso", "trancas_orc", "trancas_anas", "longo_elarim"]
const BEARDS = ["", "barba_rala", "cavanhaque", "quadrada", "bifurcada", "curta_prateada"]
const ARMOR_SLOTS = ["elmo", "peito", "luvas", "calca", "botas"]
const TARGETS = {"elmo": Rect2(19, 1, 26, 23), "peito": Rect2(18, 33, 28, 14), "luvas": Rect2(13, 39, 38, 9), "calca": Rect2(20, 46, 24, 11), "botas": Rect2(18, 55, 28, 8)}
static var images: Dictionary = {}
static var frames: Dictionary = {}
static var icons: Dictionary = {}
static var weapon_paths: Dictionary = {}

static func image_at(path: String) -> Image:
	if not images.has(path):
		var texture: Texture2D = load(path)
		var source: Image = texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		images[path] = source
	return images[path]

static func direction_row(direction: Vector2) -> int:
	if direction.length_squared() < 0.001: return 0
	return posmod(roundi((direction.angle() - PI * 0.5) / (PI * 0.25)), 8)

static func weapon_path(item_id: String, class_id: String) -> String:
	if weapon_paths.is_empty():
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "arsenal/armas/arsenal.json"))
		for entry: Dictionary in data.itens:
			weapon_paths["arsenal_" + entry.id] = ROOT + "arsenal/armas/" + entry.sprite
	if weapon_paths.has(item_id): return weapon_paths[item_id]
	var kind: String = str(GameData.item(item_id).get("type", ""))
	if kind not in ["arma", "escudo"]: return ""
	var starts: Dictionary = {"guerreiro": 1, "tank": 16, "assassino": 31, "atirador": 46, "mago": 61, "cavaleiro": 76}
	var grade: String = str(GameData.item(item_id).get("grade", "NG"))
	var offset: int = {"NG": 0, "D": 3, "C": 5, "B": 8, "A": 11, "S": 13}.get(grade, 0)
	var number: int = 89 + mini(offset, 11) if kind == "escudo" else int(starts.get(class_id, 1)) + offset
	return str(weapon_paths.get("arsenal_%03d" % number, ""))

static func armor_path(item_id: String, class_id: String, slot: String = "peito") -> String:
	var data: Dictionary = GameData.item(item_id)
	if data.has("sprite_path"): return str(data.sprite_path)
	if str(data.get("type", "")) != "armadura": return ""
	var grade: String = str(data.get("grade", "NG")).to_lower()
	if grade == "ng": grade = "no_grade"
	var job: String = {"tank": "guerreiro", "atirador": "arqueiro"}.get(class_id, class_id)
	# The supplied pack has five armor classes; tank uses warrior pieces.
	var path: String = ROOT + "arsenal/sprites/%s/%s/%s.png" % [job, grade, slot]
	return path if ResourceLoader.exists(path) else ""

static func icon(item_id: String, class_id: String) -> AtlasTexture:
	var path: String = armor_path(item_id, class_id)
	if path.is_empty(): path = weapon_path(item_id, class_id)
	if path.is_empty(): return null
	if not icons.has(path):
		var texture := AtlasTexture.new()
		texture.atlas = load(path)
		texture.region = Rect2(image_at(path).get_used_rect())
		texture.filter_clip = true
		icons[path] = texture
	return icons[path]

static func stamp(canvas: Image, path: String, target: Rect2, tint: Color = Color.WHITE, mirror: bool = false) -> void:
	if path.is_empty(): return
	var source: Image = image_at(path)
	var piece: Image = source.get_region(source.get_used_rect())
	piece.resize(maxi(1, roundi(target.size.x)), maxi(1, roundi(target.size.y)), Image.INTERPOLATE_NEAREST)
	if mirror: piece.flip_x()
	if tint != Color.WHITE:
		for y in piece.get_height():
			for x in piece.get_width():
				piece.set_pixel(x, y, piece.get_pixel(x, y) * tint)
	canvas.blend_rect(piece, Rect2i(Vector2i.ZERO, piece.get_size()), Vector2i(target.position))

static func body(state: PlayerState, row: int = 0, frame: int = 0, held_items: bool = true, walking: bool = false) -> AtlasTexture:
	row = clampi(row, 0, 7)
	frame = posmod(frame, 6)
	var equipped_ids: Array = []
	for slot: String in PlayerState.EQUIP_SLOTS:
		equipped_ids.append(str(state.equipment.get(slot, {}).get("id", "")))
	var key: String = "%s:%s:%s:%s:%s:%s:%s:%s:%s:%d:%d" % [state.race_id, state.gender_id, state.body_type, state.class_id, state.hair_style, state.hair_color, state.beard_style, state.beard_color, str(equipped_ids), row, frame]
	key += str(held_items) + str(walking)
	if frames.has(key): return frames[key]
	var identity: String = "%s/%s/%s/%s" % [state.race_id, state.gender_id, state.body_type, DIRECTIONS[row]]
	var path: String = ROOT + "heroi/topdown/" + ("andando/" + identity + "/%02d.png" % (frame + 1) if walking else "parado/" + identity + ".png")
	var canvas: Image = image_at(path).duplicate()
	var body_bounds: Rect2i = canvas.get_used_rect()
	var head_top: float = body_bounds.position.y + 1
	var body_height: float = body_bounds.end.y - head_top
	var center_x: float = body_bounds.get_center().x
	var rear: bool = row in [3, 4, 5]
	var side: bool = row in [2, 6]
	var mirror: bool = row in [5, 6, 7]
	var step: float = [0.0, -1.0, 0.0, 1.0, 0.0, -1.0][frame] if walking else 0.0
	var body_width: float = {"magro": 0.88, "medio": 1.0, "forte": 1.12}.get(state.body_type, 1.0)
	for slot: String in ["calca", "botas", "peito", "luvas"]:
		var item_id: String = str(state.equipment.get(slot, {}).get("id", ""))
		var armor: String = armor_path(item_id, state.class_id, slot)
		if item_id.is_empty(): armor = armor_path(str(state.equipment.get("armadura", {}).get("id", "")), state.class_id, slot)
		var layout: Dictionary = {"peito": Vector3(.23,.30,18), "luvas": Vector3(.38,.12,24), "calca": Vector3(.53,.26,16), "botas": Vector3(.79,.21,18)}
		var fit: Vector3 = layout[slot]
		var target: Rect2 = Rect2(0, head_top + body_height * fit.x, fit.z, body_height * fit.y)
		target.size.x *= body_width * (0.62 if side else 1.0)
		target.position.x = center_x - target.size.x * 0.5
		target.position.y += step
		stamp(canvas, armor, target, Color("b3b3b3") if rear else Color.WHITE, mirror)
	var hair: int = clampi(state.hair_style, 0, HAIRS.size() - 1)
	if hair > 0:
		var hair_width: float = 12.0 * (0.75 if side else 1.0)
		stamp(canvas, ROOT + "heroi/cabelos/topdown/%02d.png" % hair, Rect2(center_x-hair_width*.5, head_top-1, hair_width, 6 if hair < 6 else 16), preload("res://scripts/actors/character_customization.gd").COLORS.get(state.hair_color, Color.WHITE), mirror)
	var beard: int = clampi(state.beard_style, 0, BEARDS.size() - 1)
	if beard > 0 and not rear:
		var color: Color = Color.WHITE if state.beard_color == "original" else preload("res://scripts/actors/character_customization.gd").COLORS.get(state.beard_color, Color.WHITE)
		stamp(canvas, ROOT + "heroi/barbas/topdown/%02d.png" % beard, Rect2(center_x-3, head_top+6, 6, 5), color, mirror)
	var helmet: String = str(state.equipment.get("elmo", {}).get("id", ""))
	stamp(canvas, armor_path(helmet, state.class_id), Rect2(center_x-6, head_top, 12, 11), Color.WHITE, mirror)
	var weapon: String = str(state.equipment.get("arma", {}).get("id", ""))
	var shield: String = str(state.equipment.get("escudo", {}).get("id", ""))
	if held_items: stamp(canvas, weapon_path(weapon, state.class_id), Rect2(4 if not mirror else 46, 29 + step, 14, 28), Color.WHITE, mirror)
	if held_items: stamp(canvas, weapon_path(shield, state.class_id), Rect2(42 if not mirror else 4, 32 + step, 18, 22), Color.WHITE, mirror)
	var texture := AtlasTexture.new()
	texture.atlas = ImageTexture.create_from_image(canvas)
	texture.region = Rect2(0, 0, 64, 64)
	texture.filter_clip = true
	# Bound long sessions while retaining all frames of the current appearance.
	if frames.size() > 2048: frames.clear()
	frames[key] = texture
	return texture
