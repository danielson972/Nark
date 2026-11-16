class_name Hero
extends Actor

const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const ItemArt = preload("res://scripts/ui/item_catalog.gd")
var weapon_sprite: Sprite2D
var grip_hand_sprite: Sprite2D
var colossal_effect: Node2D
var aura_effect: Sprite2D
var appearance_key: String = ""
var visual_height: float = 92.0
var walk_phase: float = 0.0
var animation_clock: float = 0.0



signal leveled_up(new_level: int)
signal died_hero
signal notice(text: String, color: Color)

var state: PlayerState
var cooldowns: Dictionary = {}
var elapsed: = 0.0
var mp: = 40.0
var energy: = 100.0
var aim_point: = Vector2.ZERO
var casting_skill: = ""
var casting_time: = 0.0
var casting_total: = 0.0
var casting_aim: = Vector2.ZERO
var attack_cooldown: = 0.0
var attack_swing: = 0.0
var dodge_time: = 0.0
var dodge_cooldown_left: float = 0.0
var dash_time: = 0.0
var dodge_dir: = Vector2.ZERO
var blocking: = false
var block_press: = -100.0
var exhaust: = 0.0
var aim_charge: = 0.0
var still_time: = 0.0
var last_investida: = -100.0
var last_shadow_step: = -100.0
var blocks_recent: = 0.0
var retaliacao_ready: = false
var emboscada_ready: = false
var estocada_bonus: = 0.0
var bastiao_time: = 0.0
var bastiao_resist: = 0.0
var bastiao_speed: = 1.0
var banner_time: = 0.0
var buff_damage: = 0.0
var buff_speed: = 0.0
var buff_time: = 0.0
var marked_enemy: Node = null
var sprinting: = false
var hit_counter: = 0.0
var attack_queued: = false
var last_hit_time: = -100.0


func bind_state(player_state: PlayerState) -> void :
	if state != null and state.equipment_changed.is_connected(sync_from_state):
		state.equipment_changed.disconnect(sync_from_state)
	state = player_state
	state.equipment_changed.connect(sync_from_state)
	max_hp = state.max_hp()
	hp = state.hp
	radius = 17.0
	kind = "hero"
	# Respeita a reserva atual e o limite de energia da classe e do nível.
	energy = clampf(state.energy, 0.0, state.max_energy())
	mp = clampf(state.mp, 0.0, state.max_mp())


func setup(world_ref: Node, _texture_path: String, target_height: float = 92.0) -> void:
	# The old sprites contain baked-in weapons/armor and must never be the base.
	super.setup(world_ref, "", target_height)
	visual_height = target_height
	weapon_sprite = sprite.get_node_or_null("ArmaEquipada") as Sprite2D
	if weapon_sprite == null:
		weapon_sprite = Sprite2D.new()
		weapon_sprite.name = "ArmaEquipada"
		sprite.add_child(weapon_sprite)
	weapon_sprite.z_index = 1
	weapon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	weapon_sprite.material = Appearance.cutout_material()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	grip_hand_sprite = sprite.get_node_or_null("MaoSobreEmpunhadura") as Sprite2D
	if grip_hand_sprite == null:
		grip_hand_sprite = Sprite2D.new()
		grip_hand_sprite.name = "MaoSobreEmpunhadura"
		sprite.add_child(grip_hand_sprite)
	grip_hand_sprite.z_index = 2
	grip_hand_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	colossal_effect = weapon_sprite.get_node_or_null("EnergiaDoColosso") as Node2D
	if colossal_effect == null:
		colossal_effect = preload("res://scripts/actors/colossal_weapon_effect.gd").new()
		colossal_effect.name = "EnergiaDoColosso"
		weapon_sprite.add_child(colossal_effect)
	colossal_effect.hero = self
	aura_effect = preload("res://scripts/actors/hero_aura_effect.gd").new()
	aura_effect.name = "BrilhoHero"
	sprite.add_child(aura_effect)
	aura_effect.setup(self)
	refresh_appearance()


