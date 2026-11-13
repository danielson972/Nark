class_name RegionMap
extends RefCounted


const GRASS: = 0
const DIRT: = 1
const STONE: = 2
const GRAVEL: = 3
const WATER: = 4
const CLIFF: = 5
const SANCT: = 6
const DARK: = 7

const W: = Balance.MAP_W
const H: = Balance.MAP_H

var tiles: PackedByteArray
var props: Array = []
var monster_spawns: Array = []
var crystal_spots: Array = []
var zones: Array = []

const CITY_RECT: = Rect2i(4, 4, 18, 14)
const FARM_RECT: = Rect2i(24, 4, 27, 18)
const QUARRY_RECT: = Rect2i(5, 29, 20, 10)
const SANCT_RECT: = Rect2i(42, 26, 10, 12)

const HERO_SPAWN: = Vector2i(12, 10)
const GATE_TILE: = Vector2i(46, 24)
const ARENA_ENTRY: = Vector2i(46, 27)
const ARENA_EXIT: = Vector2i(46, 25)


func _init() -> void :
	generate()


func index(x: int, y: int) -> int:
	return y * W + x


func inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < W and y < H


func tile_at(x: int, y: int) -> int:
	if not inside(x, y):
		return CLIFF
	return tiles[index(x, y)]


func set_tile(x: int, y: int, value: int) -> void :
	if inside(x, y):
		tiles[index(x, y)] = value


func tile_at_position(point: Vector2) -> int:
	return tile_at(int(floor(point.x / Balance.TILE)), int(floor(point.y / Balance.TILE)))


func is_solid_tile(value: int) -> bool:
	return value == WATER or value == CLIFF


func is_solid_at(x: int, y: int) -> bool:
	return is_solid_tile(tile_at(x, y))


func fill_rect(rect: Rect2i, value: int) -> void :
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			set_tile(x, y, value)


func zone_at(point: Vector2) -> String:
	var tile: = Vector2i(int(point.x / Balance.TILE), int(point.y / Balance.TILE))
	if SANCT_RECT.has_point(tile):
		return "santuario"
	if QUARRY_RECT.has_point(tile):
		return "pedreira"
	if CITY_RECT.has_point(tile):
		return "cidade"
	if FARM_RECT.has_point(tile):
		return "fazenda"
	return "estrada"


func zone_name(id: String) -> String:
	match id:
		"santuario": return "Santuário do Colossal"
		"pedreira": return "Pedreira de Granito"
		"cidade": return "Aurora — Cidade Principal"
		"fazenda": return "Campos do Vale"
		_: return "Estrada do Vale"


func generate() -> void :
	tiles = PackedByteArray()
	tiles.resize(W * H)
	for y in H:
		for x in W:
			var value: = GRASS
			if randf() < 0.06:
				value = DARK
			set_tile(x, y, value)
	_border()
	_forest_patches()
	_build_city()
	_build_roads()
	_build_farm()
	_build_quarry()
	_build_sanctuary()
	_build_props()
	_build_spawns()


func _border() -> void :
	for x in W:
		for thickness in 2:
			set_tile(x, thickness, CLIFF)
			set_tile(x, H - 1 - thickness, CLIFF)
	for y in H:
		for thickness in 2:
			set_tile(thickness, y, CLIFF)
			set_tile(W - 1 - thickness, y, CLIFF)


func _forest_patches() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.seed = 20261113
	for index in 40:
		var cx: = rng.randi_range(4, W - 5)
		var cy: = rng.randi_range(4, H - 5)
		var radius: = rng.randi_range(2, 4)
		for y in range(cy - radius, cy + radius + 1):
			for x in range(cx - radius, cx + radius + 1):
				if Vector2i(x, y).distance_to(Vector2i(cx, cy)) <= radius * rng.randf_range(0.7, 1.0):
					set_tile(x, y, DARK if rng.randf() < 0.7 else GRASS)

	for index in 26:
		var x: = rng.randi_range(5, W - 6)
		var y: = rng.randi_range(5, H - 6)
		if CITY_RECT.has_point(Vector2i(x, y)) or SANCT_RECT.has_point(Vector2i(x, y)):
			continue
		if QUARRY_RECT.has_point(Vector2i(x, y)):
			continue
		set_tile(x, y, CLIFF)


