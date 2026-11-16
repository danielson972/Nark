extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"name": "Saqueador", "sprite": "res://assets/game/sprites/monstros/aurora/monster_bandit.png", "height": 96.0, 
	"hp": 120.0, "damage": 12.0, "defense": 7.0, "speed": 108.0, "xp": 120, "tier": 1, 
	"coins": [14, 32], "aggro": 330.0, "attack_range": 72.0, "attack_cd": 1.6, "windup": 0.55, 
	"drops": {"sucata_ferro": 0.9, "presa_lobo": 0.2}, "radius": 19.0, "kind": "saqueador", 
	"guard": 0.35, 
}

func _init() -> void:
	type_id = "saqueador"
