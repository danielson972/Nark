class_name WorldView
extends Node2D


signal prop_used(prop: Dictionary)
signal boss_started(enemy: Node)
signal boss_finished(defeated: bool)
signal hero_died
signal notice(text: String, color: Color)
signal skill_cast(skill_id: String)
signal level_gained(new_level: int)
signal state_dirty

const TILE_TEXTURE: = "res://assets/game/tiles/terrain.png"
const RESPAWN_TIME: = 26.0

var region: RegionMap
var state: PlayerState
var hero: Hero
var enemies: Array = []
var respawn_queue: Array = []
var tile_layer: TileMapLayer
var props_layer: Node2D
var actors_layer: Node2D
var effects_layer: Node2D
var camera: Camera2D
var night_tint: CanvasModulate
var prop_nodes: Dictionary = {}
var boss: Node = null
var rng: = RandomNumberGenerator.new()
var playing: = false
var paused: = false
var shake_amount: = 0.0
var rivals_timer: = 0.0
var crystals_taken: Dictionary = {}
var interact_prop: Dictionary = {}
var collect_radius: = 46.0


func build(player_state: PlayerState, state_flags: Dictionary = {}) -> void :
	state = player_state
	rng.randomize()
	region = RegionMap.new()
	_build_terrain()
	_build_layers()
	_build_props()
	_build_decor()
	_spawn_initial_enemies()
	_spawn_hero()
	_apply_world_flags(state_flags)
	_update_day_night(0.0)


func _build_terrain() -> void :
	tile_layer = TileMapLayer.new()
	tile_layer.name = "Terreno"
	var tile_set: = TileSet.new()
	tile_set.tile_size = Vector2i(Balance.TILE, Balance.TILE)
	var source: = TileSetAtlasSource.new()
	var texture: Texture2D = load(TILE_TEXTURE)
	source.texture = texture
	source.texture_region_size = Vector2i(Balance.TILE, Balance.TILE)
	for index in 8:
		source.create_tile(Vector2i(index, 0))
	tile_set.add_source(source, 0)
	tile_layer.tile_set = tile_set
	tile_layer.z_index = -100
	add_child(tile_layer)
	for y in RegionMap.H:
		for x in RegionMap.W:
			var value: = region.tile_at(x, y)
			tile_layer.set_cell(Vector2i(x, y), 0, Vector2i(value, 0))


func _build_layers() -> void :
	effects_layer = Node2D.new()
	effects_layer.name = "Efeitos"
	effects_layer.z_index = -5
	add_child(effects_layer)

	props_layer = Node2D.new()
	props_layer.name = "Cenario"
	props_layer.y_sort_enabled = true
	add_child(props_layer)

	actors_layer = Node2D.new()
	actors_layer.name = "Atores"
	actors_layer.y_sort_enabled = true
	add_child(actors_layer)

	night_tint = CanvasModulate.new()
	night_tint.color = Color(1, 1, 1)
	add_child(night_tint)

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = RegionMap.W * Balance.TILE
	camera.limit_bottom = RegionMap.H * Balance.TILE
	add_child(camera)


func _build_props() -> void :
	for prop: Dictionary in region.props:
		var node: = Node2D.new()
		var tile: Vector2i = prop["tile"]
		node.position = region.world_position(tile)
		node.name = str(prop["id"])
		if str(prop["sprite"]).is_empty():
			_add_crystal_visual(node)
		else:
			var sprite: = Sprite2D.new()
			sprite.texture = load(str(prop["sprite"]))
			var height: = float(prop["height"])
			var texture: = sprite.texture
			if texture != null and texture.get_height() > 0:
				var factor: = height / float(texture.get_height())
				sprite.scale = Vector2(factor, factor)
			sprite.offset = Vector2(0, - float(texture.get_height() if texture else 64) * 0.5)
			node.add_child(sprite)
		props_layer.add_child(node)
		prop_nodes[str(prop["id"])] = node


