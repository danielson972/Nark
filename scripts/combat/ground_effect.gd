class_name GroundEffect
extends Node2D

const ICE_FIELD_SPRITE: Texture2D = preload("res://assets/game/effects/ice_field_64.png")


var world: Node = null
var radius: = 100.0
var duration: = 3.0
var elapsed: = 0.0
var delay: = 0.0
var interval: = 0.0
var tick_accumulator: = 0.0
var mode: = "field"
var color: = Color(0.5, 0.75, 1.0, 0.35)
var edge: = Color(0.7, 0.9, 1.0, 0.8)
var slow: = 0.0
var mult: = 0.0
var damage: = 0.0
var magic: = false
var payload: Dictionary = {}
var triggered: = false
var hostile: = false
var label: = ""
var fade: = 0.3


func _ready() -> void :
	z_index = -1


func _process(delta: float) -> void :
	elapsed += delta
	var remaining: = duration - elapsed
	if delay > 0.0 and elapsed < delay:
		queue_redraw()
		return
	if mode == "burst" and not triggered:
		triggered = true
		_apply_damage()
	elif mode == "rain" and interval > 0.0:
		tick_accumulator += delta
		if tick_accumulator >= interval:
			tick_accumulator -= interval
			_apply_damage()
	elif mode == "field" or mode == "trail" or mode == "banner":
		_apply_field(delta)
	if remaining <= 0.0:
		if mode == "burst":
			queue_free()
		else:
			queue_redraw()
			modulate.a = maxf(0.0, modulate.a - delta / fade)
			if modulate.a <= 0.0:
				queue_free()
	queue_redraw()


func _apply_field(delta: float) -> void :
	if world == null:
		return
	if mode == "banner":
		if world.hero != null and world.hero.global_position.distance_to(global_position) <= radius:
			world.hero.banner_time = maxf(world.hero.banner_time, 0.25)
		return
	for enemy in world.enemies_alive():
		if enemy.global_position.distance_to(global_position) > radius + enemy.radius * 0.4:
			continue
		if slow > 0.0:
			enemy.apply_status("slow", 0.4, {"value": slow})
		if payload.has("ice"):
			enemy.apply_status("chilled", 0.5)


func _apply_damage() -> void :
	if world == null:
		return
	var targets: Array = world.enemies_alive()
	if hostile:
		targets = [world.hero]
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) > radius + enemy.radius * 0.5:
			continue
		var offset: = Vector2(randf_range(-18, 18), randf_range(-18, 18))
		world.spawn_impact(global_position + offset, color)
		if hostile:
			world.damage_hero(damage, {"type": "área"})
		else:
			world.hit_enemy(enemy, damage, 0.05, payload)


func _draw() -> void :
	if delay > 0.0 and elapsed < delay:
		var progress: = clampf(elapsed / maxf(0.01, delay), 0.0, 1.0)
		var warning := Color(0.85, 0.2, 0.15, 1.0)
		if payload.has("comet"):
			warning = Color(1.0, 0.48, 0.18, 1.0)
		draw_circle(Vector2.ZERO, radius, Color(warning.r, warning.g, warning.b, 0.14 + 0.1 * progress))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(warning.r, warning.g, warning.b, 0.55 + 0.4 * progress), 3.0)
		draw_circle(Vector2.ZERO, radius * progress, Color(warning.r, warning.g, warning.b, 0.18))
		if payload.has("comet"):
			var comet_pos := Vector2(-radius * 0.55, -radius * (1.0 - progress) * 1.3)
			draw_circle(comet_pos, lerpf(7.0, 20.0, progress), Color(1.0, 0.83, 0.43, 0.95))
			draw_line(comet_pos + Vector2(-8, -22), comet_pos + Vector2(8, 5), Color(1.0, 0.4, 0.14, 0.75), 7.0, true)
		return
	match mode:
		"burst":
			draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, 0.5))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 44, edge, 4.0)
		"rain":
			draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, 0.2))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(edge.r, edge.g, edge.b, 0.55), 2.0)
			for index in 12:
				var angle: = float(index) * 2.4 + elapsed * 1.2
				var point: = Vector2(cos(angle), sin(angle)) * radius * (0.2 + 0.7 * fposmod(float(index) * 0.37 + elapsed * 0.8, 1.0))
				var fall := fposmod(float(index) * 29.0 + elapsed * 115.0, 46.0)
				draw_line(point + Vector2(5, -fall), point + Vector2.ZERO, Color(1.0, 0.87, 0.57, 0.8), 2.0, true)
		"banner":
			draw_circle(Vector2.ZERO, radius, Color(0.95, 0.8, 0.35, 0.14))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 44, Color(1.0, 0.85, 0.4, 0.75), 3.0)
			draw_line(Vector2(0, 0), Vector2(0, -74), Color(0.9, 0.78, 0.4, 0.85), 4.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -74), Vector2(30, -64), Vector2(0, -48)
			]), Color(0.2, 0.35, 0.75, 0.9))
		"field":
			var pulse := 0.5 + 0.5 * sin(elapsed * 4.0)
			draw_circle(Vector2.ZERO, radius * 0.88, Color(0.22, 0.55, 0.95, 0.12 + pulse * 0.08))
			var ring_size := Vector2.ONE * radius * 2.28 * (0.98 + pulse * 0.035)
			var ring_rect := Rect2(-ring_size * 0.5, ring_size)
			draw_set_transform(Vector2.ZERO, sin(elapsed * 0.35) * 0.025, Vector2.ONE)
			draw_texture_rect(ICE_FIELD_SPRITE, ring_rect, false, Color(1.0, 1.0, 1.0, 0.88 + pulse * 0.12))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_:
			draw_circle(Vector2.ZERO, radius, color)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 44, edge, 2.0)