func _build_city() -> void :
	fill_rect(CITY_RECT, STONE)

	for x in range(CITY_RECT.position.x, CITY_RECT.position.x + CITY_RECT.size.x):
		set_tile(x, CITY_RECT.position.y, CLIFF)
		set_tile(x, CITY_RECT.position.y + CITY_RECT.size.y - 1, CLIFF)
	for y in range(CITY_RECT.position.y, CITY_RECT.position.y + CITY_RECT.size.y):
		set_tile(CITY_RECT.position.x, y, CLIFF)
		set_tile(CITY_RECT.position.x + CITY_RECT.size.x - 1, y, CLIFF)

	for x in [12, 13]:
		set_tile(x, 17, STONE)
		set_tile(x, 16, STONE)
	for y in [10, 11]:
		set_tile(21, y, STONE)
		set_tile(20, y, STONE)

	fill_rect(Rect2i(5, 5, 4, 3), CLIFF)
	fill_rect(Rect2i(17, 5, 4, 3), CLIFF)
	fill_rect(Rect2i(5, 13, 3, 4), CLIFF)
	fill_rect(Rect2i(18, 13, 2, 4), CLIFF)
	fill_rect(Rect2i(9, 6, 2, 2), CLIFF)

	for x in range(9, 17):
		set_tile(x, 9, DIRT)
	for y in range(8, 13):
		set_tile(11, y, DIRT)


func _build_roads() -> void :
	for y in range(17, 24):
		for x in [12, 13]:
			set_tile(x, y, DIRT)
	for x in range(14, 46):
		for y in [22, 23]:
			set_tile(x, y, DIRT)
	for y in range(24, 29):
		for x in [12, 13]:
			set_tile(x, y, DIRT)
	for x in range(8, 14):
		set_tile(x, 29, DIRT)
	for y in range(26, 30):
		set_tile(45, y, DIRT)
		set_tile(46, y, DIRT)

	for y in range(22, 24):
		for x in range(14, 46):
			if tile_at(x, y) == CLIFF:
				set_tile(x, y, DIRT)


func _build_farm() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.seed = 771
	for index in 24:
		var x: = rng.randi_range(FARM_RECT.position.x + 1, FARM_RECT.position.x + FARM_RECT.size.x - 2)
		var y: = rng.randi_range(FARM_RECT.position.y + 1, FARM_RECT.position.y + FARM_RECT.size.y - 2)
		if tile_at(x, y) == CLIFF:
			set_tile(x, y, GRASS)
		elif rng.randf() < 0.5:
			set_tile(x, y, DIRT)

	for y in range(11, 18):
		for x in range(35, 43):
			var d: = Vector2(float(x - 38) / 4.2, float(y - 14) / 3.2).length()
			if d < 1.0:
				set_tile(x, y, WATER)


func _build_quarry() -> void :
	fill_rect(QUARRY_RECT, GRAVEL)
	for x in range(QUARRY_RECT.position.x, QUARRY_RECT.position.x + QUARRY_RECT.size.x):
		set_tile(x, QUARRY_RECT.position.y - 1, CLIFF)
		set_tile(x, QUARRY_RECT.position.y + QUARRY_RECT.size.y, CLIFF)
	for y in range(QUARRY_RECT.position.y, QUARRY_RECT.position.y + QUARRY_RECT.size.y):
		set_tile(QUARRY_RECT.position.x - 1, y, CLIFF)
		set_tile(QUARRY_RECT.position.x + QUARRY_RECT.size.x, y, CLIFF)

	for x in [12, 13]:
		set_tile(x, QUARRY_RECT.position.y - 1, GRAVEL)

	var rng: = RandomNumberGenerator.new()
	rng.seed = 4242
	for index in 16:
		var x: = rng.randi_range(QUARRY_RECT.position.x + 1, QUARRY_RECT.position.x + QUARRY_RECT.size.x - 2)
		var y: = rng.randi_range(QUARRY_RECT.position.y + 1, QUARRY_RECT.position.y + QUARRY_RECT.size.y - 2)
		if abs(x - 15) < 5 and abs(y - 34) < 3:
			continue
		set_tile(x, y, CLIFF)


func _build_sanctuary() -> void :
	fill_rect(SANCT_RECT, SANCT)
	for x in range(SANCT_RECT.position.x, SANCT_RECT.position.x + SANCT_RECT.size.x):
		set_tile(x, SANCT_RECT.position.y, CLIFF)
		set_tile(x, SANCT_RECT.position.y + SANCT_RECT.size.y - 1, CLIFF)
	for y in range(SANCT_RECT.position.y, SANCT_RECT.position.y + SANCT_RECT.size.y):
		set_tile(SANCT_RECT.position.x, y, CLIFF)
		set_tile(SANCT_RECT.position.x + SANCT_RECT.size.x - 1, y, CLIFF)

	for tile: Vector2i in [Vector2i(44, 29), Vector2i(49, 29), Vector2i(44, 35), Vector2i(49, 35)]:
		set_tile(tile.x, tile.y, CLIFF)


