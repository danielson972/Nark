extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"level": 10,
	"name": "Monstro Errante", "sprite": "res://assets/game/sprites/monstros/aurora/monster_wolf.png", "height": 100.0, 
	"hp": 190.0, "damage": 18.0, "defense": 8.0, "speed": 152.0, "xp": 190, "tier": 2, 
	"coins": [18, 40], "aggro": 380.0, "attack_range": 66.0, "attack_cd": 1.25, "windup": 0.38, 
	"drops": {"essencia_errante": 0.85, "presa_lobo": 0.3}, "radius": 20.0, "kind": "errante", 
	"errant": true, 
}

func _init() -> void:
	type_id = "errante"
