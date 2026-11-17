extends Control
## Standalone assembly scene, also embedded in the title screen flow.
signal submitted(race_id: String, class_id: String, hero_name: String, hair_style: int, hair_color: String, gender_id: String)
signal back_requested
const Custom = preload("res://scripts/actors/character_customization.gd")
var race_id: String = "humano"
var class_id: String = "guerreiro"
@export_range(0, 16) var hair_style: int = 1
var hair_color: String = "castanho"
var hero_name: String = "Aurora"
var gender_id: String = "masculino"
var gender_buttons: Dictionary = {}
var preview: Control
var name_field: LineEdit
var summary: Label
var race_description: Label
var class_description: Label
var hair_caption: Label
var race_buttons: Dictionary = {}
var class_buttons: Dictionary = {}
var hair_buttons: Dictionary = {}
var color_buttons: Dictionary = {}

func _ready() -> void:
	preview = %Personagem
	preview.draw_character = false
	preview.show_hair = false
	%EscolhaCabelo.item_selected.connect(select_hair)
	%EscolhaCor.item_selected.connect(func(index): select_color(Custom.COLORS.keys()[index]))
	preview.resized.connect(_update_hair_overlay.call_deferred)
	name_field = %Nome
	summary = %Resumo
	race_description = %DescricaoRaca
	class_description = %DescricaoClasse
	gender_buttons = {"masculino": %Modelo_masculino, "feminino": %Modelo_feminino}
	race_buttons = {"humano": %Raca_humano, "elfo": %Raca_elfo, "orc": %Raca_orc, "anao": %Raca_anao}
	class_buttons = {"guerreiro": %Classe_guerreiro, "mago": %Classe_mago, "atirador": %Classe_atirador, "assassino": %Classe_assassino, "tank": %Classe_tank, "cavaleiro": %Classe_cavaleiro}
	name_field.text = hero_name
	name_field.text_changed.connect(func(value): hero_name = value)
	%Voltar.pressed.connect(func(): back_requested.emit())
	%Concluir.pressed.connect(submit)
	for id: String in gender_buttons:
		gender_buttons[id].pressed.connect(select_gender.bind(id))
	for id: String in race_buttons:
		race_buttons[id].pressed.connect(select_race.bind(id))
	for id: String in class_buttons:
		class_buttons[id].pressed.connect(select_class.bind(id))
	_refresh()

func select_race(id: String) -> void:
	if not GameData.RACES.has(id): return
	race_id = id
	_refresh()

func select_gender(id: String) -> void:
	gender_id = "feminino" if id == "feminino" else "masculino"
	_refresh()

func select_class(id: String) -> void:
	if not GameData.CLASSES.has(id): return
	class_id = id
	_refresh()

func select_hair(style: int) -> void:
	hair_style = clampi(style, 0, 16)
	_refresh()

func select_color(id: String) -> void:
	if not Custom.COLORS.has(id): return
	hair_color = id
	_refresh()

func _refresh() -> void:
	if preview == null: return
	var state := PlayerState.create(hero_name, race_id, class_id)
	state.gender_id = gender_id
	state.set_hair(0, hair_color)
	state.unequip("arma")
	# Creation displays the complete supplied base; equipment is applied in game.
	state.unequip("armadura")
	preview.state = state
	preview.queue_redraw()
	_update_hair_overlay.call_deferred()
	summary.text = "%s · %s" % [GameData.RACES[race_id].name, GameData.CLASSES[class_id].name]
	race_description.text = str(GameData.RACES[race_id].desc)
	class_description.text = str(GameData.CLASSES[class_id].desc)
	for id: String in race_buttons: race_buttons[id].set_pressed_no_signal(id == race_id)
	for id: String in gender_buttons: gender_buttons[id].set_pressed_no_signal(id == gender_id)
	for id: String in class_buttons: class_buttons[id].set_pressed_no_signal(id == class_id)
	%EscolhaCabelo.select(hair_style)
	%EscolhaCor.select(Custom.COLORS.keys().find(hair_color))
	%EscolhaCor.disabled = hair_style == 0

func submit() -> void:
	submitted.emit(race_id, class_id, name_field.text, hair_style, hair_color, gender_id)

func _update_hair_overlay() -> void:
	var overlay := get_node_or_null("Cabelos") as Node2D
	if overlay == null or preview == null:
		return
	# The authored sprites are the portrait. Preserve all editor transforms;
	# only switch visibility and color when the selection changes.
	var group_names := {"humano": "Humano", "elfo": "Elfo", "orc": "Orc", "anao": "Anao"}
	var active: String = group_names[race_id] + ("Masculino" if gender_id == "masculino" else "Feminino")
	for group in overlay.get_children():
		group.visible = group.name == active
		for model in group.get_children():
			if model.name == "Orelha" or model.name == "DenteEsquerdo":
				model.visible = true
				continue
			if model.name == "BaseCareca":
				model.visible = true
				continue
			model.visible = model.name == "Modelo%d" % hair_style
			if model.material == null:
				var color_material := ShaderMaterial.new()
				color_material.shader = preload("res://shaders/fitted_hair.gdshader")
				model.material = color_material
			model.material.set_shader_parameter("hair_color", Custom.COLORS[hair_color])
