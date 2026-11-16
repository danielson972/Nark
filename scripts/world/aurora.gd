extends WorldView
## Permite executar Aurora diretamente com o herói colocado no editor.

@export_enum("humano", "elfo", "orc", "anao") var hero_race: String = "humano"
@export_enum("atirador", "mago", "guerreiro", "assassino", "tank", "cavaleiro") var hero_class: String = "guerreiro"
@export var hero_name: String = "Herói"


func _ready() -> void:
	# Um PlayerState existente pode ser atribuído antes de adicionar a cena à árvore.
	if state == null:
		state = PlayerState.create(hero_name, hero_race, hero_class)
	region = RegionMap.new()
	rng.randomize()
	_build_layers()
	hero = get_node("Hero") as Hero
	hero.bind_state(state)
	hero.setup(self, "", 92.0)
	hero.global_position = get_node("InicioJogador").global_position
	hero.died_hero.connect(_on_hero_died)
	hero.hp = state.hp
	_attach_hero_camera()
	camera.global_position = hero.global_position
	_register_map_enemies(self)
	_update_day_night(0.0)
	start()
	_install_game_controller.call_deferred()


func _install_game_controller() -> void:
	# O controlador fica fora de Aurora para continuar ativo quando ela é pausada.
	var controller = load("res://scripts/main.gd").new()
	controller.name = "ControleAurora"
	controller.standalone_scene = true
	controller.world = self
	controller.state = state
	get_tree().root.add_child(controller)
	tree_exiting.connect(controller.queue_free)
