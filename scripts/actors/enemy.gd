class_name Enemy
extends Actor


const TYPES: = {
	"gosma": {
		"name": "Gosma do Vale", "sprite": "res://assets/game/sprites/monster_slime.png", "height": 84.0, 
		"hp": 70.0, "damage": 7.0, "defense": 2.0, "speed": 66.0, "xp": 60, "tier": 0, 
		"coins": [3, 9], "aggro": 190.0, "attack_range": 56.0, "attack_cd": 1.7, "windup": 0.5, 
		"drops": {"gosma": 0.9}, "radius": 18.0, "kind": "gosma", 
	}, 
	"lobo": {
		"name": "Lobo Cinzento", "sprite": "res://assets/game/sprites/monster_wolf.png", "height": 92.0, 
		"hp": 96.0, "damage": 9.0, "defense": 4.0, "speed": 134.0, "xp": 85, "tier": 0, 
		"coins": [5, 13], "aggro": 300.0, "attack_range": 64.0, "attack_cd": 1.35, "windup": 0.42, 
		"drops": {"presa_lobo": 0.85, "sucata_ferro": 0.15}, "radius": 18.0, "kind": "lobo", 
	}, 
	"saqueador": {
		"name": "Saqueador", "sprite": "res://assets/game/sprites/monster_bandit.png", "height": 96.0, 
		"hp": 120.0, "damage": 12.0, "defense": 7.0, "speed": 108.0, "xp": 120, "tier": 1, 
		"coins": [14, 32], "aggro": 330.0, "attack_range": 72.0, "attack_cd": 1.6, "windup": 0.55, 
		"drops": {"sucata_ferro": 0.9, "presa_lobo": 0.2}, "radius": 19.0, "kind": "saqueador", 
		"guard": 0.35, 
	}, 
	"errante": {
		"name": "Monstro Errante", "sprite": "res://assets/game/sprites/monster_wolf.png", "height": 100.0, 
		"hp": 190.0, "damage": 18.0, "defense": 8.0, "speed": 152.0, "xp": 190, "tier": 2, 
		"coins": [18, 40], "aggro": 380.0, "attack_range": 66.0, "attack_cd": 1.25, "windup": 0.38, 
		"drops": {"essencia_errante": 0.85, "presa_lobo": 0.3}, "radius": 20.0, "kind": "errante", 
		"errant": true, 
	}, 
	"fera": {
		"name": "Fera de Carapaça Branca", "sprite": "res://assets/game/sprites/boss_beast.png", "height": 138.0, 
		"hp": 900.0, "damage": 26.0, "defense": 16.0, "speed": 120.0, "xp": 900, "tier": 3, 
		"coins": [120, 220], "aggro": 460.0, "attack_range": 96.0, "attack_cd": 1.9, "windup": 0.7, 
		"drops": {"carapaca_branca": 1.0, "sucata_ferro": 0.6}, "radius": 40.0, "kind": "fera", 
		"miniboss": true, 
	}, 
	"colossal": {
		"name": "Colossal de Granito", "sprite": "res://assets/game/sprites/boss_colossal.png", "height": 196.0, 
		"hp": 2600.0, "damage": 34.0, "defense": 24.0, "speed": 96.0, "xp": 3500, "tier": 4, 
		"coins": [700, 1100], "aggro": 900.0, "attack_range": 170.0, "attack_cd": 2.4, "windup": 0.9, 
		"drops": {"cristal_aurora": 1.0, "carapaca_branca": 0.5}, "radius": 62.0, "kind": "colossal", 
		"miniboss": true, "boss": true, 
	}, 
	"rival": {
		"name": "Sombra de Kael", "sprite": "res://assets/game/sprites/hero_rogue.png", "height": 96.0, 
		"hp": 340.0, "damage": 18.0, "defense": 9.0, "speed": 196.0, "xp": 420, "tier": 2, 
		"coins": [0, 0], "aggro": 460.0, "attack_range": 74.0, "attack_cd": 1.1, "windup": 0.35, 
		"drops": {}, "radius": 18.0, "kind": "rival", "rival": true, 
	}, 
}

var type_id: = "lobo"
var definition: Dictionary = {}
var spawn_point: = Vector2.ZERO
var ai_state: = "idle"
var attack_timer: = 0.0
var windup_left: = 0.0
var action: = ""
var action_time: = 0.0
var action_total: = 0.0
var charge_dir: = Vector2.RIGHT
var phase: = 1
var hit_flash_reset: = 0.0
var patrol_target: = Vector2.ZERO
var patrol_timer: = 0.0
var interrupted: = false
var exposed: = 0.0
var marked_by_hero: = false
var summoned: = false
var night_bonus: = 0.0


