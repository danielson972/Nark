extends SceneTree
func _initialize() -> void:
	var appearance = load("res://scripts/actors/hero_appearance.gd")
	var art = load("res://scripts/ui/item_catalog.gd")
	var hashes: Dictionary = {}
	var state := PlayerState.create("Catalogo","humano","guerreiro")
	for number in range(1,101):
		var id := "armadura_catalogo_%03d" % number
		state.equipment["armadura"] = {"id": id}
		var body: AtlasTexture = appearance.body_texture(state)
		assert(body.atlas.resource_path.ends_with("armadura_%03d.png" % number), "Every set must load its complete sprite")
		assert(body.get_size() == Vector2(256, 512))
		var pixels := body.get_image()
		assert(pixels.get_pixel(0, 0).a == 0.0 and pixels.get_pixel(255, 511).a == 0.0)
		hashes[body.get_image().get_data().hex_encode().sha256_text()] = true
		var icon: AtlasTexture = art.texture_for(id)
		assert(icon.atlas.resource_path.contains("Armaduras_RPG/pranchas"))
	assert(hashes.size() == 100, "All 100 catalog sets must have distinct worn pixels")
	print("ALL_CATALOG_ARMOR_OK: 100 distinct worn sets and correct source icons")
	quit()
