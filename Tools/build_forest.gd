extends SceneTree
## Execute: godot --headless --path . --script Tools/build_forest.gd
const BASE := "res://Assets/Environment/forest/"
var rng := RandomNumberGenerator.new()
var forest_root: Node2D

func attach(node: Node, parent: Node) -> void:
	parent.add_child(node)
	node.owner = forest_root

func sprite(label: String, parent: Node, tex: Texture2D, rect: Rect2, pos: Vector2) -> void:
	var node := Sprite2D.new()
	node.name = label
	node.texture = tex
	node.region_enabled = true
	node.region_rect = rect
	node.position = pos
	node.offset = Vector2(0, -rect.size.y * 0.5)
	node.flip_h = rng.randf() < 0.5
	attach(node, parent)

func path_x(y: float) -> float:
	return 1280.0 + 230.0 * sin(y / 300.0)

func _initialize() -> void:
	rng.seed = 752
	forest_root = Node2D.new()
	forest_root.name = "Floresta"
	forest_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32, 32)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(BASE + "Terrain.png")
	atlas.texture_region_size = Vector2i(32, 32)
	for x in range(0, 48):
		for y in range(0, 18):
			atlas.create_tile(Vector2i(x, y))
	tiles.add_source(atlas, 0)
	var ground := TileMapLayer.new()
	ground.name = "Solo"
	ground.tile_set = tiles
	attach(ground, forest_root)
	for y in range(60):
		for x in range(80):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(2, 2))
	# Toda a trilha e a clareira agora são células do atlas Terrain.
	var trail := TileMapLayer.new()
	trail.name = "TrilhaEClareira"
	trail.tile_set = tiles
	attach(trail, forest_root)
	for y in range(60):
		for x in range(80):
			var p := Vector2(x * 32 + 16, y * 32 + 16)
			if absf(p.x - path_x(p.y)) < 44 or ((p - Vector2(1280, 960)) / Vector2(170, 110)).length() < 1:
				trail.set_cell(Vector2i(x, y), 0, Vector2i(rng.randi_range(43, 46), rng.randi_range(11, 15)))
	var details := Node2D.new()
	details.name = "GramaEFolhas"
	details.set_script(load("res://Scripts/detalhes_solo.gd"))
	attach(details, forest_root)
	var plants := Node2D.new()
	plants.name = "ArvoresEArbustos"
	plants.y_sort_enabled = true
	attach(plants, forest_root)
	var terrain: Texture2D = load(BASE + "Terrain.png")
	var occupied: Array[Vector2] = []
	for i in range(1500):
		var pos := Vector2(rng.randi_range(24, 2536), rng.randi_range(80, 1900))
		if absf(pos.x - path_x(pos.y)) < 115 or ((pos - Vector2(1280, 960)) / Vector2(230, 170)).length() < 1:
			continue
		var crowded := false
		for other in occupied:
			if pos.distance_to(other) < 94:
				crowded = true
				break
		if crowded:
			continue
		occupied.append(pos)
		var tree := Node2D.new()
		tree.name = "ArvoreTerrain_%03d" % i
		tree.position = pos
		attach(tree, plants)
		var shadow := Sprite2D.new()
		shadow.name = "Sombra"
		shadow.texture = terrain
		shadow.region_enabled = true
		shadow.region_rect = Rect2(0, 160, 160, 160)
		shadow.position = Vector2(12, -8)
		shadow.scale = Vector2(0.65, 0.32)
		shadow.modulate = Color(0.22, 0.28, 0.14, 0.45)
		attach(shadow, tree)
		var trunk := Polygon2D.new()
		trunk.name = "Tronco"
		trunk.polygon = PackedVector2Array([Vector2(-7, -58), Vector2(7, -58), Vector2(7, -8), Vector2(15, 0), Vector2(3, -3), Vector2(-3, 0), Vector2(-14, 2), Vector2(-6, -9)])
		trunk.color = Color("685339")
		attach(trunk, tree)
		var size := rng.randf_range(0.8, 1.15)
		for layer in range(3):
			var crown := Sprite2D.new()
			crown.name = "Copa_%d" % layer
			crown.texture = terrain
			crown.region_enabled = true
			crown.region_rect = Rect2(0, 160, 160, 160)
			crown.position = Vector2((layer - 1) * 22, -58 - layer * 16)
			crown.scale = Vector2.ONE * (0.6 - layer * 0.065) * size
			crown.modulate = [Color("647344"), Color("84934f"), Color("afba68")][layer]
			attach(crown, tree)
	for i in range(360):
		var pos := Vector2(rng.randi_range(20, 2540), rng.randi_range(30, 1900))
		if absf(pos.x - path_x(pos.y)) < 70 or ((pos - Vector2(1280, 960)) / Vector2(195, 135)).length() < 1:
			continue
		var bush := Sprite2D.new()
		bush.name = "MoitaTerrain_%03d" % i
		bush.texture = terrain
		bush.region_enabled = true
		bush.region_rect = Rect2(0, 160, 160, 160)
		bush.scale = Vector2.ONE * rng.randf_range(0.16, 0.28)
		bush.position = pos
		bush.modulate = Color("92a363")
		attach(bush, plants)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position = Vector2(1280, 960)
	camera.zoom = Vector2.ONE
	camera.position_smoothing_enabled = false
	camera.set_script(load("res://Scripts/camera_floresta.gd"))
	attach(camera, forest_root)
	var ui := CanvasLayer.new()
	ui.name = "Interface"
	attach(ui, forest_root)
	var label := Label.new()
	label.name = "Ajuda"
	label.position = Vector2(10, 9)
	label.add_theme_font_size_override("font_size", 10)
	label.text = "FLORESTA\nWASD / Setas: mover • Roda: zoom • Botão direito: arrastar • Home: centralizar"
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	attach(label, ui)
	var packed := PackedScene.new()
	var result := packed.pack(forest_root)
	if result == OK:
		result = ResourceSaver.save(packed, "res://Scenes/floresta.tscn")
	print("Floresta reconstruída: ", occupied.size(), " árvores. Resultado: ", result)
	forest_root.free()
	quit(result)
