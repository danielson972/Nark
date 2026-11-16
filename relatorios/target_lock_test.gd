extends Node2D

const TARGET_LOCK_RANGE: float = 720.0

var world: WorldView
var test_targets: Array[Enemy] = []
var target_origins: Array[Vector2] = []
var elapsed: float = 0.0
var next_auto_shot: float = 0.0
var initial_target_hp: float = 0.0
var collision_passed: bool = false
var nameplate_passed: bool = false
var hit_passed: bool = false
var death_switch_passed: bool = false
var range_switch_passed: bool = false
var death_switch_checked: bool = false
var range_switch_checked: bool = false
var hit_check_finished: bool = false
var target_b_forced_out: bool = false
var report: Label
var done: bool = false


func _ready() -> void:
	world = WorldView.new()
	world.name = "MundoDeTesteLockOn"
	add_child(world)
	var player_state := PlayerState.create("Teste Lock-On", "humano", "mago")
	world.build(player_state, {}, true)
	world.hero.global_position = Vector2(32.0 * Balance.TILE + Balance.TILE * 0.5, 14.0 * Balance.TILE + Balance.TILE * 0.5)
	world.camera.global_position = world.hero.global_position
	world.start()
	world.hero.set_process(false)
	var center: Vector2 = world.hero.global_position
	var target_a := world.spawn_enemy("gosma", center + Vector2(250, 0)) as Enemy
	var target_b := world.spawn_enemy("lobo", center + Vector2(420, 0)) as Enemy
	var target_c := world.spawn_enemy("saqueador", center + Vector2(590, 0)) as Enemy
	test_targets = [target_a, target_b, target_c]
	target_origins = [target_a.global_position, target_b.global_position, target_c.global_position]
	for enemy in test_targets:
		enemy.set_process(false)
	var hero_start: Vector2 = world.hero.global_position
	for step in 60:
		world.hero.move_desired(Vector2.RIGHT * 600.0, 1.0 / 60.0)
	collision_passed = world.hero.global_position.distance_to(target_a.global_position) >= world.hero.radius + target_a.radius - 0.1
	world.hero.global_position = hero_start
	world.camera.global_position = hero_start
	print("[lock-on-test] %s: o herói colide com o inimigo em vez de atravessá-lo." % ("PASS" if collision_passed else "FAIL"))
	world.lock_target(target_a, false)
	target_a._update_nameplate()
	nameplate_passed = target_a.nameplate != null and target_a.nameplate.text == target_a.display_name() and target_a.nameplate.position.y < -float(target_a.definition["height"]) and target_a.nameplate.get_theme_font("font") == Enemy.NAME_FONT_MARKED
	print("[lock-on-test] %s: nome acima da cabeça em bold no alvo fixado." % ("PASS" if nameplate_passed else "FAIL"))
	initial_target_hp = target_a.hp
	_add_test_overlay()
	_fire_arcane_projectile(true)
	print("[lock-on-test] Iniciado: alvo móvel A, projétil arcano teleguiado.")


func _process(delta: float) -> void:
	elapsed += delta
	_update_moving_targets()
	if not hit_passed and test_targets[0].hp < initial_target_hp:
		hit_passed = true
		print("[lock-on-test] PASS: projétil arcano acertou o primeiro alvo em movimento.")
	if not hit_check_finished and elapsed >= 3.2:
		hit_check_finished = true
		if not hit_passed:
			push_error("[lock-on-test] FAIL: nenhum projétil arcano acertou o primeiro alvo.")
	if not death_switch_checked and elapsed >= 1.3:
		death_switch_checked = true
		var dead_target: Enemy = test_targets[0]
		dead_target.hp = 0.0
		dead_target.dead = true
		dead_target.visible = false
		var acquired := world.locked_enemy()
		death_switch_passed = acquired == test_targets[1]
		print("[lock-on-test] %s: troca automática após morte." % ("PASS" if death_switch_passed else "FAIL"))
	if not range_switch_checked and elapsed >= 2.0:
		range_switch_checked = true
		target_b_forced_out = true
		test_targets[1].global_position = world.hero.global_position + Vector2(TARGET_LOCK_RANGE + 180.0, 0.0)
		var acquired := world.locked_enemy()
		range_switch_passed = acquired == test_targets[2]
		print("[lock-on-test] %s: troca automática ao sair do alcance." % ("PASS" if range_switch_passed else "FAIL"))
	if elapsed >= next_auto_shot:
		next_auto_shot = elapsed + 0.85
		_fire_arcane_projectile()
	_update_report()


