class_name Projectile
extends Node2D

const ARCANE_SHEET: Texture2D = preload("res://assets/game/effects/arcane_projectile_sheet.png")
const ARCANE_FRAME_SIZE: int = 64
const ARCANE_FRAMES_PER_ROW: int = 3
const ARCANE_FRAME_COUNT: int = 9
const ARCANE_FPS: float = 10.0


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
var use_arcane_gif: = false
var homing_target: Node2D = null
var homing_strength: = 10.0
var hit_ids: Array = []
var size: = 10.0
var trail: Array = []
var animation_elapsed: = 0.0


func _ready() -> void :
	z_index = 6


func _process(delta: float) -> void :
	animation_elapsed += delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if homing_target != null and is_instance_valid(homing_target) and not bool(homing_target.get("dead")):
		var target_direction: Vector2 = global_position.direction_to(homing_target.global_position)
		if target_direction != Vector2.ZERO:
			direction = direction.lerp(target_direction, clampf(homing_strength * delta, 0.0, 1.0)).normalized()
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
			var collided := false
			if not hostile and enemy.has_method("combat_hitbox"):
				collided = enemy.combat_hitbox(hit_radius).has_point(global_position)
			else:
				collided = enemy.global_position.distance_to(global_position) <= hit_radius + enemy.radius * 0.6
			if collided:
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
				world.damage_hero(damage, {"type": "projÃ©til", "crit": randf() < crit_chance})
			else:
				world.hit_enemy(target, damage, crit_chance, payload)
		world.spawn_impact(position, color)
	queue_free()


func _draw() -> void :
	for index in trail.size():
		var alpha: = 0.35 * (1.0 - float(index) / float(maxi(1, trail.size())))
		var trail_alpha := alpha * (0.32 if use_arcane_gif else 1.0)
		draw_circle(to_local(trail[index]), size * 0.45 * (1.0 - float(index) / 8.0), Color(color.r, color.g, color.b, trail_alpha))
	if use_arcane_gif:
		var frame_index := int(animation_elapsed * ARCANE_FPS) % ARCANE_FRAME_COUNT
		var source_origin := Vector2(frame_index % ARCANE_FRAMES_PER_ROW, frame_index / ARCANE_FRAMES_PER_ROW) * ARCANE_FRAME_SIZE
		var source_rect := Rect2(source_origin, Vector2.ONE * ARCANE_FRAME_SIZE)
		var sprite_rect := Rect2(-Vector2.ONE * 36.0, Vector2.ONE * 72.0)
		draw_set_transform(Vector2.ZERO, direction.angle(), Vector2.ONE)
		draw_texture_rect_region(ARCANE_SHEET, sprite_rect, source_rect, Color.WHITE, false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_circle(Vector2.ZERO, size, color)
		draw_circle(Vector2.ZERO, size * 0.55, Color(1, 1, 1, 0.85))
	if kind == "arrow":
		var tail: = - direction * 16.0
		draw_line(Vector2.ZERO, tail, Color(0.85, 0.72, 0.45), 3.0)
