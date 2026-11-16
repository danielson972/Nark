extends Enemy
## Árvore de Cipó: inimigo lento da floresta de Aurora.

# Atributos próprios; perseguição, colisões e golpes são tratados por Enemy.
const CONFIG = {
	"level": 20,
	"name": "Árvore de Cipó",
	"sprite": "res://assets/game/sprites/monstros/aurora/Sprite-0001.png",
	"height": 186.0,
	"hp": 480.0, "damage": 42.0, "defense": 28.0,
	"speed": 58.0, "xp": 480, "tier": 1,
	"coins": [12, 25], "drops": {},
	"aggro": 340.0, "attack_range": 85.0,
	"attack_cd": 2.0, "windup": 0.75,
	"radius": 28.0, "kind": "arvore_cipo",
}

# Habilidades próprias da árvore, ajustáveis pelo Inspector.
@export var root_cooldown: float = 7.0
@export var root_warning: float = 0.9
@export var root_duration: float = 2.0
@export var seed_cooldown: float = 4.5
@export var seed_damage: float = 30.0
@export var weed_enemy_id: String = "mini_daninha"
var root_timer: float = 1.0
var seed_timer: float = 2.8
var spell_left: float = 0.0
var preparing_seed: bool = false


func _init() -> void:
	# Identifica o monstro no catálogo, na sala secreta e no registro da cena.
	type_id = "arvore_cipo"


func setup_enemy(world_ref: Node, enemy_type: String, spawn: Vector2) -> void:
	# O sprite colocado no editor usa origem central: move a origem para os pés
	# sem alterar a posição visível da arte, alinhando sombra e colisão no jogo.
	var grounded_spawn: Vector2 = spawn
	if texture != null and offset.is_zero_approx():
		var half_height: float = texture.get_height() * 0.5
		offset.y = -half_height
		grounded_spawn.y += half_height * scale.y
	super.setup_enemy(world_ref, enemy_type, grounded_spawn)
	root_timer = 1.0
	seed_timer = 2.8
	spell_left = 0.0
	preparing_seed = false


func _process(delta: float) -> void:
	if world != null and world.is_playing() and not dead:
		root_timer = maxf(0.0, root_timer - delta)
		seed_timer = maxf(0.0, seed_timer - delta)
	super._process(delta)


func _process_special_action(delta: float, hero, distance: float) -> bool:
	if spell_left > 0.0:
		velocity = Vector2.ZERO
		spell_left = maxf(0.0, spell_left - delta)
		if spell_left == 0.0 and preparing_seed:
			preparing_seed = false
			var seed = load("res://scripts/combat/tree_seed.gd").new()
			seed.world = world
			seed.hostile = true
			seed.kind = "seed"
			seed.damage = seed_damage
			seed.speed = 250.0
			seed.life = 2.5
			seed.hit_radius = 9.0
			seed.weed_enemy_id = weed_enemy_id
			seed.position = global_position + Vector2(0, -45)
			seed.direction = seed.position.direction_to(hero.global_position)
			world.add_projectile(seed)
		return true
	if distance > 500.0 or windup_left > 0.0 or not action.is_empty():
		return false
	if root_timer <= 0.0:
		var trap = load("res://scripts/combat/tree_root_trap.gd").new()
		trap.world = world
		trap.position = hero.global_position
		trap.warning_time = root_warning
		trap.root_duration = root_duration
		world.effects_layer.add_child(trap)
		root_timer = root_cooldown
		spell_left = 0.35
		velocity = Vector2.ZERO
		world.show_notice("Árvore de Cipó: Raízes Prendedoras!", Color(0.85, 0.7, 0.25))
		return true
	if seed_timer <= 0.0:
		preparing_seed = true
		spell_left = 0.45
		seed_timer = seed_cooldown
		velocity = Vector2.ZERO
		world.show_notice("Árvore de Cipó: Semente Daninha!", Color(0.65, 0.85, 0.3))
		return true
	return false
