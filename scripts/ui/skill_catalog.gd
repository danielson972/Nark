extends RefCounted
## Coordinates match the supplied sheet, with one row per class.

const ATLAS_PATH = "res://assets/game/ui/skills/skills_atlas.png"
const ICON_CELLS = {
	"tiro_preciso": Vector2i(0, 0), "disparo_leque": Vector2i(1, 0), "mira_firme": Vector2i(2, 0),
	"flecha_contencao": Vector2i(3, 0), "ponto_fraco": Vector2i(4, 0), "chuva_flechas": Vector2i(5, 0),
	"projetil_arcano": Vector2i(0, 1), "campo_gelido": Vector2i(1, 1), "fluxo_arcano": Vector2i(2, 1),
	"passo_arcano": Vector2i(3, 1), "rastro_gelido": Vector2i(4, 1), "cometa_arcano": Vector2i(5, 1),
	"talho_circular": Vector2i(0, 2), "quebra_guarda": Vector2i(1, 2), "impeto": Vector2i(2, 2),
	"investida": Vector2i(3, 2), "brecha_tatica": Vector2i(4, 2), "golpe_ruptura": Vector2i(5, 2),
	"corte_duplo": Vector2i(0, 3), "adaga_arremesso": Vector2i(1, 3), "oportunismo": Vector2i(2, 3),
	"passo_sombrio": Vector2i(3, 3), "emboscada": Vector2i(4, 3), "execucao": Vector2i(5, 3),
	"pancada_escudo": Vector2i(0, 4), "abalo_sismico": Vector2i(1, 4), "guarda_firme": Vector2i(2, 4),
	"bastiao": Vector2i(3, 4), "retaliacao": Vector2i(4, 4), "revanche_ferro": Vector2i(5, 4),
	"estocada": Vector2i(0, 5), "selo_desafio": Vector2i(1, 5), "juramento": Vector2i(2, 5),
	"carga_real": Vector2i(3, 5), "cerco": Vector2i(4, 5), "estandarte_real": Vector2i(5, 5),
	"bonus_hp_grade": Vector2i(0, 6), "bonus_velocidade_grade": Vector2i(1, 6),
	"bonus_resistencia_grade": Vector2i(2, 6), "explosao_aura": Vector2i(3, 6), "despertar_heroico": Vector2i(4, 6),
}

# These entries describe existing grade effects; they do not grant new skills.
const GRADE_BONUSES = [
	{"id": "bonus_hp_grade", "name": "HP máximo", "type": "passiva", "unlock": 20,
		"grade_bonus": "hp_bonus", "desc": "Aumenta o HP máximo em 8% a partir da Grade D. O bônus é aplicado automaticamente pela progressão de grade."},
	{"id": "bonus_velocidade_grade", "name": "Velocidade de movimento", "type": "passiva", "unlock": 40,
		"grade_bonus": "speed_bonus", "desc": "Aumenta a velocidade de movimento em 5% a partir da Grade C. O bônus é aplicado automaticamente pela progressão de grade."},
	{"id": "bonus_resistencia_grade", "name": "Resistência contra monstros", "type": "passiva", "unlock": 60,
		"grade_bonus": "resist", "desc": "Concede 10% de resistência contra errantes e monstros de dungeon a partir da Grade B. O bônus é aplicado automaticamente pela progressão de grade."},
]

static func atlas_rect(skill_id: String, texture_size: Vector2) -> Rect2:
	if not ICON_CELLS.has(skill_id):
		return Rect2()
	var cell: Vector2i = ICON_CELLS[skill_id]
	var start: Vector2 = Vector2(floorf(cell.x * texture_size.x / 6.0), floorf(cell.y * texture_size.y / 7.0))
	var finish: Vector2 = Vector2(floorf((cell.x + 1) * texture_size.x / 6.0), floorf((cell.y + 1) * texture_size.y / 7.0))
	return Rect2(start + Vector2.ONE * 2, finish - start - Vector2.ONE * 4)

static func definition(class_id: String, skill_id: String) -> Dictionary:
	if skill_id.is_empty():
		return {}
	if skill_id == "explosao_aura":
		return GameData.UNIVERSAL_AURA
	if skill_id == "despertar_heroico":
		return GameData.UNIVERSAL_DESPERTAR
	for bonus: Dictionary in GRADE_BONUSES:
		if bonus["id"] == skill_id:
			return bonus
	return GameData.skill(class_id, skill_id)

static func is_learned(state: PlayerState, skill: Dictionary) -> bool:
	if state == null or skill.is_empty():
		return false
	if skill.has("grade_bonus"):
		return float(state.grade().get(skill["grade_bonus"], 0.0)) > 0.0
	return state.is_skill_learned(str(skill["id"]))

static func status_text(state: PlayerState, skill: Dictionary) -> String:
	if state == null or skill.is_empty():
		return ""
	if skill.has("grade_bonus"):
		return "Bônus de grade · Ativo" if is_learned(state, skill) else "Bônus de grade · Requer nível %d" % int(skill["unlock"])
	if is_learned(state, skill):
		return "Nível %d / %d · %s" % [maxi(1, state.skill_level(str(skill["id"]))), state.skill_cap(), "Ativa" if skill["type"] == "ativa" else "Passiva"]
	var requirement: String = "Requer nível %d" % int(skill["unlock"])
	if int(skill["unlock"]) == 20:
		requirement += " e missão de classe"
	return requirement

static func cost_text(skill: Dictionary) -> String:
	if skill.is_empty():
		return ""
	if skill.has("grade_bonus"):
		return "Bônus automático · não ocupa espaço na hotbar"
	var costs: Array[String] = []
	var cost: Dictionary = skill.get("cost", {})
	for resource: String in ["mana", "energia"]:
		if cost.has(resource):
			costs.append("%d %s" % [int(cost[resource]), resource])
	if skill.has("cd"):
		costs.append(("%.1f s de recarga" % float(skill["cd"])).replace(".", ","))
	if float(skill.get("cast", 0)) > 0:
		costs.append(("%.1f s para conjurar" % float(skill["cast"])).replace(".", ","))
	return " · ".join(costs) if not costs.is_empty() else "Efeito passivo · sem ativação manual"
