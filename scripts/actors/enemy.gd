class_name Enemy
extends Actor


const NAME_FONT_NORMAL: Font = preload("res://assets/fonts/Cinzel-SemiBold.ttf")
const NAME_FONT_MARKED: Font = preload("res://assets/fonts/Cinzel-Bold.ttf")


# Resolve concrete scripts lazily to avoid a base/subclass preload cycle.
static var TYPES: Dictionary:
	get:
		return load("res://scripts/actors/enemy_catalog.gd").definitions()

@export_enum("gosma", "golem_pedra", "lobo", "arvore_cipo", "saqueador", "errante", "fera", "colossal", "rival")
var type_id: String = "lobo"
var definition: Dictionary = {}
var level: int = 1
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
var nameplate: Label
var health_bar: ProgressBar
var nameplate_style_marked: = false
var nameplate_style_initialized: = false


func setup_enemy(world_ref: Node, enemy_type: String, spawn: Vector2) -> void :
	type_id = enemy_type
	definition = TYPES.get(enemy_type, TYPES["lobo"])
	level = maxi(1, int(definition.get("level", 1)))
	spawn_point = spawn
	kind = str(definition.get("kind", enemy_type))
	var config: Dictionary = definition
	setup(world_ref, str(config["sprite"]), float(config["height"]))
	_create_nameplate(float(config["height"]))
	max_hp = float(config["hp"])
	hp = max_hp
	_create_health_bar()
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
	_update_nameplate()


func display_name() -> String:
	return "%s · Nv. %d" % [str(definition.get("name", type_id)), level]


func _create_nameplate(_target_height: float) -> void:
	nameplate = Label.new()
	nameplate.name = "NomeDoInimigo"
	nameplate.set_as_top_level(true)
	nameplate.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	nameplate.size = Vector2(360.0, 24.0)
	nameplate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nameplate.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nameplate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nameplate.add_theme_font_size_override("font_size", 14)
	nameplate.add_theme_color_override("font_outline_color", Color(0.035, 0.045, 0.07, 0.95))
	nameplate.add_theme_constant_override("outline_size", 4)
	add_child(nameplate)
	_update_nameplate()


func _update_nameplate() -> void:
	if nameplate == null:
		return
	_update_nameplate_position()
	if health_bar != null:
		health_bar.max_value = max_hp
		health_bar.value = hp
		health_bar.visible = not dead
	nameplate.text = display_name()
	var marked: bool = marked_by_hero or has_status("mark") or has_status("duel_mark") or (world != null and world.locked_enemy() == self)
	if not nameplate_style_initialized or marked != nameplate_style_marked:
		nameplate_style_initialized = true
		nameplate_style_marked = marked
		nameplate.add_theme_font_override("font", NAME_FONT_MARKED if marked else NAME_FONT_NORMAL)
		nameplate.add_theme_color_override("font_color", Color(1.0, 0.83, 0.36) if marked else Color(0.95, 0.95, 0.91))


func _create_health_bar() -> void:
	# Colossais utilizam somente a barra grande do HUD.
	if is_boss():
		return
	if health_bar == null:
		health_bar = UiKit.bar(Color(0.85, 0.22, 0.19), 10.0)
		health_bar.name = "VidaDoInimigo"
		health_bar.set_as_top_level(true)
		health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		health_bar.custom_minimum_size = Vector2(116.0 if is_miniboss() else 96.0, 10.0)
		health_bar.size = health_bar.custom_minimum_size
		health_bar.z_as_relative = false
		health_bar.z_index = 50
		add_child(health_bar)
	# O nome também deve ficar legível acima da vegetação.
	nameplate.z_as_relative = false
	nameplate.z_index = 50
	_update_nameplate()


func combat_hitbox(extra_radius: float = 0.0) -> Rect2:
	var body_height := maxf(float(definition.get("height", 96.0)), radius * 2.0)
	var half_width := maxf(radius, body_height * 0.34)
	var top := global_position.y - body_height - extra_radius
	var bottom := global_position.y + radius * 0.35 + extra_radius
	return Rect2(
		Vector2(global_position.x - half_width - extra_radius, top),
		Vector2((half_width + extra_radius) * 2.0, bottom - top)
	)


