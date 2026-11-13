extends Camera2D
## Navegação da floresta: WASD/setas, arrastar com botão direito e roda para zoom.
const SPEED := 450.0

func _process(delta: float) -> void:
	var direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	position += direction.normalized() * SPEED * delta / zoom.x
	position = position.clamp(Vector2(240, 140), Vector2(2320, 1780))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position -= event.relative / zoom.x
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2.ONE * minf(zoom.x + 1.0, 3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2.ONE * maxf(zoom.x - 1.0, 1.0)
	if event is InputEventKey and event.pressed and event.keycode == KEY_HOME:
		position = Vector2(1280, 960)
		zoom = Vector2.ONE
