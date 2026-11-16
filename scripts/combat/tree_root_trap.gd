extends Node2D
## A marca fica no ponto escolhido; sair dela durante o aviso evita a raiz.

var world: Node
var radius: float = 48.0
var warning_time: float = 0.9
var root_duration: float = 2.0
var elapsed: float = 0.0
var triggered: bool = false
var caught_hero: bool = false


func _ready() -> void:
	# Acima do chão e abaixo dos personagens, independente da camada de efeitos.
	z_as_relative = false
	z_index = 0


func _process(delta: float) -> void:
	if world == null or not world.is_playing():
		return
	elapsed += delta
	if not triggered and elapsed >= warning_time:
		triggered = true
		var hero = world.hero
		if is_instance_valid(hero) and not hero.dead and hero.global_position.distance_to(global_position) <= radius + hero.radius * 0.4:
			if hero.dodge_time <= 0.0 and hero.invulnerable <= 0.0:
				hero.apply_status("root", root_duration)
				hero.dodge_time = 0.0
				hero.dash_time = 0.0
				hero.velocity = Vector2.ZERO
				caught_hero = true
				world.show_notice("Preso pelas raízes!", Color(0.65, 0.85, 0.35))
	if elapsed >= warning_time + root_duration:
		queue_free()
	queue_redraw()


func _draw() -> void:
	if not triggered:
		var progress: float = clampf(elapsed / maxf(warning_time, 0.01), 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius, Color(0.7, 0.35, 0.08, 0.14 + progress * 0.12))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1.0, 0.65, 0.18), 2.0)
		draw_arc(Vector2.ZERO, radius * progress, 0, TAU, 40, Color(0.9, 0.75, 0.25, 0.7), 1.0)
		return
	var growth: float = clampf((elapsed - warning_time) / 0.18, 0.0, 1.0)
	var fade: float = clampf((warning_time + root_duration - elapsed) / 0.3, 0.0, 1.0)
	for index in 7:
		var angle: float = TAU * float(index) / 7.0
		var base := Vector2(cos(angle) * radius * 0.65, sin(angle) * radius * 0.28)
		var points := PackedVector2Array([base, base + Vector2(-7, -12) * growth, base + Vector2(5, -26) * growth, base + Vector2(1, -38) * growth])
		draw_polyline(points, Color(0.32, 0.2, 0.08, fade), 6.0)
		draw_polyline(points, Color(0.42, 0.62, 0.16, fade), 2.0)