func _add_crystal_visual(node: Node2D) -> void :
	var glow: = Polygon2D.new()
	var glow_points: = PackedVector2Array()
	for index in 14:
		var angle: = TAU * float(index) / 14.0
		glow_points.append(Vector2(cos(angle) * 20.0, sin(angle) * 20.0 - 16.0))
	glow.polygon = glow_points
	glow.color = Color(0.45, 0.8, 1.0, 0.22)
	node.add_child(glow)
	var shard: = Polygon2D.new()
	shard.polygon = PackedVector2Array([
		Vector2(0, -46), Vector2(9, -22), Vector2(0, -4), Vector2(-9, -22), 
	])
	shard.color = Color(0.55, 0.85, 1.0)
	node.add_child(shard)
	var core: = Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(0, -40), Vector2(4, -24), Vector2(0, -10), Vector2(-4, -24), 
	])
	core.color = Color(0.9, 0.98, 1.0)
	node.add_child(core)


func _build_decor() -> void :
	var decor: = Node2D.new()
	decor.name = "Vegetacao"
	decor.y_sort_enabled = true
	props_layer.add_child(decor)
	var local_rng: = RandomNumberGenerator.new()
	local_rng.seed = 90210
	for y in range(3, RegionMap.H - 3):
		for x in range(3, RegionMap.W - 3):
			var value: = region.tile_at(x, y)
			var point: = region.world_position(Vector2i(x, y))
			if value == RegionMap.DARK and local_rng.randf() < 0.32:
				_add_tree(decor, point, local_rng)
			elif value == RegionMap.GRASS and local_rng.randf() < 0.07:
				_add_tuft(decor, point, local_rng)
			elif value == RegionMap.STONE and local_rng.randf() < 0.03:
				_add_tuft(decor, point, local_rng, true)
	_add_banner(decor, region.world_position(Vector2i(10, 8)))
	_add_banner(decor, region.world_position(Vector2i(14, 8)))
	_add_banner(decor, region.world_position(Vector2i(9, 11)))
	_add_banner(decor, region.world_position(Vector2i(15, 11)))


func _add_tree(parent: Node2D, point: Vector2, local_rng: RandomNumberGenerator) -> void :
	var tree: = Node2D.new()
	tree.position = point + Vector2(local_rng.randf_range(-16, 16), local_rng.randf_range(-10, 10))
	var scale_factor: = local_rng.randf_range(0.82, 1.24)
	var trunk: = Polygon2D.new()
	trunk.polygon = PackedVector2Array([
		Vector2(-5, 0), Vector2(5, 0), Vector2(4, -40), Vector2(-4, -40), 
	])
	trunk.color = Color(0.28, 0.2, 0.14)
	tree.add_child(trunk)
	var canopy_colors: = [Color(0.16, 0.29, 0.16), Color(0.2, 0.34, 0.18), Color(0.24, 0.38, 0.2)]
	for index in 4:
		var blob: = Polygon2D.new()
		var radius: = local_rng.randf_range(20.0, 30.0) * scale_factor
		var points: = PackedVector2Array()
		for step in 12:
			var angle: = TAU * float(step) / 12.0
			var wobble: = radius * local_rng.randf_range(0.82, 1.05)
			points.append(Vector2(cos(angle) * wobble, sin(angle) * wobble * 0.86))
		blob.polygon = points
		blob.color = canopy_colors[index % canopy_colors.size()]
		blob.position = Vector2(local_rng.randf_range(-13, 13), -58.0 - local_rng.randf_range(0, 16)) * scale_factor
		tree.add_child(blob)
	var highlight: = Polygon2D.new()
	highlight.polygon = PackedVector2Array([
		Vector2(-10, -76), Vector2(4, -82), Vector2(2, -62), Vector2(-12, -58), 
	])
	highlight.color = Color(0.34, 0.48, 0.26, 0.75)
	tree.add_child(highlight)
	parent.add_child(tree)


