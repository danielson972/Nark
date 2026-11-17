extends SceneTree
const Catalog = preload("res://scripts/ui/item_catalog.gd")
class Portrait extends Control:
	var texture: Texture2D
	func _draw() -> void:
		if texture == null: return
		var dimensions: Vector2 = texture.get_size()
		dimensions *= minf(size.x / dimensions.x, size.y / dimensions.y)
		draw_texture_rect(texture, Rect2((size-dimensions)*0.5, dimensions), false)

func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1280,800)
	root.content_scale_size = Vector2i(1280,800)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var backdrop := ColorRect.new()
	backdrop.color = Color("141711")
	backdrop.size = Vector2(1280,800)
	layer.add_child(backdrop)
	var header := Label.new()
	header.text = "PEITORAIS — TRANSPARÊNCIA SOBRE CORES DE RARIDADE"
	header.position = Vector2(36,20)
	header.add_theme_font_size_override("font_size",23)
	layer.add_child(header)
	var colors: Array[Color] = [Color("355044"), Color("244f70"), Color("59355f"), Color("80602f")]
	var names: Array[String] = ["Verde","Azul","Roxo","Dourado"]
	var ids: Array[int] = [3,14,24,38,47,58,68,79,89,100]
	for row in 4:
		var title := Label.new()
		title.text = names[row]
		title.position = Vector2(30,118+row*168)
		title.add_theme_font_size_override("font_size",19)
		layer.add_child(title)
		for column in 10:
			var x: float = 150+column*110
			var y: float = 84+row*168
			var slot := ColorRect.new()
			slot.position = Vector2(x,y)
			slot.size = Vector2(100,116)
			slot.color = colors[row]
			layer.add_child(slot)
			var icon := Portrait.new()
			icon.texture = Catalog.icon_texture_for("armadura_catalogo_%03d" % ids[column])
			icon.position = Vector2(x+5,y+5)
			icon.size = Vector2(90,106)
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			layer.add_child(icon)
			var label := Label.new()
			label.text = "%03d" % ids[column]
			label.position = Vector2(x+32,y+120)
			layer.add_child(label)
	for tick in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.work/armor-icons-rarity-review.png")
	layer.queue_free()
	await process_frame
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano","guerreiro","Aurora")
	game.state.set_hair(1,"castanho")
	for id: String in GameData.ITEMS: game.state.add_item(id,1,true)
	game.state.equip("armadura_catalogo_038")
	game._open_panel("inventory")
	for tick in 5: await process_frame
	game.ui.inventory_view._change_filter("armor")
	for tick in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.work/armor-icons-inventory-review.png")
	game.queue_free()
	for tick in 3: await process_frame
	print("ARMOR_PORTRAITS_RENDERED: four slot backgrounds and real inventory")
	quit()
