class_name GameUI
extends CanvasLayer


signal new_game_requested(race_id: String, class_id: String, hero_name: String)
signal continue_requested
signal quit_requested
signal resume_requested
signal title_requested
signal panel_action(action: String, payload: Dictionary)
signal save_requested
signal options_changed

var root: Control
var hud: Control
var overlay: Control
var modal_layer: Control
var toasts: VBoxContainer

var name_label: Label
var level_label: Label
var grade_label: Label
var fame_label: Label
var coins_label: Label
var clock_label: Label
var region_label: Label
var hp_bar: ProgressBar
var mp_bar: ProgressBar
var energy_bar: ProgressBar
var hp_text: Label
var mp_text: Label
var energy_text: Label
var state_label: Label
var interact_label: Label
var cast_bar: ProgressBar
var boss_panel: PanelContainer
var boss_name: Label
var boss_bar: ProgressBar
var hotbar_slots: Array = []
var minimap: Control
var creation_race: = "humano"
var creation_class: = "guerreiro"
var creation_preview: VBoxContainer
var name_input: LineEdit
var rebind_action: = ""
var rebind_buttons: Dictionary = {}
var options_status: Label
var current_panel: = ""
var inventory_view: Control
var skills_view: Control

const SkillArt = preload("res://scripts/ui/skill_icon.gd")
const SkillCatalog = preload("res://scripts/ui/skill_catalog.gd")
const SkillHover = preload("res://scripts/ui/skill_hover.gd")

const SkillsPanelView = preload("res://scripts/ui/skills_panel.gd")

const InventoryPanelView = preload("res://scripts/ui/inventory_panel.gd")

const MINIMAP_SIZE: = 174.0


func _ready() -> void :
	layer = 10
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)

	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)

	modal_layer = Control.new()
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	root.add_child(modal_layer)

	_build_hud()
	hud.visible = false




func _build_hud() -> void :
	var status_panel: = PanelContainer.new()
	status_panel.position = Vector2(16, 14)
	status_panel.size = Vector2(346, 132)
	status_panel.custom_minimum_size = Vector2(346, 132)
	status_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	status_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	UiKit.apply_panel(status_panel, Color(0.09, 0.07, 0.06, 0.9))
	hud.add_child(status_panel)
	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	status_panel.add_child(column)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	name_label = UiKit.label("Herói", 19, UiKit.PARCHMENT)
	header.add_child(name_label)
	level_label = UiKit.label("Nv 1", 17, UiKit.GOLD)
	header.add_child(level_label)
	grade_label = UiKit.label("No-Grade", 14, UiKit.MUTED)
	header.add_child(grade_label)

	var bars: = GridContainer.new()
	bars.columns = 2
	bars.add_theme_constant_override("h_separation", 6)
	bars.add_theme_constant_override("v_separation", 3)
	column.add_child(bars)
	hp_bar = UiKit.bar(UiKit.HP)
	hp_bar.custom_minimum_size = Vector2(210, 16)
	bars.add_child(hp_bar)
	hp_text = UiKit.label("100 / 100", 13, UiKit.PARCHMENT)
	bars.add_child(hp_text)
	mp_bar = UiKit.bar(UiKit.MP)
	mp_bar.custom_minimum_size = Vector2(210, 12)
	bars.add_child(mp_bar)
	mp_text = UiKit.label("40 / 40", 12, UiKit.PARCHMENT)
	bars.add_child(mp_text)
	energy_bar = UiKit.bar(UiKit.ENERGY)
	energy_bar.custom_minimum_size = Vector2(210, 12)
	bars.add_child(energy_bar)
	energy_text = UiKit.label("100 / 100", 12, UiKit.PARCHMENT)
	bars.add_child(energy_text)

	var footer: = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	column.add_child(footer)
	fame_label = UiKit.label("Fama 0 / 80", 13, UiKit.GOLD)
	footer.add_child(fame_label)
	coins_label = UiKit.label("0 bronze", 13, UiKit.PARCHMENT)
	footer.add_child(coins_label)

	state_label = UiKit.label("", 13, UiKit.BAD)
	state_label.position = Vector2(20, 132)
	hud.add_child(state_label)


	var minimap_panel: = PanelContainer.new()
	minimap_panel.anchor_left = 1.0
	minimap_panel.anchor_right = 1.0
	minimap_panel.offset_left = - MINIMAP_SIZE - 26
	minimap_panel.offset_right = -16
	minimap_panel.offset_top = 14
	minimap_panel.offset_bottom = 14 + MINIMAP_SIZE * 0.78 + 58
	UiKit.apply_panel(minimap_panel, Color(0.09, 0.07, 0.06, 0.9))
	hud.add_child(minimap_panel)
	var minimap_box: = VBoxContainer.new()
	minimap_box.add_theme_constant_override("separation", 4)
	minimap_panel.add_child(minimap_box)
	region_label = UiKit.label("Vale de Aurora", 13, UiKit.GOLD)
	region_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_box.add_child(region_label)
	minimap = MinimapView.new()
	minimap.custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE * 0.72)
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_box.add_child(minimap)
	clock_label = UiKit.label("Manhã", 12, UiKit.MUTED)
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_box.add_child(clock_label)


	var hotbar: = HBoxContainer.new()
	hotbar.add_theme_constant_override("separation", 6)
	hotbar.anchor_left = 0.5
	hotbar.anchor_right = 0.5
	hotbar.anchor_top = 1.0
	hotbar.anchor_bottom = 1.0
	hotbar.offset_left = -320
	hotbar.offset_right = 320
	hotbar.offset_top = -86
	hotbar.offset_bottom = -18
	hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	hud.add_child(hotbar)
	for index in 10:
		hotbar.add_child(_build_slot(index))


	interact_label = UiKit.label("", 16, UiKit.GOLD)
	interact_label.anchor_left = 0.5
	interact_label.anchor_right = 0.5
	interact_label.anchor_top = 1.0
	interact_label.anchor_bottom = 1.0
	interact_label.offset_left = -300
	interact_label.offset_right = 300
	interact_label.offset_top = -124
	interact_label.offset_bottom = -98
	interact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_child(interact_label)


	cast_bar = UiKit.bar(Color(0.55, 0.8, 1.0), 12)
	cast_bar.anchor_left = 0.5
	cast_bar.anchor_right = 0.5
	cast_bar.anchor_top = 1.0
	cast_bar.anchor_bottom = 1.0
	cast_bar.offset_left = -150
	cast_bar.offset_right = 150
	cast_bar.offset_top = -140
	cast_bar.offset_bottom = -128
	cast_bar.visible = false
	hud.add_child(cast_bar)


	boss_panel = PanelContainer.new()
	boss_panel.anchor_left = 0.5
	boss_panel.anchor_right = 0.5
	boss_panel.offset_left = -260
	boss_panel.offset_right = 260
	boss_panel.offset_top = 16
	boss_panel.offset_bottom = 78
	boss_panel.visible = false
	UiKit.apply_panel(boss_panel, Color(0.1, 0.06, 0.06, 0.92), Color(0.6, 0.2, 0.18))
	hud.add_child(boss_panel)
	var boss_box: = VBoxContainer.new()
	boss_panel.add_child(boss_box)
	boss_name = UiKit.title("Colossal de Granito", 20, Color(0.95, 0.8, 0.6))
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_box.add_child(boss_name)
	boss_bar = UiKit.bar(Color(0.7, 0.2, 0.18), 16)
	boss_box.add_child(boss_bar)


	toasts = VBoxContainer.new()
	toasts.anchor_left = 0.5
	toasts.anchor_right = 0.5
	toasts.anchor_top = 1.0
	toasts.anchor_bottom = 1.0
	toasts.offset_left = -280
	toasts.offset_right = 280
	toasts.offset_top = -286
	toasts.offset_bottom = -140
	toasts.alignment = BoxContainer.ALIGNMENT_END
	toasts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toasts.add_theme_constant_override("separation", 2)
	hud.add_child(toasts)


