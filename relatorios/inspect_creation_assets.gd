extends SceneTree
func _initialize() -> void:
 for path: String in ["cabelos/curto_de_lado", "cabelos/longo_liso", "barbas/quadrada"]:
  var texture: Texture2D = load("res://assets/game/sprites/racas/" + path + ".png")
  var image: Image = texture.get_image()
  print(path, " size=", image.get_size(), " bounds=", image.get_used_rect(), " corner=", image.get_pixel(0,0))
 quit()