func _add_tuft(parent: Node2D, point: Vector2, local_rng: RandomNumberGenerator, stone: bool = false) -> void :
	var tuft: = Polygon2D.new()
	if stone:
		tuft.polygon = PackedVector2Array([
			Vector2(-6, 0), Vector2(6, 0), Vector2(4, -7), Vector2(-4, -7), 
		])
		tuft.color = Color(0.42, 0.41, 0.38)
	else:
		tuft.polygon = PackedVector2Array([
			Vector2(-7, 0), Vector2(-3, -12), Vector2(0, -3), Vector2(3, -14), 
			Vector2(7, 0), 
		])
		tuft.color = Color(0.26, 0.42, 0.22) if local_rng.randf() < 0.75 else Color(0.5, 0.52, 0.26)
	tuft.position = point + Vector2(local_rng.randf_range(-20, 20), local_rng.randf_range(-14, 14))
	parent.add_child(tuft)


func _add_banner(parent: Node2D, point: Vector2) -> void :
	var banner: = Node2D.new()
	banner.position = point
	var pole: = Polygon2D.new()
	pole.polygon = PackedVector2Array([
		Vector2(-2, 0), Vector2(2, 0), Vector2(2, -96), Vector2(-2, -96), 
	])
	pole.color = Color(0.3, 0.24, 0.16)
	banner.add_child(pole)
	var flag: = Polygon2D.new()
	flag.polygon = PackedVector2Array([
		Vector2(2, -96), Vector2(34, -88), Vector2(2, -68), 
	])
	flag.color = Color(0.24, 0.34, 0.62)
	banner.add_child(flag)
	var trim: = Polygon2D.new()
	trim.polygon = PackedVector2Array([
		Vector2(2, -96), Vector2(10, -94), Vector2(4, -72), 
	])
	trim.color = Color(0.85, 0.72, 0.35)
	banner.add_child(trim)
	parent.add_child(banner)


func _spawn_initial_enemies() -> void :
	for spawn: Dictionary in region.monster_spawns:
		var kind: = str(spawn["kind"])
		if kind == "colossal":
			continue
		var position_point: Vector2 = region.world_position(spawn["tile"])
		spawn_enemy(kind, position_point)


func _spawn_hero() -> void :
	hero = Hero.new()
	hero.bind_state(state)
	hero.setup(self, _hero_sprite(), 92.0)
	hero.global_position = region.hero_spawn_position()
	hero.died_hero.connect(_on_hero_died)
	actors_layer.add_child(hero)
	camera.global_position = hero.global_position
	hero.hp = state.hp


func _hero_sprite() -> String:
	match state.class_id:
		"atirador": return "res://assets/game/sprites/hero_archer.png"
		"mago": return "res://assets/game/sprites/hero_mage.png"
		"assassino": return "res://assets/game/sprites/hero_rogue.png"
		"tank": return "res://assets/game/sprites/hero_tank.png"
		"cavaleiro": return "res://assets/game/sprites/hero_knight.png"
		_: return "res://assets/game/sprites/hero_warrior.png"


func _apply_world_flags(flags: Dictionary) -> void :
	if int(flags.get("errantes_alive", 0)) > 0:
		for index in int(flags.get("errantes_alive", 0)):
			spawn_errant()
	if bool(state.flags.get("colossal_defeated", false)):
		for node in enemies.duplicate():
			if node != null and is_instance_valid(node) and node.kind == "colossal":
				node.queue_free()
				enemies.erase(node)


func start() -> void :
	playing = true
	paused = false
	if hero != null:
		hero.set_process(true)


func set_paused(value: bool) -> void :
	paused = value
	playing = not value


func is_playing() -> bool:
	return playing and not paused


func _process(delta: float) -> void :
	if paused or hero == null:
		return
	_update_day_night(delta)
	_update_camera(delta)
	_update_respawns(delta)
	_update_rival(delta)
	_update_interaction()
	_apply_shake(delta)
	state.time_of_day = fmod(state.time_of_day + delta / Balance.DAY_LENGTH, 1.0)
	if state.time_of_day < delta / Balance.DAY_LENGTH:
		state.day_count += 1
		show_notice("Amanheceu. Dia %d no vale." % state.day_count, Color(0.9, 0.9, 0.75))


func _update_camera(delta: float) -> void :
	if hero == null:
		return
	camera.global_position = camera.global_position.lerp(hero.global_position, clampf(delta * 6.0, 0.0, 1.0))