func is_boss() -> bool:
	return bool(definition.get("boss", false))


func is_miniboss() -> bool:
	return bool(definition.get("miniboss", false))


func _process(delta: float) -> void :
	super._process(delta)
	_update_nameplate()
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
	if ai_state == "idle" and _can_aggro(distance, aggro):
		ai_state = "chase"
		if bool(definition.get("boss", false)):
			world.begin_boss_fight(self)
	if ai_state != "chase":
		_wander(delta)
		return
	if _process_special_action(delta, hero, distance):
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


func _process_special_action(_delta: float, _hero, _distance: float) -> bool:
	return false


func _can_aggro(distance: float, aggro: float) -> bool:
	return distance < aggro


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


# Concrete boss scripts provide their own attack patterns and release behavior.
func _boss_logic(delta: float, hero, _distance: float) -> void:
	move_desired((hero.global_position - global_position).normalized() * float(definition.get("speed", 96.0)), delta)


func _boss_release(hero) -> void:
	_release_attack(hero)


func take_damage(amount: float, opts: Dictionary = {}) -> Dictionary:
	var damage: = amount
	if exposed > 0.0:
		damage *= 1.5
	if bool(definition.get("rival", false)) and has_status("guard_broken"):
		damage *= 1.2
	var result: = super.take_damage(damage, opts)
	_update_nameplate()
	if world != null:
		world.play_cue("combat.hit", randf_range(0.9, 1.1) if not bool(result.get("crit", false)) else 0.8)
	queue_redraw()
	return result


func _draw() -> void :
	super._draw()
	if world == null:
		return
	if world.locked_enemy() == self:
		var lock_pulse := 0.5 + 0.5 * sin(action_time * 7.0)
		var lock_color := Color(0.35, 0.88, 1.0, 0.72 + lock_pulse * 0.25)
		draw_arc(Vector2(0, 4), radius + 12.0 + lock_pulse * 2.0, 0.0, TAU, 32, lock_color, 2.5, true)
		var marker_y := -float(definition.get("height", 96.0)) - 18.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(-6, marker_y - 8), Vector2(6, marker_y - 8), Vector2(0, marker_y + 2)
		]), Color(0.5, 0.92, 1.0, 0.9))
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


# Enemies use the Sprite2D itself. Authored textures and transforms are preserved.
func setup(world_ref: Node, texture_path: String, target_height: float = 96.0) -> void:
	world = world_ref
	sprite_path = texture_path
	sprite = self
	if texture == null and not texture_path.is_empty():
		texture = load(texture_path)
		if texture != null and texture.get_height() > 0:
			scale = Vector2.ONE * target_height / texture.get_height()
			offset = Vector2(0, -texture.get_height() * 0.5)


# Text follows the visible sprite without inheriting its size or rotation.
func _update_nameplate_position() -> void:
	var bounds: Rect2 = get_rect()
	var corners: Array[Vector2] = [
		to_global(bounds.position),
		to_global(Vector2(bounds.end.x, bounds.position.y)),
		to_global(bounds.end),
		to_global(Vector2(bounds.position.x, bounds.end.y)),
	]
	var left: float = corners[0].x
	var right: float = corners[0].x
	var top: float = corners[0].y
	for corner: Vector2 in corners:
		left = minf(left, corner.x)
		right = maxf(right, corner.x)
		top = minf(top, corner.y)
	var center_x: float = (left + right) * 0.5
	if health_bar != null:
		health_bar.global_position = Vector2(center_x - health_bar.size.x * 0.5, top - health_bar.size.y - 6.0)
		nameplate.global_position = Vector2(center_x - nameplate.size.x * 0.5, health_bar.global_position.y - nameplate.size.y - 3.0)
	else:
		nameplate.global_position = Vector2(center_x - nameplate.size.x * 0.5, top - nameplate.size.y - 8.0)
