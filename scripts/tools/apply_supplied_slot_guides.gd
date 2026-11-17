extends SceneTree
## Reference the user's original sheet through editable AtlasTexture resources.
const SOURCE = "res://assets/game/ui/equipment_slots/slot_guides_supplied.png"
const CELLS = {"aura":Vector2i(0,0), "escudo":Vector2i(1,0), "colar":Vector2i(2,0), "talisma":Vector2i(3,0), "armadura":Vector2i(0,1), "anel":Vector2i(1,1), "arma":Vector2i(2,1)}
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var texture: Texture2D = load(SOURCE)
	var source: Image = texture.get_image()
	var panel: Control = load("res://scenes/ui/equipment_status_panel.tscn").instantiate()
	DirAccess.make_dir_recursive_absolute("res://assets/game/ui/equipment_slots/guides")
	for slot: String in CELLS:
		var cell: Vector2i = CELLS[slot]
		var begin := Vector2i(floori(cell.x * source.get_width() / 4.0), floori(cell.y * source.get_height() / 2.0))
		var end := Vector2i(floori((cell.x + 1) * source.get_width() / 4.0), floori((cell.y + 1) * source.get_height() / 2.0))
		var minimum: Vector2i = end
		var maximum: Vector2i = begin
		for y in range(begin.y, end.y):
			for x in range(begin.x, end.x):
				if source.get_pixel(x, y).a >= 0.15:
					minimum = Vector2i(mini(minimum.x,x), mini(minimum.y,y))
					maximum = Vector2i(maxi(maximum.x,x), maxi(maximum.y,y))
		assert(maximum.x > minimum.x and maximum.y > minimum.y)
		var guide := AtlasTexture.new()
		guide.atlas = texture
		guide.region = Rect2(Vector2(minimum), Vector2(maximum - minimum + Vector2i.ONE))
		guide.filter_clip = true
		var path := "res://assets/game/ui/equipment_slots/guides/%s.tres" % slot
		assert(ResourceSaver.save(guide, path) == OK)
		var icon: TextureRect = panel.get_node("Equipment_%s/EmptyIcon" % slot)
		icon.texture = load(path)
		icon.modulate.a = 0.75
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.get_node("Equipment_" + slot).tooltip_text = panel.SLOT_NAMES[slot]
	var packed := PackedScene.new()
	assert(packed.pack(panel) == OK)
	assert(ResourceSaver.save(packed, "res://scenes/ui/equipment_status_panel.tscn") == OK)
	panel.free()
	print("SUPPLIED_SLOT_GUIDES_APPLIED: seven original sheet regions and hover labels")
	quit()
