extends SceneTree
var city: Node2D
var pavement: Texture2D
var rng := RandomNumberGenerator.new()
func piece(label: String, rect: Rect2, position: Vector2, size: Vector2, parent: Node) -> void:
	var node := Sprite2D.new()
	node.name = label
	node.texture = pavement
	node.region_enabled = true
	node.region_rect = rect
	node.centered = false
	node.position = position
	node.scale = size / rect.size
	parent.add_child(node)
	node.owner = city
func _initialize() -> void:
	rng.seed = 451
	city = Node2D.new()
	city.name = "CidadePrincipal"
	city.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pavement = load("res://Assets/Citys/pavimento/pavimento.png")
	var floor_node := Node2D.new()
	floor_node.name = "Chao"
	floor_node.z_index = -10
	city.add_child(floor_node)
	floor_node.owner = city
	# Atlas 4 x 4: margens irregulares da folha excluídas em cada recorte.
	# Cantos arredondados ocupam somente o perímetro do mapa.
	var nw := Rect2(34, 40, 270, 266)
	var north := Rect2(340, 40, 272, 266)
	var ne := Rect2(644, 40, 270, 266)
	var west := Rect2(34, 346, 270, 262)
	var east := Rect2(952, 346, 270, 262)
	var sw := Rect2(34, 950, 270, 260)
	var south := Rect2(340, 950, 272, 260)
	var se := Rect2(644, 950, 270, 260)
	var interiors := [Rect2(340, 346, 272, 262), Rect2(644, 346, 270, 262), Rect2(340, 648, 272, 262), Rect2(644, 648, 270, 262)]
	for y in range(16):
		for x in range(24):
			var rect: Rect2 = interiors[rng.randi_range(0, 3)]
			var label := "Miolo"
			if y == 0:
				rect = nw if x == 0 else (ne if x == 23 else north)
				label = "BordaNorte"
			elif y == 15:
				rect = sw if x == 0 else (se if x == 23 else south)
				label = "BordaSul"
			elif x == 0:
				rect = west
				label = "BordaOeste"
			elif x == 23:
				rect = east
				label = "BordaLeste"
			piece("%s_%02d_%02d" % [label,x,y], rect, Vector2(x,y) * 64, Vector2(64,64), floor_node)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position = Vector2(320,180)
	camera.set_script(load("res://Scripts/camera_cidade.gd"))
	city.add_child(camera)
	camera.owner = city
	var packed := PackedScene.new()
	packed.pack(city)
	var result := ResourceSaver.save(packed,"res://Scenes/cidadePrincipal.tscn")
	print("Cidade: 384 peças do novo atlas, com miolo, laterais e cantos. Resultado: ",result)
	city.free()
	quit(result)