func _apply_shake(delta: float) -> void :
	if shake_amount > 0.0:
		shake_amount = maxf(0.0, shake_amount - delta * 26.0)
		camera.offset = Vector2(rng.randf_range( - shake_amount, shake_amount), rng.randf_range( - shake_amount, shake_amount))
	elif camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO


func _update_day_night(_delta: float) -> void :
	var time: = state.time_of_day if state != null else 0.2
	var night_factor: = 0.0
	if time > Balance.NIGHT_FROM:
		night_factor = clampf((time - Balance.NIGHT_FROM) / (1.0 - Balance.NIGHT_FROM), 0.0, 1.0)
	elif time < Balance.NIGHT_TO:
		night_factor = clampf(1.0 - time / Balance.NIGHT_TO, 0.0, 1.0)
	var color: = Color(1, 1, 1).lerp(Color(0.44, 0.5, 0.75), night_factor)
	if night_tint != null:
		night_tint.color = color
	var night: = night_factor > 0.45
	for enemy in enemies_alive():
		if enemy.kind == "errante" or enemy.kind == "lobo":
			enemy.night_bonus = 0.22 if night else 0.0

func is_night() -> bool:
	var time: = state.time_of_day
	return time > Balance.NIGHT_FROM or time < Balance.NIGHT_TO



func can_stand(point: Vector2, body_radius: float) -> bool:
	var min_x: = int(floor((point.x - body_radius) / Balance.TILE))
	var max_x: = int(floor((point.x + body_radius) / Balance.TILE))
	var min_y: = int(floor((point.y - body_radius * 0.6) / Balance.TILE))
	var max_y: = int(floor((point.y + body_radius * 0.6) / Balance.TILE))
	for tile_y in range(min_y, max_y + 1):
		for tile_x in range(min_x, max_x + 1):
			if not region.is_solid_at(tile_x, tile_y):
				continue
			var rect: = Rect2(tile_x * Balance.TILE, tile_y * Balance.TILE, Balance.TILE, Balance.TILE)
			var closest: = Vector2(
				clampf(point.x, rect.position.x, rect.end.x), 
				clampf(point.y, rect.position.y, rect.end.y)
			)
			var offset: = point - closest
			var limit: = Vector2(body_radius, body_radius * 0.7)
			if absf(offset.x) < limit.x and absf(offset.y) < limit.y:
				return false
	return true


func enemies_alive() -> Array:
	var result: Array = []
	for node in enemies:
		if node != null and is_instance_valid(node) and not node.dead:
			result.append(node)
	return result


func enemies_in_radius(center: Vector2, radius_value: float) -> Array:
	var result: Array = []
	for enemy in enemies_alive():
		if center.distance_to(enemy.global_position) <= radius_value + enemy.radius * 0.5:
			result.append(enemy)
	return result


func enemies_in_arc(center: Vector2, direction: Vector2, radius_value: float, arc_radians: float) -> Array:
	var result: Array = []
	for enemy in enemies_alive():
		var offset: Vector2 = enemy.global_position - center
		if offset.length() > radius_value + enemy.radius:
			continue
		if offset.length() < 8.0 or absf(direction.angle_to(offset.normalized())) <= arc_radians * 0.5:
			result.append(enemy)
	return result


func enemies_in_line(origin: Vector2, direction: Vector2, length: float, width: float) -> Array:
	var result: Array = []
	for enemy in enemies_alive():
		var offset: Vector2 = enemy.global_position - origin
		var projection: = offset.dot(direction)
		if projection < -10.0 or projection > length:
			continue
		var perpendicular: = absf(offset.dot(direction.orthogonal()))
		if perpendicular <= width * 0.5 + enemy.radius * 0.5:
			result.append(enemy)
	return result


func nearest_enemy(point: Vector2, max_range: float) -> Node:
	var best: Node = null
	var best_distance: = max_range
	for enemy in enemies_alive():
		var distance: float = point.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func marked_enemy_for(_hero_ref: Node) -> Node:
	for enemy in enemies_alive():
		if enemy.has_status("mark") or enemy.has_status("duel_mark"):
			return enemy
	return null


