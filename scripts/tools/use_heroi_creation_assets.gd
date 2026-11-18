extends SceneTree
const PREFIX = "Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos"
const FOLDER = "res://assets/game/sprites/heroi/"
func bounds(texture: Texture2D) -> Rect2i:
 var image: Image = texture.get_image()
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a < .75: image.set_pixel(x,y,Color.TRANSPARENT)
 return image.get_used_rect()
func crop(path: String) -> AtlasTexture:
 var texture := AtlasTexture.new()
 texture.atlas = load(path)
 texture.region = Rect2(bounds(texture.atlas))
 texture.filter_clip = true
 return texture
func _initialize() -> void:
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 var models: Node2D = scene.get_node(PREFIX)
 var human: Sprite2D = models.get_node("humano_masculino/Base")
 var old_bounds: Rect2i = bounds(human.texture)
 var old_foot := Vector2(old_bounds.get_center().x,old_bounds.end.y)
 var anchor: Vector2 = human.get_parent().transform * (human.transform * old_foot)
 var target_height: float = human.scale.y * old_bounds.size.y
 var reference: Texture2D = load(FOLDER + "criacao/humano/masculino/medio.png")
 var factor: float = target_height / bounds(reference).size.y
 for group: Node2D in models.get_children():
  var race: String = str(group.name).get_slice("_",0)
  var gender: String = str(group.name).get_slice("_",1)
  var nodes: Dictionary = {"medio":"Base","magro":"BaseMagro","forte":"BaseForte"}
  for body: String in nodes:
   var base: Sprite2D = group.get_node(nodes[body])
   base.texture = load(FOLDER + "criacao/%s/%s/%s.png" % [race,gender,body])
   base.material = null
   base.centered = false
   base.offset = Vector2.ZERO
   base.rotation = 0.0
   base.scale = Vector2.ONE * factor
   base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   var rect: Rect2i = bounds(base.texture)
   base.position = group.transform.affine_inverse() * anchor - Vector2(rect.get_center().x,rect.end.y) * factor
   base.visible = body == "medio"
  var medium: Sprite2D = group.get_node("Base")
  var rect: Rect2i = bounds(medium.texture)
  var center: float = rect.get_center().x
  var width: float = 11.0 if race == "anao" else 10.0
  group.get_node("Cabelos").transform = medium.transform
  group.get_node("Barbas").transform = medium.transform
  for hair: Sprite2D in group.get_node("Cabelos").get_children():
   var style: int = int(str(hair.name).trim_prefix("Modelo"))
   hair.texture = crop(FOLDER + "cabelos/frente/%02d.png" % style)
   var scale_x: float = width / hair.texture.get_width()
   var scale_y: float = minf(scale_x,4.5/hair.texture.get_height()) if style < 6 else scale_x
   hair.position = Vector2(center-width*.5,rect.position.y-1)
   hair.scale = Vector2(scale_x,scale_y)
   hair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  for beard: Sprite2D in group.get_node("Barbas").get_children():
   var style: int = int(str(beard.name).trim_prefix("Modelo"))
   beard.texture = crop(FOLDER + "barbas/frente/%02d.png" % style)
   beard.position = Vector2(center-3,rect.position.y+6)
   beard.scale = Vector2.ONE * 6.0 / beard.texture.get_width()
   beard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 models.set_meta("portrait_foot_anchor",anchor)
 models.set_meta("portrait_visual_height",target_height)
 var packed := PackedScene.new()
 assert(packed.pack(scene) == OK)
 assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
 print("HEROI_CREATION_REPLACED actual_body_art=30 front_hair_layers=100 front_beard_layers=50 anchor=",anchor)
 scene.free()
 quit()
