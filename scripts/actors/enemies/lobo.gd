extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"level": 3,
	"name": "Lobo Cinzento", "sprite": "res://assets/game/sprites/monstros/aurora/monster_wolf.png", "height": 92.0, 
	"hp": 96.0, "damage": 9.0, "defense": 4.0, "speed": 134.0, "xp": 85, "tier": 0, 
	"coins": [5, 13], "aggro": 300.0, "attack_range": 64.0, "attack_cd": 1.35, "windup": 0.42, 
	"drops": {"presa_lobo": 0.85, "sucata_ferro": 0.15}, "radius": 18.0, "kind": "lobo", 
}

func _init() -> void:
	type_id = "lobo"