func _build_slot(index: int) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(58, 58)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	UiKit.apply_panel(panel, Color(0.1, 0.08, 0.07, 0.92), Color(0.35, 0.3, 0.22))
	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 0)
	panel.add_child(box)
	var key: Label = UiKit.label(str((index + 1) % 10), 11, UiKit.MUTED)
	key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(key)
	var icon: Control = SkillArt.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(icon)
	var cooldown: ColorRect = ColorRect.new()
	cooldown.color = Color(0.02, 0.02, 0.04, 0.72)
	cooldown.anchor_right = 1.0
	cooldown.anchor_bottom = 1.0
	cooldown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(cooldown)
	var cd_label: Label = UiKit.label("", 14, UiKit.PARCHMENT)
	cd_label.anchor_right = 1.0
	cd_label.anchor_bottom = 1.0
	cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cd_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(cd_label)
	var hover: Node = SkillHover.new()
	panel.add_child(hover)
	hotbar_slots.append({"panel": panel, "key": key, "icon": icon, "hover": hover, "cooldown": cooldown, "label": cd_label})
	return panel


func refresh(state: PlayerState, world: WorldView, hero: Hero, interaction: Dictionary) -> void :
	if state == null or hero == null:
		return
	name_label.text = state.hero_name
	level_label.text = "Nv %d" % state.level
	grade_label.text = UiKit.grade_name(state.level)
	fame_label.text = "Fama %d / %d" % [int(state.fame), int(state.fame_cap())]
	coins_label.text = UiKit.money_text(state.coins)
	hp_bar.max_value = hero.max_hp
	hp_bar.value = hero.hp
	hp_text.text = "%d / %d" % [int(hero.hp), int(hero.max_hp)]
	mp_bar.max_value = state.max_mp()
	mp_bar.value = hero.mp
	mp_text.text = "%d / %d" % [int(hero.mp), int(state.max_mp())]
	energy_bar.max_value = state.max_energy()
	energy_bar.value = hero.energy
	energy_text.text = "%d / %d" % [int(hero.energy), int(state.max_energy())]
	state_label.text = "EXAUSTÃO" if hero.exhaust > 0.0 else ""
	if hero.blocking:
		state_label.text = "GUARDA"
	if world != null:
		region_label.text = world.region.zone_name(world.region.zone_at(hero.global_position))
		clock_label.text = _clock_text(world)
		minimap.queue_redraw()
		if world.boss != null and is_instance_valid(world.boss):
			boss_panel.visible = true
			boss_name.text = world.boss.display_name()
			boss_bar.max_value = world.boss.max_hp
			boss_bar.value = world.boss.hp
		else:
			boss_panel.visible = false
	if not hero.casting_skill.is_empty():
		cast_bar.visible = true
		cast_bar.max_value = hero.casting_total
		cast_bar.value = hero.casting_total - hero.casting_time
	else:
		cast_bar.visible = false
	if interaction.is_empty():
		interact_label.text = ""
	else:
		interact_label.text = "[E] %s" % str(interaction.get("label", ""))
	_update_hotbar(state, hero)


func _update_hotbar(state: PlayerState, hero: Hero) -> void:
	for index in hotbar_slots.size():
		var slot: Dictionary = hotbar_slots[index]
		var skill_id: String = str(state.hotbar[index]) if index < state.hotbar.size() else ""
		var icon: Control = slot["icon"]
		var cooldown: ColorRect = slot["cooldown"]
		var label: Label = slot["label"]
		var definition: Dictionary = SkillCatalog.definition(state.class_id, skill_id)
		icon.definition = definition
		icon.learned = SkillCatalog.is_learned(state, definition)
		slot["hover"].configure(state, definition)
		if definition.is_empty():
			cooldown.visible = false
			label.text = ""
			continue
		var ratio: float = hero.cooldown_ratio(skill_id)
		cooldown.visible = ratio > 0.01
		cooldown.anchor_top = 0.0
		cooldown.anchor_bottom = 1.0 - ratio
		cooldown.offset_top = 0
		cooldown.offset_bottom = 0
		var remaining: float = float(hero.cooldowns.get(skill_id, 0.0))
		label.text = ("%.1f" % remaining) if remaining > 0.05 else ""


func _glyph_for(skill_id: String) -> String:
	var codes: = {
		"tiro_preciso": "TP", "disparo_leque": "DL", "flecha_contencao": "FC", "chuva_flechas": "CH", 
		"projetil_arcano": "PA", "campo_gelido": "CG", "passo_arcano": "PS", "cometa_arcano": "CO", 
		"talho_circular": "TC", "quebra_guarda": "QG", "investida": "IN", "golpe_ruptura": "GR", 
		"corte_duplo": "CD", "adaga_arremesso": "AA", "passo_sombrio": "SO", "execucao": "EX", 
		"pancada_escudo": "PE", "abalo_sismico": "AS", "bastiao": "BA", "revanche_ferro": "RF", 
		"estocada": "ES", "selo_desafio": "SD", "carga_real": "CR", "estandarte_real": "ER", 
		"explosao_aura": "EA", "despertar_heroico": "DH", 
	}
	return str(codes.get(skill_id, "SK"))

func _clock_text(world: WorldView) -> String:
	var time: float = world.state.time_of_day
	var hour: = int(floor(time * 24.0))
	var phase: = "Manhã"
	if hour >= 12 and hour < 18:
		phase = "Tarde"
	elif hour >= 18 and hour < 23:
		phase = "Noite"
	elif hour >= 23 or hour < 5:
		phase = "Madrugada"
	return "%s · %02d:%02d · Dia %d" % [phase, hour, int((time * 24.0 - hour) * 60.0), world.state.day_count]


