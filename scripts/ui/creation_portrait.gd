extends Control
## Only switches authored Sprite2D visibility and colors. Editor transforms stay intact.
const Custom = preload("res://scripts/actors/character_customization.gd")
var state: PlayerState
func apply_appearance(player: PlayerState) -> void:
 state = player
 var active: String = state.race_id + "_" + state.gender_id
 for group: Node2D in $Apoio/Modelos.get_children():
  group.visible = str(group.name) == active
  if not group.visible: continue
  group.get_node("Base").visible = state.body_type == "medio"
  group.get_node("BaseMagro").visible = state.body_type == "magro"
  group.get_node("BaseForte").visible = state.body_type == "forte"
  for hair: Sprite2D in group.get_node("Cabelos").get_children():
   hair.visible = str(hair.name) == "Modelo%d" % state.hair_style
   if hair.visible:
    hair.material.set_shader_parameter("hair_color",Custom.COLORS.get(state.hair_color,Custom.COLORS.castanho))
  for beard: Sprite2D in group.get_node("Barbas").get_children():
   beard.visible = str(beard.name) == "Modelo%d" % state.beard_style
   if beard.visible:
    beard.material.set_shader_parameter("original_color",state.beard_color == "original")
    beard.material.set_shader_parameter("beard_color",Custom.COLORS.get(state.beard_color,Custom.COLORS.castanho))