func _update_moving_targets() -> void:
	for index in test_targets.size():
		var enemy: Enemy = test_targets[index]
		if enemy.dead or (index == 1 and target_b_forced_out):
			continue
		var sway: float = sin(elapsed * (1.5 + index * 0.25) + float(index)) * (90.0 - index * 16.0)
		enemy.global_position = target_origins[index] + Vector2(0.0, sway)


func _fire_arcane_projectile(aim_at_body: bool = false) -> void:
	var target := world.locked_enemy()
	if target == null or world.hero == null:
		return
	var aim_point: Vector2 = target.global_position
	if aim_at_body:
		aim_point.y -= float(target.definition.get("height", 96.0)) * 0.55
	var projectile := Projectile.new()
	projectile.world = world
	projectile.hero_owner = world.hero
	projectile.kind = "arcane"
	projectile.use_arcane_gif = true
	projectile.homing_target = null if aim_at_body else target
	projectile.speed = 820.0
	projectile.homing_strength = 12.0
	projectile.damage = 18.0
	projectile.life = 3.0
	projectile.hit_radius = 25.0
	projectile.color = Color(0.5, 0.8, 1.0)
	projectile.position = world.hero.global_position + Vector2(0.0, -26.0)
	projectile.direction = projectile.global_position.direction_to(aim_point)
	world.add_projectile(projectile)


func _add_test_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(500, 132)
	canvas.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "TESTE DE LOCK-ON — PROJÉTIL ARCANO"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.55, 0.88, 1.0))
	column.add_child(title)
	report = Label.new()
	report.add_theme_font_size_override("font_size", 15)
	column.add_child(report)
	var help := Label.new()
	help.text = "Alvos A/B/C se movem. Tab alterna o lock-on; observe a retícula ciano."
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)


func _update_report() -> void:
	if report == null:
		return
	var active_name := "nenhum"
	var active := world.locked_enemy()
	if active != null and active.has_method("display_name"):
		active_name = str(active.call("display_name"))
	var hit_text := "ACERTO" if hit_passed else ("FALHOU" if hit_check_finished else "em curso")
	var death_text := "OK" if death_switch_passed else ("FALHOU" if death_switch_checked else "aguardando")
	var range_text := "OK" if range_switch_passed else ("FALHOU" if range_switch_checked else "aguardando")
	var collision_text := "OK" if collision_passed else "FALHOU"
	var nameplate_text := "OK" if nameplate_passed else "FALHOU"
	report.text = "Nome bold no lock: %s  |  Colisão: %s\nAcerto móvel: %s  |  Troca ao morrer: %s  |  Fora do alcance: %s\nAlvo atual: %s" % [nameplate_text, collision_text, hit_text, death_text, range_text, active_name]
	if not done and hit_check_finished and death_switch_checked and range_switch_checked:
		done = true
		var all_passed := hit_passed and death_switch_passed and range_switch_passed and collision_passed and nameplate_passed
		report.add_theme_color_override("font_color", Color(0.45, 1.0, 0.55) if all_passed else Color(1.0, 0.45, 0.4))
		if all_passed:
			print("[lock-on-test] RESULTADO: PASS — acerto, troca por morte e troca por alcance validados.")
		else:
			push_error("[lock-on-test] RESULTADO: FAIL — consulte as verificações acima.")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("target_lock"):
		world.toggle_target_lock()
		get_viewport().set_input_as_handled()
