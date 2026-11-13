class_name Projectile
extends Node2D


var world: Node = null
var hero_owner: Node = null
var direction: = Vector2.RIGHT
var speed: = 700.0
var damage: = 10.0
var mult: = 1.0
var magic: = false
var crit_chance: = 0.05
var life: = 1.2
var hit_radius: = 22.0
var pierce: = 0
var color: = Color(0.95, 0.85, 0.5)
var kind: = "arrow"
var payload: Dictionary = {}
var hostile: = false
var hit_ids: Array = []
var size: = 10.0
var trail: Array = []


func _ready() -> void :
	z_index = 6


func _process(delta: float) -> void :
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	var step: = direction * speed * delta
	position += step
	trail.push_front(position)
	if trail.size() > 5:
		trail.pop_back()
	if world != null:
		if not world.can_stand(position, 4.0):
			_impact(null)
			return
		for enemy in (world.enemies_alive() if not hostile else [world.hero]):
			if enemy == null or not is_instance_valid(enemy) or enemy.dead:
				continue
			if hit_ids.has(enemy.get_instance_id()):
				continue
			if enemy.global_position.distance_to(position) <= hit_radius + enemy.radius * 0.6:
				hit_ids.append(enemy.get_instance_id())
				_impact(enemy)
				if pierce <= 0:
					return
				pierce -= 1
	queue_redraw()


func _impact(target) -> void :
	if world != null:
		if target != null and target.get("dead") != true:
			if hostile:
				world.damage_hero(damage, {"type": "projétil", "crit": randf() < crit_chance})
			else:
				world.hit_enemy(target, damage, crit_chance, payload)
		world.spawn_impact(position, color)
	queue_free()


func _draw() -> void :
	for index in trail.size():
		var alpha: = 0.35 * (1.0 - float(index) / float(maxi(1, trail.size())))
		draw_circle(to_local(trail[index]), size * 0.45 * (1.0 - float(index) / 8.0), Color(color.r, color.g, color.b, alpha))
	draw_circle(Vector2.ZERO, size, color)
	draw_circle(Vector2.ZERO, size * 0.55, Color(1, 1, 1, 0.85))
	if kind == "arrow":
		var tail: = - direction * 16.0
		draw_line(Vector2.ZERO, tail, Color(0.85, 0.72, 0.45), 3.0)
