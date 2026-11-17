extends Control
## Standalone assembly scene, also embedded in the title screen flow.
signal submitted(race_id: String, class_id: String, hero_name: String, hair_style: int, hair_color: String, gender_id: String, beard_style: int, beard_color: String)
signal back_requested
const Custom = preload("res://scripts/actors/character_customization.gd")
var race_id: String = "humano"
var class_id: String = "guerreiro"
@export_range(0, 16) var hair_style: int = 1
var hair_color: String = "castanho"
var hero_name: String = "Aurora"
var gender_id: String = "masculino"
@export_range(0,20) var beard_style: int = 0
var beard_color: String = "original"
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
var portrait_origin: Vector2
var beard_origin: Vector2

func _ready() -> void:
	portrait_origin = $Cabelos.position
	beard_origin = $Barbas.position
	resized.connect(_layout_portrait.call_deferred)
	preview = %Personagem
	preview.draw_character = false
	preview.show_hair = false
	%EscolhaCabelo.item_selected.connect(select_hair)
	%EscolhaCor.item_selected.connect(func(index): select_color(Custom.COLORS.keys()[index]))
	%EscolhaBarba.item_selected.connect(select_beard)
	%CorBarba.item_selected.connect(func(index): select_beard_color((["original"]+Custom.COLORS.keys())[index]))
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
		class_buttons[id].tooltip_text = str(GameData.CLASSES[id].desc)
	for id: String in race_buttons:
		race_buttons[id].tooltip_text = str(GameData.RACES[id].desc)
	for button in %Paleta.get_children():
		var id: String = button.get_meta("color_id")
		color_buttons[id] = button
		button.add_theme_stylebox_override("disabled",button.get_theme_stylebox("normal"))
		button.pressed.connect(select_color.bind(id))
	$TituloSelecao.add_theme_color_override("font_outline_color",Color("182018"))
	$TituloSelecao.add_theme_constant_override("outline_size",4)
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

func select_beard(style: int) -> void:
	beard_style = clampi(style,0,20)
	_refresh()

func select_beard_color(id: String) -> void:
	if id != "original" and not Custom.COLORS.has(id): return
	beard_color = id
	_refresh()

func _refresh() -> void:
	if preview == null: return
	var state := PlayerState.create(hero_name, race_id, class_id)
	state.gender_id = gender_id
	state.set_hair(0, hair_color)
	state.set_beard(beard_style,beard_color)
	state.unequip("arma")
	# Creation displays the complete supplied base; equipment is applied in game.
	state.unequip("armadura")
	preview.state = state
	preview.queue_redraw()
	_update_hair_overlay.call_deferred()
	_update_beard_overlay.call_deferred()
	_layout_portrait.call_deferred()
	summary.text = "%s · %s" % [GameData.RACES[race_id].name, GameData.CLASSES[class_id].name]
	race_description.text = str(GameData.RACES[race_id].desc)
	class_description.text = str(GameData.CLASSES[class_id].desc)
	for id: String in race_buttons: race_buttons[id].set_pressed_no_signal(id == race_id)
	for id: String in gender_buttons: gender_buttons[id].set_pressed_no_signal(id == gender_id)
	for id: String in class_buttons: class_buttons[id].set_pressed_no_signal(id == class_id)
	%EscolhaCabelo.select(hair_style)
	%EscolhaCor.select(Custom.COLORS.keys().find(hair_color))
	%EscolhaCor.disabled = hair_style == 0
	%EscolhaBarba.select(beard_style)
	%CorBarba.select((["original"]+Custom.COLORS.keys()).find(beard_color))
	%CorBarba.disabled = beard_style == 0
	for id: String in color_buttons:
		color_buttons[id].set_pressed_no_signal(id == hair_color)
		color_buttons[id].disabled = hair_style == 0
		color_buttons[id].modulate.a = 0.45 if hair_style == 0 else 1.0

func submit() -> void:
	submitted.emit(race_id, class_id, name_field.text, hair_style, hair_color, gender_id, beard_style, beard_color)

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

func _update_beard_overlay() -> void:
	var overlay := get_node_or_null("Barbas")
	if overlay == null: return
	var active: String = {"humano":"Humano","elfo":"Elfo","orc":"Orc","anao":"Anao"}[race_id]+("Masculino" if gender_id == "masculino" else "Feminino")
	for group in overlay.get_children():
		group.visible = group.name == active
		for model in group.get_children():
			model.visible = model.name == "Modelo%d" % beard_style
			model.material.set_shader_parameter("original_color",beard_color == "original")
			model.material.set_shader_parameter("beard_color",Custom.COLORS.get(beard_color,Custom.COLORS.castanho))

func _layout_portrait() -> void:
	if not is_inside_tree(): return
	var group_name: String = {"humano":"Humano","elfo":"Elfo","orc":"Orc","anao":"Anao"}[race_id]+("Masculino" if gender_id == "masculino" else "Feminino")
	var group: Node2D = $Cabelos.get_node(group_name)
	var base: Sprite2D = group.get_node("BaseCareca")
	var texture_size: Vector2 = base.texture.get_size()
	var local_foot := Vector2(texture_size.x*.5,502.0)+base.offset
	if base.centered: local_foot -= texture_size*.5
	var native_foot: Vector2 = $Cabelos.transform.basis_xform(group.transform*(base.transform*local_foot))
	var target := Vector2(size.x*.5,size.y*.745)
	var translation: Vector2 = target-(portrait_origin+native_foot)
	# Translate the assembled portrait only. No sprite transform or scale changes.
	$Cabelos.position = portrait_origin+translation
	$Barbas.position = beard_origin+translation
