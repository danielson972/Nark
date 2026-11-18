extends RefCounted
## Full-body outfit frames and independent hand-held equipment.

const ATLAS_PATH = "res://assets/game/sprites/herois/compartilhados/equipamentos/hero_equipment_atlas.png"
const HUMAN_ATLAS_PATH = "res://assets/game/sprites/herois/humano/human_equipment_atlas_vibrant.png"
const Custom = preload("res://scripts/actors/character_customization.gd")
const WornLayout = {"HANDS": {}}
const Design = preload("res://scripts/actors/nark_design.gd")
const HUMAN_GRID = Vector2i(6, 6)
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
static var human_atlas: Texture2D
static var human_frames: Dictionary = {}
static var frames: Dictionary = {}
static var hand_frames: Dictionary = {}
static var cutout: ShaderMaterial
static var weapon_materials: Dictionary = {}
static var body_materials: Dictionary = {}
static var catalog_bodies: Dictionary = {}
static var world_materials: Dictionary = {}
static var shield_materials: Dictionary = {}
const WORN_CATALOG_FOLDER = "res://assets/game/sprites/herois/armaduras_vestidas/"

static func world_material(source: ShaderMaterial) -> ShaderMaterial:
	var key: int = source.get_instance_id()
	if not world_materials.has(key):
		var material: ShaderMaterial = source.duplicate()
		material.set_shader_parameter("world_antialiasing",true)
		world_materials[key] = material
	return world_materials[key]

static func cutout_material() -> ShaderMaterial:
	if cutout == null:
		cutout = ShaderMaterial.new()
		cutout.shader = CUTOUT_SHADER
	return cutout

static func body_material(state: PlayerState) -> ShaderMaterial:
	var key: String = "%s:%s:%s:%s" % [state.race_id, state.gender_id, state.class_id, state.equipment.get("armadura", {}).get("id", "")]
	if not body_materials.has(key):
		var result := ShaderMaterial.new()
		result.shader = CUTOUT_SHADER
		var body := body_texture(state)
		var texture_size: Vector2 = body.atlas.get_size()
		result.set_shader_parameter("texture_region", Vector4(body.region.position.x / texture_size.x, body.region.position.y / texture_size.y, body.region.size.x / texture_size.x, body.region.size.y / texture_size.y))
		result.set_shader_parameter("head_cutoff", 0.0)
		result.set_shader_parameter("orc_skin", false)
		body_materials[key] = result
	return body_materials[key]

static func weapon_material(state: PlayerState, texture: AtlasTexture) -> ShaderMaterial:
	var item_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	var key: String = state.class_id + ":" + item_id
	if not weapon_materials.has(key):
		var result: ShaderMaterial = ShaderMaterial.new()
		result.shader = CUTOUT_SHADER
		var atlas_size: Vector2 = texture.atlas.get_size()
		result.set_shader_parameter("texture_region", Vector4(texture.region.position.x / atlas_size.x,
			texture.region.position.y / atlas_size.y, texture.region.size.x / atlas_size.x, texture.region.size.y / atlas_size.y))
		result.set_shader_parameter("trim_grip", state.class_id == "guerreiro" and _catalog_weapon_group(item_id).is_empty())
		result.set_shader_parameter("grip_position", weapon_pivot(state.class_id, item_id))
		result.set_shader_parameter("colossal", item_id == "arma_b")
		weapon_materials[key] = result
	return weapon_materials[key]

static func outfit_column(item_id: String) -> int:
	if item_id.begins_with("armadura_catalogo_"):
		var grade := str(GameData.item(item_id).get("grade", "NG"))
		return {"NG": 2, "D": 3, "C": 4, "B": 5, "A": 5, "S": 5}.get(grade, 2)
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
	return Design.body(state)

static func catalog_body(state: PlayerState, item_id: String) -> AtlasTexture:
	var key: String = item_id + ":" + state.gender_id
	if not catalog_bodies.has(key):
		var number: int = int(str(GameData.item(item_id).get("catalog_art", "")).trim_prefix("armadura_"))
		var worn_path: String = WORN_CATALOG_FOLDER + "armadura_%03d.png" % number
		var worn := AtlasTexture.new()
		worn.atlas = load(worn_path)
		worn.region = Rect2(Vector2.ZERO, worn.atlas.get_size())
		worn.filter_clip = true
		catalog_bodies[key] = worn
	return catalog_bodies[key]

static func human_frame(class_id: String, column: int) -> AtlasTexture:
	var key := Vector2i(clampi(column, 0, 5), int(CLASS_ROWS.get(class_id, 2)))
	if not human_frames.has(key):
		if human_atlas == null:
			human_atlas = load(HUMAN_ATLAS_PATH)
		var texture := AtlasTexture.new()
		texture.atlas = human_atlas
		var cell_size: Vector2 = human_atlas.get_size() / Vector2(HUMAN_GRID)
		texture.region = Rect2(Vector2(key) * cell_size, cell_size)
		texture.filter_clip = true
		human_frames[key] = texture
	return human_frames[key]

