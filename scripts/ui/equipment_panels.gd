extends Control
## Opens both panels with the inventory; inventory close dismisses the pair.
signal action_requested(action: String, payload: Dictionary)
signal panels_changed(inventory_open: bool, status_open: bool)
var inventory_view: Control
var status_view: Control

func _ready() -> void:
	inventory_view = $InventoryPanel
	status_view = $StatusPanel
	inventory_view.slot_buttons.merge(status_view.slot_buttons)
	inventory_view._update_selection()
	inventory_view.action_requested.connect(_action)
	status_view.action_requested.connect(_action)
	status_view.equipment_selected.connect(func(id: String, slot: String) -> void:
		inventory_view._select(id, slot)
	)
	get_parent().resized.connect(_fit)
	_fit.call_deferred()

func open_inventory() -> void:
	inventory_view.show()
	status_view.show()
	refresh_data()
	_changed()

func open_status() -> void:
	status_view.show()
	status_view.refresh_data()
	_changed()

func refresh_data() -> void:
	status_view.refresh_data()
	inventory_view.refresh_data()

func _action(action: String, payload: Dictionary) -> void:
	match action:
		"close_inventory":
			inventory_view.hide()
			status_view.hide()
			_changed()
		"close_status":
			status_view.hide()
			_changed()
		_: action_requested.emit(action, payload)

func _changed() -> void:
	panels_changed.emit(inventory_view.visible, status_view.visible)
	if not inventory_view.visible and not status_view.visible:
		action_requested.emit("close_panel", {})
	else:
		_fit()

func _fit() -> void:
	if not is_inside_tree() or is_queued_for_deletion(): return
	var bounds := Rect2()
	var has_bounds: bool = false
	for panel: Control in [inventory_view, status_view]:
		if panel.visible:
			bounds = bounds.merge(panel.get_rect()) if has_bounds else panel.get_rect()
			has_bounds = true
	if not has_bounds: return
	var available: Vector2 = get_parent().size
	var factor: float = clampf(minf((available.x - 24) / bounds.size.x, (available.y - 24) / bounds.size.y), 0.1, 1.0)
	scale = Vector2.ONE * factor
	position = ((available - bounds.size * factor) * 0.5 - bounds.position * factor).floor()
