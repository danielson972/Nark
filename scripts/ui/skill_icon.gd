extends Control
## Draws a named region from the original supplied atlas, preserving its alpha.

const Catalog = preload("res://scripts/ui/skill_catalog.gd")
static var atlas: Texture2D

var definition: Dictionary = {}:
    set(value):
        definition = value
        queue_redraw()
var learned: bool = true:
    set(value):
        learned = value
        queue_redraw()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    resized.connect(queue_redraw)

func _draw() -> void:
    if definition.is_empty():
        return
    if atlas == null:
        atlas = load(Catalog.ATLAS_PATH)
    if atlas == null:
        return
    var source: Rect2 = Catalog.atlas_rect(str(definition.get("id", "")), atlas.get_size())
    if source.size == Vector2.ZERO:
        return
    var side: float = minf(size.x, size.y)
    var destination: Rect2 = Rect2(((size - Vector2.ONE * side) * 0.5).floor(), Vector2.ONE * side)
    var tint: Color = Color.WHITE if learned else Color(0.42, 0.42, 0.42, 0.88)
    draw_texture_rect_region(atlas, destination, source, tint)
