extends SceneTree
const Design = preload("res://scripts/actors/nark_design.gd")
func _initialize() -> void:
 var gallery := Image.create(704,192,false,Image.FORMAT_RGBA8)
 var player := PlayerState.create("Teste","humano","guerreiro")
 for i in 11:
  player.hair_style = i
  gallery.blend_rect(Design.body(player).get_image(),Rect2i(0,0,64,64),Vector2i(i*64,0))
 player.hair_style = 0
 for i in 6:
  player.beard_style = i
  gallery.blend_rect(Design.body(player).get_image(),Rect2i(0,0,64,64),Vector2i(i*64,64))
 player.beard_style = 0
 for i in 6:
  for slot: String in Design.ARMOR_SLOTS:
   var id: String = "guerreiro_" + ["no_grade","d","c","b","a","s"][i] + "_" + slot
   player.add_item(id,1,true)
   player.equip(id)
  gallery.blend_rect(Design.body(player).get_image(),Rect2i(0,0,64,64),Vector2i(i*64,128))
 gallery.resize(2112,576,Image.INTERPOLATE_NEAREST)
 gallery.save_png("res://relatorios/new-customization-gallery.png")
 quit()
