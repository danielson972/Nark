extends Node2D

const GroundEffectScene = preload("res://scripts/combat/ground_effect.gd")

var field: GroundEffect

func _ready() -> void:
	var background_layer := CanvasLayer.new()
	background_layer.layer = -1
	add_child(background_layer)
	var background := ColorRect.new()
	background.color = Color("101a2b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_layer.add_child(background)

	var title := Label.new()
	title.text = "TESTE VISUAL — CAMPO GÉLIDO"
	title.position = Vector2(24, 18)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("b9eaff"))
	background_layer.add_child(title)

	var instructions := Label.new()
	instructions.text = "Área pulsante, anel arcano e fragmentos de gelo. Aguarde 5 s para ver o desaparecimento."
	instructions.position = Vector2(24, 58)
	instructions.add_theme_font_size_override("font_size", 16)
	instructions.add_theme_color_override("font_color", Color("d8e6f2"))
	background_layer.add_child(instructions)

	field = GroundEffectScene.new()
	field.name = "CampoGelidoEmTeste"
	field.mode = "field"
	field.radius = 120.0
	field.duration = 5.0
	field.slow = 0.45
	field.color = Color(0.45, 0.75, 1.0, 0.26)
	field.edge = Color(0.65, 0.9, 1.0, 0.75)
	field.position = get_viewport_rect().size * 0.5
	add_child(field)

	assert(field.mode == "field", "O efeito precisa estar no modo field")
	assert(is_equal_approx(field.radius, 120.0), "Raio incorreto para Campo Gélido")
	assert(is_equal_approx(field.duration, 5.0), "Duração incorreta para Campo Gélido")
	assert(is_equal_approx(field.slow, 0.45), "Lentidão incorreta para Campo Gélido")
	print("CAMPO_GELIDO_TEST_OK: modo, raio, duração e lentidão validados")
