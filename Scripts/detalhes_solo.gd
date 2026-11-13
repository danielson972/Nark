@tool
extends Node2D
## Detalhes em pixels inteiros; a mesma distribuição aparece no editor e no jogo.
const GRASS := [Color("666f3b"), Color("7b8443"), Color("97964d"), Color("59643a")]
const LEAVES := [Color("aa934a"), Color("b09c58"), Color("82763c"), Color("a16f3d"), Color("68753c")]

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 48192
	for i in range(5800):
		var p := Vector2(rng.randi_range(8, 2550), rng.randi_range(8, 1910))
		var path_distance := absf(p.x - (1280.0 + 230.0 * sin(p.y / 300.0)))
		var in_clearing := ((p - Vector2(1280, 960)) / Vector2(175, 115)).length() < 1.0
		if path_distance < 40.0 or in_clearing:
			continue
		var shade: Color = GRASS[rng.randi_range(0, GRASS.size() - 1)]
		var height := rng.randi_range(2, 5)
		draw_rect(Rect2(p - Vector2(0, height), Vector2(1, height)), shade)
		draw_rect(Rect2(p + Vector2(-2, -height), Vector2(1, height - 1)), shade)
		draw_rect(Rect2(p + Vector2(2, -2), Vector2(1, 2)), shade.lightened(0.08))
	for i in range(2500):
		var p := Vector2(rng.randi_range(8, 2550), rng.randi_range(8, 1910))
		var path_distance := absf(p.x - (1280.0 + 230.0 * sin(p.y / 300.0)))
		# Folhas agrupadas, inclusive algumas sobre a trilha e a clareira.
		if path_distance < 27.0 and rng.randf() < 0.8:
			continue
		for leaf in range(rng.randi_range(2, 5)):
			var point := p + Vector2(rng.randi_range(-9, 9), rng.randi_range(-6, 6))
			var color: Color = LEAVES[rng.randi_range(0, LEAVES.size() - 1)]
			draw_rect(Rect2(point, Vector2(3, 2)), color)
			draw_rect(Rect2(point + Vector2(1, -1), Vector2(2, 1)), color.lightened(0.12))
			if leaf % 2 == 0:
				draw_rect(Rect2(point + Vector2(3, 1), Vector2(1, 1)), color.darkened(0.18))
