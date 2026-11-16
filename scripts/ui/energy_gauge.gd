extends Control
## Barra compacta com capacidade máxima e energia disponível.

var bar: ProgressBar
var capacity: float = 50.0
var available: float = 50.0
var capacity_width: float = 90.0


func _init() -> void:
	custom_minimum_size = Vector2(210, 22)
	mouse_filter = Control.MOUSE_FILTER_PASS
	bar = UiKit.bar(UiKit.ENERGY, 22)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	# Desenha os limites acima do preenchimento da barra.
	var marks := Control.new()
	marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marks.draw.connect(_draw_limits.bind(marks))
	add_child(marks)


func update_energy(current: float, maximum: float) -> void:
	capacity = maxf(1.0, maximum)
	available = clampf(current, 0.0, capacity)
	# A capacidade maior aumenta a largura até o espaço disponível no HUD.
	capacity_width = clampf(capacity * 1.6, 80.0, 210.0)
	bar.size = Vector2(capacity_width, 22)
	bar.max_value = capacity
	bar.value = available
	tooltip_text = "Energia disponível: %d / %d\nEsquiva: %d de energia e %.1f s de recarga.\nRegeneração base: %.1f por segundo.\nUse poções de energia pelo inventário.\nA marca dourada indica a capacidade máxima." % [int(available), int(capacity), int(Balance.DODGE_COST), Balance.DODGE_COOLDOWN, Balance.ENERGY_REGEN]
	get_child(1).queue_redraw()


func _draw_limits(marks: Control) -> void:
	# Extremidade destacada mostra o teto atual de energia.
	marks.draw_line(Vector2(capacity_width - 1, 0), Vector2(capacity_width - 1, 22), UiKit.GOLD, 2.0)