func aim_target(from: Vector2) -> Vector2:
	var point: = get_global_mouse_position()
	if point.distance_to(from) < 30.0:
		return from + (hero.facing if hero != null else Vector2.DOWN) * 120.0
	return point



func hit_enemy(enemy: Node, raw_damage: float, crit_chance: float, payload: Dictionary = {}) -> void :
	if enemy == null or not is_instance_valid(enemy) or enemy.dead or hero == null:
		return
	var damage: = raw_damage
	var crit: = crit_chance
	var melee: = bool(payload.get("melee", false))
	if melee and Combat.is_behind(hero.global_position, enemy.facing, enemy.global_position):
		damage *= 1.0 + Balance.BACKSTAB_DAMAGE
		crit += Balance.BACKSTAB_CRIT
		if state.is_skill_learned("oportunismo"):
			damage *= 1.3
		if rng.randf() < 0.4:
			show_notice("Golpe pelas costas!", Color(0.95, 0.85, 0.5))
	if payload.has("ignore_defense"):
		payload["ignore_defense"] = float(payload["ignore_defense"])
	var result: = Combat.roll(damage, 1.0, float(enemy.defense), crit, 1.0, 
		float(payload.get("ignore_defense", 0.0)), rng)
	if payload.has("root"):
		enemy.apply_status("root", float(payload["root"]))
	if payload.has("mark"):
		enemy.apply_status("mark", float(payload["mark"]))
	if payload.has("slow"):
		enemy.apply_status("slow", 3.0, {"value": float(payload["slow"])})
	if payload.has("bleed"):
		enemy.apply_status("bleed", float(payload.get("bleed_time", 4.0)), {"dps": float(payload["bleed"])})
	if bool(payload.get("flow", false)) and state.is_skill_learned("fluxo_arcano"):
		if _inside_ice(enemy.global_position):
			hero.mp = minf(state.max_mp(), hero.mp + 8.0)
			show_notice("Fluxo Arcano +8 mana", Color(0.6, 0.85, 1.0))
	enemy.take_damage(result["amount"], {"crit": result["crit"]})
	if result["crit"]:
		play_cue("combat.crit")
		shake(2.5)


func _inside_ice(point: Vector2) -> bool:
	for node in effects_layer.get_children():
		if node is GroundEffect and node.mode in ["field", "trail"] and node.payload.has("ice"):
			if node.global_position.distance_to(point) <= node.radius:
				return true
	return false


func damage_hero(amount: float, opts: Dictionary = {}) -> void :
	if hero == null or hero.dead:
		return
	hero.take_damage(amount, opts)


func knockback(actor: Node, direction: Vector2, amount: float) -> void :
	if actor == null or not is_instance_valid(actor):
		return
	var step: = direction.normalized() * amount
	var target: Vector2 = actor.global_position + step
	if can_stand(target, actor.radius):
		actor.global_position = target


func add_projectile(projectile: Projectile) -> void :
	effects_layer.add_child(projectile)


func add_area_effect(effect: GroundEffect) -> void :
	effects_layer.add_child(effect)


func spawn_enemy(kind: String, position_point: Vector2) -> Node:
	var enemy: = Enemy.new()
	enemy.setup_enemy(self, kind, position_point)
	actors_layer.add_child(enemy)
	enemies.append(enemy)
	if enemy.is_boss():
		boss = enemy
	return enemy


func spawn_errant() -> void :
	var spots: Array = [Vector2i(30, 22), Vector2i(36, 22), Vector2i(24, 23), Vector2i(15, 24), Vector2i(42, 23)]
	var tile: Vector2i = spots[rng.randi_range(0, spots.size() - 1)]
	spawn_enemy("errante", region.world_position(tile))
	state.errantes_alive += 1
	show_notice("Um monstro errante escapou para a estrada!", Color(0.85, 0.6, 0.95))


func begin_boss_fight(enemy: Node) -> void :
	boss = enemy
	boss_started.emit(enemy)


