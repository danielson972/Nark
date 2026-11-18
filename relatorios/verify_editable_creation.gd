extends SceneTree
var failures: int = 0
func _initialize() -> void:
 call_deferred("run")
func check(value: bool, message: String) -> void:
 if not value:
  failures += 1
  push_error(message)
func run() -> void:
 root.size = Vector2i(1280,720)
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 check(scene.find_child("Raca",true,false) != null,"UI must exist before entering tree")
 var models = scene.get_node("Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos")
 check(models.get_child_count() == 10,"Ten authored race/gender groups")
 root.add_child(scene)
 await process_frame
 for race: String in ["humano","elfo","orc","anao","elarim"]:
  for gender: String in ["masculino","feminino"]:
   scene.race_id = race
   scene.gender_id = gender
   scene.hair_style = 1
   scene.beard_style = 3
   var group = models.get_node(race+"_"+gender)
   var hair: Sprite2D = group.get_node("Cabelos/Modelo1")
   var initial: Transform2D = hair.transform
   scene._refresh()
   check(group.visible and hair.visible,"Selection must switch authored layers")
   check(group.get_node("Barbas/Modelo3").visible,"Selected beard")
   check(hair.texture.get_image().get_pixel(0,0).a < 1.0,"Accessory retains alpha")
   check(hair.transform == initial,"Selection must preserve editor transforms")
 scene.race_id = "humano"
 scene.gender_id = "masculino"
 scene.hair_style = 1
 scene.beard_style = 3
 scene._refresh()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://relatorios/editable-creation-hair-beard.png")
 scene.hair_style = 7
 scene.beard_style = 0
 scene._refresh()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://relatorios/editable-creation-long-hair.png")
 scene.queue_free()
 await process_frame
 print("EDITABLE_CREATION groups=10 hair_layers=100 beard_layers=50 failures=%d" % failures)
 quit(0 if failures == 0 else 1)
