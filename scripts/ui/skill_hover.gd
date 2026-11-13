extends Node
## Hover card controller. CanvasLayer lets it escape the grid's clipping area.

const TooltipCard = preload("res://scripts/ui/skill_tooltip.gd")
const HOVER_DELAY = 0.16

var state: PlayerState
var definition: Dictionary = {}
var target: Control
var card: PanelContainer
var overlay: CanvasLayer
var hovering: bool = false
var elapsed: float = 0.0
var pointer_position: Vector2 = Vector2.ZERO
var presentation_key: String = ""

func _ready() -> void:
	name = "SkillHover"
	target = get_parent() as Control
	target.mouse_entered.connect(_enter)
	target.mouse_exited.connect(_leave)
	target.gui_input.connect(_on_gui_input)
	set_process(false)

func configure(player: PlayerState, skill: Dictionary) -> void:
	state = player
	definition = skill
	if definition.is_empty():
		_leave()
		return
	var key: String = "%d:%s:%d:%d" % [state.get_instance_id(), skill.get("id", ""), state.level, state.skill_level(str(skill.get("id", "")))]
	if key != presentation_key:
		presentation_key = key
		if is_instance_valid(card):
			card.configure(state, definition)

func _enter() -> void:
	if definition.is_empty() or state == null:
		return
	hovering = true
	pointer_position = target.get_global_mouse_position()
	elapsed = 0.0
	set_process(true)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pointer_position = event.global_position

func _leave() -> void:
	hovering = false
	set_process(false)
	if is_instance_valid(card):
		card.hide()

func _process(delta: float) -> void:
	if not hovering or not is_instance_valid(target) or not target.is_visible_in_tree():
		_leave()
		return
	elapsed += delta
	if elapsed < HOVER_DELAY:
		return
	if not is_instance_valid(card):
		overlay = CanvasLayer.new()
		overlay.layer = 100
		add_child(overlay)
		card = TooltipCard.new()
		card.configure(state, definition)
		overlay.add_child(card)
		card.size = Vector2(280, 0)
	card.show()
	_position_card()

func _position_card() -> void:
	var viewport_size: Vector2 = target.get_viewport_rect().size
	var pointer: Vector2 = pointer_position
	var desired: Vector2 = pointer + Vector2(18, 18)
	if desired.y + card.size.y > viewport_size.y - 10:
		desired.y = pointer.y - card.size.y - 12
	desired.x = clampf(desired.x, 10, maxf(10, viewport_size.x - card.size.x - 10))
	desired.y = clampf(desired.y, 10, maxf(10, viewport_size.y - card.size.y - 10))
	card.position = desired.round()