func toast(text: String, color: Color = UiKit.PARCHMENT) -> void :
	var panel: = PanelContainer.new()
	UiKit.apply_panel(panel, Color(0.07, 0.06, 0.05, 0.85), Color(0.35, 0.3, 0.2))
	var label: = UiKit.label(text, 15, color)
	panel.add_child(label)
	panel.modulate.a = 0.0
	toasts.add_child(panel)
	while toasts.get_child_count() > 6:
		var first: = toasts.get_child(0)
		toasts.remove_child(first)
		first.queue_free()
	var tween: = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.12)
	tween.tween_interval(2.6)
	tween.tween_property(panel, "modulate:a", 0.0, 0.4)
	tween.tween_callback( func() -> void :
		if is_instance_valid(panel):
			panel.queue_free()
	)


func set_playing(value: bool) -> void :
	hud.visible = value




func show_title(has_save: bool) -> void :
	close_modal()
	_clear_overlay()
	hud.visible = false
	var background: = TextureRect.new()
	if ResourceLoader.exists("res://assets/game/sprites/title_keyart.png"):
		background.texture = load("res://assets/game/sprites/title_keyart.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(background)

	var shade: = ColorRect.new()
	shade.color = Color(0.03, 0.03, 0.05, 0.45)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)

	var column: = VBoxContainer.new()
	column.anchor_left = 0.06
	column.anchor_right = 0.5
	column.anchor_top = 0.16
	column.anchor_bottom = 0.9
	column.add_theme_constant_override("separation", 10)
	overlay.add_child(column)

	var eyebrow: = UiKit.label("UM RPG DE AÇÃO NO REINO DE AURORA", 14, Color(0.85, 0.76, 0.55))
	column.add_child(eyebrow)
	var title_label: = UiKit.title("RPG do Reino", 62, Color(0.97, 0.9, 0.72))
	column.add_child(title_label)
	var subtitle: = UiKit.label("Escolha sua raça, sua classe e conquiste fama diante do Rei.", 18, Color(0.9, 0.88, 0.8))
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(460, 0)
	column.add_child(subtitle)
	column.add_child(UiKit.spacer(16))

	var start: = UiKit.button("Iniciar", Vector2(260, 46), true)
	start.pressed.connect( func() -> void :
		AudioDirector.unlock_audio()
		show_creation()
	)
	column.add_child(start)
	var continue_button: = UiKit.button("Continuar", Vector2(260, 42))
	continue_button.disabled = not has_save
	continue_button.pressed.connect( func() -> void :
		AudioDirector.unlock_audio()
		continue_requested.emit()
	)
	column.add_child(continue_button)
	var options: = UiKit.button("Opções", Vector2(260, 42))
	options.pressed.connect(show_options)
	column.add_child(options)
	var quit: = UiKit.button("Sair", Vector2(260, 42))
	quit.pressed.connect( func() -> void : quit_requested.emit())
	column.add_child(quit)

	var footer: = UiKit.label("WASD move · mouse ataca · 1–0 skills · E interage · R poção · I inventário · K skills · M mapa · Esc pausa", 13, Color(0.75, 0.72, 0.66))
	footer.anchor_top = 0.94
	footer.anchor_bottom = 0.98
	footer.anchor_left = 0.06
	footer.anchor_right = 0.94
	overlay.add_child(footer)




func show_creation() -> void :
	_clear_overlay()
	hud.visible = false
	var background: = ColorRect.new()
	background.color = Color(0.04, 0.04, 0.055, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(background)

	var margin: = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	overlay.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 20)
	column.add_child(header)
	header.add_child(UiKit.title("Criação de Personagem", 38))
	var back: = UiKit.button("Voltar", Vector2(120, 34))
	back.pressed.connect(show_title.bind(SaveGame.has_save()))
	header.add_child(back)

	var body: = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	column.add_child(body)


	var race_panel: = UiKit.panel()
	race_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(race_panel)
	var race_box: = VBoxContainer.new()
	race_box.add_theme_constant_override("separation", 8)
	race_panel.add_child(race_box)
	race_box.add_child(UiKit.title("Raça", 24))
	for race_id: String in GameData.RACE_ORDER:
		var race: Dictionary = GameData.RACES[race_id]
		var button: = UiKit.button(str(race["name"]), Vector2(0, 38), race_id == creation_race)
		button.pressed.connect(_select_race.bind(race_id))
		race_box.add_child(button)
		var info: = UiKit.label(str(race["bonus"]), 12, UiKit.MUTED)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		race_box.add_child(info)
	race_box.add_child(UiKit.spacer(6))
	var name_caption: = UiKit.label("Nome do herói", 14, UiKit.GOLD)
	race_box.add_child(name_caption)
	name_input = LineEdit.new()
	name_input.text = "Aurora" if name_input == null else name_input.text
	name_input.max_length = 14
	name_input.custom_minimum_size = Vector2(0, 40)
	name_input.add_theme_font_size_override("font_size", 16)
	name_input.add_theme_color_override("font_color", UiKit.PARCHMENT)
	name_input.add_theme_color_override("font_placeholder_color", Color(0.55, 0.5, 0.42))
	name_input.add_theme_color_override("caret_color", UiKit.GOLD)
	name_input.placeholder_text = "Aurora"
	var field: = StyleBoxFlat.new()
	field.bg_color = Color(0.08, 0.07, 0.06, 0.95)
	field.border_color = UiKit.GOLD_SOFT
	field.set_border_width_all(1)
	field.set_corner_radius_all(4)
	field.content_margin_left = 10
	field.content_margin_right = 10
	name_input.add_theme_stylebox_override("normal", field)
	var field_focus: = field.duplicate() as StyleBoxFlat
	field_focus.border_color = UiKit.GOLD
	name_input.add_theme_stylebox_override("focus", field_focus)
	race_box.add_child(name_input)


	var class_panel: = UiKit.panel()
	class_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	class_panel.size_flags_stretch_ratio = 1.6
	body.add_child(class_panel)
	var class_box: = VBoxContainer.new()
	class_box.add_theme_constant_override("separation", 6)
	class_panel.add_child(class_box)
	class_box.add_child(UiKit.title("Classe", 24))
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	class_box.add_child(grid)
	for class_id: String in GameData.CLASS_ORDER:
		var data: Dictionary = GameData.CLASSES[class_id]
		var button: = UiKit.button(str(data["name"]), Vector2(0, 36), class_id == creation_class)
		button.pressed.connect(_select_class.bind(class_id))
		grid.add_child(button)

	creation_preview = VBoxContainer.new()
	creation_preview.add_theme_constant_override("separation", 4)
	class_box.add_child(creation_preview)


	var start_row: = HBoxContainer.new()
	start_row.add_theme_constant_override("separation", 16)
	column.add_child(start_row)
	var start_button: = UiKit.button("Entrar no Reino", Vector2(280, 48), true)
	start_button.pressed.connect(_submit_creation)
	start_row.add_child(start_button)
	var hint: = UiKit.label("Dica: atacar pelas costas aumenta o dano. Use esquiva e dash para flanquear.", 13, UiKit.MUTED)
	start_row.add_child(hint)
	_refresh_creation_preview()


