extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/character_creation.tscn").instantiate()
	root.add_child(scene)
	for i in 5: await process_frame
	var p = scene.preview
	var factor: float = minf(p.size.x/(272.0*1.15),p.size.y/528.0)
	var origin: Vector2 = (p.size-Vector2(272,528)*factor)*0.5+Vector2(8,8)*factor
	print("PREVIEW ",p.global_position," ",p.size," FACTOR ",factor," ORIGIN ",p.global_position+origin)
	quit()
