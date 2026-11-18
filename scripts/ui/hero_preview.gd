extends Control
const Design = preload("res://scripts/actors/nark_design.gd")
var state: PlayerState
@export var show_hair: bool = true
@export var draw_character: bool = true
@export var max_preview_size: float = 0.0
@export var align_bottom: bool = false
var walking: bool = false
var direction: int = 0
var clock: float = 0.0
func _ready() -> void:
 var old_base := get_node_or_null("BaseCarecaEditor")
 if old_base != null: old_base.hide()
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 resized.connect(queue_redraw)
func _process(delta: float) -> void:
 if walking:
  clock += delta
  queue_redraw()
func _draw() -> void:
 if state == null or not draw_character: return
 var texture: AtlasTexture = Design.body(state, direction, int(clock * 9.0) % 6 if walking else 0, true, walking)
 var side: float = floorf(minf(size.x, size.y) * 0.94)
 if max_preview_size > 0.0:
  side = minf(side, max_preview_size)
 # Use whole pixel multiples when enlarging the 64px source.
 if side >= 64.0:
  side = floorf(side / 64.0) * 64.0
 var origin: Vector2 = ((size - Vector2.ONE * side) * 0.5).floor()
 if align_bottom: origin.y = floorf(size.y - side - 8.0)
 draw_texture_rect(texture, Rect2(origin, Vector2.ONE * side), false)
