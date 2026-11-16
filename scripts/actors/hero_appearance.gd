extends RefCounted
## Full-body outfit frames and independent hand-held equipment.

const ATLAS_PATH = "res://assets/game/sprites/herois/compartilhados/equipamentos/hero_equipment_atlas.png"
const GRID = Vector2i(8, 6)
const CUTOUT_SHADER = preload("res://shaders/equipment_cutout.gdshader")
const CLASS_ROWS = {
	"atirador": 0, "mago": 1, "guerreiro": 2,
	"assassino": 3, "tank": 4, "cavaleiro": 5,
}
const OUTFIT_COLUMNS = {
	"": 0, "roupa_basica": 1, "armadura_ng": 2,
	"armadura_d": 3, "armadura_c": 4, "armadura_b": 5,
}
const FOOT_Y = 0.98
const HEAD_Y = 0.04
const HAND = Vector2(0.78, 0.65)
const SWORD_HANDS = [
	Vector2(0.395, 0.655), Vector2(0.395, 0.655),
	Vector2(0.395, 0.655), Vector2(0.395, 0.655),
	Vector2(0.395, 0.655), Vector2(0.395, 0.655),
]
const SWORD_GRIPS = {
	"arma_basica": Vector2(0.705, 0.285),
	"arma_ng": Vector2(0.745, 0.215),
	"arma_d": Vector2(0.740, 0.210),
	"arma_c": Vector2(0.735, 0.205),
	"arma_b": Vector2(0.805, 0.180),
}
# Per-class calibration; icon coordinates are normalized to the atlas cell.
# Grip order: training, NG, D, C, B.
const WEAPON_IDS = ["arma_basica", "arma_ng", "arma_d", "arma_c", "arma_b"]
const CLASS_GRIPS = {
	"atirador": [Vector2(0.415, 0.505), Vector2(0.34, 0.50), Vector2(0.34, 0.50), Vector2(0.34, 0.50), Vector2(0.34, 0.50)],
	"mago": [Vector2(0.40, 0.67), Vector2(0.36, 0.72), Vector2(0.36, 0.72), Vector2(0.36, 0.72), Vector2(0.36, 0.72)],
	"assassino": [Vector2(0.51, 0.24), Vector2(0.48, 0.20), Vector2(0.48, 0.20), Vector2(0.48, 0.20), Vector2(0.48, 0.20)],
	"tank": [Vector2(0.38, 0.72), Vector2(0.33, 0.74), Vector2(0.33, 0.74), Vector2(0.33, 0.74), Vector2(0.33, 0.74)],
	"cavaleiro": [Vector2(0.52, 0.52), Vector2(0.53, 0.45), Vector2(0.53, 0.45), Vector2(0.53, 0.45), Vector2(0.53, 0.45)],
}
const CLASS_HANDS = {
	"atirador": Vector2(0.795, 0.685), "mago": Vector2(0.365, 0.65),
	"assassino": Vector2(0.365, 0.65), "tank": Vector2(0.35, 0.65),
	"cavaleiro": Vector2(0.405, 0.655),
}
const CLASS_WEAPON_HEIGHTS = {
	"atirador": 0.58, "mago": 0.66, "guerreiro": 0.48,
	"assassino": 0.42, "tank": 0.52, "cavaleiro": 0.54,
}
static var atlas: Texture2D
static var frames: Dictionary = {}
static var hand_frames: Dictionary = {}
static var cutout: ShaderMaterial
static var weapon_materials: Dictionary = {}

static func cutout_material() -> ShaderMaterial:
	if cutout == null:
		cutout = ShaderMaterial.new()
		cutout.shader = CUTOUT_SHADER
	return cutout

