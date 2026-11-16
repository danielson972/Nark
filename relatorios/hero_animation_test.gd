extends Node2D

const CLASS_OPTIONS: Array[Dictionary] = [
	{"id": "guerreiro", "name": "Guerreiro"},
	{"id": "mago", "name": "Mago"},
	{"id": "atirador", "name": "Atirador"},
	{"id": "assassino", "name": "Assassino"},
	{"id": "tank", "name": "Tank"},
	{"id": "cavaleiro", "name": "Cavaleiro"},
]
const DIRECTIONS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const DIRECTION_NAMES: Array[String] = ["DIREITA", "BAIXO", "ESQUERDA", "CIMA"]

var world: WorldView
var elapsed: float = 0.0
var direction_index: int = -1
var class_index: int = 0
var attack_triggered: bool = false
var status_label: Label


func _ready() -> void:
	world = WorldView.new()
	world.name = "MundoTesteAnimacaoHeroi"
	add_child(world)
	var state := PlayerState.create("Teste Animação", "humano", str(CLASS_OPTIONS[class_index]["id"]))
	world.build(state, {}, true)
	world.hero.global_position = Vector2(36.0 * Balance.TILE + Balance.TILE * 0.5, 14.0 * Balance.TILE + Balance.TILE * 0.5)
	world.camera.global_position = world.hero.global_position
	world.start()
	world.hero.set_process(false)
	_create_overlay()
	_update_status()


func _process(delta: float) -> void:
	elapsed += delta
	var phase_index: int = int(floor(elapsed / 2.2)) % DIRECTIONS.size()
	var phase_time: float = fposmod(elapsed, 2.2)
	if phase_index != direction_index:
		direction_index = phase_index
		attack_triggered = false
		_update_status()
	var direction: Vector2 = DIRECTIONS[direction_index]
	world.hero.facing = direction
	if phase_time < 1.35:
		world.hero.move_desired(direction * 95.0, delta)
	else:
		world.hero.move_desired(Vector2.ZERO, delta)
	if phase_time >= 1.4 and not attack_triggered:
		world.hero.attack_swing = 0.18
		attack_triggered = true
	if world.hero.attack_swing > 0.0:
		world.hero.attack_swing = maxf(0.0, world.hero.attack_swing - delta)
	world.hero._update_hero_animation(delta)
	world.hero._update_equipment_pose()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var next_class := -1
	match event.keycode:
		KEY_1: next_class = 0
		KEY_2: next_class = 1
		KEY_3: next_class = 2
		KEY_4: next_class = 3
		KEY_5: next_class = 4
		KEY_6: next_class = 5
	if next_class < 0:
		return
	class_index = next_class
	var state := PlayerState.create("Teste Animação", "humano", str(CLASS_OPTIONS[class_index]["id"]))
	world.state = state
	world.hero.bind_state(state)
	world.hero.refresh_appearance()
	_update_status()


func _create_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(18.0, 18.0)
	panel.custom_minimum_size = Vector2(440.0, 112.0)
	canvas.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "ANIMAÇÕES DO HERÓI"
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color(0.65, 0.86, 1.0))
	column.add_child(title)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	column.add_child(status_label)
	var help := Label.new()
	help.text = "Demonstração automática: andar e golpear nas quatro direções. Teclas 1–6 alternam as classes."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)


func _update_status() -> void:
	if status_label == null:
		return
	var class_name_text: String = str(CLASS_OPTIONS[class_index]["name"])
	var dir_name: String = DIRECTION_NAMES[maxi(direction_index, 0)]
	status_label.text = "%s  |  Movimento: %s" % [class_name_text, dir_name]
