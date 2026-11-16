extends RefCounted
## Registry for editor-placed and explicitly summoned enemies.

const SCRIPTS = {
	"gosma": "res://scripts/actors/enemies/gosma.gd",
	"golem_pedra": "res://scripts/actors/enemies/golem_pedra.gd",
	"lobo": "res://scripts/actors/enemies/lobo.gd",
	"arvore_cipo": "res://scripts/actors/enemies/arvore_cipo.gd",
	"saqueador": "res://scripts/actors/enemies/saqueador.gd",
	"errante": "res://scripts/actors/enemies/errante.gd",
	"fera": "res://scripts/actors/enemies/fera.gd",
	"colossal": "res://scripts/actors/enemies/colossal_aurora.gd",
	"rival": "res://scripts/actors/enemies/rival.gd",
}
static var _definitions: Dictionary = {}

static func definitions() -> Dictionary:
	if _definitions.is_empty():
		for id: String in SCRIPTS:
			_definitions[id] = load(SCRIPTS[id]).CONFIG
	return _definitions

static func create(id: String):
	if id == "golem_pedra":
		return load("res://scenes/enemies/golem_pedra.tscn").instantiate()
	return load(SCRIPTS.get(id, SCRIPTS["lobo"])).new()
