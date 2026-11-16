extends Projectile
## Pedra Atordoante: aplica um segundo de atordoamento somente se causar dano.

func _process(delta: float) -> void:
	# Passos pequenos evitam que a pedra atravesse o herói em quadros demorados.
	var steps: int = maxi(1, ceili(speed * delta / 6.0))
	for index in steps:
		if is_queued_for_deletion():
			return
		super._process(delta / float(steps))


func _impact(target) -> void:
	if is_queued_for_deletion():
		return
	if world != null:
		if is_instance_valid(target) and not target.dead:
			var result: Dictionary = target.take_damage(damage, {"from": global_position, "type": "pedra", "crit": false})
			# Esquiva e invulnerabilidade evitam tanto o dano quanto o atordoamento.
			if float(result.get("amount", 0.0)) > 0.0 and not target.dead:
				target.apply_status("stun", 1.0)
				target.interrupt_cast("atordoamento")
				world.show_notice("Atordoado por 1 segundo!", Color(0.95, 0.8, 0.4))
		world.spawn_impact(global_position, Color(0.6, 0.58, 0.5))
	queue_free()


func _draw() -> void:
	# Silhueta irregular de pedra, com sombra e face iluminada.
	var points := PackedVector2Array([Vector2(-8, -3), Vector2(-3, -8), Vector2(5, -6), Vector2(9, 0), Vector2(4, 7), Vector2(-6, 6)])
	draw_colored_polygon(points, Color(0.42, 0.44, 0.46))
	draw_colored_polygon(PackedVector2Array([Vector2(-7, -3), Vector2(-3, -7), Vector2(4, -5), Vector2(1, 0)]), Color(0.7, 0.71, 0.67))
