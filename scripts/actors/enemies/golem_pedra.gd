extends Enemy
## Golem de Aurora: movimento e ataque herdados de Enemy, com caminhada própria.

const CONFIG = {
	"level": 2,
	"name": "Golem de Pedra", "sprite": "res://assets/game/sprites/monstros/aurora/golem_pedra_walk_64.png", "height": 64.0,
	"hp": 70.0, "damage": 7.0, "defense": 2.0, "speed": 66.0, "xp": 60, "tier": 0,
	"coins": [3, 9], "aggro": 400.0, "attack_range": 56.0, "attack_cd": 1.7, "windup": 0.5,
	"drops": {}, "radius": 18.0, "kind": "golem_pedra",
}

# Controla a velocidade dos oito quadros de caminhada.
@export var walk_fps: float = 8.0
var walk_time: float = 0.0
# Última linha ocupada pelos pés em cada quadro, descontando a margem transparente.
const FOOT_BOTTOM: Array[int] = [57, 57, 56, 56, 58, 57, 56, 56]

# Rolamento: preparação visível, perseguição teleguiada e tempo para se recuperar.
@export var roll_speed: float = 340.0
@export var roll_damage: float = 14.0
@export var roll_cooldown: float = 6.0
@export var roll_windup: float = 0.25
@export var roll_duration: float = 1.2
# Limita a curva para acompanhar o herói sem mudar de direção instantaneamente.
@export var roll_turn_speed: float = 6.0
@export var stone_damage: float = 10.0
@export var stone_cooldown: float = 5.0
@export var stone_windup: float = 0.4
var stone_cooldown_left: float = 3.0
var stone_cast_left: float = 0.0
var roll_cooldown_left: float = 1.5
var roll_state: String = ""
var roll_left: float = 0.0
var roll_direction: Vector2 = Vector2.RIGHT
# Distância percorrida determina os quadros da bola, sem girar a imagem pixelada.
var roll_distance: float = 0.0
var ball: Sprite2D
var ball_shadow: Polygon2D


func _align_feet() -> void:
	# Encosta a sola no ponto da colisão e da sombra, sem deslocar o corpo físico.
	offset.y = 32.0 - float(FOOT_BOTTOM[frame] + 1)


func _init() -> void:
	# Permite registrar golens colocados no editor e criados pela habilidade.
	type_id = "golem_pedra"


func setup(world_ref: Node, texture_path: String, target_height: float = 64.0) -> void:
	# A imagem contém quatro colunas e duas linhas de quadros de 64 pixels.
	if texture == null:
		texture = load(texture_path)
	hframes = 4
	vframes = 2
	offset = Vector2(0, -32)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	super.setup(world_ref, texture_path, target_height)
	frame = 0
	walk_time = 0.0
	_align_feet()
	_create_roll_visual()
	roll_state = ""
	roll_cooldown_left = 1.5
	stone_cooldown_left = 3.0
	stone_cast_left = 0.0


func _create_roll_visual() -> void:
	# O visual gira separado do corpo para não deslocar a colisão nem o nome.
	if ball != null:
		return
	ball = Sprite2D.new()
	ball.name = "FormaBola"
	ball.texture = load("res://assets/game/sprites/monstros/aurora/golem_pedra_roll_spritesheet_64.png")
	ball.hframes = 4
	ball.vframes = 2
	ball.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ball.position = Vector2(0, -18)
	ball.visible = false
	add_child(ball)
	ball_shadow = Polygon2D.new()
	ball_shadow.name = "SombraRolamento"
	var points := PackedVector2Array()
	for index in 20:
		var angle: float = TAU * float(index) / 20.0
		points.append(Vector2(cos(angle) * 16.0, sin(angle) * 6.0))
	ball_shadow.polygon = points
	ball_shadow.color = Color(0, 0, 0, 0.28)
	ball_shadow.z_index = -1
	ball_shadow.visible = false
	add_child(ball_shadow)


func _finish_roll() -> void:
	# Volta à forma normal e pausa por um instante após o impacto ou fim da corrida.
	roll_state = "recover"
	roll_left = 0.18
	velocity = Vector2.ZERO
	self_modulate.a = 1.0
	ball.visible = false
	ball_shadow.visible = false
	frame = 0
	_align_feet()


