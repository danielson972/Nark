extends RefCounted
## Shared attachment data for the world, inventory and assembly scene.
const FOLDER = "res://assets/game/character_builder/"
const HairLayout = preload("res://assets/game/character_builder/hair_layout_supplied.gd")
const FittedLayout = preload("res://assets/game/character_builder/fitted_layout.gd")
static var fitted_atlases: Dictionary = {}
static var fitted_frames: Dictionary = {}

static func fitted_hair_texture(state: PlayerState) -> AtlasTexture:
	var key: String = state.race_id + "_" + state.gender_id
	var frame_key: String = key + ":" + str(state.hair_style)
	if not fitted_frames.has(frame_key):
		if not fitted_atlases.has(key):
			fitted_atlases[key] = load(FOLDER + "fitted_" + key + ".png")
		var index: int = clampi(state.hair_style - 1, 0, 15)
		var bounds: Array = FittedLayout.RECTS[key][index]
		var texture := AtlasTexture.new()
		texture.atlas = fitted_atlases[key]
		texture.region = Rect2(index % 4 * 256 + bounds[0], index / 4 * 384 + bounds[1], bounds[2], bounds[3])
		texture.filter_clip = true
		fitted_frames[frame_key] = texture
	return fitted_frames[frame_key]

static func fitted_hair_destination(state: PlayerState) -> Rect2:
	var bounds: Array = FittedLayout.RECTS[state.race_id + "_" + state.gender_id][clampi(state.hair_style - 1, 0, 15)]
	var source: Rect2 = head_rect(state)
	var destination: Rect2 = head_destination(state)
	var factor: float = destination.size.x / source.size.x
	return Rect2(destination.position + (Vector2(bounds[0], bounds[1] - 32) - source.position) * factor, Vector2(bounds[2], bounds[3]) * factor)
const RACES = ["humano", "elfo", "orc", "anao"]
const HAIR_NAMES = ["Careca", "Desarrumado", "Lateral", "Cacheado", "Penteado", "Cortina", "Rebelde", "Curto", "Longo", "Ondulado", "Rabo de cavalo", "Coque", "Trança", "Rente", "Crista", "Volume", "Picos"]
const COLORS = {"castanho": Color("90664b"), "preto": Color("383641"), "ruivo": Color("bf6a42"), "loiro": Color("d7bd83"), "branco": Color("d9dbe0"), "azul": Color("617fab"), "roxo": Color("966a9f")}
const COLOR_NAMES = {"castanho": "Castanho", "preto": "Preto", "ruivo": "Ruivo", "loiro": "Loiro", "branco": "Branco", "azul": "Azul", "roxo": "Roxo"}
const HEADS = {"humano": Rect2(80, 20, 100, 113), "elfo": Rect2(69, 20, 120, 113), "orc": Rect2(77, 20, 108, 104), "anao": Rect2(74, 77, 112, 140)}
const SCALPS = {"humano": Rect2(88, 20, 81, 58), "elfo": Rect2(88, 20, 80, 58), "orc": Rect2(81, 20, 85, 56), "anao": Rect2(85, 77, 87, 54)}
const FEMALE_SCALPS = {"humano": Rect2(93, 20, 73, 56), "elfo": Rect2(91, 20, 75, 56), "orc": Rect2(95, 20, 71, 56), "anao": Rect2(84, 20, 85, 56)}
# Width, horizontal offset and height offset measured against each hairstyle's
# own silhouette. Ponytails and long strands must not move the skull anchor.
const HAIR_FITS = [
	Vector3(1.30, 2, -23), Vector3(1.30, 2, -22),
	Vector3(1.40, -2, -23), Vector3(1.28, 2, -30),
	Vector3(1.30, 3, -19), Vector3(1.32, 4, -22),
	Vector3(1.28, 3, -19), Vector3(1.34, 4, -22),
	Vector3(1.30, 6, -18), Vector3(1.32, 7, -25),
	Vector3(1.24, 3, -25), Vector3(1.30, 5, -25),
	Vector3(1.10, -2, -3), Vector3(1.36, -4, -17),
	Vector3(1.36, -4, -17), Vector3(1.36, -4, -18),
]
# Keep the same hairstyle profile while fitting the different skull proportions.
const RACE_HAIR_SCALE = {"humano": 1.0, "elfo": 0.98, "orc": 0.94, "anao": 1.0}
static var bodies: Texture2D
static var hairs: Texture2D
static var frames: Dictionary = {}
static var hair_frames: Dictionary = {}

static func bald_body(race_id: String, gender_id: String = "masculino") -> AtlasTexture:
	var key: String = race_id + ":" + gender_id
	if not frames.has(key):
		if bodies == null:
			bodies = load(FOLDER + "bald_races_supplied.png")
		var texture := AtlasTexture.new()
		texture.atlas = bodies
		texture.region = Rect2(maxi(RACES.find(race_id), 0) * 256, 512 if gender_id == "feminino" else 0, 256, 512)
		texture.filter_clip = true
		frames[key] = texture
	return frames[key]

static func armored(state: PlayerState) -> bool:
	var armor_id := str(state.equipment.get("armadura", {}).get("id", ""))
	return str(GameData.item(armor_id).get("type", "")) == "armadura"

static func head_rect(state: PlayerState) -> Rect2:
	if state.gender_id == "feminino" and state.race_id == "anao":
		return Rect2(78, 20, 108, 110)
	return HEADS.get(state.race_id, HEADS.humano)

static func head_destination(state: PlayerState) -> Rect2:
	var source: Rect2 = head_rect(state)
	if not armored(state):
		return source
	# The armor neckline is shared; racial ears, scalp and beard remain separate.
	var factor: float = 0.82 if state.race_id == "anao" else 0.84
	# Keep the bottom of the neck on the collar, including the shorter female
	# dwarf source. The former fixed 113px anchor enlarged and floated the face.
	return Rect2(Vector2(127, 128) - Vector2(source.size.x * 0.5, source.size.y) * factor, source.size * factor)

static func hair_texture(style: int) -> AtlasTexture:
	if style <= 0:
		return null
	if hairs == null:
		hairs = load(FOLDER + "hair_models_supplied.png")
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
	var width: float = scalp.size.x * fit.x * RACE_HAIR_SCALE.get(state.race_id, 1.0)
	var size := Vector2(width, width * texture.get_height() / texture.get_width())
	var top: float = scalp.position.y + fit.z * factor * scalp_rect(state).size.x / 80.0
	# Length belongs below the skull: a braid must reach the chest without
	# enlarging the crown or moving the fringe down over the eyes.
	size.y += strand_extension(state) * factor
	return Rect2(Vector2(scalp.get_center().x - size.x * 0.5 + fit.y * factor, top), size)

static func strand_extension(state: PlayerState) -> float:
	return 60.0 if state.hair_style == 12 else 0.0

static func scalp_rect(state: PlayerState) -> Rect2:
	if state.gender_id == "feminino":
		return FEMALE_SCALPS.get(state.race_id, FEMALE_SCALPS.humano)
	return SCALPS.get(state.race_id, SCALPS.humano)