static func weapon_material(state: PlayerState, texture: AtlasTexture) -> ShaderMaterial:
	var item_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	var key: String = state.class_id + ":" + item_id
	if not weapon_materials.has(key):
		var result: ShaderMaterial = ShaderMaterial.new()
		result.shader = CUTOUT_SHADER
		var atlas_size: Vector2 = texture.atlas.get_size()
		result.set_shader_parameter("texture_region", Vector4(texture.region.position.x / atlas_size.x,
			texture.region.position.y / atlas_size.y, texture.region.size.x / atlas_size.x, texture.region.size.y / atlas_size.y))
		result.set_shader_parameter("trim_grip", state.class_id == "guerreiro")
		result.set_shader_parameter("grip_position", weapon_pivot(state.class_id, item_id))
		result.set_shader_parameter("colossal", item_id == "arma_b")
		weapon_materials[key] = result
	return weapon_materials[key]

static func outfit_column(item_id: String) -> int:
	return int(OUTFIT_COLUMNS.get(item_id, 0))

static func frame(class_id: String, column: int) -> AtlasTexture:
	var row: int = int(CLASS_ROWS.get(class_id, 2))
	var key: Vector2i = Vector2i(column, row)
	if frames.has(key):
		return frames[key]
	if atlas == null:
		atlas = load(ATLAS_PATH)
	var texture: AtlasTexture = AtlasTexture.new()
	texture.atlas = atlas
	var cell_size: Vector2 = atlas.get_size() / Vector2(GRID)
	var start: Vector2 = (Vector2(key) * cell_size).floor()
	var finish: Vector2 = (Vector2(key + Vector2i.ONE) * cell_size).floor()
	texture.region = Rect2(start, finish - start)
	texture.filter_clip = true
	frames[key] = texture
	return texture

static func body_texture(state: PlayerState) -> AtlasTexture:
	var armor_id: String = str(state.equipment.get("armadura", {}).get("id", ""))
	return frame(state.class_id, outfit_column(armor_id))

static func hand_position(state: PlayerState) -> Vector2:
	if state.class_id == "guerreiro":
		var armor_id: String = str(state.equipment.get("armadura", {}).get("id", ""))
		return SWORD_HANDS[outfit_column(armor_id)]
	return CLASS_HANDS.get(state.class_id, HAND)

static func hand_rect(state: PlayerState) -> Rect2:
	# Reuse only the existing fingers/wrist, with their original transparency.
	return Rect2(hand_position(state) - Vector2(0.038, 0.043), Vector2(0.076, 0.086))

static func hand_texture(state: PlayerState) -> AtlasTexture:
	var body: AtlasTexture = body_texture(state)
	var key: Rect2 = body.region
	if not hand_frames.has(key):
		var patch: AtlasTexture = AtlasTexture.new()
		patch.atlas = body.atlas
		var rect: Rect2 = hand_rect(state)
		patch.region = Rect2(body.region.position + rect.position * body.region.size, rect.size * body.region.size)
		patch.filter_clip = true
		hand_frames[key] = patch
	return hand_frames[key]

static func weapon_pivot(class_id: String, item_id: String = "") -> Vector2:
	if class_id == "guerreiro":
		return SWORD_GRIPS.get(item_id, SWORD_GRIPS["arma_ng"])
	var grips: Array = CLASS_GRIPS.get(class_id, [])
	var index: int = WEAPON_IDS.find(item_id)
	return Vector2(0.28, 0.76) if grips.is_empty() else grips[maxi(index, 0)]

static func weapon_height(class_id: String) -> float:
	return CLASS_WEAPON_HEIGHTS.get(class_id, 0.48)

# Rest pose follows the reference: bow across the waist, staff upward-left,
# blades and heavy weapons downward-left, spear across the body.
static func weapon_rotation(class_id: String) -> float:
	match class_id:
		"atirador": return deg_to_rad(-115.0)
		"mago": return deg_to_rad(-47.0)
		"tank": return deg_to_rad(-165.0)
		"cavaleiro": return deg_to_rad(-160.0)
		_: return 0.0

static func weapon_layer(class_id: String) -> int:
	# A spear crosses behind the torso; the fingers remain above the shaft.
	return -1 if class_id == "cavaleiro" else 1
