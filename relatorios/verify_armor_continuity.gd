extends SceneTree
func _initialize() -> void:
	var appearance = load("res://scripts/actors/hero_appearance.gd")
	var state := PlayerState.create("Roupa","humano","guerreiro")
	for number in [1,7,8,87,89,95,100]:
		state.equipment["armadura"] = {"id":"armadura_catalogo_%03d" % number}
		var image: Image = appearance.body_texture(state).get_image()
		for y in range(135,490):
			var occupied := 0
			for x in range(25,226):
				if image.get_pixel(x,y).a >= 0.95: occupied += 1
			assert(occupied > 5, "Armor must not contain a horizontal transparent break at the waist or ankles")
	print("ARMOR_ASSEMBLY_OK: seven representative catalog sets have continuous silhouettes, including dark set 89")
	quit()
