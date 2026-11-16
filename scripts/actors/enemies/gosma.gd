extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"name": "Gosma do Vale", "sprite": "res://assets/game/sprites/monstros/aurora/monster_slime.png", "height": 84.0, 
	"hp": 70.0, "damage": 7.0, "defense": 2.0, "speed": 66.0, "xp": 60, "tier": 0, 
	"coins": [3, 9], "aggro": 190.0, "attack_range": 56.0, "attack_cd": 1.7, "windup": 0.5, 
	"drops": {"gosma": 0.9}, "radius": 18.0, "kind": "gosma", 
}

func _init() -> void:
	type_id = "gosma"
