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

var developer_room: = false
var tiles: PackedByteArray
var props: Array = []
var monster_spawns: Array = []
var crystal_spots: Array = []
var zones: Array = []

const CITY_RECT: = Rect2i(4, 4, 18, 14)
const FARM_RECT: = Rect2i(24, 4, 27, 18)
const QUARRY_RECT: = Rect2i(5, 29, 20, 10)
const SANCT_RECT: = Rect2i(42, 26, 10, 12)

const DEV_ARENA_ENTRY := Vector2i(33, 13)
const DEV_ARENA_FOE := Vector2i(38, 13)
const DEV_ARENA_GATE := Vector2i(21, 15)
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


func zone_at(_point: Vector2) -> String:
	return "developer" if developer_room else "mapa"


func zone_name(id: String) -> String:
	match id:
		"developer": return "Sala Secreta — Desenvolvedor"
		"santuario": return "Santuário do Colossal"
		"pedreira": return "Pedreira de Granito"
		"cidade": return "Aurora — Cidade Principal"
		"fazenda": return "Campos do Vale"
		_: return "Estrada do Vale"


# Empty logical bounds only; scenery is authored in scenes/map.tscn.
func generate() -> void:
	tiles = PackedByteArray()
	tiles.resize(W * H)
	tiles.fill(GRASS)
	props.clear()
	monster_spawns.clear()
	crystal_spots.clear()
	zones.clear()

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


func generate_developer_room() -> void:
	developer_room = true
	props.clear()
	for entry: Array in [
		["dev_items", "Arsenal", Vector2i(8, 7)],
		["dev_skills", "Biblioteca", Vector2i(12, 7)],
		["dev_tools", "Bancada", Vector2i(16, 7)],
		["dev_quests", "Missões", Vector2i(8, 14)],
		["dev_arena", "Arena de testes", DEV_ARENA_GATE],
		["arena_console", "Invocar adversário", Vector2i(32, 10)],
		["estatua", "Estátua", Vector2i(5, 10)],
		["forja", "Forja", Vector2i(5, 13)],
		["bau", "Baú", Vector2i(16, 14)],
		["mural", "Mural", Vector2i(12, 14)],
		["dev_exit", "Voltar ao jogo", Vector2i(12, 17)],
	]:
		props.append({"id": entry[0], "kind": entry[0], "name": entry[1], "tile": entry[2], "radius": 90.0})