func _select_race(race_id: String) -> void :
	creation_race = race_id
	show_creation()


func _select_class(class_id: String) -> void :
	creation_class = class_id
	show_creation()


func _refresh_creation_preview() -> void :
	for child in creation_preview.get_children():
		child.queue_free()
	var data: Dictionary = GameData.CLASSES[creation_class]
	var race: Dictionary = GameData.RACES[creation_race]
	creation_preview.add_child(UiKit.divider())
	var preview_row: = HBoxContainer.new()
	preview_row.add_theme_constant_override("separation", 14)
	creation_preview.add_child(preview_row)
	var portrait: = TextureRect.new()
	var portrait_path: = _class_sprite_path(creation_class)
	if ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
	portrait.custom_minimum_size = Vector2(104, 132)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_row.add_child(portrait)
	var text_column: = VBoxContainer.new()
	text_column.add_theme_constant_override("separation", 3)
	preview_row.add_child(text_column)
	text_column.add_child(UiKit.label("%s — %s" % [str(data["name"]), str(data["role"])], 15, UiKit.GOLD))
	var description: = UiKit.label(str(data["desc"]), 13, UiKit.MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(420, 0)
	text_column.add_child(description)
	var base: Dictionary = data["base"]
	var hp_value: = float(base["hp"]) + float(race["hp"])
	text_column.add_child(UiKit.label(
		"HP %d   Mana %d   Energia %d   Dano %d   Defesa %d   Crítico %d%%" % [
			int(hp_value), int(base["mp"]), int(base["energy"]), int(base["damage"]), 
			int(base["defense"]), int(float(base["crit_phys"]) * 100.0)], 13))
	var skill_names: Array = []
	for skill: Dictionary in data["ativas"]:
		if int(skill["unlock"]) <= 1:
			skill_names.append(str(skill["name"]))
	for skill: Dictionary in data["passivas"]:
		if int(skill["unlock"]) <= 1:
			skill_names.append("(passiva) " + str(skill["name"]))
	var starts: = UiKit.label("Começa com: " + ", ".join(skill_names), 13, UiKit.PARCHMENT)
	starts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	starts.custom_minimum_size = Vector2(420, 0)
	text_column.add_child(starts)


func _class_sprite_path(class_id: String) -> String:
	match class_id:
		"atirador": return "res://assets/game/sprites/hero_archer.png"
		"mago": return "res://assets/game/sprites/hero_mage.png"
		"assassino": return "res://assets/game/sprites/hero_rogue.png"
		"tank": return "res://assets/game/sprites/hero_tank.png"
		"cavaleiro": return "res://assets/game/sprites/hero_knight.png"
		_: return "res://assets/game/sprites/hero_warrior.png"


func _submit_creation() -> void :
	var hero_name: = name_input.text if name_input != null else "Herói"
	AudioDirector.unlock_audio()
	new_game_requested.emit(creation_race, creation_class, hero_name)




func show_options() -> void :
	_clear_overlay()
	var background: = ColorRect.new()
	background.color = Color(0.03, 0.03, 0.045, 0.94)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(background)

	var panel: = UiKit.panel()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.05
	panel.anchor_bottom = 0.95
	panel.offset_left = -430
	panel.offset_right = 430
	overlay.add_child(panel)
	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	column.add_child(UiKit.title("Opções", 32))

	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var content: = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6)
	scroll.add_child(content)

	content.add_child(UiKit.label("Atalhos", 18, UiKit.GOLD))
	rebind_buttons.clear()
	for action: String in Controls.REBINDABLE:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		content.add_child(row)
		var caption: = UiKit.label(str(Controls.LABELS.get(action, action)), 15)
		caption.custom_minimum_size = Vector2(260, 0)
		row.add_child(caption)
		var button: = UiKit.button(Controls.describe(action, SaveGame.bindings), Vector2(220, 32))
		button.pressed.connect(_begin_rebind.bind(action))
		row.add_child(button)
		rebind_buttons[action] = button

	content.add_child(UiKit.spacer(8))
	content.add_child(UiKit.label("Vídeo e jogo", 18, UiKit.GOLD))
	var resolution_row: = HBoxContainer.new()
	resolution_row.add_theme_constant_override("separation", 10)
	content.add_child(resolution_row)
	var resolution_label: = UiKit.label("Resolução", 15)
	resolution_label.custom_minimum_size = Vector2(260, 0)
	resolution_row.add_child(resolution_label)
	var resolution_button: = UiKit.button("", Vector2(220, 32))
	resolution_button.text = "%d x %d" % [SaveGame.RESOLUTIONS[SaveGame.resolution_index].x, SaveGame.RESOLUTIONS[SaveGame.resolution_index].y]
	resolution_button.pressed.connect( func() -> void :
		SaveGame.resolution_index = (SaveGame.resolution_index + 1) % SaveGame.RESOLUTIONS.size()
		SaveGame.apply_display()
		SaveGame.save_settings()
		resolution_button.text = "%d x %d" % [SaveGame.RESOLUTIONS[SaveGame.resolution_index].x, SaveGame.RESOLUTIONS[SaveGame.resolution_index].y]
	)
	resolution_row.add_child(resolution_button)

	content.add_child(_toggle_row("Tela cheia", SaveGame.fullscreen, func(value: bool) -> void :
		SaveGame.fullscreen = value
		SaveGame.apply_display()
	))
	content.add_child(_toggle_row("Salvamento automático", SaveGame.autosave, func(value: bool) -> void :
		SaveGame.autosave = value
	))
	content.add_child(_toggle_row("Números de dano", SaveGame.show_damage, func(value: bool) -> void :
		SaveGame.show_damage = value
	))

	options_status = UiKit.label("", 13, UiKit.GOLD)
	column.add_child(options_status)
	var footer: = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	column.add_child(footer)
	var back: = UiKit.button("Salvar e voltar", Vector2(220, 42), true)
	back.pressed.connect(_close_options)
	footer.add_child(back)
	if current_panel == "options_in_game":
		var note: = UiKit.label("A partida continua pausada.", 13, UiKit.MUTED)
		footer.add_child(note)