func setup_enemy(world_ref: Node, enemy_type: String, spawn: Vector2) -> void :
	type_id = enemy_type
	definition = TYPES.get(enemy_type, TYPES["lobo"])
	spawn_point = spawn
	kind = str(definition.get("kind", enemy_type))
	var config: Dictionary = definition
	setup(world_ref, str(config["sprite"]), float(config["height"]))
	max_hp = float(config["hp"])
	hp = max_hp
	defense = float(config["defense"])
	radius = float(config.get("radius", 18.0))
	global_position = spawn
	patrol_target = spawn
	spawn_animation = 0.35
	if bool(config.get("errant", false)):
		modulate = Color(1.15, 0.85, 1.25)
	elif bool(config.get("rival", false)):
		modulate = Color(1.0, 0.72, 0.72)
	elif bool(config.get("boss", false)):
		modulate = Color(1.1, 1.1, 1.05)
	attack_timer = randf_range(0.2, 1.0)
	ai_state = "idle"


func display_name() -> String:
	return str(definition.get("name", type_id))


func is_boss() -> bool:
	return bool(definition.get("boss", false))


func is_miniboss() -> bool:
	return bool(definition.get("miniboss", false))


func _process(delta: float) -> void :
	super._process(delta)
	if dead or world == null:
		return
	if not world.is_playing():
		return
	action_time += delta
	attack_timer = maxf(0.0, attack_timer - delta)
	exposed = maxf(0.0, exposed - delta)
	if has_status("stun") or has_status("root"):
		velocity = Vector2.ZERO
		return
	var hero = world.hero
	if hero == null or hero.dead:
		_wander(delta)
		return
	var distance: float = global_position.distance_to(hero.global_position)
	var aggro: = float(definition.get("aggro", 300.0)) * (1.0 + night_bonus)
	if bool(definition.get("boss", false)) or bool(definition.get("rival", false)):
		aggro = 4000.0
	if ai_state == "chase" and not bool(definition.get("boss", false)) and not bool(definition.get("rival", false)):
		if global_position.distance_to(spawn_point) > 520.0:
			ai_state = "idle"
			return
	if ai_state == "idle" and distance < aggro:
		ai_state = "chase"
		if bool(definition.get("boss", false)):
			world.begin_boss_fight(self)
	if ai_state != "chase":
		_wander(delta)
		return
	if windup_left > 0.0:
		windup_left -= delta
		velocity = Vector2.ZERO
		if windup_left <= 0.0:
			if bool(definition.get("boss", false)):
				_boss_release(hero)
			else:
				_release_attack(hero)
		queue_redraw()
		return
	if action == "charge":
		_run_charge(delta, hero)
		return
	if action == "recover":
		velocity = Vector2.ZERO
		if action_time >= action_total:
			action = ""
			action_time = 0.0
		queue_redraw()
		return
	var attack_range: = float(definition.get("attack_range", 60.0))
	if bool(definition.get("boss", false)):
		_boss_logic(delta, hero, distance)
		return
	if bool(definition.get("miniboss", false)) and distance < 420.0 and attack_timer <= 0.0:
		_begin_charge(hero)
		return
	if distance <= attack_range and attack_timer <= 0.0:
		_begin_attack()
		return
	var speed: = float(definition.get("speed", 120.0)) * (1.0 + night_bonus) * speed_factor()
	var direction: Vector2 = (hero.global_position - global_position).normalized()
	if distance > attack_range * 0.75:
		move_desired(direction * speed, delta)
	else:
		move_desired(Vector2.ZERO, delta)


func _wander(delta: float) -> void :
	patrol_timer -= delta
	if patrol_timer <= 0.0:
		patrol_timer = randf_range(1.4, 3.4)
		if global_position.distance_to(spawn_point) > 180.0:
			patrol_target = spawn_point
		else:
			patrol_target = spawn_point + Vector2(randf_range(-120, 120), randf_range(-120, 120))
	var direction: Vector2 = patrol_target - global_position
	if direction.length() < 12.0:
		move_desired(Vector2.ZERO, delta)
		return
	move_desired(direction.normalized() * float(definition.get("speed", 120.0)) * 0.35, delta)


