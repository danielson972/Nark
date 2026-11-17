extends RefCounted
## Inventory art: six class rows, four weapon grades and four armor grades.

const ATLAS_PATH = "res://assets/game/ui/items/items_atlas.png"
const GRID = Vector2i(8, 8)
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ArmorIconLayout = preload("res://assets/game/ui/items/armor_icon_layout.gd")
const ArmorPortraits = preload("res://scripts/ui/armor_portrait_catalog.gd")
static var source_atlas: Texture2D
static var textures: Dictionary = {}
static var catalog_atlases: Dictionary = {}

const WEAPON_SHEETS = [
	[1, 15, "res://assets/game/sprites/Arsenal_RPG/pranchas/001-015.png"],
	[16, 30, "res://assets/game/sprites/Arsenal_RPG/pranchas/016-030.png"],
	[31, 45, "res://assets/game/sprites/Arsenal_RPG/pranchas/031-045.png"],
	[46, 60, "res://assets/game/sprites/Arsenal_RPG/pranchas/046-060.png"],
	[61, 75, "res://assets/game/sprites/Arsenal_RPG/pranchas/061-075.png"],
	[76, 88, "res://assets/game/sprites/Arsenal_RPG/pranchas/076-088.png", 5, 1],
	[89, 100, "res://assets/game/sprites/Arsenal_RPG/pranchas/089-100.png", 4],
]
const ARMOR_SHEETS = [
	[1, 10, "res://assets/game/sprites/Armaduras_RPG/pranchas/001-010.png"],
	[11, 20, "res://assets/game/sprites/Armaduras_RPG/pranchas/011-020.png"],
	[21, 30, "res://assets/game/sprites/Armaduras_RPG/pranchas/021-030.png"],
	[31, 40, "res://assets/game/sprites/Armaduras_RPG/pranchas/031-040.png"],
	[41, 50, "res://assets/game/sprites/Armaduras_RPG/pranchas/041-050.png"],
	[51, 60, "res://assets/game/sprites/Armaduras_RPG/pranchas/051-060.png"],
	[61, 70, "res://assets/game/sprites/Armaduras_RPG/pranchas/061-070.png"],
	[71, 80, "res://assets/game/sprites/Armaduras_RPG/pranchas/071-080.png"],
	[81, 90, "res://assets/game/sprites/Armaduras_RPG/pranchas/081-090.png"],
	[91, 100, "res://assets/game/sprites/Armaduras_RPG/pranchas/091-100.png"],
]
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
	var slot_art: String = str(GameData.item(item_id).get("slot_art", ""))
	if slot_art in ["colar", "talisma"]:
		return load("res://assets/game/ui/equipment_slots/%s.svg" % slot_art)
	var catalog_texture := _catalog_texture(item_id, class_id)
	if catalog_texture != null:
		return catalog_texture
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

## Recorta a arte das pranchas de apresentação sem a faixa de legenda.
static func _catalog_texture(item_id: String, class_id: String = "guerreiro") -> Texture2D:
	var data: Dictionary = GameData.item(item_id)
	var art_id := str(data.get("catalog_art", ""))
	if art_id.is_empty():
		return null
	var cache_key := "catalog:" + art_id
	if textures.has(cache_key):
		return textures[cache_key]
	var is_weapon := art_id.begins_with("arma_")
	var numeric := int(art_id.trim_prefix("arma_").trim_prefix("armadura_"))
	var sheets: Array = WEAPON_SHEETS if is_weapon else ARMOR_SHEETS
	var sheet: Array = []
	for candidate: Array in sheets:
		if numeric >= int(candidate[0]) and numeric <= int(candidate[1]):
			sheet = candidate
			break
	if sheet.is_empty():
		return null
	var sheet_path := str(sheet[2])
	if not catalog_atlases.has(sheet_path):
		catalog_atlases[sheet_path] = load(sheet_path) if ResourceLoader.exists(sheet_path) else null
	var atlas: Texture2D = catalog_atlases[sheet_path]
	if atlas == null:
		# As pranchas de armaduras são opcionais durante a recuperação dos assets.
		# Enquanto ausentes, mantém o equipamento visível usando a arte do grau.
		if not is_weapon:
			var grade := str(data.get("grade", "NG")).to_lower()
			var fallback_id := "armadura_" + grade if grade in ["ng", "d", "c", "b"] else "armadura_b"
			return texture_for(fallback_id, class_id)
		return null
	var local_index := numeric - int(sheet[0])
	if not is_weapon:
		var bounds: Array = ArmorIconLayout.RECTS[clampi(numeric-1,0,99)]
		var armor_texture := AtlasTexture.new()
		armor_texture.atlas = atlas
		armor_texture.region = Rect2(bounds[0],bounds[1],bounds[2],bounds[3])
		armor_texture.filter_clip = true
		textures[cache_key] = armor_texture
		return armor_texture
	var columns := int(sheet[3]) if sheet.size() > 3 else 5
	var rows := ceili(float(int(sheet[1]) - int(sheet[0]) + 1) / float(columns))
	var cell := atlas.get_size() / Vector2(columns, rows)
	var column := local_index % columns
	var row := int(local_index / columns)
	if sheet.size() > 4 and row == rows - 1:
		column += int(sheet[4])
	var region_height := 0.80 if is_weapon else 0.83
	var region := Rect2(Vector2(column, row) * cell + Vector2(8, 8), Vector2(cell.x - 16, cell.y * region_height - 16))
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
	texture.filter_clip = true
	textures[cache_key] = texture
	return texture

static func icon_texture_for(item_id: String, class_id: String = "guerreiro") -> Texture2D:
	var portrait: Texture2D = ArmorPortraits.texture_for(item_id, class_id)
	if portrait != null:
		return portrait
	var source := texture_for(item_id,class_id)
	if source == null or str(GameData.item(item_id).get("type","")) != "armadura":
		return source
	if str(GameData.item(item_id).get("catalog_art","")).begins_with("armadura_"):
		return source
	var key := "centered_armor:"+class_id+":"+item_id
	if not textures.has(key):
		var image := source.get_image()
		var minimum := image.get_size()
		var maximum := Vector2i.ZERO
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x,y).a >= 0.75:
					minimum = Vector2i(mini(minimum.x,x),mini(minimum.y,y))
					maximum = Vector2i(maxi(maximum.x,x),maxi(maximum.y,y))
		if maximum.x <= minimum.x or maximum.y <= minimum.y: return source
		var texture := AtlasTexture.new()
		texture.atlas = source.atlas if source is AtlasTexture else source
		var origin: Vector2 = source.region.position if source is AtlasTexture else Vector2.ZERO
		texture.region = Rect2(origin+Vector2(minimum),Vector2(maximum-minimum+Vector2i.ONE))
		texture.filter_clip = true
		textures[key] = texture
	return textures[key]

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
