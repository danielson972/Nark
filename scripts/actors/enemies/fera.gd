extends Enemy
## Attributes for this enemy. Override inherited movement methods here if needed.

const CONFIG = {
	"name": "Fera de Carapaça Branca", "sprite": "res://assets/game/sprites/miniboss/aurora/boss_beast.png", "height": 138.0, 
	"hp": 900.0, "damage": 26.0, "defense": 16.0, "speed": 120.0, "xp": 900, "tier": 3, 
	"coins": [120, 220], "aggro": 460.0, "attack_range": 96.0, "attack_cd": 1.9, "windup": 0.7, 
	"drops": {"carapaca_branca": 1.0, "sucata_ferro": 0.6}, "radius": 40.0, "kind": "fera", 
	"miniboss": true, 
}

func _init() -> void:
	type_id = "fera"
