extends RefCounted
## One armor item, with separately editable visual layers.
const ROOT = "res://scenes/armor_parts/"
const CLASSIC_IDS = ["armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
static var scenes: Dictionary = {}

static func scene_path(state: PlayerState) -> String:
	var id: String = str(state.equipment.get("armadura", {}).get("id", ""))
	if id == "roupa_basica":
		return ROOT + "basicos/%s_%s.tscn" % [state.race_id, state.gender_id]
	if id.begins_with("armadura_catalogo_"):
		var number: int = int(str(GameData.item(id).get("catalog_art", "")).trim_prefix("armadura_"))
		return ROOT + "catalogo/armadura_%03d.tscn" % number
	if id in CLASSIC_IDS:
		return ROOT + "classes/%s/%s.tscn" % [state.class_id, id]
	return ""

static func instantiate(state: PlayerState) -> Node2D:
	var path := scene_path(state)
	if path.is_empty() or not ResourceLoader.exists(path): return null
	if not scenes.has(path): scenes[path] = load(path)
	return scenes[path].instantiate()
