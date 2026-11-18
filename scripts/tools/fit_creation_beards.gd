extends SceneTree
func _initialize() -> void:
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 var models = scene.get_node("Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos")
 for group: Node2D in models.get_children():
  var bounds: Rect2i = group.get_node("Base").texture.get_image().get_used_rect()
  var race: String = str(group.name).get_slice("_",0)
  var mouth: float = {"humano":77.0,"elfo":75.0,"orc":76.0,"anao":73.0,"elarim":75.0}[race]
  if str(group.name).ends_with("feminino"): mouth -= 3.0
  for beard: Sprite2D in group.get_node("Barbas").get_children():
   beard.position.y = bounds.position.y + mouth
 var packed := PackedScene.new()
 assert(packed.pack(scene) == OK)
 assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
 scene.free()
 quit()