func _begin_attack() -> void :
	windup_left = float(definition.get("windup", 0.5))
	attack_timer = float(definition.get("attack_cd", 1.5))
	interrupted = false
	queue_redraw()


func interrupt_cast() -> void :
	if windup_left > 0.0:
		windup_left = 0.0
		interrupted = true
		attack_timer = maxf(attack_timer, 0.8)
		if world != null:
			world.show_notice("%s interrompido" % display_name(), Color(0.85, 0.9, 1.0))
			queue_redraw()


func _release_attack(hero) -> void :
	if interrupted:
		return
	var reach: = float(definition.get("attack_range", 60.0)) + 20.0
	if global_position.distance_to(hero.global_position) > reach:
		return
	var damage: = float(definition.get("damage", 10.0))
	var crit: = randf() < 0.08
	hero.take_damage(damage, {"from": global_position, "crit": crit, "type": type_id})
	if world != null:
		world.play_cue("combat.hit", randf_range(0.85, 1.0))
		world.spawn_vfx(hero.global_position + Vector2(0, -24), Color(0.9, 0.4, 0.3), 6, 110.0)


func _begin_charge(hero) -> void :
	action = "charge"
	action_time = 0.0
	action_total = 2.6
	attack_timer = 4.5
	charge_dir = (hero.global_position - global_position).normalized()
	windup_left = 0.55
	if world != null:
		world.show_notice("A fera vai investir!", Color(0.95, 0.75, 0.4))


func _run_charge(delta: float, hero) -> void :
	if exposed > 0.0:
		action = "recover"
		action_time = 0.0
		action_total = 2.4
		return
	var speed: = 520.0
	var next: Vector2 = global_position + charge_dir * speed * delta
	move_desired(charge_dir * speed, delta)
	if world != null and world.hero != null and global_position.distance_to(world.hero.global_position) < 90.0:
		world.hero.take_damage(float(definition.get("damage", 20.0)) * 1.3, {"from": global_position, "crit": false, "type": type_id})
		world.knockback(world.hero, charge_dir, 90.0)
		action = "recover"
		action_time = 0.0
		action_total = 1.6
	if not world.can_stand(next, radius):

		global_position = global_position - charge_dir * 6.0
		exposed = 3.0
		windup_left = 0.0
		apply_status("stun", 2.4)
		action = "recover"
		action_time = 0.0
		action_total = 2.4
		if world != null:
			world.shake(8.0)
			world.spawn_vfx(global_position + charge_dir * 30.0, Color(0.9, 0.9, 0.8), 18, 260.0)
			world.show_notice("A carapaça bateu na rocha — costas expostas!", Color(0.95, 0.85, 0.45))
		queue_redraw()
	if action_time > action_total:
		action = ""
		action_time = 0.0


func _boss_logic(delta: float, hero, distance: float) -> void :
	var phase_two: = hp < max_hp * 0.5
	if phase_two and phase == 1:
		phase = 2
		world.show_notice("O Colossal desperta seu núcleo!", Color(0.6, 0.85, 1.0))
		world.shake(10.0)
		for index in 2:
			world.spawn_enemy("gosma", global_position + Vector2(randf_range(-160, 160), randf_range(60, 140)))
	var speed: = float(definition.get("speed", 96.0)) * (1.25 if phase_two else 1.0)
	if action == "sweep_recover":
		velocity = Vector2.ZERO
		if action_time > 1.5:
			action = ""
			action_time = 0.0
			exposed = 0.0
		queue_redraw()
		return
	if attack_timer <= 0.0 and distance < 720.0:
		var pattern: = randi() % (4 if phase_two else 3)
		if distance > 260.0 and pattern != 3:
			pattern = 2
		attack_timer = float(definition.get("attack_cd", 2.4)) * (0.8 if phase_two else 1.0)
		match pattern:
			0:
				action = "slam"
				action_time = 0.0
				action_total = 1.3
				windup_left = 1.1
			1:
				action = "sweep"
				action_time = 0.0
				action_total = 1.25
				windup_left = 0.95
				facing = (hero.global_position - global_position).normalized()
			2:
				action = "rocks"
				action_time = 0.0
				action_total = 1.4
				windup_left = 0.7
			_:
				action = "summon"
				action_time = 0.0
				action_total = 1.6
				windup_left = 1.2
		queue_redraw()
		return
	if distance > float(definition.get("attack_range", 170.0)) * 0.8:
		move_desired((hero.global_position - global_position).normalized() * speed, delta)
	else:
		move_desired(Vector2.ZERO, delta)


