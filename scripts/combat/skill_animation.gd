extends Node2D
## Short combat animation. The atlas emblem identifies the exact ability.
const Catalog = preload("res://scripts/ui/skill_catalog.gd")
const COLORS = {"atirador": Color("#8de480"), "mago": Color("#95adff"), "guerreiro": Color("#ffc96b"), "assassino": Color("#dc85e8"), "tank": Color("#84d8ff"), "cavaleiro": Color("#ffdc8b")}
const DURATION = 0.48
var world: WorldView
var elapsed := 0.0
var direction := Vector2.RIGHT
var color := Color.WHITE
var handler := ""
var passive := false
var emblem: Rect2
var atlas: Texture2D

func configure(view: WorldView, id: String) -> void:
	world = view
	set_meta("skill_id", id)
	var definition := Catalog.definition(view.state.class_id, id)
	handler = str(definition.get("handler", ""))
	passive = definition.get("type") == "passiva"
	if not passive:
		AudioDirector.play_skill_sfx(id)
	color = COLORS.get(view.state.class_id, Color.GOLD)
	if id in ["explosao_aura", "despertar_heroico"] or definition.has("grade_bonus"):
		color = Color.GOLD
	direction = view.hero.global_position.direction_to(view.hero.casting_aim)
	if direction == Vector2.ZERO:
		direction = view.hero.facing
	atlas = load(Catalog.ATLAS_PATH)
	emblem = Catalog.atlas_rect(id, atlas.get_size())
	z_index = 8
	if id == "campo_gelido":
		_add_ice_particles(view)


func _add_ice_particles(view: WorldView) -> void:
	var particles := GPUParticles2D.new()
	particles.name = "ParticulasCampoGelido"
	particles.position = view.hero.casting_aim - (view.hero.global_position + Vector2(0, -32))
	particles.amount = 48
	particles.lifetime = 0.9
	particles.explosiveness = 0.72
	particles.one_shot = true
	particles.emitting = true
	particles.z_index = -1
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 78.0
	process_material.direction = Vector3(0.0, -0.35, 0.0)
	process_material.spread = 180.0
	process_material.initial_velocity_min = 35.0
	process_material.initial_velocity_max = 125.0
	process_material.gravity = Vector3(0.0, -24.0, 0.0)
	process_material.scale_min = 2.0
	process_material.scale_max = 5.0
	process_material.color = Color(0.66, 0.9, 1.0, 0.9)
	particles.process_material = process_material
	var shard_image := Image.create(9, 17, false, Image.FORMAT_RGBA8)
	shard_image.fill(Color.TRANSPARENT)
	for y in range(17):
		for x in range(9):
			if absf(float(x) - 4.0) / 4.0 + absf(float(y) - 8.0) / 8.0 <= 1.0:
				shard_image.set_pixel(x, y, Color(0.8, 0.97, 1.0, 0.95))
	particles.texture = ImageTexture.create_from_image(shard_image)
	add_child(particles)

func _process(delta: float) -> void:
	if not world.is_playing():
		return
	elapsed += delta
	if elapsed >= DURATION:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var progress := clampf(elapsed / DURATION, 0, 1)
	var ink := Color(color, 1.0 - progress)
	var radius := lerpf(10, 64, progress)
	var angle := direction.angle()
	var id := str(get_meta("skill_id", ""))
	match id:
		"campo_gelido":
			for i in 8:
				var shard_dir := Vector2.RIGHT.rotated(TAU * float(i) / 8.0 + progress * 0.25)
				draw_line(shard_dir * 10.0, shard_dir * radius, Color(0.55, 0.86, 1.0, 1.0 - progress), 3.0, true)
		"cometa_arcano", "golpe_ruptura", "revanche_ferro", "abalo_sismico", "explosao_aura":
			var burst_color := Color(1.0, 0.48, 0.19, 1.0 - progress) if id == "cometa_arcano" or id == "golpe_ruptura" else Color(0.66, 0.83, 1.0, 1.0 - progress)
			draw_arc(Vector2.ZERO, radius * 1.25, 0.0, TAU, 40, burst_color, 4.0, true)
			draw_circle(Vector2.ZERO, radius * 0.42 * (1.0 - progress), Color(burst_color, 0.35))
		"chuva_flechas":
			for i in 7:
				var x := (float(i) - 3.0) * 15.0
				var y := -radius + fmod(float(i) * 23.0 + progress * 120.0, radius * 1.5)
				draw_line(Vector2(x, y), Vector2(x - 4, y + 15), Color(1.0, 0.85, 0.53, 1.0 - progress), 2.0, true)
		"estandarte_real":
			draw_line(Vector2.ZERO, Vector2(0, -radius * 1.45), Color(0.95, 0.78, 0.35, 1.0 - progress), 4.0, true)
			draw_colored_polygon(PackedVector2Array([Vector2(0, -radius * 1.4), Vector2(radius * 0.55, -radius * 1.22), Vector2(0, -radius)]), Color(0.25, 0.42, 0.82, 1.0 - progress))
		"despertar_heroico":
			draw_arc(Vector2.ZERO, radius, progress * TAU, progress * TAU + PI * 1.5, 36, Color(1.0, 0.79, 0.3, 1.0 - progress), 5.0, true)
			draw_circle(Vector2.ZERO, radius * 0.25, Color(1.0, 0.86, 0.42, 0.45 * (1.0 - progress)))
		"passo_arcano", "passo_sombrio":
			var blink_color := Color(0.48, 0.82, 1.0, 1.0 - progress) if id == "passo_arcano" else Color(0.7, 0.35, 0.9, 1.0 - progress)
			for i in 4:
				var offset := Vector2.RIGHT.rotated(angle + PI * 0.5) * (float(i) - 1.5) * 9.0
				draw_line(offset - direction * radius * 0.15, offset + direction * radius * 0.7, blink_color, 3.0, true)
		"selo_desafio", "adaga_arremesso", "tiro_preciso", "flecha_contencao", "projetil_arcano":
			var missile_color := Color(0.6, 0.82, 1.0, 1.0 - progress) if id == "projetil_arcano" else Color(1.0, 0.82, 0.45, 1.0 - progress)
			draw_line(direction * 8.0, direction * radius * 1.2, missile_color, 4.0, true)
			draw_circle(direction * radius * 1.2, 5.0, missile_color)
	if passive or handler in ["buff", "banner", "shield_advance"]:
		draw_arc(Vector2.ZERO, radius * 0.65, progress * TAU, progress * TAU + PI * 1.6, 24, ink, 2, true)
	elif handler in ["bash", "spin", "execute", "dash_strike", "line"]:
		var sweep := angle - 1.4 + progress * 2.8
		draw_arc(Vector2.ZERO, radius, sweep - 1.3, sweep, 16, ink, 4, true)
	elif handler in ["projectile", "cone_shot", "rain", "blink", "blink_behind"]:
		for i in range(-1, 2):
			var ray := direction.rotated(i * 0.15)
			draw_line(ray * (radius - 12), ray * radius, ink, 3, true)
	else:
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, ink, 3, true)
		for i in 8:
			draw_circle(Vector2.RIGHT.rotated(i * TAU / 8 + progress) * radius, 3, ink)
	if emblem.has_area():
		var center := Vector2(0, -38 - progress * 20)
		var side := 20.0 + 6.0 * sin(progress * PI)
		draw_texture_rect_region(atlas, Rect2(center - Vector2.ONE * side / 2, Vector2.ONE * side), emblem, Color(1, 1, 1, 1 - progress))
