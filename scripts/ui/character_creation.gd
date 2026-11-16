extends Control
## Standalone assembly scene, also embedded in the title screen flow.
signal submitted(race_id: String, class_id: String, hero_name: String, hair_style: int, hair_color: String, gender_id: String)
signal back_requested
const Custom = preload("res://scripts/actors/character_customization.gd")
var race_id: String = "humano"
var class_id: String = "guerreiro"
var hair_style: int = 0
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
	var background := ColorRect.new()
	background.color = Color("111713")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 20)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := UiKit.title("Monte seu personagem", 30)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var back := UiKit.button("Voltar", Vector2(100, 42))
	back.pressed.connect(func(): back_requested.emit())
	header.add_child(back)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	scroll.add_child(columns)
	var choices := _panel(columns, 260, true)
	choices.add_child(UiKit.title("Identidade", 22))
	choices.add_child(UiKit.label("Nome do personagem", 14, UiKit.MUTED))
	name_field = LineEdit.new()
	name_field.name = "Nome"
	name_field.text = hero_name
	name_field.max_length = 14
	name_field.custom_minimum_size.y = 42
	name_field.text_changed.connect(func(value): hero_name = value)
	choices.add_child(name_field)
	choices.add_child(UiKit.label("Modelo", 16, UiKit.GOLD))
	var models := HBoxContainer.new()
	choices.add_child(models)
	for id: String in ["masculino", "feminino"]:
		var button := UiKit.button("Masculino" if id == "masculino" else "Feminino", Vector2(112, 36))
		button.toggle_mode = true
		button.pressed.connect(select_gender.bind(id))
		models.add_child(button)
		gender_buttons[id] = button
	choices.add_child(UiKit.label("Raça", 16, UiKit.GOLD))
	var races := GridContainer.new()
	races.columns = 2
	choices.add_child(races)
	for id: String in GameData.RACE_ORDER:
		var button := UiKit.button(str(GameData.RACES[id].name), Vector2(112, 36))
		button.toggle_mode = true
		button.pressed.connect(select_race.bind(id))
		races.add_child(button)
		race_buttons[id] = button
	race_description = _description(choices)
	choices.add_child(UiKit.label("Classe", 16, UiKit.GOLD))
	var classes := GridContainer.new()
	classes.columns = 2
	choices.add_child(classes)
	for id: String in GameData.CLASS_ORDER:
		var button := UiKit.button(str(GameData.CLASSES[id].name), Vector2(112, 36))
		button.toggle_mode = true
		button.pressed.connect(select_class.bind(id))
		classes.add_child(button)
		class_buttons[id] = button
	class_description = _description(choices)
	var stage := _panel(columns, 270)
	stage.size_flags_stretch_ratio = 1.1
	stage.add_child(UiKit.title("Seu personagem", 22))
	preview = preload("res://scripts/ui/hero_preview.gd").new()
	preview.custom_minimum_size = Vector2(240, 300)
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_child(preview)
	summary = UiKit.label("", 16, UiKit.GOLD)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage.add_child(summary)
	var hint := _description(stage)
	hint.text = "A base começa careca. Escolha um cabelo ou mantenha a cabeça raspada."
	var appearance := _panel(columns, 420)
	appearance.size_flags_stretch_ratio = 1.5
	appearance.add_child(UiKit.title("Cabelo", 22))
	hair_caption = UiKit.label("", 14, UiKit.GOLD)
	appearance.add_child(hair_caption)
	var hair_scroll := ScrollContainer.new()
	hair_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hair_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hair_scroll.custom_minimum_size.y = 240
	appearance.add_child(hair_scroll)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hair_scroll.add_child(grid)
	for style in 17:
		var button := UiKit.button("", Vector2(82, 83))
		button.name = "Cabelo%02d" % style
		button.toggle_mode = true
		button.tooltip_text = Custom.HAIR_NAMES[style]
		button.pressed.connect(select_hair.bind(style))
		grid.add_child(button)
		hair_buttons[style] = button
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.add_child(content)
		if style > 0:
			var image := TextureRect.new()
			image.texture = Custom.hair_texture(style)
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			image.custom_minimum_size = Vector2(70, 57)
			image.mouse_filter = Control.MOUSE_FILTER_IGNORE
			image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var hair_material := ShaderMaterial.new()
			hair_material.shader = preload("res://shaders/character_hair.gdshader")
			image.material = hair_material
			content.add_child(image)
		var caption := UiKit.label("Careca" if style == 0 else "%02d" % style, 13)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(caption)
	appearance.add_child(UiKit.label("Cor do cabelo", 16, UiKit.GOLD))
	var colors := GridContainer.new()
	colors.columns = 4
	appearance.add_child(colors)
	for id: String in Custom.COLORS:
		var button := UiKit.button(str(Custom.COLOR_NAMES[id]), Vector2(82, 38))
		button.add_theme_color_override("font_color", Custom.COLORS[id].lightened(0.25))
		button.toggle_mode = true
		button.pressed.connect(select_color.bind(id))
		colors.add_child(button)
		color_buttons[id] = button
	var footer := HBoxContainer.new()
	layout.add_child(footer)
	var note := UiKit.label("Sua aparência acompanha o personagem e fica salva com a partida.", 13, UiKit.MUTED)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_child(note)
	var start := UiKit.button("Entrar no Reino", Vector2(230, 46), true)
	start.name = "Concluir"
	start.pressed.connect(submit)
	footer.add_child(start)
	_refresh()

func _panel(parent: Node, width: float, scroll_content: bool = false) -> VBoxContainer:
	var panel := UiKit.panel()
	panel.custom_minimum_size.x = width
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	if scroll_content:
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.add_child(scroll)
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(column)
	else:
		panel.add_child(column)
	return column

func _description(parent: Node) -> Label:
	var label := UiKit.label("", 13, UiKit.MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.max_lines_visible = 2
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(label)
	return label

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
	state.set_hair(hair_style, hair_color)
	state.unequip("arma")
	preview.state = state
	preview.queue_redraw()
	summary.text = "%s · %s" % [GameData.RACES[race_id].name, GameData.CLASSES[class_id].name]
	race_description.text = str(GameData.RACES[race_id].desc)
	class_description.text = str(GameData.CLASSES[class_id].desc)
	hair_caption.text = "%s · %s" % [Custom.HAIR_NAMES[hair_style], Custom.COLOR_NAMES[hair_color]]
	for id: String in race_buttons: race_buttons[id].set_pressed_no_signal(id == race_id)
	for id: String in gender_buttons: gender_buttons[id].set_pressed_no_signal(id == gender_id)
	for id: String in class_buttons: class_buttons[id].set_pressed_no_signal(id == class_id)
	for style: int in hair_buttons:
		hair_buttons[style].set_pressed_no_signal(style == hair_style)
		for image in hair_buttons[style].find_children("*", "TextureRect", true, false):
			image.material.set_shader_parameter("hair_color", Custom.COLORS[hair_color])
	for id: String in color_buttons:
		color_buttons[id].set_pressed_no_signal(id == hair_color)
		color_buttons[id].disabled = hair_style == 0

func submit() -> void:
	submitted.emit(race_id, class_id, name_field.text, hair_style, hair_color, gender_id)
