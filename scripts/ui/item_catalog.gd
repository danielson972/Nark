extends RefCounted
## Inventory art: six class rows, four weapon grades and four armor grades.

const ATLAS_PATH = "res://assets/game/ui/items/items_atlas.png"
const GRID = Vector2i(8, 8)
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
static var source_atlas: Texture2D
static var textures: Dictionary = {}
const CLASS_ROWS = {
	"atirador": 0, "mago": 1, "guerreiro": 2,
	"assassino": 3, "tank": 4, "cavaleiro": 5,
}
const EQUIPMENT_COLUMNS = {
	"arma_ng": 0, "arma_d": 1, "arma_c": 2, "arma_b": 3,
	"armadura_ng": 4, "armadura_d": 5, "armadura_c": 6, "armadura_b": 7,
}
const ITEM_CELLS = {
	"presa_lobo": Vector2i(0, 6), "gosma": Vector2i(1, 6),
	"sucata_ferro": Vector2i(2, 6), "cristal_aurora": Vector2i(3, 6),
	"carapaca_branca": Vector2i(4, 6), "essencia_errante": Vector2i(5, 6),
	"selo_entrada": Vector2i(6, 6), "livro_skill": Vector2i(7, 6),
	"pocao_cura": Vector2i(0, 7), "joia_ng": Vector2i(1, 7), "joia_d": Vector2i(2, 7),
}
const EXTRA_CELLS = {
	"bolsa_moedas": Vector2i(3, 7), "escudo_ng": Vector2i(4, 7),
	"escudo_d": Vector2i(5, 7), "escudo_c": Vector2i(6, 7), "escudo_b": Vector2i(7, 7),
}

static func cell_for(item_id: String, class_id: String = "guerreiro") -> Vector2i:
	if item_id in ["arma_basica", "roupa_basica"]:
		return Vector2i(6 if item_id == "arma_basica" else 7, int(CLASS_ROWS.get(class_id, 2)))
	if EQUIPMENT_COLUMNS.has(item_id):
		return Vector2i(int(EQUIPMENT_COLUMNS[item_id]), int(CLASS_ROWS.get(class_id, 2)))
	return ITEM_CELLS.get(item_id, EXTRA_CELLS.get(item_id, Vector2i(-1, -1)))

static func atlas_rect(item_id: String, class_id: String, texture_size: Vector2) -> Rect2:
	var cell: Vector2i = cell_for(item_id, class_id)
	if cell.x < 0 or cell.y < 0:
		return Rect2()
	var grid: Vector2i = Appearance.GRID if item_id in ["arma_basica", "roupa_basica"] else GRID
	var start: Vector2 = (Vector2(cell) * texture_size / Vector2(grid)).floor()
	var finish: Vector2 = (Vector2(cell + Vector2i.ONE) * texture_size / Vector2(grid)).floor()
	# Keep the neighboring icon outside the sampled region, including at small sizes.
	return Rect2(start + Vector2.ONE * 2, finish - start - Vector2.ONE * 4)

static func texture_for(item_id: String, class_id: String = "guerreiro") -> Texture2D:
	if item_id == "hero":
		if not textures.has(item_id):
			textures[item_id] = load("res://assets/game/ui/items/hero.png")
		return textures[item_id]
	# Frascos próprios baseados no mesmo design da poção de vida.
	if item_id in ["pocao_mana", "pocao_energia"]:
		if not textures.has(item_id):
			textures[item_id] = load("res://assets/game/ui/items/" + item_id + "_64.png")
		return textures[item_id]
	if cell_for(item_id, class_id).x < 0:
		return null
	if item_id in ["arma_basica", "roupa_basica"]:
		if class_id == "assassino" and item_id == "arma_basica":
			return _single_dagger(item_id, Appearance.frame(class_id, 6))
		return Appearance.frame(class_id, 6 if item_id == "arma_basica" else 7)
	var key: String = class_id + ":" + item_id
	if textures.has(key):
		return textures[key]
	if source_atlas == null:
		source_atlas = load(ATLAS_PATH)
	var texture: AtlasTexture = AtlasTexture.new()
	texture.atlas = source_atlas
	texture.region = atlas_rect(item_id, class_id, source_atlas.get_size())
	texture.filter_clip = true
	if class_id == "assassino" and item_id in ["arma_ng", "arma_d", "arma_c", "arma_b"]:
		texture = _single_dagger(item_id, texture)
	textures[key] = texture
	return texture

# The source icons contain two parallel daggers. Keep the first complete blade
# in the original square, so the existing grip and scale remain valid everywhere.
static func _single_dagger(item_id: String, source: AtlasTexture) -> AtlasTexture:
	var key: String = "single_dagger:" + item_id
	if textures.has(key):
		return textures[key]
	var pixels: Image = source.atlas.get_image().get_region(source.region)
	pixels.convert(Image.FORMAT_RGBA8)
	var boundary: float = 0.84 if item_id == "arma_basica" else 0.80
	for y in pixels.get_height():
		for x in pixels.get_width():
			var diagonal: float = float(x) / pixels.get_width() + 0.65 * float(y) / pixels.get_height()
			if diagonal > boundary:
				pixels.set_pixel(x, y, Color.TRANSPARENT)
	var result: AtlasTexture = AtlasTexture.new()
	result.atlas = ImageTexture.create_from_image(pixels)
	result.region = Rect2(Vector2.ZERO, pixels.get_size())
	result.filter_clip = true
	textures[key] = result
	return result
