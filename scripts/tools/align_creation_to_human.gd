extends SceneTree
const PREFIX = "Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos"
func opaque_bounds(texture: Texture2D) -> Rect2i:
 var image: Image = texture.get_image()
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a < .75: image.set_pixel(x,y,Color.TRANSPARENT)
 return image.get_used_rect()
func _initialize() -> void:
 var scene = load("res://scenes/character_creation.tscn").instantiate()
 var models: Node2D = scene.get_node(PREFIX)
 var reference: Node2D = models.get_node("humano_masculino")
 var original: Sprite2D = reference.get_node("Base")
 var saved_transform: Transform2D = original.transform
 var saved_group: Transform2D = reference.transform
 var reference_bounds: Rect2i = opaque_bounds(original.texture)
 var reference_foot := Vector2(reference_bounds.get_center().x, reference_bounds.end.y)
 for group: Node2D in models.get_children():
  var base: Sprite2D = group.get_node("Base")
  var bounds: Rect2i = opaque_bounds(base.texture)
  var foot := Vector2(bounds.get_center().x,bounds.end.y)
  group.transform = saved_group
  base.transform = saved_transform
  base.position += saved_transform.basis_xform(reference_foot-foot)
  base.visible = true
  for label: String in ["Cabelos","Barbas"]:
   # Accessory anchors are in the source portrait's coordinates.
   group.get_node(label).transform = base.transform
  var center_x: float = bounds.get_center().x
  var width: float = 106.0 if str(group.name).begins_with("anao") else 98.0
  for hair: Sprite2D in group.get_node("Cabelos").get_children():
   var style: int = int(str(hair.name).trim_prefix("Modelo"))
   var factor: float = width / hair.texture.get_width()
   hair.scale = Vector2(factor,minf(factor,48.0 / hair.texture.get_height()) if style < 6 else factor)
   hair.position = Vector2(center_x-width*.5,bounds.position.y-7)
  var race: String = str(group.name).get_slice("_",0)
  var mouth: float = {"humano":68.0,"elfo":68.0,"orc":68.0,"anao":63.0,"elarim":68.0}[race]
  for beard: Sprite2D in group.get_node("Barbas").get_children():
   beard.position = Vector2(center_x-31,bounds.position.y+mouth)
  # Author all three physical builds as separate, editable Sprite2D nodes.
  for kind: String in ["magro","forte"]:
   var node_name: String = "BaseMagro" if kind == "magro" else "BaseForte"
   var variant: Sprite2D = group.get_node_or_null(node_name)
   if variant == null:
    variant = Sprite2D.new()
    variant.name = node_name
    group.add_child(variant)
    variant.owner = scene
   variant.texture = base.texture
   variant.centered = base.centered
   variant.offset = base.offset
   variant.transform = base.transform
   variant.texture_filter = base.texture_filter
   variant.visible = false
   var atlas: AtlasTexture = base.texture
   var material := ShaderMaterial.new()
   material.shader = load("res://shaders/creation_body_shape.gdshader")
   var size: Vector2 = atlas.atlas.get_size()
   material.set_shader_parameter("region",Vector4(atlas.region.position.x/size.x,atlas.region.position.y/size.y,atlas.region.size.x/size.x,atlas.region.size.y/size.y))
   material.set_shader_parameter("center_x",bounds.get_center().x/atlas.region.size.x)
   material.set_shader_parameter("shoulders",(bounds.position.y+105.0)/atlas.region.size.y)
   material.set_shader_parameter("hips",(bounds.position.y+245.0)/atlas.region.size.y)
   material.set_shader_parameter("body_width",.80 if kind == "magro" else 1.22)
   variant.material = material
  # Keep accessories above every build even after adding the variant nodes.
  group.get_node("Cabelos").z_index = 2
  group.get_node("Barbas").z_index = 3
 assert(original.transform.is_equal_approx(saved_transform))
 assert(reference.transform.is_equal_approx(saved_group))
 var packed := PackedScene.new()
 assert(packed.pack(scene) == OK)
 assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
 print("CREATION_ALIGNED reference=",saved_transform," builds=30")
 scene.free()
 quit()