func _toggle_row(caption: String, value: bool, on_change: Callable) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label: = UiKit.label(caption, 15)
	label.custom_minimum_size = Vector2(260, 0)
	row.add_child(label)
	var button: = UiKit.button("Ativado" if value else "Desativado", Vector2(220, 32), value)
	button.pressed.connect( func() -> void :
		var new_value: = not value
		on_change.call(new_value)
		button.text = "Ativado" if new_value else "Desativado"
		AudioDirector.play_cue("ui.confirm")
	)
	row.add_child(button)
	return row


func _begin_rebind(action: String) -> void :
	rebind_action = action
	if options_status != null:
		options_status.text = "Pressione a nova tecla para %s" % str(Controls.LABELS.get(action, action))


func _close_options() -> void :
	rebind_action = ""
	SaveGame.save_settings()
	options_changed.emit()
	if current_panel == "options_in_game":
		show_pause_panel()
	else:
		show_title(SaveGame.has_save())


func _input(event: InputEvent) -> void :
	if rebind_action.is_empty():
		return
	var binding: = Controls.event_to_binding(event)
	if binding.is_empty():
		return
	SaveGame.bindings[rebind_action] = [binding]
	SaveGame.save_settings()
	Controls.apply(SaveGame.bindings)
	if rebind_buttons.has(rebind_action):
		var button: Button = rebind_buttons[rebind_action]
		button.text = Controls.describe(rebind_action, SaveGame.bindings)
	if options_status != null:
		options_status.text = "Atalho atualizado."
	rebind_action = ""
	get_viewport().set_input_as_handled()




func show_death(info: Dictionary) -> void :
	close_modal()
	_clear_overlay()
	var shade: = ColorRect.new()
	shade.color = Color(0.12, 0.02, 0.02, 0.72)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var panel: = UiKit.panel()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.32
	panel.anchor_bottom = 0.78
	panel.offset_left = -300
	panel.offset_right = 300
	overlay.add_child(panel)
	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	column.add_child(UiKit.title("Você desmaiou", 38, Color(0.95, 0.7, 0.55)))
	var body: = UiKit.label(str(info.get("text", "")), 15, UiKit.PARCHMENT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(body)
	column.add_child(UiKit.spacer(8))
	var button: = UiKit.button("Voltar à estátua", Vector2(280, 46), true)
	button.pressed.connect( func() -> void : panel_action.emit("respawn", {}))
	column.add_child(button)


func show_victory(info: Dictionary) -> void :
	close_modal()
	_clear_overlay()
	var shade: = ColorRect.new()
	shade.color = Color(0.04, 0.05, 0.09, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var panel: = UiKit.panel()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.26
	panel.anchor_bottom = 0.82
	panel.offset_left = -330
	panel.offset_right = 330
	overlay.add_child(panel)
	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	column.add_child(UiKit.title("O Colossal caiu", 40, Color(0.98, 0.9, 0.6)))
	var body: = UiKit.label(str(info.get("text", "")), 15, UiKit.PARCHMENT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(body)
	column.add_child(UiKit.spacer(6))
	var button: = UiKit.button("Continuar no reino", Vector2(300, 46), true)
	button.pressed.connect( func() -> void : panel_action.emit("continue_after_boss", {}))
	column.add_child(button)


func _clear_overlay() -> void :
	for child in overlay.get_children():
		child.queue_free()


func close_overlay() -> void :
	_clear_overlay()




class MinimapView extends Control:
	var world: WorldView

	func _draw() -> void :
		if world == null or world.region == null:
			return
		var scale_x: = size.x / float(RegionMap.W)
		var scale_y: = size.y / float(RegionMap.H)
		var colors: = {
			RegionMap.GRASS: Color(0.22, 0.32, 0.18), 
			RegionMap.DIRT: Color(0.38, 0.31, 0.22), 
			RegionMap.STONE: Color(0.36, 0.35, 0.33), 
			RegionMap.GRAVEL: Color(0.42, 0.39, 0.34), 
			RegionMap.WATER: Color(0.16, 0.28, 0.42), 
			RegionMap.CLIFF: Color(0.15, 0.14, 0.14), 
			RegionMap.SANCT: Color(0.22, 0.22, 0.3), 
			RegionMap.DARK: Color(0.16, 0.24, 0.14), 
		}
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.04, 0.05))
		for y in range(0, RegionMap.H, 1):
			for x in range(0, RegionMap.W, 1):
				var value: int = world.region.tile_at(x, y)
				var color: Color = colors.get(value, Color(0.2, 0.2, 0.2))
				draw_rect(Rect2(x * scale_x, y * scale_y, scale_x + 0.6, scale_y + 0.6), color)
		for enemy in world.enemies_alive():
			var position: = Vector2(enemy.global_position.x / Balance.TILE * scale_x, enemy.global_position.y / Balance.TILE * scale_y)
			var tint: = Color(0.9, 0.35, 0.3)
			if enemy.kind == "errante":
				tint = Color(0.8, 0.5, 0.95)
			elif enemy.is_miniboss():
				tint = Color(1.0, 0.75, 0.3)
			draw_circle(position, 2.4 if not enemy.is_miniboss() else 3.6, tint)
		var hero = world.hero
		if hero != null:
			var marker: = Vector2(hero.global_position.x / Balance.TILE * scale_x, hero.global_position.y / Balance.TILE * scale_y)
			draw_circle(marker, 5.2, Color(0.95, 0.92, 0.8))
			draw_circle(marker, 3.2, Color(0.35, 0.6, 0.95))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.55, 0.45, 0.25, 0.6), false, 1.0)




var state: PlayerState
var world: WorldView


func attach(player_state: PlayerState, world_view: WorldView) -> void :
	state = player_state
	world = world_view
	if minimap is MinimapView:
		(minimap as MinimapView).world = world_view


func open_modal(caption: String, panel_size: Vector2 = Vector2(900, 570)) -> VBoxContainer:
	modal_layer.visible = true
	for child in modal_layer.get_children():
		child.queue_free()
	var shade: = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.03, 0.62)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.add_child(shade)
	var panel: = UiKit.panel()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = - panel_size.x * 0.5
	panel.offset_right = panel_size.x * 0.5
	panel.offset_top = - panel_size.y * 0.5
	panel.offset_bottom = panel_size.y * 0.5
	modal_layer.add_child(panel)
	var outer: = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)
	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	outer.add_child(header)
	header.add_child(UiKit.title(caption, 28))
	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var close: = UiKit.button("Fechar", Vector2(110, 32))
	close.pressed.connect( func() -> void : panel_action.emit("close_panel", {}))
	header.add_child(close)
	outer.add_child(UiKit.divider())
	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(scroll)
	var content: = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)
	return content


func close_modal() -> void :
	current_panel = ""
	modal_layer.visible = false
	for child in modal_layer.get_children():
		child.queue_free()


