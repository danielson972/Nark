extends Camera2D

const FLOOR_SIZE := Vector2(1536, 1024)

func _process(delta: float) -> void:
	var direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	position += direction.normalized() * 320.0 * delta / zoom.x
	clamp_to_floor()

func clamp_to_floor() -> void:
	var half_view := get_viewport_rect().size / (2.0 * zoom)
	position = position.clamp(half_view, FLOOR_SIZE - half_view).round()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position -= event.relative / zoom
		clamp_to_floor()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2.ONE * minf(zoom.x + 1.0, 3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2.ONE * maxf(zoom.x - 1.0, 1.0)
		clamp_to_floor()
	if event is InputEventKey and event.pressed and event.keycode == KEY_HOME:
		zoom = Vector2.ONE
		position = Vector2(320, 180)
