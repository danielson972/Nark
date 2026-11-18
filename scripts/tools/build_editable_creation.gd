extends SceneTree
const Design = preload("res://scripts/actors/nark_design.gd")
const Custom = preload("res://scripts/actors/character_customization.gd")
var scene: Control
func put(parent: Node, node: Node, title: String, unique: bool = false) -> Node:
 node.name = title
 parent.add_child(node)
 node.owner = scene
 node.unique_name_in_owner = unique
 return node
func choice(parent: Node, title: String, caption: String, values: Array, selected: int = 0) -> void:
 var label := Label.new()
 label.text = caption
 put(parent, label, title + "Label")
 var option := OptionButton.new()
 for value in values: option.add_item(str(value))
 option.select(selected)
 put(parent, option, title, true)
func cropped(path: String) -> AtlasTexture:
 var texture := AtlasTexture.new()
 texture.atlas = load(path)
 texture.region = Rect2(Design.image_at(path).get_used_rect())
 texture.filter_clip = true
 return texture
func _initialize() -> void:
 scene = Control.new()
 scene.name = "CharacterCreation"
 scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var background := TextureRect.new()
 background.texture = load("res://assets/game/ui/creation/ruins_background.png")
 background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 background.modulate = Color(.32,.35,.4)
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 put(scene, background, "Fundo")
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for edge: String in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_" + edge,24)
 put(scene, margin, "Margens")
 var row := HBoxContainer.new()
 row.add_theme_constant_override("separation",32)
 put(margin,row,"Colunas")
 var scroll := ScrollContainer.new()
 scroll.custom_minimum_size.x = 340
 put(row,scroll,"Rolagem")
 var fields := VBoxContainer.new()
 fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 fields.add_theme_constant_override("separation",6)
 put(scroll,fields,"Escolhas")
 var title := Label.new()
 title.text = "CRIE SEU HERÓI"
 title.add_theme_font_size_override("font_size",25)
 title.add_theme_color_override("font_color",Color("e6c27c"))
 put(fields,title,"Titulo")
 var name_field := LineEdit.new()
 name_field.text = "Aurora"
 name_field.max_length = 14
 name_field.placeholder_text = "Nome do herói"
 put(fields,name_field,"Nome",true)
 choice(fields,"Raca","Raça",["Humano","Elfo","Orc","Anão","Elarim"])
 choice(fields,"Modelo","Modelo",["Masculino","Feminino"])
 choice(fields,"Corpo","Corpo",["Magro","Médio","Forte"],1)
 var class_names: Array = []
 for id: String in GameData.CLASSES: class_names.append(GameData.CLASSES[id].name)
 choice(fields,"Classe","Classe",class_names,GameData.CLASSES.keys().find("guerreiro"))
 choice(fields,"EscolhaCabelo","Cabelo",["Careca","Curto de lado","Ondas curtas","Franja lisa","Moicano","Curto lilás","Ondas longas","Longo liso","Tranças orc","Tranças anãs","Longo elarim"])
 choice(fields,"CorCabelo","Cor do cabelo",Custom.COLOR_NAMES.values())
 choice(fields,"EscolhaBarba","Barba",["Sem barba","Rala","Cavanhaque","Quadrada","Bifurcada","Curta prateada"])
 choice(fields,"CorBarba","Cor da barba",["Original"] + Custom.COLOR_NAMES.values())
 var right := VBoxContainer.new()
 right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 put(row,right,"Apresentacao")
 var summary := Label.new()
 summary.text = "Humano · Guerreiro"
 summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 summary.add_theme_font_size_override("font_size",24)
 put(right,summary,"Resumo",true)
 var preview := Control.new()
 preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
 preview.custom_minimum_size = Vector2(200,220)
 preview.set_script(load("res://scripts/ui/creation_portrait.gd"))
 put(right,preview,"Personagem",true)
 var anchor := Control.new()
 anchor.anchor_left = .5
 anchor.anchor_right = .5
 anchor.anchor_top = 1
 anchor.anchor_bottom = 1
 anchor.offset_top = -12
 anchor.offset_bottom = -12
 anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
 put(preview,anchor,"Apoio")
 var models := Node2D.new()
 models.scale = Vector2.ONE * .4
 put(anchor,models,"Modelos")
 var source: Texture2D = load("res://assets/game/ui/creation/front_races_reference.png")
 var races: Array = ["humano","elfo","orc","anao","elarim"]
 for gender in 2:
  for race_index in 5:
   var start := Vector2i(roundi(race_index * source.get_width()/5.0), roundi(gender * source.get_height()/2.0))
   var end := Vector2i(roundi((race_index+1) * source.get_width()/5.0),roundi((gender+1)*source.get_height()/2.0))
   var texture := AtlasTexture.new()
   texture.atlas = source
   texture.region = Rect2(Vector2(start),Vector2(end-start))
   texture.filter_clip = true
   var bounds: Rect2i = texture.get_image().get_used_rect()
   var group := Node2D.new()
   group.visible = gender == 0 and race_index == 0
   group.position = Vector2(-bounds.get_center().x, -(end.y-start.y))
   put(models,group,races[race_index] + ("_masculino" if gender == 0 else "_feminino"))
   var base := Sprite2D.new()
   base.centered = false
   base.texture = texture
   base.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
   put(group,base,"Base")
   var hairs := Node2D.new()
   put(group,hairs,"Cabelos")
   var beards := Node2D.new()
   put(group,beards,"Barbas")
   var center_x: float = bounds.get_center().x
   var top: float = bounds.position.y
   for style in range(1,Design.HAIRS.size()):
    var hair := Sprite2D.new()
    hair.centered = false
    hair.visible = false
    hair.texture = cropped(Design.ROOT + "racas/cabelos/" + Design.HAIRS[style] + ".png")
    var target_width: float = 106.0 if race_index == 3 else 98.0
    # Preserve accessory proportions; fit its crown to the forehead.
    var factor: float = target_width / hair.texture.get_width()
    hair.scale = Vector2(factor, minf(factor, 48.0 / hair.texture.get_height()) if style < 6 else factor)
    hair.position = Vector2(center_x-target_width*.5,top-4)
    var material := ShaderMaterial.new()
    material.shader = load("res://shaders/fitted_hair.gdshader")
    material.set_shader_parameter("hair_color",Custom.COLORS.castanho)
    hair.material = material
    put(hairs,hair,"Modelo%d" % style)
   for style in range(1,Design.BEARDS.size()):
    var beard := Sprite2D.new()
    beard.centered = false
    beard.visible = false
    beard.texture = cropped(Design.ROOT + "racas/barbas/" + Design.BEARDS[style] + ".png")
    var target_width: float = 62.0
    beard.scale = Vector2.ONE * target_width / beard.texture.get_width()
    beard.position = Vector2(center_x-target_width*.5,top + (83 if race_index == 3 else 88))
    var material := ShaderMaterial.new()
    material.shader = load("res://shaders/character_beard.gdshader")
    beard.material = material
    put(beards,beard,"Modelo%d" % style)
 var description := Label.new()
 description.text = "Ambicioso e sociável. O reino abre portas para quem sabe negociar.\nRompe guardas e pune quem tenta se proteger."
 description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 put(right,description,"Descricao",true)
 var actions := HBoxContainer.new()
 put(right,actions,"Acoes")
 for caption: String in ["Voltar","Iniciar aventura"]:
  var button := Button.new()
  button.text = caption
  button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  button.custom_minimum_size.y = 46
  put(actions,button,"Voltar" if caption == "Voltar" else "Concluir",true)
 scene.set_script(load("res://scripts/ui/character_creation.gd"))
 var packed := PackedScene.new()
 assert(packed.pack(scene) == OK)
 assert(ResourceSaver.save(packed,"res://scenes/character_creation.tscn") == OK)
 scene.free()
 print("EDITABLE_CREATION_SAVED: UI + 10 bases + 100 hair sprites + 50 beard sprites")
 quit()