func on_actor_died(actor: Node) -> void :
	if actor == null:
		return
	enemies.erase(actor)
	if actor == hero:
		return
	var enemy_kind: = str(actor.kind)
	if actor.is_boss():
		_on_boss_defeated(actor)
		return
	var xp_value: = int(actor.definition.get("xp", 60))
	var coins_range: Array = actor.definition.get("coins", [1, 3])
	var coins: = rng.randi_range(int(coins_range[0]), int(coins_range[1]))
	coins = int(round(float(coins) * (1.0 + float(state.race()["coin_bonus"]))))
	if float(state.flags.get("bencao_fortuna", 0.0)) > state.play_seconds:
		coins = int(round(float(coins) * 1.25))
	state.coins += coins
	var drops: Dictionary = actor.definition.get("drops", {})
	for item_id: String in drops.keys():
		if rng.randf() <= float(drops[item_id]):
			if state.add_item(item_id, 1):
				show_notice("+ %s" % GameData.item_short_name(item_id), Color(0.9, 0.85, 0.6))
			else:
				show_notice("Inventário cheio — item perdido", Color(0.95, 0.6, 0.5))
	if enemy_kind == "errante":
		state.errantes_alive = maxi(0, state.errantes_alive - 1)
		state.hostility = maxf(0.0, state.hostility - Balance.HOSTILITY_PER_ERRANTE)
		show_notice("Hostilidade reduzida", Color(0.75, 0.9, 0.7))
	if enemy_kind == "rival":
		var returned: = int(state.flags.get("rival_stolen", 0))
		if returned > 0:
			state.coins += returned
			state.flags["rival_stolen"] = 0
			show_notice("Você recuperou %s moedas de Kael" % _format_coins(returned), Color(0.95, 0.85, 0.4))
		state.rival_defeated += 1
		state.add_fame(1.0)
	state.kills += 1
	state.wear_equipment(Balance.FARM_DURABILITY_LOSS)
	_grant_xp(xp_value)
	var completed: Array = state.register_kill(enemy_kind)
	for contract_id: String in completed:
		show_notice("Contrato concluído — volte ao mural", Color(0.9, 0.85, 0.5))
	if not actor.is_boss():
		respawn_queue.append({"kind": enemy_kind, "time": RESPAWN_TIME, "position": actor.spawn_point})
	Vfx.burst(self, actor.global_position + Vector2(0, -30), Color(0.95, 0.8, 0.45), 12, 150.0)
	play_cue("loot.coin", rng.randf_range(0.95, 1.15))
	state_dirty.emit()


func _on_boss_defeated(actor: Node) -> void :
	boss = null
	var is_colossal: bool = str(actor.kind) == "colossal"
	var xp_value: = int(actor.definition.get("xp", 900))
	_grant_xp(xp_value)
	var coins_range: Array = actor.definition.get("coins", [100, 200])
	var coins: = rng.randi_range(int(coins_range[0]), int(coins_range[1]))
	state.coins += coins
	show_notice("+ %s moedas" % _format_coins(coins), Color(0.95, 0.85, 0.4))
	var drops: Dictionary = actor.definition.get("drops", {})
	for item_id: String in drops.keys():
		if rng.randf() <= float(drops[item_id]):
			state.add_item(item_id, 1)
	var completed_contracts: Array = state.register_kill(str(actor.kind))
	for contract_id: String in completed_contracts:
		show_notice("Contrato concluído — volte ao mural", Color(0.9, 0.85, 0.5))
	if is_colossal:
		state.flags["colossal_defeated"] = true
		var gain: = state.add_fame(GameData.QUEST_COLOSSAL["fame"])
		state.add_item("livro_skill", 1, true)
		show_notice("Colossal derrotado! +%d de fama" % int(gain), Color(1.0, 0.9, 0.4))
		state.flags["class_quest_done"] = true
		state._sync_evolution_skills()
		play_cue("game.victory")
		boss_finished.emit(true)
	else:
		show_notice("Fera da pedreira derrotada", Color(0.95, 0.85, 0.5))
	state_dirty.emit()