func _build_props() -> void :
	props = [
		{"id": "estatua", "kind": "estatua", "tile": Vector2i(12, 8), "label": "Estátua de Save", 
			"sprite": "res://assets/game/sprites/prop_statue.png", "height": 120.0, "radius": 90.0}, 
		{"id": "forja", "kind": "forja", "tile": Vector2i(8, 13), "label": "Forja do Ferrreiro", 
			"sprite": "res://assets/game/sprites/prop_forge.png", "height": 96.0, "radius": 90.0}, 
		{"id": "mural", "kind": "mural", "tile": Vector2i(16, 13), "label": "Mural de Contratos", 
			"sprite": "res://assets/game/sprites/prop_board.png", "height": 88.0, "radius": 90.0}, 
		{"id": "bau", "kind": "bau", "tile": Vector2i(12, 5), "label": "Baú da Cidade", 
			"sprite": "res://assets/game/sprites/prop_chest.png", "height": 62.0, "radius": 80.0}, 
		{"id": "mestre", "kind": "mestre", "tile": Vector2i(9, 7), "label": "Mestra da Guilda", 
			"sprite": "res://assets/game/sprites/hero_mage.png", "height": 92.0, "radius": 84.0}, 
		{"id": "bencao", "kind": "bencao", "tile": Vector2i(17, 8), "label": "Sacerdote das Bênçãos", 
			"sprite": "res://assets/game/sprites/hero_knight.png", "height": 92.0, "radius": 84.0}, 
		{"id": "teleporte", "kind": "teleporte", "tile": Vector2i(19, 14), "label": "Mestre de Teleporte", 
			"sprite": "res://assets/game/sprites/hero_archer.png", "height": 92.0, "radius": 84.0}, 
		{"id": "portao", "kind": "portao", "tile": GATE_TILE, "label": "Portão do Santuário", 
			"sprite": "res://assets/game/sprites/prop_gate.png", "height": 148.0, "radius": 110.0}, 
	]
	crystal_spots = [Vector2i(41, 22), Vector2i(49, 23), Vector2i(38, 25)]
	for index in crystal_spots.size():
		var tile: Vector2i = crystal_spots[index]
		props.append({
			"id": "cristal_%d" % index, "kind": "cristal", "tile": tile, "label": "Cristal de Aurora", 
			"sprite": "", "height": 40.0, "radius": 74.0, 
		})


func _build_spawns() -> void :
	monster_spawns = [
		{"kind": "lobo", "tile": Vector2i(28, 8)}, 
		{"kind": "lobo", "tile": Vector2i(33, 19)}, 
		{"kind": "lobo", "tile": Vector2i(44, 8)}, 
		{"kind": "lobo", "tile": Vector2i(48, 17)}, 
		{"kind": "lobo", "tile": Vector2i(26, 15)}, 
		{"kind": "gosma", "tile": Vector2i(31, 12)}, 
		{"kind": "gosma", "tile": Vector2i(40, 6)}, 
		{"kind": "gosma", "tile": Vector2i(46, 12)}, 
		{"kind": "gosma", "tile": Vector2i(29, 6)}, 
		{"kind": "saqueador", "tile": Vector2i(43, 20)}, 
		{"kind": "saqueador", "tile": Vector2i(36, 21)}, 
		{"kind": "saqueador", "tile": Vector2i(27, 13)}, 
		{"kind": "fera", "tile": Vector2i(15, 34)}, 
		{"kind": "colossal", "tile": Vector2i(46, 32)}, 
	]
	for spawn: Dictionary in monster_spawns:
		var tile: Vector2i = spawn["tile"]
		if is_solid_at(tile.x, tile.y):
			set_tile(tile.x, tile.y, GRASS if FARM_RECT.has_point(tile) else GRAVEL)


func world_position(tile: Vector2i) -> Vector2:
	return Vector2(float(tile.x) * Balance.TILE + Balance.TILE * 0.5, float(tile.y) * Balance.TILE + Balance.TILE * 0.5)


func hero_spawn_position() -> Vector2:
	return world_position(HERO_SPAWN)


func arena_entry_position() -> Vector2:
	return world_position(ARENA_ENTRY)


func gate_position() -> Vector2:
	return world_position(GATE_TILE)


func random_open_tile(rect: Rect2i, rng: RandomNumberGenerator) -> Vector2:
	for attempt in 60:
		var tile: = Vector2i(rng.randi_range(rect.position.x + 1, rect.position.x + rect.size.x - 2), 
			rng.randi_range(rect.position.y + 1, rect.position.y + rect.size.y - 2))
		if not is_solid_at(tile.x, tile.y):
			return world_position(tile)
	return world_position(Vector2i(rect.position.x + 1, rect.position.y + 1))
