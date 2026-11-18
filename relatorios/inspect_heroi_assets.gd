extends SceneTree
func _initialize() -> void:
 for path: String in ["criacao/humano/masculino/medio.png","criacao/anao/masculino/medio.png","cabelos/frente/01.png","cabelos/frente/07.png","barbas/frente/03.png","cabelos/topdown/01.png","topdown/parado/humano/masculino/medio/s.png"]:
  var image: Image = Image.load_from_file("res://assets/game/sprites/heroi/"+path)
  print(path," bounds=",image.get_used_rect())
 quit()