func refresh_appearance() -> void:
	if state == null or sprite == null or weapon_sprite == null:
		return
	var armor_id: String = str(state.equipment.get("armadura", {}).get("id", ""))
	var weapon_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	appearance_key = "%s:%s:%s" % [state.class_id, armor_id, weapon_id]
	sprite.texture = Appearance.body_texture(state)
	var body_size: Vector2 = sprite.texture.get_size()
	# O brilho acompanha o torso e os movimentos do corpo em todas as classes e raças.
	if aura_effect != null:
		aura_effect.visible = str(state.equipment.get("aura", {}).get("id", "")) == "hero"
		aura_effect.scale = Vector2.ONE * body_size.y * 0.95 / 362.0
		aura_effect._sync_layers()
	base_scale = visual_height / (body_size.y * (Appearance.FOOT_Y - Appearance.HEAD_Y))
	sprite.scale = Vector2.ONE * base_scale
	sprite.offset = Vector2(0, (0.5 - Appearance.FOOT_Y) * body_size.y)
	weapon_sprite.visible = not weapon_id.is_empty()
	weapon_sprite.texture = null if weapon_id.is_empty() else ItemArt.texture_for(weapon_id, state.class_id)
	grip_hand_sprite.visible = not weapon_id.is_empty()
	grip_hand_sprite.texture = Appearance.hand_texture(state) if grip_hand_sprite.visible else null
	if weapon_sprite.texture != null:
		weapon_sprite.material = Appearance.weapon_material(state, weapon_sprite.texture)
		var weapon_size: Vector2 = weapon_sprite.texture.get_size()
		weapon_sprite.scale = Vector2.ONE * (body_size.y * Appearance.weapon_height(state.class_id) / weapon_size.y)
	colossal_effect.visible = weapon_id == "arma_b"
	_update_equipment_pose()


func _update_equipment_pose() -> void:
	if weapon_sprite == null or weapon_sprite.texture == null:
		return
	var mirror: float = -1.0 if sprite.flip_h else 1.0
	var direction: Vector2 = facing.normalized() if facing.length_squared() > 0.001 else Vector2.DOWN
	var body_size: Vector2 = sprite.texture.get_size()
	var hand: Vector2 = Appearance.hand_position(state)
	weapon_sprite.position = Vector2((hand.x - 0.5) * body_size.x * mirror, (hand.y - Appearance.FOOT_Y) * body_size.y)
	grip_hand_sprite.position = weapon_sprite.position
	grip_hand_sprite.flip_h = sprite.flip_h
	var weapon_id: String = str(state.equipment.get("arma", {}).get("id", ""))
	var pivot: Vector2 = Appearance.weapon_pivot(state.class_id, weapon_id)
	weapon_sprite.offset = (Vector2(0.5, 0.5) - pivot) * weapon_sprite.texture.get_size()
	weapon_sprite.offset.x *= mirror
	weapon_sprite.flip_h = sprite.flip_h
	var swing_rotation: float = sin((1.0 - attack_swing / 0.18) * PI) * 0.8 if attack_swing > 0.0 else 0.0
	var vertical_turn: float = -PI * 0.5 if absf(direction.y) > absf(direction.x) and direction.y < 0.0 else (PI * 0.5 if absf(direction.y) > absf(direction.x) else 0.0)
	var walk_sway: float = sin(walk_phase) * 0.055 if velocity.length() > 24.0 else 0.0
	weapon_sprite.rotation = (Appearance.weapon_rotation(state.class_id) + vertical_turn + swing_rotation + walk_sway) * mirror
	if absf(direction.y) > absf(direction.x) and direction.y < 0.0:
		weapon_sprite.z_index = -1
		grip_hand_sprite.z_index = -2
	elif absf(direction.y) > absf(direction.x) and direction.y > 0.0:
		weapon_sprite.z_index = 2
		grip_hand_sprite.z_index = 3
	else:
		weapon_sprite.z_index = Appearance.weapon_layer(state.class_id)
		grip_hand_sprite.z_index = 2


func has_passive(skill_id: String) -> bool:
	return state != null and state.is_skill_learned(skill_id)


func is_busy() -> bool:
	return not casting_skill.is_empty() or dodge_time > 0.0 or dash_time > 0.0


func can_act() -> bool:
	return not dead and not is_stunned() and not is_busy()


func _process(delta: float) -> void :
	super._process(delta)
	if state == null or dead:
		return
	# A recarga e a regeneração ficam congeladas enquanto o mundo está pausado.
	if world != null and world.has_method("is_playing") and not world.is_playing():
		_update_equipment_pose()
		return
	elapsed += delta
	state.play_seconds += delta
	_tick_timers(delta)
	_regen(delta)
	_handle_input(delta)
	_update_hero_animation(delta)
	_update_equipment_pose()


