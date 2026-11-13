class_name SkillEngine
extends RefCounted


static func execute(world: Node, hero: Node, definition: Dictionary, aim: Vector2) -> void :
	if world == null or hero == null or definition.is_empty():
		return
	var params: Dictionary = definition.get("params", {})
	match str(definition.get("handler", "")):
		"projectile": _projectile(world, hero, definition, params, aim, 1)
		"cone_shot": _projectile(world, hero, definition, params, aim, int(params.get("count", 3)))
		"spin": _spin(world, hero, definition, params)
		"bash": _bash(world, hero, definition, params, aim)
		"dash_strike": _dash_strike(world, hero, definition, params, aim)
		"line": _line(world, hero, definition, params, aim)
		"blink": _blink(world, hero, definition, params, aim)
		"blink_behind": _blink_behind(world, hero, definition, params, aim)
		"ground_field": _ground_field(world, hero, definition, params, aim)
		"delayed_aoe": _delayed_aoe(world, hero, definition, params, aim)
		"rain": _rain(world, hero, definition, params, aim)
		"banner": _banner(world, hero, definition, params, aim)
		"execute": _execute(world, hero, definition, params, aim)
		"wave": _wave(world, hero, definition, params, aim)
		"shield_advance": _shield_advance(world, hero, definition, params)
		"mark": _mark(world, hero, definition, params, aim)
		"buff": _buff(world, hero, definition, params)
		_: pass


static func _hero_power(hero: Node) -> float:
	return hero.state.damage_power()


static func _crit_for(hero: Node, magic: bool) -> float:
	return hero.state.crit_magical() if magic else hero.state.crit_physical()


static func _projectile(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2, count: int) -> void :
	var origin: Vector2 = hero.global_position + Vector2(0, -26)
	var base_dir: Vector2 = (aim - hero.global_position)
	if base_dir.length() < 4.0:
		base_dir = hero.facing
	base_dir = base_dir.normalized()
	hero.facing = base_dir
	var magic: = bool(params.get("magic", false))
	var power: = _hero_power(hero)
	var mult: = float(params.get("mult", 1.0))
	var crit: = _crit_for(hero, magic)
	var payload: Dictionary = {"melee": false}
	if params.has("root"):
		payload["root"] = float(params["root"])
	if params.has("mark"):
		payload["mark"] = float(params["mark"])
	if params.has("slow"):
		payload["slow"] = float(params["slow"])
	var skill_id: = str(definition.get("id", ""))
	var flow_skill: = skill_id == "projetil_arcano" or skill_id == "tiro_preciso"
	var aim_charge: = float(hero.aim_charge)
	if skill_id == "tiro_preciso":
		if hero.has_passive("mira_firme") and aim_charge >= 1.0:
			crit += 0.3
			world.show_notice("Mira Firme!", Color(0.95, 0.85, 0.45))
		payload["ignore_defense"] = 0.5 if hero.has_passive("ponto_fraco") else 0.0
		hero.aim_charge = 0.0
	var spread: = 0.0
	if count > 1:
		spread = deg_to_rad(float(params.get("spread", 40.0)))
	for index in count:
		var offset: = 0.0
		if count > 1:
			offset = lerpf( - spread * 0.5, spread * 0.5, float(index) / float(count - 1))
		var projectile: = Projectile.new()
		projectile.world = world
		projectile.hero_owner = hero
		projectile.direction = base_dir.rotated(offset)
		projectile.speed = float(params.get("speed", 800.0))
		projectile.damage = power * mult
		projectile.magic = magic
		projectile.crit_chance = crit
		projectile.life = float(params.get("range", 500.0)) / maxf(1.0, projectile.speed)
		projectile.kind = str(params.get("kind", "arrow"))
		projectile.color = Color(0.55, 0.75, 1.0) if magic else Color(0.95, 0.86, 0.55)
		projectile.size = 11.0 if magic else 7.0
		projectile.payload = payload.duplicate()
		projectile.payload["flow"] = flow_skill
		projectile.position = origin
		world.add_projectile(projectile)


static func _spin(world: Node, hero: Node, definition: Dictionary, params: Dictionary) -> void :
	var hits: = int(params.get("hits", 1))
	var interval: = float(params.get("interval", 0.0))
	for index in hits:
		var delay: = interval * float(index)
		if delay <= 0.0:
			_spin_hit(world, hero, definition, params)
		else:
			var timer: SceneTreeTimer = world.get_tree().create_timer(delay)
			timer.timeout.connect( func() -> void :
				if is_instance_valid(hero) and is_instance_valid(world):
					_spin_hit(world, hero, definition, params)
			)