func _process_special_action(delta: float, hero, distance: float) -> bool:
	# Prepara e solta uma pedra entre os rolamentos, com aviso antes do disparo.
	if stone_cast_left > 0.0:
		velocity = Vector2.ZERO
		stone_cast_left = maxf(0.0, stone_cast_left - delta)
		if stone_cast_left == 0.0:
			var stone = load("res://scripts/combat/golem_stone.gd").new()
			stone.world = world
			stone.hostile = true
			stone.kind = "stone"
			stone.damage = stone_damage
			stone.speed = 320.0
			stone.life = 2.0
			stone.size = 8.0
			stone.hit_radius = 10.0
			stone.direction = global_position.direction_to(hero.global_position)
			stone.position = global_position + stone.direction * (radius + 12.0)
			world.add_projectile(stone)
		return true
	if roll_state.is_empty() and roll_cooldown_left > 0.0 and stone_cooldown_left <= 0.0 and distance >= 100.0 and distance <= 500.0 and windup_left <= 0.0 and action.is_empty():
		stone_cast_left = stone_windup
		stone_cooldown_left = stone_cooldown
		velocity = Vector2.ZERO
		world.show_notice("Golem de Pedra: Pedra Atordoante!", Color(0.95, 0.8, 0.4))
		return true
	if roll_state.is_empty():
		# Só inicia quando existe espaço para uma investida e não está preparando um golpe.
		if roll_cooldown_left > 0.0 or distance < 120.0 or distance > 480.0 or windup_left > 0.0 or not action.is_empty():
			return false
		roll_state = "windup"
		roll_left = roll_windup
		roll_cooldown_left = roll_cooldown
		roll_direction = (hero.global_position - global_position).normalized()
		ball.rotation = 0.0
		ball.frame = 0
		roll_distance = 0.0
		ball.visible = true
		world.show_notice("Golem de Pedra: Rolamento!", Color(0.6, 0.85, 1.0))
	roll_left -= delta
	velocity = Vector2.ZERO
	if roll_state == "windup":
		var progress: float = clampf(1.0 - roll_left / maxf(roll_windup, 0.001), 0.0, 1.0)
		self_modulate.a = 1.0 - progress
		ball.modulate.a = progress
		ball.scale = Vector2.ONE * lerpf(0.65, 1.0, progress)
		if roll_left <= 0.0:
			roll_state = "rolling"
			roll_left = roll_duration
			self_modulate.a = 0.0
			ball.modulate.a = 1.0
			ball.scale = Vector2.ONE
			ball_shadow.visible = true
		return true
	if roll_state == "recover":
		if roll_left <= 0.0:
			roll_state = ""
		return true
	if roll_left <= 0.0:
		_finish_roll()
		return true
	# Divide o deslocamento para não atravessar tochas ou o herói entre dois quadros.
	# Recalcula a mira a cada quadro, respeitando a velocidade máxima de curva.
	var target_direction: Vector2 = global_position.direction_to(hero.global_position)
	if target_direction != Vector2.ZERO:
		var turn: float = clampf(roll_direction.angle_to(target_direction), -roll_turn_speed * delta, roll_turn_speed * delta)
		roll_direction = roll_direction.rotated(turn).normalized()
	var steps: int = maxi(1, ceili(roll_speed * delta / 6.0))
	var step: Vector2 = roll_direction * roll_speed * delta / float(steps)
	for index in steps:
		var next: Vector2 = global_position + step
		if not world.can_stand(next, radius) or not world.can_actor_stand(self, next, radius, true):
			_finish_roll()
			return true
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(hero.global_position, global_position, next)
		if closest.distance_to(hero.global_position) <= radius + hero.radius:
			hero.take_damage(roll_damage, {"from": global_position, "type": type_id, "crit": false})
			world.knockback(hero, roll_direction, 45.0)
			world.shake(3.0)
			_finish_roll()
			return true
		global_position = next
		roll_distance += step.length()
	# Sincroniza o giro desenhado com a distância, mantendo tamanho e ponto de apoio fixos.
	var roll_frame: int = int(roll_distance / (TAU * 18.0) * 8.0) % 8
	ball.frame = (8 - roll_frame) % 8 if roll_direction.x < 0.0 else roll_frame
	velocity = roll_direction * roll_speed
	return true


func _wander(delta: float) -> void:
	# Cancela o arremesso se não houver mais um alvo válido.
	stone_cast_left = 0.0
	# Se o herói morrer ou sair, encerra a forma de bola antes de voltar ao movimento ocioso.
	if not roll_state.is_empty():
		_finish_roll()
		roll_state = ""
	super._wander(delta)


func _process(delta: float) -> void:
	if world != null and world.is_playing() and not dead:
		roll_cooldown_left = maxf(0.0, roll_cooldown_left - delta)
		stone_cooldown_left = maxf(0.0, stone_cooldown_left - delta)
	# Invocados perseguem o jogador sem retornar à posição de nascimento.
	if summoned:
		spawn_point = global_position
		ai_state = "chase"
	var previous_position: Vector2 = global_position
	# Atualiza perseguição, ataque e colisões pelo comportamento geral de Enemy.
	super._process(delta)
	if not roll_state.is_empty():
		return
	# Os passos avançam apenas quando houve deslocamento real.
	var moved_distance: float = global_position.distance_to(previous_position)
	if moved_distance > 0.0317:
		# Sincroniza os passos com o deslocamento, inclusive quando uma colisão reduz o avanço.
		walk_time += moved_distance / float(CONFIG["speed"])
		frame = int(walk_time * walk_fps) % 8
	else:
		walk_time = 0.0
		frame = 0
	_align_feet()
