extends Projectile
## A daninha só nasce quando seu tipo for cadastrado no catálogo de inimigos.

var weed_enemy_id: String = "mini_daninha"


func _process(delta: float) -> void:
	if world == null or not world.is_playing():
		return
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
			var result: Dictionary = target.take_damage(damage, {"from": global_position, "type": "semente", "crit": false})
			if float(result.get("amount", 0.0)) > 0.0 and not target.dead:
				# Não usa o fallback do catálogo enquanto o futuro monstro não existir.
				if Enemy.TYPES.has(weed_enemy_id):
					var direction_out: Vector2 = -direction.normalized()
					var weed_radius: float = float(Enemy.TYPES[weed_enemy_id].get("radius", 18.0))
					var point: Vector2 = target.global_position + direction_out * (target.radius + weed_radius + 8.0)
					if world.can_stand(point, weed_radius) and world.can_actor_stand(target, point, weed_radius):
						var weed = world.spawn_enemy(weed_enemy_id, point)
						weed.summoned = true
				world.spawn_vfx(target.global_position, Color(0.5, 0.8, 0.2), 8, 55.0)
		world.spawn_impact(global_position, Color(0.5, 0.65, 0.2))
	queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, direction.angle())
	draw_colored_polygon(PackedVector2Array([Vector2(-9, 0), Vector2(-3, -5), Vector2(6, -3), Vector2(10, 0), Vector2(6, 4), Vector2(-3, 5)]), Color(0.46, 0.3, 0.12))
	draw_line(Vector2(-5, 0), Vector2(7, 0), Color(0.85, 0.7, 0.3), 2.0)
	draw_circle(Vector2(-3, -4), 3, Color(0.4, 0.7, 0.2))
