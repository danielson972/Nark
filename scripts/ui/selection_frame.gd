extends PanelContainer
## Ornamental frame drawn independently of the portrait and its sprite scale.
func _ready() -> void:
	resized.connect(queue_redraw)
func _draw() -> void:
	var gold := Color("8c7950")
	var light := Color("cbb786")
	draw_rect(Rect2(Vector2(5,5),size-Vector2(10,10)),Color("514832"),false,1)
	for corner: Vector2 in [Vector2(8,8),Vector2(size.x-8,8),Vector2(8,size.y-8),Vector2(size.x-8,size.y-8)]:
		var direction := Vector2(1 if corner.x < size.x*.5 else -1,1 if corner.y < size.y*.5 else -1)
		draw_polyline(PackedVector2Array([corner+Vector2(0,24)*direction,corner,corner+Vector2(24,0)*direction]),light,1,true)
		draw_line(corner+Vector2(3,16)*direction,corner+Vector2(16,3)*direction,gold,1,true)
		var center := corner+direction*3
		draw_colored_polygon(PackedVector2Array([center+Vector2(0,-3),center+Vector2(3,0),center+Vector2(0,3),center+Vector2(-3,0)]),gold)
	var center := Vector2(size.x*.5,4)
	draw_colored_polygon(PackedVector2Array([center+Vector2(0,-4),center+Vector2(5,0),center+Vector2(0,4),center+Vector2(-5,0)]),light)
