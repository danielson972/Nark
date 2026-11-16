extends Sprite2D
## Brilho cosmético do item Hero: 12 quadros, seis colunas e duas linhas.

var hero: Hero
var elapsed: float = 0.0
@export var fps: float = 10.0
@export var orbit_seconds: float = 1.8
var back_sprite: Sprite2D
# Ponto do peito na arte de cada classe, em coordenadas normalizadas.
const TORSO_CENTERS = {
	"guerreiro": Vector2(0.57, 0.40), "atirador": Vector2(0.53, 0.41),
	"mago": Vector2(0.52, 0.42), "assassino": Vector2(0.53, 0.41),
	"tank": Vector2(0.52, 0.42), "cavaleiro": Vector2(0.53, 0.41),
}


func setup(hero_ref: Hero) -> void:
	hero = hero_ref
	texture = load("res://assets/game/effects/hero_aura_sheet.png")
	hframes = 6
	vframes = 2
	z_index = 4
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var glow := ShaderMaterial.new()
	glow.shader = preload("res://shaders/hero_aura_orbit.gdshader")
	material = glow
	# A camada traseira precisa ser irmã do efeito, abaixo do desenho do corpo.
	back_sprite = Sprite2D.new()
	back_sprite.name = "BrilhoHeroAtras"
	back_sprite.texture = texture
	back_sprite.hframes = hframes
	back_sprite.vframes = vframes
	back_sprite.z_index = -1
	back_sprite.texture_filter = texture_filter
	var back_material := ShaderMaterial.new()
	back_material.shader = glow.shader
	back_material.set_shader_parameter("back_layer", true)
	back_sprite.material = back_material
	get_parent().add_child(back_sprite)
	visibility_changed.connect(_sync_layers)
	visible = false
	_sync_layers()


func _sync_layers() -> void:
	if back_sprite == null:
		return
	# Mantém o centro sobre o peito, inclusive quando o corpo é espelhado.
	if hero != null and hero.sprite != null and hero.sprite.texture != null and hero.state != null:
		var body_size: Vector2 = hero.sprite.texture.get_size()
		var torso: Vector2 = TORSO_CENTERS.get(hero.state.class_id, Vector2(0.52, 0.41))
		var mirror: float = -1.0 if hero.sprite.flip_h else 1.0
		position = Vector2((torso.x - 0.5) * body_size.x * mirror, (torso.y - hero.Appearance.FOOT_Y) * body_size.y)
	back_sprite.visible = visible
	back_sprite.position = position
	back_sprite.scale = scale
	back_sprite.frame = frame


func _process(delta: float) -> void:
	_sync_layers()
	if not visible or hero == null or hero.dead:
		return
	if hero.world != null and not hero.world.is_playing():
		return
	elapsed += delta
	frame = int(elapsed * fps) % 12
	# O ciclo faz uma volta completa e reinicia sem pausa, independente dos quadros da luz.
	var phase: float = fposmod(elapsed / maxf(orbit_seconds, 0.1) * TAU, TAU)
	material.set_shader_parameter("orbit_phase", phase)
	back_sprite.material.set_shader_parameter("orbit_phase", phase)
	_sync_layers()
