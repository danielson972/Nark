extends SceneTree
func _initialize() -> void: call_deferred("run")
func check_text(node: Node) -> int:
	var count: int = 0
	if node is Label or node is Button or node is LineEdit or node is TextEdit or node is RichTextLabel or node is ItemList or node is Tree:
		assert(node.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS,"Text inherited sprite filtering: "+str(node.get_path()))
		count += 1
	elif node is PopupMenu:
		assert(node.canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	for child in node.get_children(true): count += check_text(child)
	return count
func run() -> void:
	for path: String in ["res://assets/fonts/Cinzel-SemiBold.ttf","res://assets/fonts/Cinzel-Bold.ttf","res://assets/template/fonts/Figtree-VF.subset.woff2","res://assets/template/fonts/NotoSansSC-VF.subset.woff2","res://assets/template/fonts/display/Sora-VF.subset.woff2"]:
		var font: FontFile = load(path)
		assert(font.generate_mipmaps,"Font mipmaps not imported: "+path)
	assert(ProjectSettings.get_setting("gui/fonts/dynamic_fonts/use_oversampling"))
	assert(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0)
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	for i in 3: await process_frame
	var count: int = check_text(scene)
	for sprite in scene.get_node("Cabelos").find_children("*","Sprite2D",true,false):
		if sprite.texture != null:
			assert(sprite.texture_filter in [CanvasItem.TEXTURE_FILTER_PARENT_NODE,CanvasItem.TEXTURE_FILTER_NEAREST])
	# Simulate a scaled panel with dynamically inserted text and a pixel icon.
	var panel := Control.new()
	panel.scale = Vector2(.65,.65)
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(panel)
	var label := Label.new()
	label.text = "Criação · Poção · Anão · Opções"
	panel.add_child(label)
	var popup := PopupMenu.new()
	popup.add_item("Opções de aparência")
	panel.add_child(popup)
	var icon = load("res://scripts/ui/inventory_icon.gd").new()
	icon.item_id = "armadura_catalogo_001"
	panel.add_child(icon)
	for i in 3: await process_frame
	assert(label.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	assert(popup.canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	assert(icon.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	for character: String in ["ç","ã","ó"]:
		assert(label.get_theme_font("font").has_char(character.unicode_at(0)))
	panel.queue_free()
	scene.queue_free()
	await process_frame
	print("FONT_SCALING_OK: five imported fonts, %d text controls, dropdown filtering, scaled panels, accents and preserved sprite/icon filtering" % count)
	quit()