func _update_hero_animation(delta: float) -> void:
	if sprite == null:
		return
	animation_clock += delta
	var moving: bool = velocity.length() > 24.0
	if moving:
		var cadence: float = 13.0 if dodge_time > 0.0 or dash_time > 0.0 else (10.5 if sprinting else 8.5)
		walk_phase = fposmod(walk_phase + delta * cadence, TAU)
	var direction: Vector2 = facing.normalized() if facing.length_squared() > 0.001 else Vector2.DOWN
	if absf(direction.x) > 0.12:
		sprite.flip_h = direction.x < 0.0
	else:
		sprite.flip_h = false
	var step_wave: float = sin(walk_phase)
	var bob: float = -absf(step_wave) * 2.4 if moving else sin(animation_clock * 1.8) * 0.55
	var side_step: float = cos(walk_phase) * 1.1 if moving else 0.0
	var attack_amount: float = 0.0
	if attack_swing > 0.0:
		var progress: float = clampf(1.0 - attack_swing / 0.18, 0.0, 1.0)
		attack_amount = sin(progress * PI)
	sprite.position = Vector2(side_step, bob) + direction * attack_amount * 3.2
	var lean: float = direction.x * step_wave * 0.025 if moving else 0.0
	lean += (direction.x * 0.04 - direction.y * 0.015) * attack_amount
	sprite.rotation = lean
	var squash: float = absf(step_wave) * 0.018 if moving else 0.0
	squash += attack_amount * 0.008
	sprite.scale = Vector2(base_scale * (1.0 + squash), base_scale * (1.0 - squash))


