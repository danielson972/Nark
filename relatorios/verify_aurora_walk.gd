extends SceneTree

class TestHero extends Node2D:
	var dead: bool = false

class TestWorld extends Node:
	var hero: TestHero
	var playing: bool = true
	var blocked: bool = false
	func is_playing() -> bool: return playing
	func locked_enemy() -> Node: return null
	func can_stand(_point: Vector2, _radius: float) -> bool: return not blocked
	func can_actor_stand(_actor: Node, _point: Vector2, _radius: float, _ignore_hero: bool = false) -> bool: return not blocked
	func begin_boss_fight(_boss: Node) -> void: pass

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world := TestWorld.new()
	root.add_child(world)
	world.hero = TestHero.new()
	world.add_child(world.hero)
	var script = load("res://scripts/actors/enemies/colossal_aurora.gd")
	var boss = script.new()
	world.add_child(boss)
	boss.setup_enemy(world, "colossal", Vector2(1000, 1000))
	boss.set_process(false)
	boss.ai_state = "chase"
	boss.awakened = true
	boss.attack_timer = 999.0
	assert(is_equal_approx(float(boss.WALK_COLUMNS) / boss.walk_fps, 1.5), "Full walk cycle must last 1.5 seconds")
	assert(float(boss.CONFIG["speed"]) == 96.0, "Physical movement speed must be preserved")
	assert(boss.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(boss.animation_state == "idle" and boss.texture.resource_path.ends_with("aurora_idle.png"), "Spawn must load original idle")
	assert(boss.hframes == 10 and boss.vframes == 1)
	boss._update_animation(Vector2.ZERO, 0.2)
	assert(boss.frame > 0, "Idle must animate instead of showing a frozen pose")
	var directions: Array[Vector2] = [Vector2.DOWN, Vector2(1,1), Vector2.RIGHT, Vector2(1,-1), Vector2.UP, Vector2(-1,-1), Vector2.LEFT, Vector2(-1,1)]
	for row in 8:
		boss.global_position = Vector2(1000, 1000)
		boss.walk_time = 0.0
		world.hero.global_position = boss.global_position + directions[row].normalized() * 400.0
		boss._process(0.2)
		assert(boss.global_position.distance_to(Vector2(1000,1000)) > 0.1, "Expected movement")
		assert(boss.frame / 12 == row, "Wrong directional row: %d" % row)
		assert(boss.frame % 12 > 0, "Walk should advance beyond standing pose")
		assert(boss.flip_h == (row >= 5), "Left directions must mirror the matching native right profile")
		assert(boss.texture.get_size() == Vector2(3072, 2048) and boss.offset.y == -112.0)
	# Regressão: deslocamentos pequenos e interrupções breves não zeram o ciclo.
	var visited: Dictionary = {}
	for tick in 120:
		var displacement := Vector2(0.005, 0) if tick % 5 != 0 else Vector2.ZERO
		boss._update_animation(displacement, 1.0 / 60.0)
		if tick > 5:
			assert(boss.animation_state == "walk", "One blocked frame must not reset walking")
			visited[boss.frame % 12] = true
	assert(visited.size() == 12, "All twelve walk frames must play at 60 FPS despite partial collisions")
	# Exercita o relógio completo junto da perseguição real, na taxa normal do jogo.
	visited.clear()
	world.hero.global_position = boss.global_position + Vector2.RIGHT * 400.0
	for tick in 120:
		boss._process(1.0 / 60.0)
		assert(boss.animation_state == "walk" and boss.walk_row == 2)
		visited[boss.frame % 12] = true
	assert(visited.size() == 12)
	world.blocked = true
	var position_before: Vector2 = boss.global_position
	boss._process(0.2)
	assert(boss.global_position == position_before and boss.animation_state == "idle", "Blocked movement must restore idle")
	world.blocked = false
	world.playing = false
	var frame_before: int = boss.frame
	boss._process(0.5)
	assert(boss.frame == frame_before and boss.global_position == position_before, "Paused animation must freeze")
	world.playing = true
	boss.apply_status("root", 1.0)
	boss._process(0.1)
	assert(boss.animation_state == "idle" and boss.global_position == position_before)
	var placed = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(placed)
	var authored: Sprite2D = placed.get_node("Aurora_boss")
	assert(authored.hframes == 10 and authored.vframes == 1 and authored.animation_state == "idle")
	assert(not authored.get_node("AnimationPlayer").active)
	var standalone = load("res://scenes/enemies/colossal.tscn").instantiate()
	assert(standalone is Enemy)
	assert(standalone.texture.resource_path.ends_with("aurora_idle.png") and standalone.hframes == 10)
	standalone.free()
	placed.queue_free()
	world.queue_free()
	await process_frame
	print("AURORA_WALK_OK: 1.5s cycle, all 12 frames at 60 FPS, 8 directions, original idle and speed, partial collisions, pause and root")
	quit()
