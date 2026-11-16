extends Node2D
## Sparks follow the weapon; the attack trail rotates around the same hand pivot.

var hero: Hero
var clock: float = 0.0

func _ready() -> void:
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive

func _process(delta: float) -> void:
	if not visible or hero == null or hero.dead:
		return
	if hero.world != null and not hero.world.is_playing():
		return
	clock += delta
	queue_redraw()

func _draw() -> void:
	if hero == null or hero.weapon_sprite == null or hero.weapon_sprite.texture == null:
		return
	var size: Vector2 = hero.weapon_sprite.texture.get_size()
	var pivot: Vector2 = hero.Appearance.weapon_pivot(hero.state.class_id, "arma_b")
	var tip: Vector2 = Vector2(0.12, 0.85) if hero.state.class_id in ["guerreiro", "assassino"] else Vector2(0.72, 0.22)
	var end: Vector2 = (tip - pivot) * size
	var mirror: float = -1.0 if hero.sprite.flip_h else 1.0
	end.x *= mirror
	var side: Vector2 = end.normalized().orthogonal()
	for index in 9:
		var phase: float = fmod(clock * 0.55 + float(index) / 9.0, 1.0)
		var point: Vector2 = end * (0.25 + phase * 0.8) + side * sin(clock * 3.5 + index * 2.1) * 9.0
		var strength: float = sin(phase * PI)
		var radius: float = 2.0 + strength * 2.0
		var color: Color = Color(0.86, 0.5, 1.0, strength * 0.8) if index % 3 else Color(1.0, 0.88, 0.52, strength)
		draw_line(point - Vector2(radius, 0), point + Vector2(radius, 0), color, 1.5)
		draw_line(point - Vector2(0, radius), point + Vector2(0, radius), color, 1.5)
	if hero.attack_swing > 0.0:
		var strength: float = sin(clampf(hero.attack_swing / 0.18, 0.0, 1.0) * PI)
		var angle: float = end.angle()
		for index in 3:
			draw_arc(Vector2.ZERO, end.length() * (0.72 + index * 0.12), angle - 0.9 * mirror,
				angle + 0.1 * mirror, 18, Color(0.72, 0.30, 1.0, strength * (0.5 - index * 0.12)), 5.0 - index)