func _grant_xp(amount: int) -> void :
	var levels: Array = state.add_xp(amount)
	show_notice("+%d XP" % amount, Color(0.75, 0.85, 1.0))
	for new_level in levels:
		hero.sync_from_state()
		hero.hp = state.max_hp()
		show_notice("Nível %d alcançado!" % new_level, Color(1.0, 0.9, 0.45))
		level_gained.emit(new_level)
		play_cue("progress.level")
		var grade: = GameData.grade_for_level(new_level)
		if int(grade["min"]) == new_level:
			show_notice("Promoção de grade: %s" % str(grade["name"]), Color(1.0, 0.85, 0.4))
			state_dirty.emit()


func _update_respawns(delta: float) -> void :
	var still_pending: Array = []
	for entry: Dictionary in respawn_queue:
		entry["time"] = float(entry["time"]) - delta
		if float(entry["time"]) <= 0.0:
			var kind: = str(entry["kind"])
			if kind in ["fera", "colossal", "rival"]:
				continue
			if enemies_alive().size() > 26:
				still_pending.append(entry)
				continue
			spawn_enemy(kind, entry["position"])
		else:
			still_pending.append(entry)
	respawn_queue = still_pending


func _update_rival(delta: float) -> void :
	if state.level < 4 or state.rival_pending or bool(state.flags.get("colossal_defeated", false)):
		return
	rivals_timer += delta
	if rivals_timer < 95.0:
		return
	rivals_timer = 0.0
	for enemy in enemies_alive():
		if enemy.kind == "rival":
			return
	var spawn_point: = region.random_open_tile(RegionMap.FARM_RECT, rng)
	spawn_enemy("rival", spawn_point)
	state.rival_pending = true
	show_notice("Sombra de Kael surgiu nos campos!", Color(0.95, 0.65, 0.65))



func show_notice(text: String, color: Color = Color(0.95, 0.92, 0.85)) -> void :
	notice.emit(text, color)


func show_damage_number(position_point: Vector2, amount: float, crit: bool, type: String = "") -> void :
	if not SaveGame.show_damage:
		return
	var text: = str(int(round(amount)))
	var tint: = Color(1, 0.95, 0.85)
	if type == "recebido":
		tint = Color(1.0, 0.45, 0.4)
	elif crit:
		tint = Color(1.0, 0.85, 0.3)
	if crit:
		text = "%s!" % text
	Vfx.floating_text(self, position_point, text, tint, crit)


func show_dodge_text(position_point: Vector2) -> void :
	Vfx.floating_text(self, position_point, "esquiva", Color(0.7, 0.9, 1.0), false)


func spawn_vfx(position_point: Vector2, color: Color, count: int = 8, power: float = 130.0) -> void :
	Vfx.burst(self, position_point, color, count, power)


func spawn_impact(position_point: Vector2, color: Color) -> void :
	Vfx.burst(self, position_point, color, 5, 90.0)


func spawn_swing_arc(position_point: Vector2, _direction: Vector2, _radius: float) -> void :
	Vfx.burst(self, position_point, Color(1.0, 0.95, 0.8), 5, 80.0)


func spawn_cone_telegraph(position_point: Vector2, _direction: Vector2, _radius: float, _arc: float, color: Color, _duration: float) -> void :
	Vfx.burst(self, position_point, color, 10, 160.0)


func spawn_area_burst(position_point: Vector2, radius_value: float, damage: float, color: Color, _source: Node) -> void :
	var effect: = GroundEffect.new()
	effect.world = self
	effect.mode = "burst"
	effect.hostile = true
	effect.radius = radius_value
	effect.duration = 0.35
	effect.damage = damage
	effect.color = Color(color.r, color.g, color.b, 0.45)
	effect.edge = Color(1.0, 0.8, 0.5, 0.9)
	effect.position = position_point
	add_area_effect(effect)


func shake(amount: float) -> void :
	shake_amount = maxf(shake_amount, amount)


func play_cue(cue_id: String, pitch: float = 1.0) -> void :
	AudioDirector.play_cue(cue_id, pitch)


func flash_skill(skill_id: String) -> void :
	skill_cast.emit(skill_id)


func show_cast_bar(_duration: float) -> void :
	pass


