extends SceneTree
var failures: int = 0
func opaque_bounds(texture: Texture2D) -> Rect2i:
 var image: Image = texture.get_image()
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a < .75: image.set_pixel(x,y,Color.TRANSPARENT)
 return image.get_used_rect()
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
 if not value:
  failures += 1
  push_error(message)
func run() -> void:
 root.size = Vector2i(1280,720)
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 var path: String = "Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos"
 var models = scene.get_node(path)
 var reference: Sprite2D = models.get_node("humano_masculino/Base")
 var bounds: Rect2i = opaque_bounds(reference.texture)
 var foot: Vector2 = reference.get_parent().transform * (reference.transform * Vector2(bounds.get_center().x,bounds.end.y))
 check(foot.distance_to(models.get_meta("portrait_foot_anchor")) < .01,"Saved portrait anchor changed")
 root.add_child(scene)
 await process_frame
 var gallery := Image.create(900,520,false,Image.FORMAT_RGBA8)
 var index: int = 0
 for race: String in ["humano","elfo","orc","anao","elarim"]:
  for gender: String in ["masculino","feminino"]:
   scene.race_id = race
   scene.gender_id = gender
   scene.hair_style = 1
   scene.beard_style = 3 if gender == "masculino" else 0
   var group = models.get_node(race+"_"+gender)
   var base: Sprite2D = group.get_node("Base")
   var rect: Rect2i = opaque_bounds(base.texture)
   var actual: Vector2 = group.transform * (base.transform * Vector2(rect.get_center().x,rect.end.y))
   check(actual.distance_to(foot) < .01,"Unaligned feet: " + str(group.name))
   var previous: Transform2D = base.transform
   for body: String in ["magro","medio","forte"]:
    var sprite: Sprite2D = group.get_node({"magro":"BaseMagro","medio":"Base","forte":"BaseForte"}[body])
    check(sprite.texture.resource_path == "res://assets/game/sprites/heroi/criacao/%s/%s/%s.png" % [race,gender,body],"Wrong physical build art")
    check(sprite.material == null,"Build must use supplied art without deformation")
    scene.get_node("%Corpo").item_selected.emit(["magro","medio","forte"].find(body))
    check(scene.preview.state.body_type == body,"Body selection not propagated")
    check(base.visible == (body == "medio"),"Medium visibility")
    check(group.get_node("BaseMagro").visible == (body == "magro"),"Slim visibility")
    check(group.get_node("BaseForte").visible == (body == "forte"),"Strong visibility")
    check(base.transform == previous,"Runtime changed authored transform")
   scene.body_type = "medio"
   scene._refresh()
   await process_frame
   await RenderingServer.frame_post_draw
   var capture: Image = root.get_texture().get_image().get_region(Rect2i(550,290,180,260))
   var column: int = index / 2
   var row: int = index % 2
   gallery.blit_rect(capture,Rect2i(0,0,180,260),Vector2i(column*180,row*260))
   index += 1
 gallery.save_png("res://relatorios/creation-aligned-models.png")
 var builds := Image.create(540,260,false,Image.FORMAT_RGBA8)
 var fingerprints: Array = []
 scene.race_id = "humano"
 scene.gender_id = "masculino"
 scene.hair_style = 1
 scene.beard_style = 3
 for i in 3:
  scene.get_node("%Corpo").item_selected.emit(i)
  await process_frame
  await RenderingServer.frame_post_draw
  var capture: Image = root.get_texture().get_image().get_region(Rect2i(550,290,180,260))
  fingerprints.append(hash(capture.get_data()))
  builds.blit_rect(capture,Rect2i(0,0,180,260),Vector2i(i*180,0))
 check(fingerprints[0] != fingerprints[1] and fingerprints[1] != fingerprints[2],"Physical builds must differ visibly")
 builds.save_png("res://relatorios/creation-build-comparison.png")
 scene.queue_free()
 await process_frame
 print("CREATION_BUILDS models=10 builds=30 portrait_anchor_preserved=true failures=%d" % failures)
 quit(0 if failures == 0 else 1)
