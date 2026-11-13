class_name Combat
extends RefCounted


static func variance(rng: RandomNumberGenerator) -> float:
	return rng.randf_range(0.92, 1.08)


static func mitigate(raw: float, defense: float) -> float:
	return raw * (100.0 / (100.0 + maxf(0.0, defense)))


static func roll(power: float, mult: float, defense: float, crit_chance: float, 
		bonus_mult: float = 1.0, ignore_defense: float = 0.0, 
		rng: RandomNumberGenerator = null) -> Dictionary:
	var generator: = rng if rng != null else RandomNumberGenerator.new()
	var effective_defense: = defense * (1.0 - clampf(ignore_defense, 0.0, 1.0))
	var raw: = power * mult * bonus_mult * variance(generator)
	var critical: = generator.randf() < clampf(crit_chance, 0.0, 1.0)
	if critical:
		raw *= Balance.CRIT_MULT
	var amount: = maxf(1.0, mitigate(raw, effective_defense))
	return {"amount": amount, "crit": critical}


static func is_behind(attacker_pos: Vector2, facing: Vector2, target_pos: Vector2) -> bool:
	var to_attacker: = (attacker_pos - target_pos)
	if to_attacker.length() < 0.001:
		return false
	return facing.normalized().dot(to_attacker.normalized()) < -0.28


static func is_frontal(attacker_pos: Vector2, facing: Vector2, target_pos: Vector2) -> bool:
	var to_attacker: = (attacker_pos - target_pos)
	if to_attacker.length() < 0.001:
		return true
	return facing.normalized().dot(to_attacker.normalized()) > 0.15
