extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _shortcut() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_F12
	event.pressed = true
	event.ctrl_pressed = true
	event.shift_pressed = true
	Input.parse_input_event(event)

func _run() -> void:
	var aurora = load("res://scenes/Aurora.tscn").instantiate()
	root.add_child(aurora)
	await process_frame
	await process_frame
	var controller = root.get_node("ControleAurora")
	assert(controller.world == aurora)
	var state = aurora.state
	var position: Vector2 = aurora.hero.global_position
	_shortcut()
	await process_frame
	assert(controller.developer_active)
	assert(controller.world.region.developer_room)
	assert(not aurora.visible)
	controller._open_developer_shop("dev_items")
	await process_frame
	_shortcut()
	await process_frame
	assert(not controller.developer_active)
	assert(controller.world == aurora and aurora.state == state)
	assert(aurora.visible and aurora.is_playing())
	assert(aurora.hero.global_position.distance_to(position) < 1.0)
	aurora.queue_free()
	await process_frame
	await process_frame
	print("AURORA_SECRET_ROOM_OK: real shortcut, room entry, exit with panel open, state/position restored")
	quit()