func hide_cast_bar() -> void :
	pass



func _update_interaction() -> void :
	interact_prop = {}
	if hero == null:
		return
	var closest_distance: = 9999.0
	for prop: Dictionary in region.props:
		if str(prop["kind"]) == "cristal" and crystals_taken.has(str(prop["id"])):
			continue
		var tile: Vector2i = prop["tile"]
		var point: = region.world_position(tile)
		var distance: = hero.global_position.distance_to(point)
		if distance <= float(prop["radius"]) and distance < closest_distance:
			closest_distance = distance
			interact_prop = prop


func current_interaction() -> Dictionary:
	return interact_prop


func use_interaction() -> void :
	if interact_prop.is_empty():
		return
	var prop: Dictionary = interact_prop.duplicate()
	if str(prop["kind"]) == "cristal":
		crystals_taken[str(prop["id"])] = true
		if prop_nodes.has(str(prop["id"])):
			var node: Node2D = prop_nodes[str(prop["id"])]
			node.queue_free()
		state.add_item("cristal_aurora", 1)
		show_notice("Cristal de Aurora coletado", Color(0.6, 0.85, 1.0))
		state_dirty.emit()
		return
	play_cue("ui.confirm")
	prop_used.emit(prop)


func use_potion() -> void :
	if hero == null or hero.dead or not playing:
		return
	if state.count_item("pocao_cura") <= 0:
		show_notice("Sem poções de cura. Compre no baú da praça.", Color(0.92, 0.72, 0.5))
		return
	if hero.hp >= hero.max_hp - 0.5:
		show_notice("Sua vida já está cheia.", Color(0.8, 0.86, 0.92))
		return
	state.remove_item("pocao_cura", 1)
	hero.heal(60.0)
	spawn_vfx(hero.global_position + Vector2(0, -36), Color(0.45, 0.95, 0.55), 12, 120.0)
	play_cue("ui.confirm", 1.0)
	show_notice("Poção de cura: +60 HP (%d restantes)" % state.count_item("pocao_cura"), Color(0.62, 0.95, 0.62))


func enter_arena() -> void :
	if hero == null:
		return
	hero.global_position = region.arena_entry_position()
	camera.global_position = hero.global_position
	show_notice("O selo se rompe. O Colossal desperta.", Color(0.75, 0.85, 1.0))
	shake(8.0)


func leave_arena() -> void :
	if hero == null:
		return
	hero.global_position = region.world_position(RegionMap.ARENA_EXIT)
	camera.global_position = hero.global_position


func respawn_hero() -> void :
	if hero == null:
		return
	if region.zone_at(hero.global_position) == "santuario":
		leave_arena()
	hero.revive_at(region.hero_spawn_position())
	state.hp = hero.hp
	hero.sync_from_state()
	camera.global_position = hero.global_position


func _on_hero_died() -> void :
	var in_dungeon: bool = region.zone_at(hero.global_position) == "santuario"
	var lost_xp: = int(round(float(state.xp) * Balance.DEATH_XP_LOSS))
	state.xp = maxi(0, state.xp - lost_xp)
	state.wear_equipment(Balance.DEATH_DURABILITY_LOSS)
	state.hp = 1.0
	if in_dungeon:
		state.add_fame( - Balance.DUNGEON_FAME_LOSS_EASY)
		state.hostility = minf(100.0, state.hostility + 22.0)
		state.flags["colossal_defeated"] = false
		if boss != null and is_instance_valid(boss):
			boss.queue_free()
			enemies.erase(boss)
			boss = null
		for index in 2:
			spawn_errant()
		boss_finished.emit(false)
		show_notice("O núcleo do santuário se desestabilizou!", Color(0.95, 0.5, 0.45))
	state.rival_pending = false
	play_cue("game.defeat")
	hero_died.emit()


func _format_coins(value: int) -> String:
	if value >= 10000:
		return "%d ouro, %d prata" % [value / 10000, (value / 100) % 100]
	if value >= 100:
		return "%d prata, %d bronze" % [value / 100, value % 100]
	return "%d bronze" % value


func boss_node() -> Node:
	return boss