static func _spin_hit(world: Node, hero: Node, definition: Dictionary, params: Dictionary) -> void :
	var radius: = float(params.get("radius", 100.0))
	var power: = _hero_power(hero)
	var mult: = float(params.get("mult", 1.0))
	world.spawn_vfx(hero.global_position + Vector2(0, -22), Color(0.95, 0.8, 0.5), 12, 190.0)
	var targets: Array = world.enemies_in_radius(hero.global_position, radius)
	var skill_id: = str(definition.get("id", ""))
	for enemy in targets:
		var bonus: = 1.0
		var payload: Dictionary = {"melee": true}
		if params.has("slow"):
			enemy.apply_status("slow", float(params.get("slow_time", 3.0)), {"value": float(params["slow"])})
		if params.has("knockback"):
			world.knockback(enemy, (enemy.global_position - hero.global_position).normalized(), float(params["knockback"]))
		if skill_id == "corte_duplo" and hero.has_passive("emboscada") and hero.emboscada_ready:
			payload["bleed"] = 6.0
			payload["bleed_time"] = 4.0
			hero.emboscada_ready = false
		world.hit_enemy(enemy, power * mult * bonus, _crit_for(hero, false), payload)


static func _bash(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var radius: = float(params.get("radius", 96.0))
	var arc: = deg_to_rad(float(params.get("arc", 120.0)))
	var direction: Vector2 = (aim - hero.global_position)
	if direction.length() < 4.0:
		direction = hero.facing
	direction = direction.normalized()
	hero.facing = direction
	var power: = _hero_power(hero)
	var mult: = float(params.get("mult", 0.8))
	var skill_id: = str(definition.get("id", ""))
	if skill_id == "quebra_guarda" and hero.has_passive("brecha_tatica"):
		if hero.last_investida >= 0.0 and hero.elapsed - hero.last_investida <= 2.5:
			mult *= 1.6
			world.show_notice("Brecha Tática!", Color(0.95, 0.8, 0.4))
	if skill_id == "pancada_escudo" and hero.retaliacao_ready:
		radius += 50.0
		mult *= 1.5
		hero.retaliacao_ready = false
	world.spawn_vfx(hero.global_position + direction * 40.0, Color(0.9, 0.85, 0.7), 10, 160.0)
	for enemy in world.enemies_in_arc(hero.global_position, direction, radius, arc):
		var payload: Dictionary = {"melee": true}
		if bool(params.get("interrupt", false)) and enemy.has_method("interrupt_cast"):
			enemy.interrupt_cast()
		if params.has("stun"):
			enemy.apply_status("stun", float(params["stun"]))
		if params.has("break"):
			enemy.apply_status("guard_broken", float(params["break"]))
			hero.blocks_recent = hero.blocks_recent
			if hero.has_passive("impeto"):
				hero.energy = minf(hero.state.max_energy(), hero.energy + 25.0)
		world.hit_enemy(enemy, power * mult, _crit_for(hero, false), payload)


static func _dash_strike(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var direction: Vector2 = (aim - hero.global_position)
	if direction.length() < 4.0:
		direction = hero.facing
	direction = direction.normalized()
	hero.facing = direction
	var distance: = float(params.get("distance", 260.0))
	var steps: = int(distance / 16.0)
	var travelled: = 0.0
	var hit_ids: Array = []
	for step in steps:
		var next: Vector2 = hero.global_position + direction * 16.0
		if not world.can_stand(next, hero.radius):
			break
		hero.global_position = next
		travelled += 16.0
		for enemy in world.enemies_in_radius(hero.global_position, 74.0):
			if hit_ids.has(enemy.get_instance_id()):
				continue
			hit_ids.append(enemy.get_instance_id())
			var skill_id: = str(definition.get("id", ""))
			if skill_id == "carga_real" and hero.has_passive("cerco") and enemy.has_status("duel_mark"):
				if enemy.has_method("interrupt_cast"):
					enemy.interrupt_cast()
				enemy.apply_status("stun", 0.6)
				hero.estocada_bonus = 1.8
			if bool(params.get("push_all", false)):
				world.knockback(enemy, direction, float(params.get("knockback", 90.0)))
			else:
				world.knockback(enemy, direction, float(params.get("knockback", 70.0)))
			world.hit_enemy(enemy, _hero_power(hero) * float(params.get("mult", 1.3)), _crit_for(hero, false), {"melee": true})
	world.spawn_vfx(hero.global_position, Color(0.9, 0.8, 0.55), 12, 200.0)
	if str(definition.get("id", "")) == "investida":
		hero.last_investida = hero.elapsed


static func _line(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var direction: Vector2 = (aim - hero.global_position)
	if direction.length() < 4.0:
		direction = hero.facing
	direction = direction.normalized()
	hero.facing = direction
	var bonus: float = hero.estocada_bonus if float(hero.estocada_bonus) > 0.0 else 1.0
	hero.estocada_bonus = 0.0
	for enemy in world.enemies_in_line(hero.global_position, direction, float(params.get("length", 240.0)), float(params.get("width", 56.0))):
		world.hit_enemy(enemy, _hero_power(hero) * float(params.get("mult", 1.0)) * bonus, _crit_for(hero, false), {"melee": true})
		if enemy.has_status("estocada_vulnerable"):
			enemy.clear_status("estocada_vulnerable")
	world.spawn_vfx(hero.global_position + direction * 90.0, Color(0.9, 0.9, 0.75), 8, 170.0)
	if hero.banner_time > 0.0:
		hero.energy = minf(hero.state.max_energy(), hero.energy + 10.0)


static func _blink(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var direction: Vector2 = (aim - hero.global_position)
	if direction.length() < 4.0:
		direction = hero.facing
	direction = direction.normalized()
	var start: Vector2 = hero.global_position
	var target: Vector2 = start + direction * float(params.get("distance", 200.0))
	var offset: float = float(params.get("distance", 200.0))
	while offset > 24.0 and not world.can_stand(target, hero.radius):
		offset -= 16.0
		target = start + direction * offset
	hero.spawn_afterimage()
	hero.global_position = target
	world.spawn_vfx(target, Color(0.55, 0.75, 1.0), 14, 200.0)
	if hero.has_passive("rastro_gelido"):
		_spawn_trail(world, hero, start, target)


static func _spawn_trail(world: Node, hero: Node, from: Vector2, to: Vector2) -> void :
	var steps: = maxi(2, int(from.distance_to(to) / 44.0))
	for index in steps:
		var effect: = GroundEffect.new()
		effect.world = world
		effect.mode = "trail"
		effect.radius = 34.0
		effect.duration = 4.0
		effect.slow = 0.35
		effect.color = Color(0.5, 0.8, 1.0, 0.25)
		effect.edge = Color(0.7, 0.92, 1.0, 0.6)
		effect.payload = {"ice": true}
		effect.position = from.lerp(to, float(index) / float(steps))
		world.add_area_effect(effect)


static func _blink_behind(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, _aim: Vector2) -> void :
	var target = world.marked_enemy_for(hero)
	if target == null:
		world.show_notice("Nenhum alvo marcado.", Color(0.9, 0.7, 0.5))
		return
	var behind: Vector2 = target.global_position - target.facing.normalized() * 58.0
	if not world.can_stand(behind, hero.radius):
		behind = target.global_position + Vector2(0, 58)
	hero.spawn_afterimage()
	hero.global_position = behind
	hero.facing = (target.global_position - behind).normalized()
	hero.last_shadow_step = hero.elapsed
	hero.emboscada_ready = hero.has_passive("emboscada")
	world.spawn_vfx(behind, Color(0.6, 0.4, 0.85), 12, 180.0)


static func _ground_field(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var effect: = GroundEffect.new()
	effect.world = world
	effect.mode = "field"
	effect.radius = float(params.get("radius", 120.0))
	effect.duration = float(params.get("duration", 5.0))
	effect.slow = float(params.get("slow", 0.4))
	effect.color = Color(0.45, 0.75, 1.0, 0.26)
	effect.edge = Color(0.65, 0.9, 1.0, 0.75)
	effect.payload = {"ice": true}
	effect.position = aim
	world.add_area_effect(effect)


static func _delayed_aoe(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var effect: = GroundEffect.new()
	effect.world = world
	effect.mode = "burst"
	effect.radius = float(params.get("radius", 160.0))
	effect.duration = 0.5
	effect.delay = float(params.get("delay", 0.7))
	effect.damage = _hero_power(hero) * float(params.get("mult", 3.0))
	effect.color = Color(1.0, 0.6, 0.3, 0.45)
	effect.edge = Color(1.0, 0.85, 0.5, 0.95)
	effect.position = aim
	world.add_area_effect(effect)


static func _rain(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var effect: = GroundEffect.new()
	effect.world = world
	effect.mode = "rain"
	effect.radius = float(params.get("radius", 130.0))
	effect.duration = float(params.get("duration", 3.0))
	effect.interval = float(params.get("interval", 0.45))
	effect.damage = _hero_power(hero) * float(params.get("mult", 0.42))
	effect.color = Color(0.95, 0.85, 0.55, 0.25)
	effect.edge = Color(1.0, 0.9, 0.6, 0.7)
	effect.position = aim
	world.add_area_effect(effect)


static func _banner(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var effect: = GroundEffect.new()
	effect.world = world
	effect.mode = "banner"
	effect.radius = float(params.get("radius", 150.0))
	effect.duration = float(params.get("duration", 10.0))
	effect.position = aim
	world.add_area_effect(effect)


static func _execute(world: Node, hero: Node, definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var radius: = float(params.get("radius", 120.0))
	var power: = _hero_power(hero)
	var mult: = float(params.get("mult", 2.0))
	var targets: Array = world.enemies_in_radius(aim, radius)
	for enemy in targets:
		var bonus: = 1.0
		var payload: Dictionary = {"melee": true}
		if params.has("missing_hp_scale"):
			var missing: = 1.0 - clampf(enemy.hp / maxf(1.0, enemy.max_hp), 0.0, 1.0)
			bonus += missing * float(params["missing_hp_scale"])
		if params.has("guard_bonus") and enemy.has_status("guard_broken"):
			bonus += float(params["guard_bonus"])
		if bool(params.get("consume_mark", false)) and enemy.has_status("mark"):
			enemy.clear_status("mark")
			world.show_notice("Marca consumida.", Color(0.9, 0.6, 0.9))
		world.hit_enemy(enemy, power * mult * bonus, _crit_for(hero, false), payload)
	world.spawn_vfx(aim, Color(0.95, 0.5, 0.4), 16, 230.0)
	if str(definition.get("id", "")) == "golpe_ruptura":
		world.shake(6.0)


static func _wave(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var blocks: = float(hero.blocks_recent)
	hero.blocks_recent = 0.0
	var mult: = float(params.get("mult", 1.2)) * (1.0 + float(params.get("per_block", 0.35)) * blocks)
	var radius: = float(params.get("radius", 130.0)) + 12.0 * blocks
	for enemy in world.enemies_in_radius(hero.global_position, radius):
		world.hit_enemy(enemy, _hero_power(hero) * mult, _crit_for(hero, false), {"melee": true})
		world.knockback(enemy, (enemy.global_position - hero.global_position).normalized(), 80.0)
	world.spawn_vfx(hero.global_position, Color(0.75, 0.85, 1.0), 22, 260.0)
	world.shake(5.0)
	world.show_notice("Revanche de Ferro: %d bloqueios" % int(blocks), Color(0.8, 0.9, 1.0))


static func _shield_advance(_world: Node, hero: Node, _definition: Dictionary, params: Dictionary) -> void :
	hero.bastiao_time = float(params.get("duration", 4.0))
	hero.bastiao_resist = float(params.get("frontal_resist", 0.7))
	hero.bastiao_speed = float(params.get("speed", 0.55))


static func _mark(world: Node, hero: Node, _definition: Dictionary, params: Dictionary, aim: Vector2) -> void :
	var target = world.nearest_enemy(aim, float(params.get("range", 420.0)))
	if target == null:
		target = world.nearest_enemy(hero.global_position, float(params.get("range", 420.0)))
	if target == null:
		world.show_notice("Nenhum alvo no alcance.", Color(0.9, 0.7, 0.5))
		return
	target.apply_status("mark", float(params.get("duration", 10.0)))
	target.apply_status("duel_mark", float(params.get("duration", 10.0)))
	hero.marked_enemy = target
	world.spawn_vfx(target.global_position + Vector2(0, -30), Color(0.95, 0.8, 0.35), 12, 150.0)
	world.show_notice("Selo do Desafio: duelo marcado.", Color(0.95, 0.8, 0.35))


static func _buff(_world: Node, hero: Node, _definition: Dictionary, params: Dictionary) -> void :
	hero.buff_damage = float(params.get("damage", 0.5))
	hero.buff_speed = float(params.get("speed", 0.3))
	hero.buff_time = float(params.get("duration", 8.0))