func show_pause_panel() -> void :
	current_panel = "pause"
	var content: = open_modal("Pausa", Vector2(520, 470))
	content.add_child(UiKit.label("O vale espera por você.", 15, UiKit.MUTED))
	content.add_child(UiKit.spacer(8))
	var resume: = UiKit.button("Continuar", Vector2(0, 46), true)
	resume.pressed.connect( func() -> void : panel_action.emit("resume", {}))
	content.add_child(resume)
	var save: = UiKit.button("Salvar no local atual", Vector2(0, 40))
	save.pressed.connect( func() -> void : panel_action.emit("save", {}))
	content.add_child(save)
	var options: = UiKit.button("Opções", Vector2(0, 40))
	options.pressed.connect( func() -> void :
		current_panel = "options_in_game"
		show_options()
	)
	content.add_child(options)
	var inventory: = UiKit.button("Inventário", Vector2(0, 40))
	inventory.pressed.connect( func() -> void : panel_action.emit("open_inventory", {}))
	content.add_child(inventory)
	var skills: = UiKit.button("Skills", Vector2(0, 40))
	skills.pressed.connect( func() -> void : panel_action.emit("open_skills", {}))
	content.add_child(skills)
	var quit: = UiKit.button("Sair para o menu principal", Vector2(0, 40))
	quit.pressed.connect( func() -> void : panel_action.emit("to_title", {}))
	content.add_child(quit)


func show_inventory_panel() -> void:
	var item_id: String = ""
	var equip_slot: String = ""
	var scroll_y: int = 0
	if is_instance_valid(inventory_view) and not inventory_view.is_queued_for_deletion():
		item_id = inventory_view.selected_id
		equip_slot = inventory_view.selected_slot
		scroll_y = inventory_view.bag_scroll.scroll_vertical
	current_panel = "inventory"
	modal_layer.visible = true
	for child in modal_layer.get_children():
		modal_layer.remove_child(child)
		child.queue_free()
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.015, 0.01, 0.008, 0.8)
	modal_layer.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventory_view = InventoryPanelView.new()
	inventory_view.configure(state, item_id, equip_slot, scroll_y)
	inventory_view.action_requested.connect(func(action: String, payload: Dictionary) -> void:
		panel_action.emit(action, payload)
	)
	modal_layer.add_child(inventory_view)


func show_skills_panel(tab: String = "") -> void:
	var selection: String = ""
	var scroll_y: int = 0
	if current_panel == "skills" and is_instance_valid(skills_view) and not skills_view.is_queued_for_deletion():
		if tab.is_empty() or tab == skills_view.active_tab:
			selection = skills_view.selected_id
			scroll_y = skills_view.skill_scroll.scroll_vertical
		if tab.is_empty():
			tab = skills_view.active_tab
	if tab.is_empty():
		tab = "ativas"
	current_panel = "skills"
	modal_layer.visible = true
	for child in modal_layer.get_children():
		modal_layer.remove_child(child)
		child.queue_free()
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.015, 0.01, 0.008, 0.8)
	modal_layer.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	skills_view = SkillsPanelView.new()
	skills_view.configure(state, tab, selection, scroll_y)
	skills_view.action_requested.connect(func(action: String, payload: Dictionary) -> void:
		panel_action.emit(action, payload)
	)
	modal_layer.add_child(skills_view)


func show_region_map() -> void :
	current_panel = "map_region"
	var content: = open_modal("Mapa da Região — %s" % GameData.REGION_NAME, Vector2(920, 600))
	var map: = RegionMapView.new()
	map.world = world
	map.custom_minimum_size = Vector2(860, 430)
	content.add_child(map)
	var legend: = UiKit.label("Esfera azul: você · Vermelho: monstros · Roxo: errantes · Dourado: miniboss e Colossal", 13, UiKit.MUTED)
	content.add_child(legend)


func show_world_map() -> void :
	current_panel = "map_world"
	var content: = open_modal("Mapa do Reino", Vector2(960, 620))
	content.add_child(UiKit.label("Nove regiões guardam nove Colossais. O décimo espera no mar.", 14, UiKit.MUTED))
	var grid: = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	for entry: Dictionary in GameData.REGIONS:
		var card: = PanelContainer.new()
		UiKit.apply_panel(card, Color(0.12, 0.1, 0.08, 0.92) if bool(entry["open"]) else Color(0.07, 0.07, 0.075, 0.9), 
			UiKit.GOLD if bool(entry["open"]) else Color(0.25, 0.24, 0.22))
		card.custom_minimum_size = Vector2(280, 120)
		grid.add_child(card)
		var box: = VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		card.add_child(box)
		box.add_child(UiKit.label(str(entry["name"]), 17, UiKit.GOLD if bool(entry["open"]) else Color(0.5, 0.48, 0.44)))
		var description: = UiKit.label(str(entry["desc"]), 12, UiKit.MUTED)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.custom_minimum_size = Vector2(250, 0)
		box.add_child(description)
		if not bool(entry["open"]):
			box.add_child(UiKit.label("Selo não descoberto", 12, UiKit.BAD))


func show_forge_panel() -> void :
	current_panel = "forge"
	var content: = open_modal("Forja da Cidade", Vector2(900, 600))
	content.add_child(UiKit.label("O ferreiro cobra moedas pelo trabalho. Forjar pode falhar; anões têm mais sorte.", 13, UiKit.MUTED))
	content.add_child(UiKit.divider())
	content.add_child(UiKit.label("Reparo", 17, UiKit.GOLD))
	var cost: = state.repair_cost()
	var durability_text: = "Durabilidade média: %d%%" % int(state.durability_ratio() * 100.0)
	content.add_child(UiKit.label(durability_text, 14))
	if cost > 0:
		var repair: = UiKit.button("Reparar equipamento — %s" % UiKit.money_text(cost), Vector2(0, 34))
		repair.pressed.connect( func() -> void : panel_action.emit("repair", {}))
		content.add_child(repair)
	else:
		content.add_child(UiKit.label("Equipamento em bom estado.", 13, UiKit.GOOD))
	content.add_child(UiKit.divider())
	content.add_child(UiKit.label("Receitas", 17, UiKit.GOLD))
	for recipe: Dictionary in GameData.RECIPES:
		content.add_child(_recipe_row(recipe))


