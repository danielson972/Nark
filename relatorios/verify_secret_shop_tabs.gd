extends SceneTree
var received: Dictionary = {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano","guerreiro","Teste")
	await process_frame
	game._enter_developer_room()
	game._open_developer_shop("dev_items")
	await process_frame
	var tabs: TabBar = game.ui.find_child("ShopCategoryTabs",true,false)
	var items: VBoxContainer = game.ui.find_child("ShopCategoryItems",true,false)
	assert(tabs.tab_count == 3)
	assert(tabs.get_tab_title(0) == "Armas" and tabs.get_tab_title(1) == "Armaduras" and tabs.get_tab_title(2) == "Itens")
	var seen: Dictionary = {}
	for index in 3:
		tabs.current_tab = index
		await process_frame
		assert(items.get_child_count() > 0)
		for row in items.get_children():
			var id: String = str(row.name).trim_prefix("ShopItem_")
			var type: String = str(GameData.item(id).get("type",""))
			assert((index == 0 and type == "arma") or (index == 1 and type == "armadura") or (index == 2 and type not in ["arma","armadura"]))
			assert(not seen.has(id))
			seen[id] = true
	assert(seen.size() == GameData.ITEMS.size(), "All products remain available exactly once")
	var row = items.get_child(0)
	var id: String = str(row.name).trim_prefix("ShopItem_")
	var before: int = game.state.count_item(id)
	var buttons: Array = row.find_children("*","Button",true,false)
	buttons[1].pressed.emit()
	assert(game.state.count_item(id) == before+10)
	game._close_panel()
	game._open_developer_shop("dev_items")
	await process_frame
	assert(game.ui.find_child("ShopCategoryTabs",true,false).current_tab == 2)
	for i in 3: await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://relatorios/secret-shop-tabs.png")
	print("SECRET_SHOP_TABS_OK: three categories, every product once, free quantities and category persistence")
	quit()
