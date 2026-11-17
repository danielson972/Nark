extends SceneTree
## Update the existing editable scenes without rebuilding their layout.
const PATH = "res://assets/game/ui/inventory/equipment_inventory_gold.png"
var art: Texture2D
func _initialize() -> void: call_deferred("_run")
func region(rect: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = art
	texture.region = rect
	texture.filter_clip = true
	return texture
func adapt(path: String, is_status: bool) -> void:
	var panel: Control = load(path).instantiate()
	var background: TextureRect = panel.get_node("ReferenceBackground")
	background.texture = region(Rect2(0, 0, 755, 1029) if is_status else Rect2(755, 0, 756, 1029))
	var old: Control = panel.get_node("ClearExampleContent")
	var clear := TextureRect.new()
	clear.name = old.name
	clear.texture = region(Rect2(205, 270, 340, 465))
	clear.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	clear.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	clear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clear.position = old.position
	clear.size = old.size
	var index: int = old.get_index()
	panel.remove_child(old)
	old.free()
	panel.add_child(clear)
	clear.owner = panel
	panel.move_child(clear, index)
	var backing := ColorRect.new()
	backing.name = "OpaqueBacking"
	backing.color = Color("10110e")
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.show_behind_parent = true
	clear.add_child(backing)
	backing.owner = panel
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for slot: TextureRect in panel.find_children("SlotBackground", "TextureRect", true, false):
		slot.texture = region(Rect2(794, 210, 78, 78))
	if is_status:
		var inventory_button: Node = panel.get_node_or_null("OpenInventory")
		if inventory_button != null:
			panel.remove_child(inventory_button)
			inventory_button.free()
		var marker: Label = panel.get_node_or_null("Equipment_aura/EmptyMarker")
		if marker != null:
			marker.text = "H"
			marker.add_theme_font_size_override("font_size", 20)
	var packed := PackedScene.new()
	assert(packed.pack(panel) == OK)
	assert(ResourceSaver.save(packed, path) == OK)
	panel.free()
func _run() -> void:
	art = load(PATH)
	adapt("res://scenes/ui/equipment_status_panel.tscn", true)
	adapt("res://scenes/ui/inventory_panel.tscn", false)
	print("GOLD_BACKGROUND_APPLIED")
	quit()
