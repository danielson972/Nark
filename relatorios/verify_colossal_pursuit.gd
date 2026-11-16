extends SceneTree

class TestHero extends Node2D:
	var dead: bool = false

class TestWorld extends Node:
	var hero: TestHero
	var origin := Vector2(1000, 1000)
	var blocked: bool = false
	var directional_gate: bool = false
	var short_corridor: bool = false
	func is_playing() -> bool: return true
	func locked_enemy() -> Node: return null
	func can_actor_stand(_actor: Node, _point: Vector2, _radius: float, _ignore_hero: bool = false) -> bool: return not blocked
	func can_stand(point: Vector2, _radius: float) -> bool:
		if blocked: return false
		var d: Vector2 = point - origin
		if short_corridor: return d.length() <= 20.0
		if directional_gate: return d.angle() < deg_to_rad(-5.0) or d.angle() > deg_to_rad(170.0)
		return true

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world := TestWorld.new()
	root.add_child(world)
	world.hero = TestHero.new()
	world.add_child(world.hero)
	var boss = load("res://scripts/actors/enemies/colossal_aurora.gd").new()
	world.add_child(boss)
	boss.setup_enemy(world, "colossal", world.origin)
	boss.set_process(false)
	boss.ai_state = "chase"
	boss.awakened = true
	boss.attack_timer = 999.0

	# Regressão: a saída de -25 graus deve vencer a volta de +180 graus.
	world.directional_gate = true
	var direction: Vector2 = boss._avoid_obstacles(Vector2.RIGHT * 96.0, 1.0 / 60.0)
	assert(direction.x > 80.0 and direction.y < 0.0, "Prefer the short turn on the other side over turning back")
	for tick in 5:
		var retargeted := Vector2.RIGHT.rotated(deg_to_rad(1.0 if tick % 2 == 0 else -1.0)) * 96.0
		assert(boss._avoid_obstacles(retargeted, 1.0 / 60.0).is_equal_approx(direction), "Minor target movement must keep a valid detour")
	world.directional_gate = false
	assert(boss._avoid_obstacles(Vector2.DOWN * 96.0, 1.0 / 60.0).is_equal_approx(Vector2.DOWN * 96.0), "A large dodge must invalidate the old detour immediately")
	world.short_corridor = true
	boss.avoidance_left = 0.0
	assert(boss._avoid_obstacles(Vector2.RIGHT * 96.0, 1.0 / 60.0).x > 90.0, "A short clear step must not require 100px of free corridor")
	world.blocked = true
	assert(boss._avoid_obstacles(Vector2.RIGHT * 96.0, 1.0 / 60.0) == Vector2.ZERO, "Actual blockage must still stop movement")
	world.blocked = false
	world.short_corridor = false

	# A direção visual não pisca ao cruzar a fronteira de 22,5 graus repetidamente.
	boss._update_animation(Vector2.RIGHT, 1.0 / 60.0)
	for tick in 120:
		boss._update_animation(Vector2.RIGHT.rotated(deg_to_rad(22.0 if tick % 2 == 0 else 24.0)), 1.0 / 60.0)
		assert(boss.walk_row == 2, "Direction must not flicker at sector boundaries")
	boss._update_animation(Vector2.RIGHT.rotated(deg_to_rad(34.0)), 1.0 / 60.0)
	assert(boss.walk_row == 1, "A deliberate turn must still update the sprite")
	boss._update_animation(Vector2.LEFT, 1.0 / 60.0)
	assert(boss.walk_row == 6)

	# Fuga e esquivas consecutivas: o chefe acompanha o alvo atual sem quadros parados.
	world.hero.global_position = boss.global_position + Vector2.RIGHT * 400.0
	for tick in 240:
		world.hero.position.x += 3.0
		if tick % 60 == 0: world.hero.position.y += 64.0 if tick % 120 == 0 else -64.0
		var previous: Vector2 = boss.global_position
		boss._process(1.0 / 60.0)
		assert(boss.global_position.distance_to(previous) > 1.0, "Free chase must not stall after a dodge or retreat")
		assert(boss.ai_state == "chase" and boss.animation_state == "walk")

	# Escapar de um golpe curto devolve a perseguição, mantendo a recarga.
	world.hero.position = boss.position + Vector2.RIGHT * 400.0
	boss.action = "sweep"
	boss.windup_left = 0.8
	boss.attack_timer = 2.0
	var previous: Vector2 = boss.position
	boss._process(0.1)
	assert(boss.action.is_empty() and boss.windup_left == 0.0 and boss.position.distance_to(previous) > 1.0)
	assert(boss.attack_timer > 1.0, "Cancel must preserve attack cooldown")
	world.hero.position = boss.position + Vector2.RIGHT * 200.0
	boss.action = "sweep"
	boss.windup_left = 0.8
	previous = boss.position
	boss._process(0.1)
	assert(boss.action == "sweep" and boss.windup_left > 0.0 and boss.position == previous, "Nearby melee windup must be preserved")
	world.hero.position = boss.position + Vector2.RIGHT * 500.0
	boss.action = "rocks"
	boss.windup_left = 0.8
	boss._process(0.1)
	assert(boss.action == "rocks" and boss.windup_left > 0.0, "Ranged casting must be preserved")
	world.queue_free()
	await process_frame
	print("COLOSSAL_PURSUIT_OK: shortest detour, stable steering, fast retarget, short corridor, direction hysteresis, 4s dodge/retreat chase, escaped melee and preserved casts")
	quit()
