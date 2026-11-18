extends Control
## Layout and appearance layers are authored in character_creation.tscn.
signal submitted(race_id: String, class_id: String, hero_name: String, hair_style: int, hair_color: String, gender_id: String, beard_style: int, beard_color: String, body_type: String)
signal back_requested
const Custom = preload("res://scripts/actors/character_customization.gd")
const RACE_IDS = ["humano", "elfo", "orc", "anao", "elarim"]
@export var race_id: String = "humano"
@export var class_id: String = "guerreiro"
@export var gender_id: String = "masculino"
@export var body_type: String = "medio"
@export_range(0,10) var hair_style: int = 0
@export var hair_color: String = "castanho"
@export_range(0,5) var beard_style: int = 0
@export var beard_color: String = "original"
@export var hero_name: String = "Aurora"
var preview: Control
var name_field: LineEdit
func _ready() -> void:
 preview = %Personagem
 name_field = %Nome
 name_field.text = hero_name
 name_field.text_changed.connect(func(value): hero_name = value)
 %Raca.item_selected.connect(func(i): race_id = RACE_IDS[i]; _refresh())
 %Modelo.item_selected.connect(func(i): gender_id = ["masculino","feminino"][i]; _refresh())
 %Corpo.item_selected.connect(func(i): body_type = ["magro","medio","forte"][i]; _refresh())
 %Classe.item_selected.connect(func(i): class_id = GameData.CLASSES.keys()[i]; _refresh())
 %EscolhaCabelo.item_selected.connect(func(i): hair_style = i; _refresh())
 %CorCabelo.item_selected.connect(func(i): hair_color = Custom.COLORS.keys()[i]; _refresh())
 %EscolhaBarba.item_selected.connect(func(i): beard_style = i; _refresh())
 %CorBarba.item_selected.connect(func(i): beard_color = (["original"] + Custom.COLORS.keys())[i]; _refresh())
 %Voltar.pressed.connect(func(): back_requested.emit())
 %Concluir.pressed.connect(submit)
 _refresh()
func _refresh() -> void:
 if preview == null: return
 var state := PlayerState.create(hero_name, race_id, class_id)
 state.gender_id = gender_id
 state.body_type = body_type
 state.set_hair(hair_style,hair_color,false)
 state.set_beard(beard_style,beard_color,false)
 for slot: String in PlayerState.EQUIP_SLOTS: state.equipment[slot] = {}
 preview.apply_appearance(state)
 %Resumo.text = "%s · %s" % [GameData.race(race_id).name,state.class_data().name]
 %Descricao.text = "%s\n%s" % [GameData.race(race_id).desc,state.class_data().desc]
 %Raca.select(maxi(RACE_IDS.find(race_id),0))
 %Modelo.select(1 if gender_id == "feminino" else 0)
 %Corpo.select(maxi(["magro","medio","forte"].find(body_type),0))
 %Classe.select(maxi(GameData.CLASSES.keys().find(class_id),0))
 %EscolhaCabelo.select(hair_style)
 %CorCabelo.select(maxi(Custom.COLORS.keys().find(hair_color),0))
 %CorCabelo.disabled = hair_style == 0
 %EscolhaBarba.select(beard_style)
 %CorBarba.select(maxi((["original"] + Custom.COLORS.keys()).find(beard_color),0))
 %CorBarba.disabled = beard_style == 0
func submit() -> void:
 submitted.emit(race_id,class_id,name_field.text,hair_style,hair_color,gender_id,beard_style,beard_color,body_type)
