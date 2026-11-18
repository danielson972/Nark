extends SceneTree
func _initialize() -> void:
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 for group: Node2D in scene.get_node("Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos").get_children():
  var image: Image = group.get_node("Base").texture.get_image()
  var raw: Rect2i = image.get_used_rect()
  for y in image.get_height():
   for x in image.get_width():
    if image.get_pixel(x,y).a < .75: image.set_pixel(x,y,Color.TRANSPARENT)
  print(group.name," raw=",raw," opaque=",image.get_used_rect())
 scene.free()
 quit()