func _tick_timers(delta: float) -> void :
	for key: String in cooldowns.keys():
		cooldowns[key] = maxf(0.0, float(cooldowns[key]) - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	attack_swing = maxf(0.0, attack_swing - delta)
	dodge_time = maxf(0.0, dodge_time - delta)
	dodge_cooldown_left = maxf(0.0, dodge_cooldown_left - delta)
	dash_time = maxf(0.0, dash_time - delta)
	exhaust = maxf(0.0, exhaust - delta)
	bastiao_time = maxf(0.0, bastiao_time - delta)
	banner_time = maxf(0.0, banner_time - delta)
	buff_time = maxf(0.0, buff_time - delta)
	if buff_time <= 0.0:
		buff_damage = 0.0
		buff_speed = 0.0
	if casting_skill.is_empty():
		aim_charge = minf(1.0, aim_charge + delta / 0.6) if still_time >= 0.6 else maxf(0.0, aim_charge - delta * 0.6)


func _regen(delta: float) -> void :
	var factor: float = state.regen_multiplier()
	var regen_energy: = Balance.ENERGY_REGEN * factor
	var regen_mana: = Balance.MANA_REGEN * factor
	if sprinting:
		regen_energy = 0.0
	if exhaust > 0.0:
		regen_energy *= 0.35
	energy = minf(state.max_energy(), energy + regen_energy * delta)
	mp = minf(state.max_mp(), mp + regen_mana * delta)
	if elapsed - last_hit_time > 6.0:
		hp = minf(max_hp, hp + Balance.HP_REGEN_OUT_OF_COMBAT * delta)


func _handle_input(delta: float) -> void :
	# Atordoado não pode andar, atacar, bloquear, esquivar ou usar dash.
	if is_stunned():
		velocity = Vector2.ZERO
		blocking = false
		sprinting = false
		dodge_time = 0.0
		dash_time = 0.0
		attack_queued = false
		return
	var input_vector: = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var moving: = input_vector.length() > 0.12
	if moving:
		still_time = 0.0
	else:
		still_time += delta

	if dodge_time > 0.0:
		move_desired(dodge_dir * (Balance.DODGE_SPEED * (1.0 + buff_speed)), delta)
		_update_sprite_tint()
		return
	if dash_time > 0.0:
		move_desired(dodge_dir * Balance.DASH_SPEED, delta)
		_update_sprite_tint()
		return

	if not casting_skill.is_empty():
		casting_time -= delta
		velocity = Vector2.ZERO
		if bastiao_time > 0.0 and moving:
			move_desired(input_vector.normalized() * state.move_speed() * bastiao_speed, delta)
		if casting_time <= 0.0:
			_finish_cast()
		return

	sprinting = Input.is_action_pressed("sprint") and moving and exhaust <= 0.0 and energy > 1.0
	blocking = Input.is_action_pressed("block") and exhaust <= 0.0

	var speed: = state.move_speed()
	speed *= 1.0 + buff_speed
	if sprinting:
		speed *= Balance.SPRINT_MULT
		energy = maxf(0.0, energy - Balance.SPRINT_COST * delta)
	if exhaust > 0.0:
		speed *= 0.5
	if bastiao_time > 0.0:
		speed *= bastiao_speed
	if blocking:
		speed *= 0.55
		if Input.is_action_just_pressed("block"):
			block_press = elapsed
	if moving:
		move_desired(input_vector.normalized() * speed, delta)
	else:
		move_desired(Vector2.ZERO, delta)

	if Input.is_action_just_pressed("dodge"):
		_try_dodge(input_vector)
	if Input.is_action_just_pressed("dash"):
		_try_dash(input_vector)
	if (attack_queued or Input.is_action_pressed("attack")) and attack_cooldown <= 0.0:
		attack_queued = false
		_basic_attack()

	for index in 10:
		if Input.is_action_just_pressed("hotbar_%d" % (index + 1)):
			cast_slot(index)
	if energy <= 0.01 and exhaust <= 0.0 and not blocking:
		_enter_exhaustion()
	_update_sprite_tint()


func _input(event: InputEvent) -> void :
	if not is_stunned() and event.is_action_pressed("attack"):
		attack_queued = true


func _update_sprite_tint() -> void :
	if sprite == null:
		return
	if dodge_time > 0.0:
		sprite.modulate = Color(1.3, 1.3, 1.6, 0.75)
	elif exhaust > 0.0:
		sprite.modulate = Color(0.75, 0.7, 0.8)
	elif bastiao_time > 0.0:
		sprite.modulate = Color(0.85, 0.95, 1.15)
	elif buff_time > 0.0:
		sprite.modulate = Color(1.25, 1.15, 0.8)
	else:
		sprite.modulate = Color.WHITE


func _enter_exhaustion() -> void :
	exhaust = Balance.EXHAUSTION_TIME
	world.show_notice("Exaustão! Sem esquiva nem dash.", Color(0.95, 0.55, 0.35))


func _try_dodge(input_vector: Vector2) -> void :
	if is_rooted() or exhaust > 0.0 or dodge_time > 0.0 or dodge_cooldown_left > 0.0 or energy < Balance.DODGE_COST:
		return
	dodge_dir = input_vector.normalized() if input_vector.length() > 0.12 else facing
	energy = maxf(0.0, energy - Balance.DODGE_COST)
	dodge_time = Balance.DODGE_TIME
	dodge_cooldown_left = Balance.DODGE_COOLDOWN
	invulnerable = maxf(invulnerable, Balance.DODGE_TIME)
	world.play_cue("combat.dodge")
	Vfx.burst(world, global_position + Vector2(0, -20), Color(0.8, 0.9, 1.0), 6, 90.0)


func _try_dash(input_vector: Vector2) -> void :
	if is_rooted():
		return
	if exhaust > 0.0 or dash_time > 0.0 or energy < Balance.DASH_COST:
		return
	dodge_dir = input_vector.normalized() if input_vector.length() > 0.12 else facing
	energy = maxf(0.0, energy - Balance.DASH_COST)
	dash_time = Balance.DASH_TIME
	world.play_cue("combat.dodge", 0.85)
	Vfx.burst(world, global_position, Color(0.95, 0.85, 0.6), 7, 130.0)


func spawn_afterimage() -> void :
	if world != null:
		Vfx.burst(world, global_position + Vector2(0, -22), Color(0.6, 0.55, 0.9), 8, 110.0)


func _basic_attack() -> void :
	aim_point = world.aim_target(global_position)
	var dir: = (aim_point - global_position)
	if dir.length() < 4.0:
		dir = facing
	dir = dir.normalized()
	facing = dir
	attack_swing = 0.18
	attack_cooldown = 0.42 if state.attack_range() > 200.0 else 0.52
	world.play_cue("combat.swing", randf_range(0.92, 1.08))
	if state.attack_range() > 200.0:
		var projectile: = Projectile.new()
		projectile.world = world
		projectile.hero_owner = self
		projectile.homing_target = world.locked_enemy()
		projectile.direction = dir
		projectile.speed = 900.0
		projectile.damage = state.damage_power() * 1.0 * (1.0 + buff_damage)
		projectile.crit_chance = state.crit_physical()
		projectile.life = state.attack_range() / 900.0
		projectile.kind = "arrow" if state.class_id == "atirador" else "arcane"
		projectile.color = Color(0.95, 0.86, 0.55) if state.class_id == "atirador" else Color(0.6, 0.8, 1.0)
		projectile.position = global_position + Vector2(0, -26)
		world.add_projectile(projectile)
		return
	var reach: float = state.attack_range()
	var hits: Array = world.enemies_in_arc(global_position, dir, reach, deg_to_rad(120.0))
	for enemy in hits:
		world.hit_enemy(enemy, state.damage_power() * (1.0 + buff_damage), state.crit_physical(), {"melee": true})
	world.spawn_swing_arc(global_position + Vector2(0, -18), dir, reach * 0.75)


func cast_slot(index: int) -> void :
	if is_stunned():
		return
	if index < 0 or index >= state.hotbar.size():
		return
	var skill_id: = str(state.hotbar[index])
	if skill_id.is_empty():
		return
	if not state.is_skill_learned(skill_id):
		world.show_notice("Skill não aprendida.", Color(0.9, 0.7, 0.5))
		return
	if float(cooldowns.get(skill_id, 0.0)) > 0.0:
		world.show_notice("Em recarga (%.1f s)." % float(cooldowns[skill_id]), Color(0.85, 0.8, 0.65))
		return
	if not casting_skill.is_empty():
		return
	var definition: = _definition_for(skill_id)
	# Continua podendo atacar preso, mas não escapa por skills de deslocamento.
	if has_status("root") and str(definition.get("handler", "")) in ["dash_strike", "shield_advance", "blink_behind", "blink"]:
		return
	if definition.is_empty():
		return
	var cost: Dictionary = definition.get("cost", {})
	var mana_cost: = float(cost.get("mana", 0))
	var energy_cost: = float(cost.get("energia", 0))
	if mana_cost > 0.0 and mp < mana_cost:
		world.show_notice("Mana insuficiente.", Color(0.6, 0.8, 1.0))
		return
	if energy_cost > 0.0 and energy < energy_cost:
		world.show_notice("Energia insuficiente.", Color(0.95, 0.8, 0.5))
		return
	if exhaust > 0.0:
		world.show_notice("Em Exaustão.", Color(0.95, 0.55, 0.35))
		return
	mp = maxf(0.0, mp - mana_cost)
	energy = maxf(0.0, energy - energy_cost)
	var aimed: Vector2 = world.aim_target(global_position)
	if str(definition.get("handler", "")) in ["blink", "shield_advance", "buff"]:
		aimed = global_position + facing * 120.0
	if str(definition.get("handler", "")) == "dash_strike":
		aimed = world.aim_target(global_position)
	casting_aim = aimed
	cooldowns[skill_id] = float(definition.get("cd", 1.0))
	var cast_time: = float(definition.get("cast", 0.0))
	world.play_cue("combat.cast", 1.0 + 0.06 * index)
	if cast_time <= 0.0:
		SkillEngine.execute(world, self, definition, aimed)
		world.flash_skill(skill_id)
		return
	casting_skill = skill_id
	casting_time = cast_time
	casting_total = cast_time
	world.show_cast_bar(cast_time)


func _finish_cast() -> void :
	var skill_id: = casting_skill
	casting_skill = ""
	casting_time = 0.0
	var definition: = _definition_for(skill_id)
	if definition.is_empty():
		return
	# A raiz também cancela o deslocamento de uma skill preparada antes de prender.
	if has_status("root") and str(definition.get("handler", "")) in ["dash_strike", "shield_advance", "blink_behind", "blink"]:
		world.hide_cast_bar()
		return
	SkillEngine.execute(world, self, definition, casting_aim)
	world.flash_skill(skill_id)
	world.hide_cast_bar()


func interrupt_cast(reason: String = "") -> void :
	if casting_skill.is_empty():
		return
	var skill_id: = casting_skill
	casting_skill = ""
	casting_time = 0.0
	world.hide_cast_bar()
	world.show_notice("Conjuração interrompida%s" % (" — " + reason if not reason.is_empty() else ""), Color(0.95, 0.5, 0.4))
	if cooldowns.has(skill_id):
		cooldowns[skill_id] = maxf(float(cooldowns[skill_id]), 2.0)


func _definition_for(skill_id: String) -> Dictionary:
	if skill_id == "explosao_aura":
		return GameData.UNIVERSAL_AURA
	if skill_id == "despertar_heroico":
		return GameData.UNIVERSAL_DESPERTAR
	return GameData.skill(state.class_id, skill_id)


func cooldown_ratio(skill_id: String) -> float:
	var definition: = _definition_for(skill_id)
	if definition.is_empty():
		return 0.0
	var total: = float(definition.get("cd", 1.0))
	if total <= 0.0:
		return 0.0
	return clampf(float(cooldowns.get(skill_id, 0.0)) / total, 0.0, 1.0)


func take_damage(amount: float, opts: Dictionary = {}) -> Dictionary:
	if dead:
		return {"amount": 0.0, "crit": false, "killed": false}
	if dodge_time > 0.0 or invulnerable > 0.0:
		world.show_dodge_text(global_position + Vector2(0, -50))
		return {"amount": 0.0, "crit": false, "killed": false}
	var damage: = amount
	var source: Vector2 = opts.get("from", global_position + facing * -40.0)
	var crit: = bool(opts.get("crit", false))
	var frontal: = Combat.is_frontal(source, facing, global_position)

	if bastiao_time > 0.0 and frontal:
		damage *= 1.0 - bastiao_resist
	if blocking and frontal:
		var perfect: bool = elapsed - block_press <= Balance.PERFECT_BLOCK_WINDOW
		var cost: = Balance.BLOCK_COST_PER_HIT
		if perfect and has_passive("guarda_firme"):
			world.play_skill_animation("guarda_firme")
			cost = 0.0
		if energy >= cost:
			energy = maxf(0.0, energy - cost)
			damage *= 1.0 - Balance.BLOCK_REDUCTION
			blocks_recent += 1.0
			if perfect and has_passive("retaliacao"):
				world.play_skill_animation("retaliacao")
				retaliacao_ready = true
			world.play_cue("combat.block")
			world.show_notice("Bloqueio!", Color(0.8, 0.9, 1.0))
		else:
			world.show_notice("Guarda rompida!", Color(0.95, 0.6, 0.4))
	if marked_enemy != null and is_instance_valid(marked_enemy) and source.distance_to(marked_enemy.global_position) < 40.0:
		if has_passive("juramento"):
			world.play_skill_animation("juramento")
			damage *= 0.75
	if str(opts.get("type", "")) in ["errante", "dungeon"]:
		damage *= 1.0 - state.resist_wanderers()
	damage = maxf(1.0, damage)
	hp = maxf(0.0, hp - damage)
	flash_time = 0.14
	last_hit_time = elapsed
	if crit or damage > max_hp * 0.12:
		interrupt_cast("golpe forte")
	world.show_damage_number(global_position + Vector2(0, -56), damage, crit, "recebido")
	world.shake(4.0 if crit else 2.0)
	if hp <= 0.0:
		_die_hero()
	return {"amount": damage, "crit": crit, "killed": hp <= 0.0}


func _die_hero() -> void :
	dead = true
	died_hero.emit()
	if world != null and world.has_method("on_hero_died"):
		world.on_hero_died()


func revive_at(position_point: Vector2) -> void :
	dead = false
	hp = max_hp
	mp = state.max_mp()
	energy = state.max_energy()
	exhaust = 0.0
	casting_skill = ""
	statuses.clear()
	invulnerable = Balance.RESPAWN_INVULNERABILITY
	global_position = position_point
	modulate = Color.WHITE
	if sprite != null:
		sprite.modulate = Color.WHITE


func sync_from_state() -> void :
	max_hp = state.max_hp()
	hp = minf(hp, max_hp)
	mp = minf(mp, state.max_mp())
	energy = minf(energy, state.max_energy())
	state.hp = hp
	refresh_appearance()


func _draw() -> void :
	super._draw()
	if attack_swing > 0.0:
		var reach: float = maxf(60.0, state.attack_range() if state != null else 90.0)
		var alpha: = attack_swing / 0.18
		draw_arc(Vector2.ZERO, reach * 0.8, facing.angle() - 0.7, facing.angle() + 0.7, 14, 
			Color(1.0, 0.95, 0.75, 0.5 * alpha), 5.0)
	if casting_skill != "":
		var progress: float = 1.0 - casting_time / maxf(0.01, casting_total)
		draw_arc(Vector2(0, -20), 34.0, - PI * 0.5, - PI * 0.5 + TAU * progress, 26, 
			Color(0.55, 0.8, 1.0, 0.95), 4.0)
	if bastiao_time > 0.0:
		draw_arc(Vector2.ZERO, 30.0, facing.angle() - 0.9, facing.angle() + 0.9, 12, 
			Color(0.75, 0.9, 1.0, 0.8), 4.0)