func _recipe_row(recipe: Dictionary) -> Control:
	var panel: = PanelContainer.new()
	UiKit.apply_panel(panel, Color(0.13, 0.11, 0.085, 0.9), Color(0.3, 0.26, 0.19))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var info: = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(UiKit.label(str(recipe["name"]), 16, UiKit.GOLD))
	var materials: Dictionary = recipe["materials"]
	var parts: Array = []
	var affordable: = true
	for item_id: String in materials.keys():
		var needed: = int(materials[item_id])
		var owned: = state.count_item(item_id)
		if owned < needed:
			affordable = false
		parts.append("%s %d/%d" % [GameData.item_short_name(item_id), owned, needed])
	var line: = UiKit.label(" · ".join(parts), 13, UiKit.PARCHMENT if affordable else UiKit.BAD)
	info.add_child(line)
	var chance: = int(round(float(recipe.get("chance", 0.9)) * 100.0 + float(state.race()["craft_bonus"]) * 100.0))
	info.add_child(UiKit.label("Custo %s · chance de sucesso %d%%" % [UiKit.money_text(state.price(int(recipe.get("cost", 0)))), mini(100, chance)], 12, UiKit.MUTED))
	var craft: = UiKit.button("Forjar", Vector2(120, 32), affordable and state.coins >= state.price(int(recipe.get("cost", 0))))
	craft.pressed.connect( func() -> void : panel_action.emit("craft", {"id": str(recipe["id"])}))
	row.add_child(craft)
	return panel


func show_board_panel() -> void :
	current_panel = "board"
	var content: = open_modal("Mural de Contratos", Vector2(920, 600))
	content.add_child(UiKit.label("Contratos elevam a fama. Habilidades de classe exigem a missão do mestre.", 13, UiKit.MUTED))
	content.add_child(UiKit.divider())
	for contract: Dictionary in GameData.CONTRACTS:
		var contract_id: = str(contract["id"])
		var entry: Dictionary = state.contract_state(contract_id)
		var panel: = PanelContainer.new()
		UiKit.apply_panel(panel, Color(0.13, 0.11, 0.085, 0.9), Color(0.3, 0.26, 0.19))
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		panel.add_child(row)
		var info: = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		info.add_child(UiKit.label("%s — %s" % [str(contract["name"]), str(contract["difficulty"])], 16, UiKit.GOLD))
		var description: = UiKit.label(str(contract["desc"]), 13, UiKit.PARCHMENT)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.custom_minimum_size = Vector2(520, 0)
		info.add_child(description)
		info.add_child(UiKit.label("Recompensa: %.1f de fama · %s · %d XP" % [
			float(contract["fame"]), UiKit.money_text(int(contract["coins"])), int(contract["xp"])], 12, UiKit.MUTED))
		if not entry.is_empty():
			info.add_child(UiKit.label("Progresso: %d / %d" % [int(entry.get("progress", 0)), int(contract["count"])], 13, 
				UiKit.GOOD if bool(entry.get("done", false)) else UiKit.PARCHMENT))
		var action: Button
		if entry.is_empty():
			var available: = state.accepts_contract(contract_id)
			action = UiKit.button("Aceitar" if available else "Indisponível", Vector2(140, 32), available)
			action.disabled = not available
			action.pressed.connect( func() -> void : panel_action.emit("accept_contract", {"id": contract_id}))
		elif bool(entry.get("done", false)) and not bool(entry.get("claimed", false)):
			action = UiKit.button("Entregar", Vector2(140, 32), true)
			action.pressed.connect( func() -> void : panel_action.emit("claim_contract", {"id": contract_id}))
		elif bool(entry.get("claimed", false)):
			action = UiKit.button("Concluído", Vector2(140, 32))
			action.disabled = true
		else:
			action = UiKit.button("Em andamento", Vector2(140, 32))
			action.disabled = true
		row.add_child(action)
		content.add_child(panel)


func show_chest_panel() -> void :
	current_panel = "chest"
	var content: = open_modal("Baú da Cidade", Vector2(900, 600))
	var columns: = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	content.add_child(columns)
	var left: = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(left)
	left.add_child(UiKit.label("Mochila", 17, UiKit.GOLD))
	if state.inventory.is_empty():
		left.add_child(UiKit.label("Nada para guardar.", 13, UiKit.MUTED))
	for entry: Dictionary in state.inventory:
		var item_id: = str(entry.get("id", ""))
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		left.add_child(row)
		var caption: = UiKit.label("%s x%d" % [GameData.item_short_name(item_id), int(entry.get("qty", 1))], 14)
		caption.custom_minimum_size = Vector2(220, 0)
		row.add_child(caption)
		var store: = UiKit.button("Guardar", Vector2(96, 26))
		store.pressed.connect( func() -> void : panel_action.emit("store", {"id": item_id}))
		row.add_child(store)
	var right: = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(right)
	right.add_child(UiKit.label("Guardado no baú", 17, UiKit.GOLD))
	if state.stored.is_empty():
		right.add_child(UiKit.label("O baú está vazio.", 13, UiKit.MUTED))
	for entry: Dictionary in state.stored:
		var item_id: = str(entry.get("id", ""))
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		right.add_child(row)
		var caption: = UiKit.label("%s x%d" % [GameData.item_short_name(item_id), int(entry.get("qty", 1))], 14)
		caption.custom_minimum_size = Vector2(220, 0)
		row.add_child(caption)
		var retrieve: = UiKit.button("Retirar", Vector2(96, 26))
		retrieve.pressed.connect( func() -> void : panel_action.emit("retrieve", {"id": item_id}))
		row.add_child(retrieve)


func show_statue_panel() -> void :
	current_panel = "statue"
	var content: = open_modal("Estátua de Save", Vector2(620, 470))
	content.add_child(UiKit.label("O cristal guarda sua história. Aqui você salva manualmente e descansa.", 14, UiKit.MUTED))
	content.add_child(UiKit.label("Nível %d · %s · Fama %d/%d" % [state.level, UiKit.grade_name(state.level), int(state.fame), int(state.fame_cap())], 15))
	content.add_child(UiKit.spacer(6))
	var save: = UiKit.button("Salvar o jogo", Vector2(0, 44), true)
	save.pressed.connect( func() -> void : panel_action.emit("save", {}))
	content.add_child(save)
	var rest: = UiKit.button("Descansar (recupera HP, mana e energia)", Vector2(0, 40))
	rest.pressed.connect( func() -> void : panel_action.emit("rest", {}))
	content.add_child(rest)
	var title_button: = UiKit.button("Voltar ao menu principal", Vector2(0, 36))
	title_button.pressed.connect( func() -> void : panel_action.emit("to_title", {}))
	content.add_child(title_button)


