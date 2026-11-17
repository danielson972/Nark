extends SceneTree
const Custom = preload("res://scripts/actors/character_customization.gd")
var scene: Control
var kept: Dictionary = {}
var gold := Color("c9b385")

func _initialize() -> void:
	var original_header := FileAccess.get_file_as_string("res://scenes/character_creation.tscn").get_slice("\n",0)
	scene = load("res://scenes/character_creation.tscn").instantiate()
	var snapshot: Dictionary = {}
	for node in scene.find_children("*","Sprite2D",true,false):
		if node.texture != null:
			snapshot[str(scene.get_path_to(node))] = [node.position.x,node.position.y,node.scale.x,node.scale.y,node.rotation,node.offset.x,node.offset.y]
	var file := FileAccess.open("res://.work/selection-sprites-before.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(snapshot,"\t"))
	var ids := ["Nome","Modelo_masculino","Modelo_feminino","Raca_humano","Raca_elfo","Raca_orc","Raca_anao","Classe_guerreiro","Classe_mago","Classe_atirador","Classe_assassino","Classe_tank","Classe_cavaleiro","DescricaoRaca","DescricaoClasse","Concluir","Voltar","Personagem","Resumo","EscolhaCabelo","EscolhaCor","EscolhaBarba","CorBarba"]
	for id: String in ids: kept[id] = scene.get_node("%"+id)
	kept.Cabelos = scene.get_node("Cabelos")
	kept.Barbas = scene.get_node("Barbas")
	for node: Node in kept.values():
		node.owner = null
		node.get_parent().remove_child(node)
	for child in scene.get_children(): child.free()
	var background := TextureRect.new()
	background.name = "FundoRuinas"
	background.texture = load("res://assets/game/ui/creation/ruins_background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.add_child(background)
	var title := label("CRIAÇÃO DE PERSONAGEM",20,true)
	title.name = "TituloSelecao"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 16
	title.offset_bottom = 46
	scene.add_child(title)
	var left := panel("PainelIdentidade",false)
	left.add_child(label("IDENTIDADE",19,true))
	left.add_child(HSeparator.new())
	left.add_child(label("NOME",12,true))
	add_control(left,"Nome",34)
	left.add_child(label("MODELO",12,true))
	var models := HBoxContainer.new()
	models.add_theme_constant_override("separation",6)
	left.add_child(models)
	for id in ["Modelo_masculino","Modelo_feminino"]: add_control(models,id,36)
	left.add_child(label("RAÇA",12,true))
	var races := GridContainer.new()
	races.columns = 2
	races.add_theme_constant_override("h_separation",6)
	races.add_theme_constant_override("v_separation",5)
	left.add_child(races)
	for id in ["Raca_humano","Raca_elfo","Raca_orc","Raca_anao"]: add_control(races,id,32)
	left.add_child(label("CLASSE",12,true))
	var jobs := GridContainer.new()
	jobs.columns = 2
	jobs.add_theme_constant_override("h_separation",6)
	jobs.add_theme_constant_override("v_separation",5)
	left.add_child(jobs)
	for id in ["Classe_guerreiro","Classe_mago","Classe_atirador","Classe_assassino","Classe_tank","Classe_cavaleiro"]: add_control(jobs,id,32)
	var hint := label("A origem e a classe definem o início da sua jornada.",12)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.modulate = Color("b4ac96")
	left.add_child(hint)
	var right := panel("PainelAparencia",true)
	right.add_child(label("APARÊNCIA",19,true))
	right.add_child(HSeparator.new())
	for field: Array in [["CABELO","EscolhaCabelo"],["COR DO CABELO","EscolhaCor"],["BARBA","EscolhaBarba"],["COR DA BARBA","CorBarba"]]:
		right.add_child(label(field[0],12,true))
		add_control(right,field[1],36)
	right.add_child(label("PALETA DO CABELO",12,true))
	var palette := HBoxContainer.new()
	palette.name = "Paleta"
	palette.unique_name_in_owner = true
	palette.add_theme_constant_override("separation",5)
	right.add_child(palette)
	for id: String in Custom.COLORS:
		var swatch := Button.new()
		swatch.name = "Cor_"+id
		swatch.custom_minimum_size = Vector2(26,28)
		swatch.tooltip_text = Custom.COLOR_NAMES[id]
		swatch.toggle_mode = true
		swatch.set_meta("color_id",id)
		var normal := field_style()
		normal.bg_color = Custom.COLORS[id]
		var active: StyleBoxFlat = normal.duplicate()
		active.border_color = Color("f1d398")
		active.set_border_width_all(2)
		swatch.add_theme_stylebox_override("normal",normal)
		swatch.add_theme_stylebox_override("disabled",normal)
		swatch.add_theme_stylebox_override("pressed",active)
		swatch.add_theme_stylebox_override("hover",active)
		swatch.add_theme_stylebox_override("focus",active)
		palette.add_child(swatch)
	var help := label("Cabelo e barba são escolhas independentes. Você também pode manter a opção sem.",12)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.modulate = Color("b4ac96")
	right.add_child(help)
	for id in ["DescricaoRaca","DescricaoClasse","Personagem"]:
		scene.add_child(kept[id])
		kept[id].hide()
	var summary: Label = kept.Resumo
	summary.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	summary.offset_left = -230
	summary.offset_right = 230
	summary.offset_top = -143
	summary.offset_bottom = -112
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_font_override("font",UiKit.display_font())
	summary.add_theme_font_size_override("font_size",17)
	summary.add_theme_color_override("font_color",Color("f2d99b"))
	summary.add_theme_color_override("font_outline_color",Color("141b16"))
	summary.add_theme_constant_override("outline_size",5)
	scene.add_child(summary)
	for id in ["Concluir","Voltar"]:
		var button: Button = kept[id]
		button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		button.offset_left = -135
		button.offset_right = 135
		button.offset_top = -99 if id == "Concluir" else -47
		button.offset_bottom = -55 if id == "Concluir" else -13
		button.custom_minimum_size = Vector2(270,44 if id == "Concluir" else 34)
		button.text = "CRIAR PERSONAGEM" if id == "Concluir" else "VOLTAR"
		style_control(button,15)
		scene.add_child(button)
	for id in ["Cabelos","Barbas"]: scene.add_child(kept[id])
	for child in scene.get_children(): own(child)
	if scene.has_method("set_editable_instance"): scene.set_editable_instance(kept.Barbas,true)
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
	var saved_text := FileAccess.get_file_as_string("res://scenes/character_creation.tscn")
	var scene_file := FileAccess.open("res://scenes/character_creation.tscn",FileAccess.WRITE)
	scene_file.store_string(original_header+"\n"+saved_text.substr(saved_text.find("\n")+1))
	print("SELECTION_SCENE_ADAPTED: ",snapshot.size()," authored sprites preserved, side panels, live controls and podium")
	scene.free()
	quit()

func own(node: Node) -> void:
	node.owner = scene
	if not node.scene_file_path.is_empty(): return
	for child in node.get_children(): own(child)

func panel(name: String, right: bool) -> VBoxContainer:
	var frame = load("res://scripts/ui/selection_frame.gd").new()
	frame.name = name
	frame.anchor_left = 1.0 if right else 0.0
	frame.anchor_right = frame.anchor_left
	frame.anchor_bottom = 1.0
	frame.offset_left = -304 if right else 24
	frame.offset_right = -24 if right else 304
	frame.offset_top = 46
	frame.offset_bottom = -113
	var style := field_style()
	style.bg_color = Color(0.025,0.035,0.031,0.94)
	style.border_color = Color("84734c")
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 22
	style.content_margin_bottom = 20
	style.shadow_color = Color(0,0,0,.65)
	style.shadow_size = 12
	frame.add_theme_stylebox_override("panel",style)
	scene.add_child(frame)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	frame.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",8)
	scroll.add_child(column)
	return column

func label(text: String, font_size: int, serif: bool = false) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size",font_size)
	result.add_theme_color_override("font_color",gold)
	if serif: result.add_theme_font_override("font",UiKit.display_font())
	return result

func add_control(parent: Node, id: String, height: float) -> void:
	var control: Control = kept[id]
	control.custom_minimum_size = Vector2(0,height)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	style_control(control,14)
	parent.add_child(control)

func field_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("111612")
	style.border_color = Color("6e6044")
	style.set_border_width_all(1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

func style_control(control: Control, font_size: int) -> void:
	var normal := field_style()
	var active: StyleBoxFlat = normal.duplicate()
	active.bg_color = Color("343023")
	active.border_color = Color("c9ad70")
	for state in ["normal","disabled"]: control.add_theme_stylebox_override(state,normal)
	for state in ["focus","hover","pressed"]: control.add_theme_stylebox_override(state,active)
	control.add_theme_font_size_override("font_size",font_size)
	control.add_theme_color_override("font_color",gold)
	control.add_theme_color_override("font_hover_color",Color("ffe3a1"))
	control.add_theme_color_override("font_pressed_color",Color("ffe3a1"))
	control.add_theme_color_override("font_disabled_color",Color("706f60"))
