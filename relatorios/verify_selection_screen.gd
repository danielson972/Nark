extends SceneTree
const Baseline = preload("res://relatorios/selection_sprite_baseline.gd")
func _initialize() -> void: call_deferred("run")

func check_sprites(scene: Node) -> void:
	for path: String in Baseline.SPRITES:
		var sprite: Sprite2D = scene.get_node(path)
		var expected: Array = Baseline.SPRITES[path]
		assert(sprite.position.is_equal_approx(Vector2(expected[0],expected[1])), "Changed authored position: "+path)
		assert(sprite.scale.is_equal_approx(Vector2(expected[2],expected[3])), "Changed authored size: "+path)
		assert(is_equal_approx(sprite.rotation,expected[4]), "Changed authored rotation: "+path)
		assert(sprite.offset.is_equal_approx(Vector2(expected[5],expected[6])), "Changed authored offset: "+path)

func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	check_sprites(scene)
	root.add_child(scene)
	for i in 3: await process_frame
	for name in ["Nome","Modelo_masculino","Modelo_feminino","Raca_humano","Raca_anao","Classe_guerreiro","Classe_cavaleiro","EscolhaCabelo","EscolhaCor","EscolhaBarba","CorBarba","Concluir","Voltar"]:
		var control: Control = scene.get_node("%"+name)
		assert(control.is_visible_in_tree() and scene.get_viewport_rect().encloses(control.get_global_rect()),"Control outside viewport: "+name)
	assert(scene.get_node("FundoRuinas").texture != null)
	scene.name_field.text = "Aurora"
	for gender: String in ["masculino","feminino"]:
		for race: String in ["humano","elfo","orc","anao"]:
			scene.select_gender(gender)
			scene.select_race(race)
			scene.select_hair(1)
			scene.select_beard(12)
			for i in 2: await process_frame
			check_sprites(scene)
			var group_name: String = {"humano":"Humano","elfo":"Elfo","orc":"Orc","anao":"Anao"}[race]+("Masculino" if gender == "masculino" else "Feminino")
			var base: Sprite2D = scene.get_node("Cabelos/"+group_name+"/BaseCareca")
			var local_foot := Vector2(base.texture.get_width()*.5,502.0)+base.offset
			if base.centered: local_foot -= base.texture.get_size()*.5
			var foot: Vector2 = base.global_transform*local_foot
			assert(foot.is_equal_approx(Vector2(scene.size.x*.5,scene.size.y*.745)),"Character must stand on the podium without rescaling")
			assert(scene.get_node("Cabelos").position-scene.portrait_origin == scene.get_node("Barbas").position-scene.beard_origin)
			assert(scene.name_field.text == "Aurora")
	scene.color_buttons.azul.pressed.emit()
	assert(scene.hair_color == "azul")
	assert(scene.get_node("%EscolhaCor").selected == scene.Custom.COLORS.keys().find("azul"))
	scene.select_hair(0)
	assert(scene.get_node("%EscolhaCor").disabled and scene.color_buttons.azul.disabled)
	var back: Array = []
	scene.back_requested.connect(func(): back.append(true))
	scene.get_node("%Voltar").pressed.emit()
	assert(back.size() == 1)
	scene.queue_free()
	await process_frame
	print("SELECTION_SCREEN_OK: %d original sprite transforms, eight podium placements without scaling, visible controls, palette, bald option and back action" % Baseline.SPRITES.size())
	quit()
