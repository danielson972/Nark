extends SceneTree
const Design = preload("res://scripts/actors/nark_design.gd")
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 root.size = Vector2i(1280, 720)
 var creation = load("res://scenes/character_creation.tscn").instantiate()
 root.add_child(creation)
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://relatorios/new-character-creation.png")
 creation.queue_free()
 await process_frame
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game._on_new_game("elarim", "guerreiro", "Teste")
 await process_frame
 await process_frame
 game.ui.show_inventory_panel()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://relatorios/new-equipment-panel.png")
 game.queue_free()
 await process_frame
 var gallery := Image.create(512, 256, false, Image.FORMAT_RGBA8)
 for row in 8:
  var player := PlayerState.create("Teste", "humano", "guerreiro")
  player.hair_style = 2
  gallery.blend_rect(Design.body(player, row, 0).get_image(), Rect2i(0,0,64,64), Vector2i(row*64,0))
  player.equipment = {}
  gallery.blend_rect(Design.body(player, row, 0).get_image(), Rect2i(0,0,64,64), Vector2i(row*64,64))
  player.race_id = "anao"
  gallery.blend_rect(Design.body(player, row, 0).get_image(), Rect2i(0,0,64,64), Vector2i(row*64,128))
  player.race_id = "orc"
  gallery.blend_rect(Design.body(player, row, 0).get_image(), Rect2i(0,0,64,64), Vector2i(row*64,192))
 gallery.resize(1536,768,Image.INTERPOLATE_NEAREST)
 gallery.save_png("res://relatorios/new-design-gallery.png")
 print("NEW_DESIGN_RENDER complete")
 quit()