static func hand_position(state: PlayerState) -> Vector2:
	var armor_id: String = str(state.equipment.get("armadura", {}).get("id", ""))
	if armor_id.begins_with("armadura_catalogo_"):
		var number: String = str(int(str(GameData.item(armor_id).get("catalog_art", "")).trim_prefix("armadura_")))
		if WornLayout.HANDS.has(number):
			var coordinates: Array = WornLayout.HANDS[number]
			return Vector2(coordinates[0], coordinates[1])
	var worn_hands := {"armadura_catalogo_022": Vector2(0.25, 0.55), "armadura_catalogo_039": Vector2(0.24, 0.55), "armadura_catalogo_040": Vector2(0.23, 0.58)}
	if worn_hands.has(armor_id):
		return worn_hands[armor_id]
	if not Custom.armored(state):
		if state.gender_id == "feminino":
			return {"humano": Vector2(0.17, 0.55), "elfo": Vector2(0.20, 0.55), "orc": Vector2(0.13, 0.55), "anao": Vector2(0.14, 0.56)}.get(state.race_id, Vector2(0.20, 0.535))
		return {"humano": Vector2(0.17, 0.55), "elfo": Vector2(0.19, 0.55), "orc": Vector2(0.12, 0.57), "anao": Vector2(0.13, 0.65)}.get(state.race_id, Vector2(0.20, 0.535))
	return {"atirador": Vector2(0.23, 0.54), "mago": Vector2(0.23, 0.55), "guerreiro": Vector2(0.23, 0.53), "assassino": Vector2(0.23, 0.54), "tank": Vector2(0.235, 0.535), "cavaleiro": Vector2(0.235, 0.55)}.get(state.class_id, Vector2(0.23, 0.54))

static func hand_rect(state: PlayerState) -> Rect2:
	# Reuse only the existing fingers/wrist, with their original transparency.
	if state.race_id == "humano":
		return Rect2(hand_position(state) - Vector2(0.04, 0.027), Vector2(0.08, 0.054))
	return Rect2(hand_position(state) - Vector2(0.038, 0.043), Vector2(0.076, 0.086))

static func hand_texture(state: PlayerState) -> AtlasTexture:
	var body: AtlasTexture = body_texture(state)
	var rect: Rect2 = hand_rect(state)
	var key: String = "%s:%s:%s:%s:%s" % [body.atlas.resource_path, body.region, rect, state.gender_id, state.equipment.get("armadura", {}).get("id", "")]
	if not hand_frames.has(key):
		var patch: AtlasTexture = AtlasTexture.new()
		patch.atlas = body.atlas
		patch.region = Rect2(body.region.position + rect.position * body.region.size, rect.size * body.region.size)
		patch.filter_clip = true
		hand_frames[key] = patch
	return hand_frames[key]

static func _catalog_weapon_group(item_id: String) -> String:
	var art_id := str(GameData.item(item_id).get("catalog_art", ""))
	if not art_id.begins_with("arma_"):
		return ""
	var number := int(art_id.trim_prefix("arma_"))
	if number <= 15: return "sword"
	if number <= 30: return "heavy"
	if number <= 45: return "dagger"
	if number <= 60: return "bow"
	if number <= 75: return "staff"
	if number <= 88: return "spear"
	return "shield"

static func weapon_pivot(class_id: String, item_id: String = "") -> Vector2:
	var group := _catalog_weapon_group(item_id)
	if not group.is_empty():
		return {
			"sword": Vector2(0.32, 0.65),
			"heavy": Vector2(0.18, 0.80),
			"dagger": Vector2(0.24, 0.76),
			"bow": Vector2(0.50, 0.54),
			"staff": Vector2(0.46, 0.78),
			"spear": Vector2(0.20, 0.77),
			"shield": Vector2(0.50, 0.50),
		}.get(group, Vector2(0.28, 0.76))
	if class_id == "guerreiro":
		return SWORD_GRIPS.get(item_id, SWORD_GRIPS["arma_ng"])
	var grips: Array = CLASS_GRIPS.get(class_id, [])
	var index: int = WEAPON_IDS.find(item_id)
	return Vector2(0.28, 0.76) if grips.is_empty() else grips[maxi(index, 0)]

static func weapon_height(class_id: String, item_id: String = "") -> float:
	var base: float = CLASS_WEAPON_HEIGHTS.get(class_id, 0.48)
	match _catalog_weapon_group(item_id):
		"heavy", "spear": return base * 1.08
		"dagger": return base * 0.82
		"bow": return base * 0.92
		"staff": return base * 1.06
		"shield": return 0.28
		"sword": return 0.38
	return base

# Rest pose follows the reference: bow across the waist, staff upward-left,
# blades and heavy weapons downward-left, spear across the body.
static func weapon_rotation(class_id: String, item_id: String = "") -> float:
	match _catalog_weapon_group(item_id):
		"bow": return deg_to_rad(-115.0)
		"staff": return deg_to_rad(-47.0)
		"shield": return 0.0
		"spear": return deg_to_rad(-160.0)
		"sword", "heavy", "dagger": return PI
	match class_id:
		"atirador": return deg_to_rad(-115.0)
		"mago": return deg_to_rad(-47.0)
		"tank": return deg_to_rad(-165.0)
		"cavaleiro": return deg_to_rad(-160.0)
		_: return 0.0

static func weapon_layer(class_id: String) -> int:
	# A spear crosses behind the torso; the fingers remain above the shaft.
	return -1 if class_id == "cavaleiro" else 1

static func shield_anchor(state: PlayerState) -> Vector2:
	var right_hand := hand_position(state)
	return Vector2(1.0 - right_hand.x, right_hand.y - 0.025)

static func shield_material(item_id: String, texture: AtlasTexture) -> ShaderMaterial:
	if not shield_materials.has(item_id):
		var result := ShaderMaterial.new()
		result.shader = CUTOUT_SHADER
		var dimensions := texture.atlas.get_size()
		result.set_shader_parameter("texture_region", Vector4(texture.region.position.x / dimensions.x, texture.region.position.y / dimensions.y, texture.region.size.x / dimensions.x, texture.region.size.y / dimensions.y))
		shield_materials[item_id] = result
	return shield_materials[item_id]
