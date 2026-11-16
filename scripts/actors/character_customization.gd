extends RefCounted
## Shared attachment data for the world, inventory and assembly scene.
const FOLDER = "res://assets/game/character_builder/"
const HairLayout = preload("res://assets/game/character_builder/hair_layout.gd")
const RACES = ["humano", "elfo", "orc", "anao"]
const HAIR_NAMES = ["Careca", "Desarrumado", "Lateral", "Cacheado", "Penteado", "Cortina", "Rebelde", "Curto", "Longo", "Ondulado", "Rabo de cavalo", "Coque", "Trança", "Espetado", "Crista", "Volume", "Picos"]
const COLORS = {"castanho": Color("90664b"), "preto": Color("383641"), "ruivo": Color("bf6a42"), "loiro": Color("d7bd83"), "branco": Color("d9dbe0"), "azul": Color("617fab"), "roxo": Color("966a9f")}
const COLOR_NAMES = {"castanho": "Castanho", "preto": "Preto", "ruivo": "Ruivo", "loiro": "Loiro", "branco": "Branco", "azul": "Azul", "roxo": "Roxo"}
const HEADS = {"humano": Rect2(80, 20, 100, 113), "elfo": Rect2(69, 20, 120, 113), "orc": Rect2(77, 20, 108, 104), "anao": Rect2(74, 82, 112, 140)}
const SCALPS = {"humano": Rect2(88, 20, 81, 58), "elfo": Rect2(88, 20, 80, 58), "orc": Rect2(81, 20, 85, 56), "anao": Rect2(85, 82, 87, 54)}
const FEMALE_SCALPS = {"humano": Rect2(93, 20, 73, 56), "elfo": Rect2(91, 20, 75, 56), "orc": Rect2(95, 20, 71, 56), "anao": Rect2(84, 20, 85, 56)}
# Width, horizontal offset and height offset measured against each hairstyle's
# own silhouette. Ponytails and long strands must not move the skull anchor.
const HAIR_FITS = [
	Vector3(1.48, 0, -30), Vector3(1.48, 0, -28),
	Vector3(1.45, 0, -30), Vector3(1.45, 0, -38),
	Vector3(1.40, 0, -21), Vector3(1.50, 0, -23),
	Vector3(1.38, 0, -30), Vector3(1.52, 0, -24),
	Vector3(1.52, 0, -25), Vector3(1.55, 0, -30),
	Vector3(1.35, 0, -30), Vector3(1.45, 0, -30),
	Vector3(1.30, 0, -14), Vector3(1.35, 0, -24),
	Vector3(1.35, 0, -22), Vector3(1.35, 0, -24),
]
static var bodies: Texture2D
static var hairs: Texture2D
static var frames: Dictionary = {}
static var hair_frames: Dictionary = {}

static func bald_body(race_id: String, gender_id: String = "masculino") -> AtlasTexture:
	var key: String = race_id + ":" + gender_id
	if not frames.has(key):
		if bodies == null:
			bodies = load(FOLDER + "bald_races.png")
		var texture := AtlasTexture.new()
		texture.atlas = bodies
		texture.region = Rect2(maxi(RACES.find(race_id), 0) * 256, 512 if gender_id == "feminino" else 0, 256, 512)
		texture.filter_clip = true
		frames[key] = texture
	return frames[key]

static func armored(state: PlayerState) -> bool:
	return str(state.equipment.get("armadura", {}).get("id", "")) in ["armadura_ng", "armadura_d", "armadura_c", "armadura_b"]

static func head_rect(state: PlayerState) -> Rect2:
	if state.gender_id == "feminino" and state.race_id == "anao":
		return Rect2(78, 20, 108, 110)
	return HEADS.get(state.race_id, HEADS.humano)

static func head_destination(state: PlayerState) -> Rect2:
	var source: Rect2 = head_rect(state)
	if not armored(state):
		return source
	# The armor neckline is shared; racial ears, scalp and beard remain separate.
	var factor: float = 0.95 if state.race_id == "anao" else 1.0
	return Rect2(Vector2(127, 128) - Vector2(source.size.x * 0.5, 113) * factor, source.size * factor)

static func hair_texture(style: int) -> AtlasTexture:
	if style <= 0:
		return null
	if hairs == null:
		hairs = load(FOLDER + "hair_models.png")
	var index: int = clampi(style - 1, 0, 15)
	if hair_frames.has(index):
		return hair_frames[index]
	var bounds: Array = HairLayout.RECTS[index]
	var texture := AtlasTexture.new()
	texture.atlas = hairs
	texture.region = Rect2(index % 4 * 512 + int(bounds[0]), index / 4 * 512 + int(bounds[1]), int(bounds[2]), int(bounds[3]))
	texture.filter_clip = true
	hair_frames[index] = texture
	return texture

static func hair_destination(state: PlayerState) -> Rect2:
	var scalp: Rect2 = scalp_rect(state)
	var original: Rect2 = head_rect(state)
	var destination: Rect2 = head_destination(state)
	var factor: float = destination.size.x / original.size.x
	scalp = Rect2(destination.position + (scalp.position - original.position) * factor, scalp.size * factor)
	var texture := hair_texture(state.hair_style)
	if texture == null:
		return Rect2()
	var fit: Vector3 = HAIR_FITS[state.hair_style - 1]
	var width: float = scalp.size.x * fit.x
	var size := Vector2(width, width * texture.get_height() / texture.get_width())
	var top: float = scalp.position.y + fit.z * factor * scalp_rect(state).size.x / 80.0
	return Rect2(Vector2(scalp.get_center().x - size.x * 0.5 + fit.y * factor, top), size)

static func scalp_rect(state: PlayerState) -> Rect2:
	if state.gender_id == "feminino":
		return FEMALE_SCALPS.get(state.race_id, FEMALE_SCALPS.humano)
	return SCALPS.get(state.race_id, SCALPS.humano)