func _boss_release(hero) -> void :
	match action:
		"slam":
			var target: Vector2 = hero.global_position
			world.spawn_area_burst(target, 165.0, 42.0, Color(0.85, 0.55, 0.3), self)
			action = "recover"
			action_time = 0.0
			action_total = 0.9
			world.shake(12.0)
		"sweep":
			var reach: = 235.0
			if global_position.distance_to(hero.global_position) < reach:
				var dir: Vector2 = (hero.global_position - global_position).normalized()
				if dir.dot(facing) > 0.2:
					hero.take_damage(float(definition.get("damage", 34.0)) * 1.4, {"from": global_position, "crit": true, "type": type_id})
			world.spawn_cone_telegraph(global_position, facing, reach, 100.0, Color(0.95, 0.4, 0.25), 0.6)
			action = "sweep_recover"
			action_time = 0.0
			action_total = 1.5
		"rocks":
			for index in 3:
				var projectile: = Projectile.new()
				projectile.world = world
				projectile.hostile = true
				projectile.direction = (hero.global_position - global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))).normalized()
				projectile.speed = 420.0
				projectile.damage = float(definition.get("damage", 34.0)) * 0.6
				projectile.life = 2.4
				projectile.size = 13.0
				projectile.color = Color(0.7, 0.65, 0.55)
				projectile.position = global_position + Vector2(0, -90)
				world.add_projectile(projectile)
			action = ""
			action_time = 0.0
		"summon":
			for index in 2:
				world.spawn_enemy("gosma", global_position + Vector2(randf_range(-180, 180), randf_range(80, 180)))
			action = ""
			action_time = 0.0
		_:
			action = ""
	action_time = 0.0


func take_damage(amount: float, opts: Dictionary = {}) -> Dictionary:
	var damage: = amount
	if exposed > 0.0:
		damage *= 1.5
	if bool(definition.get("rival", false)) and has_status("guard_broken"):
		damage *= 1.2
	var result: = super.take_damage(damage, opts)
	if world != null:
		world.play_cue("combat.hit", randf_range(0.9, 1.1) if not bool(result.get("crit", false)) else 0.8)
	queue_redraw()
	return result


func _draw() -> void :
	super._draw()
	if world == null:
		return
	if windup_left > 0.0:
		var progress: float = 1.0 - windup_left / maxf(0.01, float(definition.get("windup", 0.5)))
		var reach: = float(definition.get("attack_range", 60.0)) + 18.0
		draw_circle(Vector2.ZERO, reach * 0.75, Color(0.9, 0.25, 0.2, 0.1 + 0.12 * progress))
		draw_arc(Vector2.ZERO, reach * 0.75, 0.0, TAU, 26, Color(1.0, 0.4, 0.3, 0.75), 2.5)
	if action == "slam" and windup_left > 0.0 and world.hero != null:
		var target: Vector2 = to_local(world.hero.global_position)
		draw_circle(target, 165.0, Color(0.9, 0.3, 0.2, 0.18))
		draw_arc(target, 165.0, 0.0, TAU, 40, Color(1.0, 0.5, 0.3, 0.8), 3.0)
	if action == "sweep" and windup_left > 0.0:
		var angle: = facing.angle()
		draw_arc(Vector2.ZERO, 235.0, angle - 0.9, angle + 0.9, 20, Color(1.0, 0.45, 0.3, 0.85), 4.0)
	if exposed > 0.0:
		draw_arc(Vector2.ZERO, radius + 16.0, 0.0, TAU, 28, Color(1.0, 0.9, 0.4, 0.9), 3.0)
		var label_pos: = Vector2(-40, - float(definition.get("height", 96.0)) - 14.0)
		draw_line(label_pos, label_pos + Vector2(80, 0), Color(1.0, 0.9, 0.4, 0.7), 2.0)
	if is_miniboss() and hp < max_hp:
		var width: = 90.0 if not is_boss() else 150.0
		var top: = - float(definition.get("height", 96.0)) - 18.0
		draw_rect(Rect2( - width * 0.5, top, width, 6), Color(0.1, 0.08, 0.08, 0.85))
		draw_rect(Rect2( - width * 0.5, top, width * (hp / max_hp), 6), Color(0.85, 0.3, 0.25))
