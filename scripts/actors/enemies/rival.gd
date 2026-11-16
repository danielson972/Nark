extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"level": 12,
	"name": "Sombra de Kael", "sprite": "res://assets/game/sprites/herois/compartilhados/hero_rogue.png", "height": 96.0, 
	"hp": 340.0, "damage": 18.0, "defense": 9.0, "speed": 196.0, "xp": 420, "tier": 2, 
	"coins": [0, 0], "aggro": 460.0, "attack_range": 74.0, "attack_cd": 1.1, "windup": 0.35, 
	"drops": {}, "radius": 18.0, "kind": "rival", "rival": true, 
}

func _init() -> void:
	type_id = "rival"
