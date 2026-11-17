extends Node

const GameFonts = preload("res://scripts/manus/game_fonts.gd")
var _regular: Font
var _theme: Theme

func _enter_tree() -> void :
	_regular = load("res://assets/template/fonts/ui_regular.tres") as Font
	assert (_regular != null, "Bundled UI font failed to import")
	_theme = GameFonts.create_theme(_regular, load("res://assets/template/fonts/ui_medium.tres") as Font, load("res://assets/template/fonts/ui_bold.tres") as Font)
	get_tree().node_added.connect(_bind_node)
	_bind_tree(get_tree().root)

func _bind_tree(node: Node) -> void :
	_bind_node(node)
	for child in node.get_children():
		_bind_tree(child)

func _bind_node(node: Node) -> void :
	if node is Label or node is Button or node is LineEdit or node is TextEdit or node is RichTextLabel or node is ItemList or node is Tree or node is PopupMenu:
		_apply_text_sampling(node)
		# Nodes can override their filter in _ready after entering the tree.
		_apply_text_sampling.call_deferred(node)
	if node is Control:
		if node.theme != null:
			if node.theme.default_font == null:
				node.theme = node.theme.duplicate()
				node.theme.default_font = _regular
		elif node.get_parent_control() == null:
			node.theme = _theme
	elif node is Label3D and node.font == null:
		GameFonts.apply_world_label(node, _regular)

func _apply_text_sampling(node: Node) -> void:
	if not is_instance_valid(node) or node.is_queued_for_deletion(): return
	if node is PopupMenu:
		node.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		# Apply to text-bearing nodes only; artwork keeps its existing filter.
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
