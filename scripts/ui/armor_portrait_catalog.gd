extends RefCounted
## Dedicated UI art. Worn character textures continue to use their original files.
const ROOT = "res://assets/game/ui/items/armor_portraits/icons/"
const LEGACY_IDS = ["roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
static var textures: Dictionary = {}

static func texture_for(item_id: String, class_id: String) -> Texture2D:
	if str(GameData.item(item_id).get("type", "")) != "armadura":
		return null
	var path: String = ""
	if item_id.begins_with("armadura_catalogo_"):
		path = ROOT + item_id + ".tres"
	elif item_id in LEGACY_IDS:
		var job: String = class_id if GameData.CLASSES.has(class_id) else "guerreiro"
		path = ROOT + job + "/" + item_id + ".tres"
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	if not textures.has(path):
		textures[path] = load(path)
	return textures[path]
