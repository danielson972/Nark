extends SceneTree
## One-time scene authoring utility. The game loads the saved scene directly.
const Kit = preload("res://scripts/ui/rpg_panel_theme.gd")
const Catalog = preload("res://scripts/ui/skill_catalog.gd")
const Icon = preload("res://scripts/ui/skill_icon.gd")
var panel: PanelContainer

func _initialize() -> void:
	call_deferred("_run")

func node(parent: Node, child: Node, node_name: String, unique: bool = false) -> Node:
	child.name = node_name
	parent.add_child(child)
	child.owner = panel
	child.unique_name_in_owner = unique
	return child

func label(parent: Node, node_name: String, caption: String, font_size: int = 13, color: Color = Kit.CREAM, unique: bool = false) -> Label:
	var text: Label = Kit.text(caption, font_size, color)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node(parent, text, node_name, unique)
	return text

func art(parent: Control, skill_id: String) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = load(Catalog.ATLAS_PATH)
	texture.region = Catalog.atlas_rect(skill_id, texture.atlas.get_size())
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node(parent, preview, "EditorArt")
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _run() -> void:
	panel = PanelContainer.new()
	panel.name = "SkillsPanel"
	panel.custom_minimum_size = Vector2(560, 620)
	panel.size = panel.custom_minimum_size
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.add_theme_stylebox_override("panel", Kit.frame(Color("10130f"), Color("9b8354"), 2, 16))
	# Corner decorations are native 2D nodes, so they can also be edited visually.
	var ornaments := Control.new()
	ornaments.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node(panel, ornaments, "Ornaments")
	for index in 4:
		var corner := Control.new()
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node(ornaments, corner, "Corner%d" % index)
		corner.set_anchors_and_offsets_preset([Control.PRESET_TOP_LEFT, Control.PRESET_TOP_RIGHT, Control.PRESET_BOTTOM_LEFT, Control.PRESET_BOTTOM_RIGHT][index])
		corner.set_meta("_edit_layout_mode", 0)
		var sx: float = 1.0 if index % 2 == 0 else -1.0
		var sy: float = 1.0 if index < 2 else -1.0
		corner.offset_left = -16 * sx
		corner.offset_right = -16 * sx
		corner.offset_top = -16 * sy
		corner.offset_bottom = -16 * sy
		var edge := Line2D.new()
		edge.width = 2
		edge.default_color = Kit.BRIGHT
		edge.points = PackedVector2Array([Vector2(26 * sx, 7 * sy), Vector2(7 * sx, 7 * sy), Vector2(7 * sx, 26 * sy)])
		node(corner, edge, "OuterGold")
		var spiral := Line2D.new()
		spiral.width = 2
		spiral.default_color = Kit.GOLD
		spiral.points = PackedVector2Array([Vector2(12 * sx, 22 * sy), Vector2(12 * sx, 12 * sy), Vector2(22 * sx, 12 * sy), Vector2(22 * sx, 17 * sy), Vector2(17 * sx, 17 * sy)])
		node(corner, spiral, "InnerGold")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	node(panel, column, "Layout")
	var header := HBoxContainer.new()
	node(column, header, "Header")
	var title := label(header, "Title", "HABILIDADES", 23)
	title.add_theme_font_override("font", UiKit.display_font())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close := Kit.button("×")
	close.custom_minimum_size = Vector2(30, 30)
	close.tooltip_text = "Fechar habilidades"
	node(header, close, "CloseSkills", true)
	node(column, Kit.line(), "HeaderDivider")
	var identity := label(column, "ClassIdentity", "Guerreiro · Nível 1", 12, Kit.MUTED, true)
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	node(column, tabs, "Tabs")
	for tab: String in ["ativas", "passivas"]:
		var button := Kit.button(tab.to_upper())
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(112, 32)
		node(tabs, button, "Tab_" + tab, true)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 220
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	node(column, scroll, "SkillsScroll", true)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	node(scroll, grid, "SkillsGrid", true)
	var examples: Array[String] = ["talho_circular", "quebra_guarda", "impeto", "investida", "brecha_tatica", "golpe_ruptura"]
	for index in 16:
		var card := Kit.button("")
		card.toggle_mode = true
		card.custom_minimum_size = Vector2(246, 82)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.clip_contents = true
		card.add_theme_stylebox_override("normal", Kit.frame(Color("1c2018"), Color("6d6546"), 1, 6))
		card.add_theme_stylebox_override("pressed", Kit.frame(Color("353422"), Kit.BRIGHT, 2, 6))
		card.add_theme_stylebox_override("hover", Kit.frame(Color("2d3022"), Kit.BRIGHT, 1, 6))
		card.visible = index < 6
		node(grid, card, "SkillCard%02d" % (index + 1))
		var content := HBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_theme_constant_override("separation", 7)
		node(card, content, "Content")
		content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content.offset_left = 7
		content.offset_right = -7
		content.offset_top = 7
		content.offset_bottom = -7
		var icon: Control = Icon.new()
		icon.custom_minimum_size = Vector2(42, 42)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node(content, icon, "Icon")
		art(icon, examples[index % examples.size()])
		var texts := VBoxContainer.new()
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texts.add_theme_constant_override("separation", 1)
		node(content, texts, "Text")
		var definition: Dictionary = Catalog.definition("guerreiro", examples[index % examples.size()])
		var caption := label(texts, "Name", str(definition.get("name", "Habilidade")), 13)
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.max_lines_visible = 2
		caption.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label(texts, "Level", "Nv. 1", 11, Kit.MUTED)
		var cost := label(texts, "Cost", "Energia: 12 · Recarga: 6 s", 10, Kit.MUTED)
		cost.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cost.max_lines_visible = 2
		var hover: Node = load("res://scripts/ui/skill_hover.gd").new()
		node(card, hover, "SkillHover")
	node(column, Kit.line(), "DetailsDivider")
	var details := HBoxContainer.new()
	details.add_theme_constant_override("separation", 10)
	node(column, details, "SelectedAbility")
	var selected: Control = Icon.new()
	selected.custom_minimum_size = Vector2(52, 52)
	selected.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	node(details, selected, "SelectedIcon", true)
	art(selected, "talho_circular")
	var summary := VBoxContainer.new()
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node(details, summary, "Summary")
	var selected_name := label(summary, "SelectedName", "Talho Circular", 17, Kit.CREAM, true)
	selected_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label(summary, "SelectedStatus", "Nível 1 / 5 · Ativa", 12, Kit.MUTED, true)
	var description := label(column, "SelectedDescription", "Selecione uma habilidade para consultar seus efeitos.", 13, Kit.CREAM, true)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 48
	description.max_lines_visible = 3
	var selected_cost := label(column, "SelectedCost", "Energia: 12 · 6 s de recarga", 12, Kit.MUTED, true)
	selected_cost.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_cost.custom_minimum_size.y = 28
	selected_cost.max_lines_visible = 2
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	node(column, actions, "Actions")
	for entry: Array in [["AssignHotbar", "Para a hotbar"], ["UpgradeSkill", "Usar livro (0)"]]:
		var button := Kit.button(str(entry[1]))
		button.custom_minimum_size.y = 36
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node(actions, button, str(entry[0]), true)
	panel.set_script(load("res://scripts/ui/skills_panel.gd"))
	var packed := PackedScene.new()
	assert(packed.pack(panel) == OK)
	DirAccess.make_dir_recursive_absolute("res://scenes/ui")
	assert(ResourceSaver.save(packed, "res://scenes/ui/skills_panel.tscn") == OK)
	panel.free()
	print("SKILLS_SCENE_AUTHORED")
	quit()