func show_blessings_panel() -> void :
	current_panel = "blessings"
	var content: = open_modal("Bênçãos", Vector2(680, 520))
	content.add_child(UiKit.label("O sacerdote cobra moedas pela bênção do santuário.", 14, UiKit.MUTED))
	var blessings: = [
		{"kind": "vigor", "name": "Bênção do Vigor", "desc": "Cura totalmente e restaura mana e energia.", "cost": 90}, 
		{"kind": "furia", "name": "Bênção da Fúria", "desc": "+20% de dano por 3 minutos.", "cost": 160}, 
		{"kind": "fortuna", "name": "Bênção da Fortuna", "desc": "+25% de moedas por 3 minutos.", "cost": 140}, 
	]
	for blessing: Dictionary in blessings:
		var panel: = PanelContainer.new()
		UiKit.apply_panel(panel, Color(0.13, 0.11, 0.085, 0.9), Color(0.3, 0.26, 0.19))
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		panel.add_child(row)
		var info: = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		info.add_child(UiKit.label(str(blessing["name"]), 16, UiKit.GOLD))
		info.add_child(UiKit.label(str(blessing["desc"]), 13, UiKit.PARCHMENT))
		var cost: = state.price(int(blessing["cost"]))
		info.add_child(UiKit.label("Custo: %s" % UiKit.money_text(cost), 12, UiKit.MUTED))
		var buy: = UiKit.button("Receber", Vector2(120, 32), state.coins >= cost)
		buy.pressed.connect( func() -> void : panel_action.emit("bless", {"kind": str(blessing["kind"])}))
		row.add_child(buy)
		content.add_child(panel)


func show_teleport_panel() -> void :
	current_panel = "teleport"
	var content: = open_modal("Círculo de Teleporte", Vector2(660, 460))
	var unlocked: = bool(state.flags.get("teleport_unlocked", false))
	if not unlocked:
		content.add_child(UiKit.label("O mestre exige uma missão especial antes de abrir o círculo.", 14, UiKit.MUTED))
		var cost: = state.price(400)
		var button: = UiKit.button("Pagar a liberação — %s" % UiKit.money_text(cost), Vector2(0, 40), true)
		button.pressed.connect( func() -> void : panel_action.emit("unlock_teleport", {}))
		content.add_child(button)
		return
	if state.hostility > 50.0:
		content.add_child(UiKit.label("Serviço suspenso: a região está hostil.", 15, UiKit.BAD))
		content.add_child(UiKit.label("Cace os monstros errantes para reduzir a hostilidade.", 13, UiKit.MUTED))
		return
	content.add_child(UiKit.label("Hostilidade: %d%% · Custo por salto: %s" % [int(state.hostility), UiKit.money_text(state.price(30))], 14, UiKit.MUTED))
	var city: = UiKit.button("Viajar para a estátua de Aurora", Vector2(0, 42), true)
	city.pressed.connect( func() -> void : panel_action.emit("teleport_city", {}))
	content.add_child(city)


func show_master_panel() -> void :
	current_panel = "master"
	var content: = open_modal("Mestra da Guilda", Vector2(720, 540))
	var class_name_text: = str(state.class_data()["name"])
	content.add_child(UiKit.label("Classe: %s · Nível %d · %s" % [class_name_text, state.level, UiKit.grade_name(state.level)], 15, UiKit.GOLD))
	content.add_child(UiKit.label(str(GameData.CLASS_QUEST["desc"]), 14))
	content.add_child(UiKit.label("Missão de classe: %s" % ("concluída" if bool(state.flags.get("class_quest_done", false)) else "pendente"), 14, 
		UiKit.GOOD if bool(state.flags.get("class_quest_done", false)) else UiKit.BAD))
	content.add_child(UiKit.divider())
	content.add_child(UiKit.label("Evoluções da classe", 17, UiKit.GOLD))
	var actives: Array = state.class_data()["ativas"]
	var passives: Array = state.class_data()["passivas"]
	var rows: = [
		{"level": 20, "skill": str(actives[2]["name"]), "kind": "ativa", "requirement": "Nível 20 + missão de classe"}, 
		{"level": 40, "skill": str(passives[1]["name"]), "kind": "passiva", "requirement": "Nível 40"}, 
		{"level": 60, "skill": str(actives[3]["name"]), "kind": "ativa", "requirement": "Nível 60"}, 
	]
	for row_data: Dictionary in rows:
		var unlocked: = state.level >= int(row_data["level"])
		content.add_child(UiKit.label("Nv %d — %s (%s)" % [int(row_data["level"]), str(row_data["skill"]), str(row_data["kind"])], 14, 
			UiKit.PARCHMENT if unlocked else UiKit.MUTED))
		if not unlocked:
			content.add_child(UiKit.label("Requer: %s" % str(row_data["requirement"]), 12, UiKit.MUTED))
	if state.level >= 20 and bool(state.flags.get("class_quest_done", false)):
		var claim: = UiKit.button("Receber a terceira skill da classe", Vector2(0, 40), true)
		claim.pressed.connect( func() -> void : panel_action.emit("claim_class_skill", {}))
		content.add_child(claim)


class RegionMapView extends Control:
	var world: WorldView

	func _draw() -> void :
		if world == null:
			return
		var region: RegionMap = world.region
		var scale_x: = size.x / float(RegionMap.W)
		var scale_y: = size.y / float(RegionMap.H)
		var colors: = {
			RegionMap.GRASS: Color(0.22, 0.32, 0.18), 
			RegionMap.DIRT: Color(0.4, 0.32, 0.22), 
			RegionMap.STONE: Color(0.38, 0.37, 0.34), 
			RegionMap.GRAVEL: Color(0.44, 0.41, 0.35), 
			RegionMap.WATER: Color(0.16, 0.3, 0.45), 
			RegionMap.CLIFF: Color(0.13, 0.13, 0.14), 
			RegionMap.SANCT: Color(0.24, 0.24, 0.34), 
			RegionMap.DARK: Color(0.15, 0.23, 0.13), 
		}
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.05, 0.06))
		for y in RegionMap.H:
			for x in RegionMap.W:
				var value: = region.tile_at(x, y)
				draw_rect(Rect2(x * scale_x, y * scale_y, scale_x + 0.8, scale_y + 0.8), colors.get(value, Color(0.2, 0.2, 0.2)))
		for prop: Dictionary in region.props:
			if str(prop["kind"]) == "cristal":
				continue
			var tile: Vector2i = prop["tile"]
			var point: = Vector2(tile.x * scale_x, tile.y * scale_y)
			draw_circle(point, 4.0, Color(0.9, 0.8, 0.45))
		for enemy in world.enemies_alive():
			var point: = Vector2(enemy.global_position.x / Balance.TILE * scale_x, enemy.global_position.y / Balance.TILE * scale_y)
			var tint: = Color(0.9, 0.35, 0.3)
			if enemy.kind == "errante":
				tint = Color(0.8, 0.5, 0.95)
			elif enemy.is_miniboss():
				tint = Color(1.0, 0.8, 0.3)
			draw_circle(point, 3.0 if not enemy.is_miniboss() else 5.0, tint)
		if world.hero != null:
			var marker: = Vector2(world.hero.global_position.x / Balance.TILE * scale_x, world.hero.global_position.y / Balance.TILE * scale_y)
			draw_circle(marker, 6.0, Color(0.95, 0.92, 0.8))
			draw_circle(marker, 4.0, Color(0.35, 0.6, 0.95))
