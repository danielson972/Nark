class_name Actor
extends Node2D


signal died(actor: Actor)

const SHADOW_SIZE: = Vector2(34.0, 14.0)

var world: Node = null
var radius: = 17.0
var max_hp: = 100.0
var hp: = 100.0
var defense: = 0.0
var facing: = Vector2.DOWN
var velocity: = Vector2.ZERO
var sprite: Sprite2D
var sprite_path: = ""
var base_scale: = 1.0
var statuses: Dictionary = {}
var flash_time: = 0.0
var invulnerable: = 0.0
var spawn_animation: = 0.0
var dead: = false
var bob: = 0.0
var kind: = "actor"


func setup(world_ref: Node, texture_path: String, target_height: float = 96.0) -> void :
	world = world_ref
	sprite_path = texture_path
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		var texture: Texture2D = load(texture_path)
		if texture != null and texture.get_height() > 0:
			base_scale = target_height / float(texture.get_height())
	_build_nodes()


func _build_nodes() -> void :
	if sprite != null:
		return
	sprite = Sprite2D.new()
	if not sprite_path.is_empty() and ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)
	sprite.scale = Vector2(base_scale, base_scale)
	sprite.offset = Vector2(0, - float(sprite.texture.get_height() if sprite.texture else 64) * 0.5)
	add_child(sprite)
	z_index = 1


func _process(delta: float) -> void :
	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)
		if sprite != null:
			sprite.modulate = Color(2.4, 1.1, 1.1) if flash_time > 0.0 else Color.WHITE
	if invulnerable > 0.0:
		invulnerable = maxf(0.0, invulnerable - delta)
	if spawn_animation > 0.0:
		spawn_animation = maxf(0.0, spawn_animation - delta)
		if sprite != null:
			var progress: float = 1.0 - spawn_animation / 0.35
			sprite.modulate.a = clampf(progress, 0.0, 1.0)
	_update_statuses(delta)
	queue_redraw()


func _update_statuses(delta: float) -> void :
	for key: String in statuses.keys():
		var entry: Dictionary = statuses[key]
		entry["time"] = float(entry.get("time", 0.0)) - delta
		if key == "bleed" and world != null and world.has_method("spawn_bleed_tick"):
			var accumulator: = float(entry.get("acc", 0.0)) + delta
			if accumulator >= 0.5:
				accumulator -= 0.5
				take_damage(float(entry.get("dps", 4.0)) * 0.5, {"type": "sangramento", "silent": true})
			entry["acc"] = accumulator
		if float(entry["time"]) <= 0.0:
			statuses.erase(key)


func has_status(key: String) -> bool:
	return statuses.has(key)

func status_time(key: String) -> float:
	return float(statuses.get(key, {}).get("time", 0.0))

func is_rooted() -> bool:
	return has_status("root") or has_status("stun")

func is_stunned() -> bool:
	return has_status("stun")

func speed_factor() -> float:
	var factor: = 1.0
	if has_status("slow"):
		factor *= 1.0 - clampf(float(statuses["slow"].get("value", 0.4)), 0.0, 0.9)
	if is_rooted():
		factor = 0.0
	return - factor if factor < 0.0 else factor


func apply_status(key: String, duration: float, extra: Dictionary = {}) -> void :
	var entry: Dictionary = statuses.get(key, {})
	entry["time"] = maxf(float(entry.get("time", 0.0)), duration)
	for field: String in extra.keys():
		entry[field] = extra[field]
	statuses[key] = entry


func clear_status(key: String) -> void :
	statuses.erase(key)


func move_desired(desired: Vector2, delta: float) -> void :
	if desired.length_squared() > 1.0:
		if absf(desired.x) > absf(desired.y):
			facing = Vector2(signf(desired.x), 0)
		else:
			facing = Vector2(0, signf(desired.y))
	velocity = desired
	if desired.length_squared() > 1.0:
		var fx: = desired.normalized()
		if sprite != null:
			sprite.flip_h = fx.x < -0.15
	var step: = desired * delta
	if world == null:
		position += step
		return
	var try_x: = position + Vector2(step.x, 0.0)
	if world.can_stand(try_x, radius):
		position = try_x
	var try_y: = position + Vector2(0.0, step.y)
	if world.can_stand(try_y, radius):
		position = try_y
	position.x = clampf(position.x, radius, float(Balance.MAP_W * Balance.TILE) - radius)
	position.y = clampf(position.y, radius, float(Balance.MAP_H * Balance.TILE) - radius)


func take_damage(amount: float, opts: Dictionary = {}) -> Dictionary:
	if dead:
		return {"amount": 0.0, "crit": false, "killed": false}
	if invulnerable > 0.0 and not bool(opts.get("ignore_invulnerable", false)):
		return {"amount": 0.0, "crit": false, "killed": false}
	hp = maxf(0.0, hp - amount)
	flash_time = 0.12
	var result: = {"amount": amount, "crit": bool(opts.get("crit", false)), "killed": hp <= 0.0}
	if world != null and world.has_method("show_damage_number") and not bool(opts.get("silent", false)):
		world.show_damage_number(global_position + Vector2(0, -46), amount, bool(opts.get("crit", false)), str(opts.get("type", "")))
	if hp <= 0.0 and not dead:
		die()
	return result


func heal(amount: float) -> void :
	hp = minf(max_hp, hp + amount)


func die() -> void :
	dead = true
	died.emit(self)
	if world != null and world.has_method("on_actor_died"):
		world.on_actor_died(self)
	queue_free()


func _draw() -> void :
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_ellipse_shadow()
	if has_status("mark") or has_status("duel_mark"):
		draw_arc(Vector2.ZERO, radius + 10.0, 0.0, TAU, 26, Color(0.95, 0.75, 0.25, 0.85), 2.0)
	if has_status("slow"):
		draw_arc(Vector2.ZERO, radius + 4.0, 0.0, TAU, 22, Color(0.45, 0.8, 1.0, 0.7), 2.0)
	if has_status("guard_broken"):
		draw_arc(Vector2.ZERO, radius + 14.0, 0.0, TAU, 24, Color(1.0, 0.35, 0.2, 0.9), 3.0)
	if has_status("root"):
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 20, Color(0.4, 0.9, 0.6, 0.95), 3.0)
	if has_status("stun"):
		draw_arc(Vector2.ZERO + Vector2(0, -70), 9.0, 0.0, TAU, 12, Color(1, 0.9, 0.3, 0.95), 3.0)


func draw_ellipse_shadow() -> void :
	var points: = PackedVector2Array()
	for index in 18:
		var angle: = TAU * float(index) / 18.0
		points.append(Vector2(cos(angle) * SHADOW_SIZE.x * 0.5, sin(angle) * SHADOW_SIZE.y * 0.5))
	draw_colored_polygon(points, Color(0, 0, 0, 0.28))
