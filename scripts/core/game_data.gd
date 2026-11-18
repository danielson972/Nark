class_name GameData
extends RefCounted

const COIN_VALUES = {"ouro": 10000, "prata": 100, "bronze": 1}
const TELEPORT_GOLD_COST = 2



const TITLE: = "RPG do Reino"
const REGION_NAME: = "Vale de Aurora"



const RACES: = {
	"humano": {
		"name": "Humano", 
		"desc": "Ambicioso e sociável. O reino abre portas para quem sabe negociar.", 
		"bonus": "+10% de fama em missões e 10% de desconto com os NPCs.", 
		"hp": 0, 
		"speed": 0.0, 
		"regen": 1.0, 
		"fame_bonus": 0.1, 
		"discount": 0.1, 
		"low_hp_damage": 0.0, 
		"craft_bonus": 0.0, 
		"coin_bonus": 0.0, 
	}, 
	"elfo": {
		"name": "Elfo", 
		"desc": "Ligado ao santuário antigo. Move-se como se o vento o empurrasse.", 
		"bonus": "Regenera energia e mana 30% mais rápido e move-se 5% mais rápido.", 
		"hp": 0, 
		"speed": 0.05, 
		"regen": 1.3, 
		"fame_bonus": 0.0, 
		"discount": 0.0, 
		"low_hp_damage": 0.0, 
		"craft_bonus": 0.0, 
		"coin_bonus": 0.0, 
	}, 
	"orc": {
		"name": "Orc", 
		"desc": "Nascido nas pedreiras. Quanto mais sangra, mais perigoso fica.", 
		"bonus": "+20 de HP e até +25% de dano com HP baixo.", 
		"hp": 20, 
		"speed": 0.0, 
		"regen": 1.0, 
		"fame_bonus": 0.0, 
		"discount": 0.0, 
		"low_hp_damage": 0.25, 
		"craft_bonus": 0.0, 
		"coin_bonus": 0.0, 
	}, 
	"anao": {
		"name": "Anão", 
		"desc": "Mestre da forja. Nenhuma liga resiste às suas mãos.", 
		"bonus": "+15% de chance no craft e +15% de moedas nos drops.", 
		"hp": 0, 
		"speed": 0.0, 
		"regen": 1.0, 
		"fame_bonus": 0.0, 
		"discount": 0.0, 
		"low_hp_damage": 0.0, 
		"craft_bonus": 0.15, 
		"coin_bonus": 0.15, 
	}, 
}



const SKILL_TIRO_PRECISO: = {
	"id": "tiro_preciso", "name": "Tiro Preciso", "unlock": 1, "type": "ativa", 
	"desc": "Concentra dano em um único alvo. 110% do dano da arma.", 
	"cost": {"mana": 6}, "cd": 1.0, "cast": 0.0, "handler": "projectile", 
	"params": {"speed": 900.0, "mult": 1.1, "range": 560.0, "pierce": 0, "kind": "arrow"}, 
}
const SKILL_DISPARO_LEQUE: = {
	"id": "disparo_leque", "name": "Disparo em Leque", "unlock": 1, "type": "ativa", 
	"desc": "Cinco flechas em cone à frente. 65% do dano cada.", 
	"cost": {"mana": 12}, "cd": 3.5, "cast": 0.15, "handler": "cone_shot", 
	"params": {"count": 5, "spread": 46.0, "speed": 780.0, "mult": 0.65, "range": 420.0}, 
}
const SKILL_MIRA_FIRME: = {
	"id": "mira_firme", "name": "Mira Firme", "unlock": 1, "type": "passiva", 
	"desc": "Ficar parado por 0,6 s carrega a mira: o próximo Tiro Preciso ganha +30% de crítico.", 
}
const SKILL_FLECHA_CONTENCAO: = {
	"id": "flecha_contencao", "name": "Flecha de Contenção", "unlock": 20, "type": "ativa", 
	"desc": "Imobiliza o alvo por 2,5 s e causa 60% do dano.", 
	"cost": {"mana": 18}, "cd": 9.0, "cast": 0.2, "handler": "projectile", 
	"params": {"speed": 820.0, "mult": 0.6, "range": 560.0, "root": 2.5, "kind": "arrow"}, 
}
const SKILL_PONTO_FRACO: = {
	"id": "ponto_fraco", "name": "Ponto Fraco", "unlock": 40, "type": "passiva", 
	"desc": "Tiro Preciso ignora 50% da defesa de alvos contidos.", 
}
const SKILL_CHUVA_FLECHAS: = {
	"id": "chuva_flechas", "name": "Chuva de Flechas", "unlock": 60, "type": "ativa", 
	"desc": "Após 0,8 s de conjuração, atinge repetidamente uma área por 3 s.", 
	"cost": {"mana": 45}, "cd": 18.0, "cast": 0.8, "handler": "rain", 
	"params": {"radius": 130.0, "duration": 3.0, "interval": 0.45, "mult": 0.42}, 
}

const SKILL_PROJETIL_ARCANO: = {
	"id": "projetil_arcano", "name": "Projétil Arcano", "unlock": 1, "type": "ativa", 
	"desc": "Dano mágico direto, ignora metade da armadura.", 
	"cost": {"mana": 8}, "cd": 1.1, "cast": 0.0, "handler": "projectile", 
	"params": {"speed": 640.0, "mult": 1.05, "range": 560.0, "magic": true, "kind": "arcane"}, 
}
const SKILL_CAMPO_GELIDO: = {
	"id": "campo_gelido", "name": "Campo Gélido", "unlock": 1, "type": "ativa", 
	"desc": "Área de gelo por 5 s que desacelera inimigos em 45%.", 
	"cost": {"mana": 20}, "cd": 8.0, "cast": 0.35, "handler": "ground_field", 
	"params": {"radius": 120.0, "duration": 5.0, "slow": 0.45, "magic": true}, 
}
const SKILL_FLUXO_ARCANO: = {
	"id": "fluxo_arcano", "name": "Fluxo Arcano", "unlock": 1, "type": "passiva", 
	"desc": "Projétil Arcano que acerta um inimigo no Campo Gélido devolve 8 de mana.", 
}
const SKILL_PASSO_ARCANO: = {
	"id": "passo_arcano", "name": "Passo Arcano", "unlock": 20, "type": "ativa", 
	"desc": "Teleporta 200 px na direção do movimento.", 
	"cost": {"mana": 22}, "cd": 6.0, "cast": 0.0, "handler": "blink", 
	"params": {"distance": 200.0, "trail": false}, 
}
const SKILL_RASTRO_GELIDO: = {
	"id": "rastro_gelido", "name": "Rastro Gélido", "unlock": 40, "type": "passiva", 
	"desc": "Passo Arcano deixa uma faixa de gelo; acertar sobre ela ativa Fluxo Arcano.", 
}
const SKILL_COMETA_ARCANO: = {
	"id": "cometa_arcano", "name": "Cometa Arcano", "unlock": 60, "type": "ativa", 
	"desc": "Conjuração de 1,2 s e queda de cometa: 300% de dano mágico em área.", 
	"cost": {"mana": 55}, "cd": 20.0, "cast": 1.2, "handler": "delayed_aoe", 
	"params": {"radius": 165.0, "mult": 3.0, "delay": 0.75, "magic": true}, 
}

const SKILL_TALHO_CIRCULAR: = {
	"id": "talho_circular", "name": "Talho Circular", "unlock": 1, "type": "ativa", 
	"desc": "Golpe giratório que atinge todos os inimigos ao redor.", 
	"cost": {"energia": 16}, "cd": 2.6, "cast": 0.1, "handler": "spin", 
	"params": {"radius": 108.0, "mult": 1.05}, 
}
const SKILL_QUEBRA_GUARDA: = {
	"id": "quebra_guarda", "name": "Quebra-Guarda", "unlock": 1, "type": "ativa", 
	"desc": "Rompe a guarda do alvo por 5 s e causa 80% do dano.", 
	"cost": {"energia": 18}, "cd": 6.0, "cast": 0.25, "handler": "bash", 
	"params": {"radius": 96.0, "arc": 110.0, "mult": 0.8, "break": 5.0}, 
}
const SKILL_IMPETO: = {
	"id": "impeto", "name": "Ímpeto", "unlock": 1, "type": "passiva", 
	"desc": "Recupera 25 de energia ao romper uma guarda.", 
}
const SKILL_INVESTIDA: = {
	"id": "investida", "name": "Investida", "unlock": 20, "type": "ativa", 
	"desc": "Avança até o inimigo e causa dano de impacto.", 
	"cost": {"energia": 24}, "cd": 8.0, "cast": 0.15, "handler": "dash_strike", 
	"params": {"distance": 260.0, "mult": 1.5, "knockback": 90.0}, 
}
const SKILL_BRECHA_TATICA: = {
	"id": "brecha_tatica", "name": "Brecha Tática", "unlock": 40, "type": "passiva", 
	"desc": "Quebra-Guarda usada até 2,5 s após a Investida causa +60% e rompe por mais tempo.", 
}
const SKILL_GOLPE_RUPTURA: = {
	"id": "golpe_ruptura", "name": "Golpe de Ruptura", "unlock": 60, "type": "ativa", 
	"desc": "Conjuração de 0,9 s: golpe pesado com +120% contra alvos de guarda quebrada.", 
	"cost": {"mana": 35}, "cd": 12.0, "cast": 0.9, "handler": "execute", 
	"params": {"radius": 120.0, "mult": 2.2, "guard_bonus": 1.2}, 
}

const SKILL_CORTE_DUPLO: = {
	"id": "corte_duplo", "name": "Corte Duplo", "unlock": 1, "type": "ativa", 
	"desc": "Dois golpes rápidos de 65% cada.", 
	"cost": {"energia": 14}, "cd": 2.2, "cast": 0.05, "handler": "spin", 
	"params": {"radius": 96.0, "mult": 0.65, "hits": 2, "interval": 0.22}, 
}
const SKILL_ADAGA_ARREMESSO: = {
	"id": "adaga_arremesso", "name": "Adaga de Arremesso", "unlock": 1, "type": "ativa", 
	"desc": "Marca um inimigo à distância por 8 s.", 
	"cost": {"energia": 10}, "cd": 4.0, "cast": 0.0, "handler": "projectile", 
	"params": {"speed": 820.0, "mult": 0.55, "range": 520.0, "mark": 8.0, "kind": "dagger"}, 
}
const SKILL_OPORTUNISMO: = {
	"id": "oportunismo", "name": "Oportunismo", "unlock": 1, "type": "passiva", 
	"desc": "Ataques pelas costas causam +30% de dano.", 
}
const SKILL_PASSO_SOMBRIO: = {
	"id": "passo_sombrio", "name": "Passo Sombrio", "unlock": 20, "type": "ativa", 
	"desc": "Reposiciona-se atrás de um alvo marcado.", 
	"cost": {"energia": 20}, "cd": 7.0, "cast": 0.0, "handler": "blink_behind", 
	"params": {"distance": 300.0}, 
}
const SKILL_EMBOSCADA: = {
	"id": "emboscada", "name": "Emboscada", "unlock": 40, "type": "passiva", 
	"desc": "O primeiro Corte Duplo após o Passo Sombrio aplica sangramento.", 
}
const SKILL_EXECUCAO: = {
	"id": "execucao", "name": "Execução", "unlock": 60, "type": "ativa", 
	"desc": "Consome a marca: +2% de dano por cada 1% de HP perdido do alvo.", 
	"cost": {"mana": 30}, "cd": 15.0, "cast": 0.4, "handler": "execute", 
	"params": {"radius": 110.0, "mult": 1.8, "missing_hp_scale": 2.0, "consume_mark": true}, 
}

const SKILL_PANCADA_ESCUDO: = {
	"id": "pancada_escudo", "name": "Pancada de Escudo", "unlock": 1, "type": "ativa", 
	"desc": "Interrompe a ação inimiga e causa 70% do dano.", 
	"cost": {"energia": 16}, "cd": 4.0, "cast": 0.15, "handler": "bash", 
	"params": {"radius": 96.0, "arc": 130.0, "mult": 0.7, "interrupt": true, "stun": 0.8}, 
}
const SKILL_ABALO_SISMICO: = {
	"id": "abalo_sismico", "name": "Abalo Sísmico", "unlock": 1, "type": "ativa", 
	"desc": "Onda ao redor que desacelera inimigos em 50% por 3 s.", 
	"cost": {"energia": 24}, "cd": 8.0, "cast": 0.3, "handler": "spin", 
	"params": {"radius": 150.0, "mult": 0.6, "slow": 0.5, "slow_time": 3.0}, 
}
const SKILL_GUARDA_FIRME: = {
	"id": "guarda_firme", "name": "Guarda Firme", "unlock": 1, "type": "passiva", 
	"desc": "Bloquear no instante do impacto não gasta energia.", 
}
const SKILL_BASTIAO: = {
	"id": "bastiao", "name": "Bastião", "unlock": 20, "type": "ativa", 
	"desc": "Avança de escudo erguido por 4 s resistindo a 70% dos golpes frontais.", 
	"cost": {"energia": 28}, "cd": 10.0, "cast": 0.0, "handler": "shield_advance", 
	"params": {"duration": 4.0, "frontal_resist": 0.7, "speed": 0.55}, 
}
const SKILL_RETALIACAO: = {
	"id": "retaliacao", "name": "Retaliação", "unlock": 40, "type": "passiva", 
	"desc": "Um bloqueio preciso amplia o alcance e o dano da próxima Pancada de Escudo.", 
}
const SKILL_REVANCHE_FERRO: = {
	"id": "revanche_ferro", "name": "Revanche de Ferro", "unlock": 60, "type": "ativa", 
	"desc": "Onda de impacto que cresce com os golpes bloqueados nos últimos 6 s.", 
	"cost": {"mana": 40}, "cd": 14.0, "cast": 0.6, "handler": "wave", 
	"params": {"radius": 130.0, "mult": 1.2, "per_block": 0.35}, 
}

const SKILL_ESTOCADA: = {
	"id": "estocada", "name": "Estocada", "unlock": 1, "type": "ativa", 
	"desc": "Atinge todos os inimigos em linha à frente.", 
	"cost": {"energia": 15}, "cd": 2.8, "cast": 0.1, "handler": "line", 
	"params": {"length": 240.0, "width": 56.0, "mult": 1.0}, 
}
const SKILL_SELO_DESAFIO: = {
	"id": "selo_desafio", "name": "Selo do Desafio", "unlock": 1, "type": "ativa", 
	"desc": "Marca um adversário para duelo por 10 s.", 
	"cost": {"energia": 12}, "cd": 6.0, "cast": 0.0, "handler": "mark", 
	"params": {"duration": 10.0, "range": 420.0, "duel": true}, 
}
const SKILL_JURAMENTO: = {
	"id": "juramento", "name": "Juramento", "unlock": 1, "type": "passiva", 
	"desc": "Recebe 25% menos dano do adversário marcado.", 
}
const SKILL_CARGA_REAL: = {
	"id": "carga_real", "name": "Carga Real", "unlock": 20, "type": "ativa", 
	"desc": "Percorre curta distância empurrando inimigos no caminho.", 
	"cost": {"energia": 26}, "cd": 9.0, "cast": 0.1, "handler": "dash_strike", 
	"params": {"distance": 300.0, "mult": 1.3, "knockback": 120.0, "push_all": true}, 
}
const SKILL_CERCO: = {
	"id": "cerco", "name": "Cerco", "unlock": 40, "type": "passiva", 
	"desc": "Carga Real interrompe o alvo marcado e o deixa vulnerável à próxima Estocada.", 
}
const SKILL_ESTANDARTE: = {
	"id": "estandarte_real", "name": "Estandarte Real", "unlock": 60, "type": "ativa", 
	"desc": "Área por 10 s: Estocadas recuperam 10 de energia.", 
	"cost": {"mana": 45}, "cd": 20.0, "cast": 0.5, "handler": "banner", 
	"params": {"radius": 150.0, "duration": 10.0}, 
}

const UNIVERSAL_AURA: = {
	"id": "explosao_aura", "name": "Explosão de Aura", "unlock": 80, "type": "ativa", 
	"desc": "Skill universal da Grade A: onda de aura que atinge e empurra ao redor.", 
	"cost": {"mana": 30}, "cd": 16.0, "cast": 0.3, "handler": "spin", 
	"params": {"radius": 190.0, "mult": 1.8, "knockback": 140.0}, 
}
const UNIVERSAL_DESPERTAR: = {
	"id": "despertar_heroico", "name": "Despertar Heroico", "unlock": 100, "type": "ativa", 
	"desc": "Skill universal da Grade S: +50% de dano e +30% de velocidade por 8 s.", 
	"cost": {"mana": 50}, "cd": 45.0, "cast": 0.4, "handler": "buff", 
	"params": {"duration": 8.0, "damage": 0.5, "speed": 0.3}, 
}

const CLASSES: = {
	"atirador": {
		"name": "Atirador", 
		"role": "Dano à distância", 
		"desc": "Controla o campo com flechas e mantém o inimigo longe da lâmina.", 
		"base": {"hp": 100, "mp": 45, "energy": 100, "damage": 12.0, "defense": 4.0, 
			"crit_phys": 0.08, "crit_magic": 0.03, "speed": 214.0, "strength": 9}, 
		"range": 460.0, 
		"ativas": [SKILL_TIRO_PRECISO, SKILL_DISPARO_LEQUE, SKILL_FLECHA_CONTENCAO, SKILL_CHUVA_FLECHAS], 
		"passivas": [SKILL_MIRA_FIRME, SKILL_PONTO_FRACO], 
	}, 
	"mago": {
		"name": "Mago", 
		"role": "Dano mágico em área", 
		"desc": "Converte mana em gelo e fogo arcano; frágil, mas devastador.", 
		"base": {"hp": 100, "mp": 80, "energy": 100, "damage": 11.0, "defense": 3.0, 
			"crit_phys": 0.03, "crit_magic": 0.1, "speed": 210.0, "strength": 7}, 
		"range": 420.0, 
		"ativas": [SKILL_PROJETIL_ARCANO, SKILL_CAMPO_GELIDO, SKILL_PASSO_ARCANO, SKILL_COMETA_ARCANO], 
		"passivas": [SKILL_FLUXO_ARCANO, SKILL_RASTRO_GELIDO], 
	}, 
	"guerreiro": {
		"name": "Guerreiro", 
		"role": "Combate corpo a corpo", 
		"desc": "Rompe guardas e pune quem tenta se proteger.", 
		"base": {"hp": 100, "mp": 35, "energy": 110, "damage": 14.0, "defense": 8.0, 
			"crit_phys": 0.06, "crit_magic": 0.02, "speed": 212.0, "strength": 12}, 
		"range": 96.0, 
		"ativas": [SKILL_TALHO_CIRCULAR, SKILL_QUEBRA_GUARDA, SKILL_INVESTIDA, SKILL_GOLPE_RUPTURA], 
		"passivas": [SKILL_IMPETO, SKILL_BRECHA_TATICA], 
	}, 
	"assassino": {
		"name": "Assassino", 
		"role": "Golpes pelas costas", 
		"desc": "Marca, reposiciona e executa antes que o inimigo vire o rosto.", 
		"base": {"hp": 100, "mp": 40, "energy": 115, "damage": 13.0, "defense": 5.0, 
			"crit_phys": 0.12, "crit_magic": 0.03, "speed": 226.0, "strength": 9}, 
		"range": 88.0, 
		"ativas": [SKILL_CORTE_DUPLO, SKILL_ADAGA_ARREMESSO, SKILL_PASSO_SOMBRIO, SKILL_EXECUCAO], 
		"passivas": [SKILL_OPORTUNISMO, SKILL_EMBOSCADA], 
	}, 
	"tank": {
		"name": "Tank", 
		"role": "Defesa e controle", 
		"desc": "Bloqueia, interrompe e devolve o impacto acumulado.", 
		"base": {"hp": 100, "mp": 30, "energy": 120, "damage": 10.0, "defense": 14.0, 
			"crit_phys": 0.04, "crit_magic": 0.02, "speed": 202.0, "strength": 14}, 
		"range": 96.0, 
		"ativas": [SKILL_PANCADA_ESCUDO, SKILL_ABALO_SISMICO, SKILL_BASTIAO, SKILL_REVANCHE_FERRO], 
		"passivas": [SKILL_GUARDA_FIRME, SKILL_RETALIACAO], 
	}, 
	"cavaleiro": {
		"name": "Cavaleiro", 
		"role": "Duelo e mobilidade", 
		"desc": "Escolhe um adversário, marca o duelo e o derruba com cargas.", 
		"base": {"hp": 100, "mp": 42, "energy": 108, "damage": 13.0, "defense": 10.0, 
			"crit_phys": 0.06, "crit_magic": 0.03, "speed": 218.0, "strength": 11}, 
		"range": 128.0, 
		"ativas": [SKILL_ESTOCADA, SKILL_SELO_DESAFIO, SKILL_CARGA_REAL, SKILL_ESTANDARTE], 
		"passivas": [SKILL_JURAMENTO, SKILL_CERCO], 
	}, 
}

const CLASS_ORDER: = ["atirador", "mago", "guerreiro", "assassino", "tank", "cavaleiro"]
const RACE_ORDER: = ["humano", "elfo", "orc", "anao"]



const GRADES: = [
	{"id": "NG", "name": "No-Grade", "min": 1, "max": 19, "skill_cap": 1, 
		"hp_bonus": 0.0, "speed_bonus": 0.0, "resist": 0.0, 
		"bonus": "Nenhum reforço universal."}, 
	{"id": "D", "name": "Grade D", "min": 20, "max": 39, "skill_cap": 1, 
		"hp_bonus": 0.08, "speed_bonus": 0.0, "resist": 0.0, 
		"bonus": "+8% de HP máximo."}, 
	{"id": "C", "name": "Grade C", "min": 40, "max": 59, "skill_cap": 1, 
		"hp_bonus": 0.08, "speed_bonus": 0.05, "resist": 0.0, 
		"bonus": "+8% de HP máximo e +5% de velocidade."}, 
	{"id": "B", "name": "Grade B", "min": 60, "max": 79, "skill_cap": 5, 
		"hp_bonus": 0.08, "speed_bonus": 0.05, "resist": 0.1, 
		"bonus": "+10% de resistência contra errantes e monstros de dungeon."}, 
	{"id": "A", "name": "Grade A", "min": 80, "max": 99, "skill_cap": 10, 
		"hp_bonus": 0.08, "speed_bonus": 0.05, "resist": 0.1, 
		"bonus": "Skill universal ativa: Explosão de Aura."}, 
	{"id": "S", "name": "Grade S", "min": 100, "max": 100, "skill_cap": 20, 
		"hp_bonus": 0.08, "speed_bonus": 0.05, "resist": 0.1, 
		"bonus": "Skill universal ativa: Despertar Heroico."}, 
]



const ITEMS: = {
	"guerreiro_no_grade_elmo": {"name": "Elmo · Aço de Caminho", "type": "elmo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Equipamento de quem patrulhava as estradas partidas pelo Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/no_grade/elmo.png", "class": "guerreiro"},
	"guerreiro_no_grade_peito": {"name": "Peitoral com avambraços · Aço de Caminho", "type": "peito", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Equipamento de quem patrulhava as estradas partidas pelo Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/no_grade/peito.png", "class": "guerreiro"},
	"guerreiro_no_grade_luvas": {"name": "Luvas · Aço de Caminho", "type": "luvas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Equipamento de quem patrulhava as estradas partidas pelo Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/no_grade/luvas.png", "class": "guerreiro"},
	"guerreiro_no_grade_calca": {"name": "Calça · Aço de Caminho", "type": "calca", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Equipamento de quem patrulhava as estradas partidas pelo Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/no_grade/calca.png", "class": "guerreiro"},
	"guerreiro_no_grade_botas": {"name": "Botas · Aço de Caminho", "type": "botas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Equipamento de quem patrulhava as estradas partidas pelo Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/no_grade/botas.png", "class": "guerreiro"},
	"guerreiro_d_elmo": {"name": "Elmo · Pedra Rachada", "type": "elmo", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os ferreiros copiaram nas placas as fraturas deixadas pela marcha dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/d/elmo.png", "class": "guerreiro"},
	"guerreiro_d_peito": {"name": "Peitoral com avambraços · Pedra Rachada", "type": "peito", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os ferreiros copiaram nas placas as fraturas deixadas pela marcha dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/d/peito.png", "class": "guerreiro"},
	"guerreiro_d_luvas": {"name": "Luvas · Pedra Rachada", "type": "luvas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os ferreiros copiaram nas placas as fraturas deixadas pela marcha dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/d/luvas.png", "class": "guerreiro"},
	"guerreiro_d_calca": {"name": "Calça · Pedra Rachada", "type": "calca", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os ferreiros copiaram nas placas as fraturas deixadas pela marcha dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/d/calca.png", "class": "guerreiro"},
	"guerreiro_d_botas": {"name": "Botas · Pedra Rachada", "type": "botas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os ferreiros copiaram nas placas as fraturas deixadas pela marcha dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/d/botas.png", "class": "guerreiro"},
	"guerreiro_c_elmo": {"name": "Elmo · Bastião de Ferro", "type": "elmo", "grade": "C", "value": 0, "weight": 0.0, "desc": "Modelo usado por combatentes que ganhavam tempo para os conjuradores da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/c/elmo.png", "class": "guerreiro"},
	"guerreiro_c_peito": {"name": "Peitoral com avambraços · Bastião de Ferro", "type": "peito", "grade": "C", "value": 0, "weight": 0.0, "desc": "Modelo usado por combatentes que ganhavam tempo para os conjuradores da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/c/peito.png", "class": "guerreiro"},
	"guerreiro_c_luvas": {"name": "Luvas · Bastião de Ferro", "type": "luvas", "grade": "C", "value": 0, "weight": 0.0, "desc": "Modelo usado por combatentes que ganhavam tempo para os conjuradores da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/c/luvas.png", "class": "guerreiro"},
	"guerreiro_c_calca": {"name": "Calça · Bastião de Ferro", "type": "calca", "grade": "C", "value": 0, "weight": 0.0, "desc": "Modelo usado por combatentes que ganhavam tempo para os conjuradores da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/c/calca.png", "class": "guerreiro"},
	"guerreiro_c_botas": {"name": "Botas · Bastião de Ferro", "type": "botas", "grade": "C", "value": 0, "weight": 0.0, "desc": "Modelo usado por combatentes que ganhavam tempo para os conjuradores da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/c/botas.png", "class": "guerreiro"},
	"guerreiro_b_elmo": {"name": "Elmo · Frente da Aliança", "type": "elmo", "grade": "B", "value": 0, "weight": 0.0, "desc": "As marcas no aço registram as companhias que sustentaram a linha diante dos gigantes.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/b/elmo.png", "class": "guerreiro"},
	"guerreiro_b_peito": {"name": "Peitoral com avambraços · Frente da Aliança", "type": "peito", "grade": "B", "value": 0, "weight": 0.0, "desc": "As marcas no aço registram as companhias que sustentaram a linha diante dos gigantes.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/b/peito.png", "class": "guerreiro"},
	"guerreiro_b_luvas": {"name": "Luvas · Frente da Aliança", "type": "luvas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As marcas no aço registram as companhias que sustentaram a linha diante dos gigantes.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/b/luvas.png", "class": "guerreiro"},
	"guerreiro_b_calca": {"name": "Calça · Frente da Aliança", "type": "calca", "grade": "B", "value": 0, "weight": 0.0, "desc": "As marcas no aço registram as companhias que sustentaram a linha diante dos gigantes.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/b/calca.png", "class": "guerreiro"},
	"guerreiro_b_botas": {"name": "Botas · Frente da Aliança", "type": "botas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As marcas no aço registram as companhias que sustentaram a linha diante dos gigantes.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/b/botas.png", "class": "guerreiro"},
	"guerreiro_a_elmo": {"name": "Elmo · Juramento da Montanha", "type": "elmo", "grade": "A", "value": 0, "weight": 0.0, "desc": "O brasão recorda uma montanha derrubada durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/a/elmo.png", "class": "guerreiro"},
	"guerreiro_a_peito": {"name": "Peitoral com avambraços · Juramento da Montanha", "type": "peito", "grade": "A", "value": 0, "weight": 0.0, "desc": "O brasão recorda uma montanha derrubada durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/a/peito.png", "class": "guerreiro"},
	"guerreiro_a_luvas": {"name": "Luvas · Juramento da Montanha", "type": "luvas", "grade": "A", "value": 0, "weight": 0.0, "desc": "O brasão recorda uma montanha derrubada durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/a/luvas.png", "class": "guerreiro"},
	"guerreiro_a_calca": {"name": "Calça · Juramento da Montanha", "type": "calca", "grade": "A", "value": 0, "weight": 0.0, "desc": "O brasão recorda uma montanha derrubada durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/a/calca.png", "class": "guerreiro"},
	"guerreiro_a_botas": {"name": "Botas · Juramento da Montanha", "type": "botas", "grade": "A", "value": 0, "weight": 0.0, "desc": "O brasão recorda uma montanha derrubada durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/a/botas.png", "class": "guerreiro"},
	"guerreiro_s_elmo": {"name": "Elmo · Martelo do Mundo Partido", "type": "elmo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia que honra os combatentes que abriram caminho até as prisões dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/s/elmo.png", "class": "guerreiro"},
	"guerreiro_s_peito": {"name": "Peitoral com avambraços · Martelo do Mundo Partido", "type": "peito", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia que honra os combatentes que abriram caminho até as prisões dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/s/peito.png", "class": "guerreiro"},
	"guerreiro_s_luvas": {"name": "Luvas · Martelo do Mundo Partido", "type": "luvas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia que honra os combatentes que abriram caminho até as prisões dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/s/luvas.png", "class": "guerreiro"},
	"guerreiro_s_calca": {"name": "Calça · Martelo do Mundo Partido", "type": "calca", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia que honra os combatentes que abriram caminho até as prisões dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/s/calca.png", "class": "guerreiro"},
	"guerreiro_s_botas": {"name": "Botas · Martelo do Mundo Partido", "type": "botas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia que honra os combatentes que abriram caminho até as prisões dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/guerreiro/s/botas.png", "class": "guerreiro"},
	"cavaleiro_no_grade_elmo": {"name": "Elmo · Vigília de Estrada", "type": "elmo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Traje de escolta dos povoados reconstruídos após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/no_grade/elmo.png", "class": "cavaleiro"},
	"cavaleiro_no_grade_peito": {"name": "Peitoral com avambraços · Vigília de Estrada", "type": "peito", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Traje de escolta dos povoados reconstruídos após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/no_grade/peito.png", "class": "cavaleiro"},
	"cavaleiro_no_grade_luvas": {"name": "Luvas · Vigília de Estrada", "type": "luvas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Traje de escolta dos povoados reconstruídos após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/no_grade/luvas.png", "class": "cavaleiro"},
	"cavaleiro_no_grade_calca": {"name": "Calça · Vigília de Estrada", "type": "calca", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Traje de escolta dos povoados reconstruídos após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/no_grade/calca.png", "class": "cavaleiro"},
	"cavaleiro_no_grade_botas": {"name": "Botas · Vigília de Estrada", "type": "botas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Traje de escolta dos povoados reconstruídos após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/no_grade/botas.png", "class": "cavaleiro"},
	"cavaleiro_d_elmo": {"name": "Elmo · Escudo da Aurora", "type": "elmo", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os primeiros votos a Nivah aparecem gravados nos rebites do conjunto.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/d/elmo.png", "class": "cavaleiro"},
	"cavaleiro_d_peito": {"name": "Peitoral com avambraços · Escudo da Aurora", "type": "peito", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os primeiros votos a Nivah aparecem gravados nos rebites do conjunto.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/d/peito.png", "class": "cavaleiro"},
	"cavaleiro_d_luvas": {"name": "Luvas · Escudo da Aurora", "type": "luvas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os primeiros votos a Nivah aparecem gravados nos rebites do conjunto.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/d/luvas.png", "class": "cavaleiro"},
	"cavaleiro_d_calca": {"name": "Calça · Escudo da Aurora", "type": "calca", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os primeiros votos a Nivah aparecem gravados nos rebites do conjunto.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/d/calca.png", "class": "cavaleiro"},
	"cavaleiro_d_botas": {"name": "Botas · Escudo da Aurora", "type": "botas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Os primeiros votos a Nivah aparecem gravados nos rebites do conjunto.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/d/botas.png", "class": "cavaleiro"},
	"cavaleiro_c_elmo": {"name": "Elmo · Estandarte da Aurora", "type": "elmo", "grade": "C", "value": 0, "weight": 0.0, "desc": "O heráldico sol nascente marca o juramento de defender os refugiados.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/c/elmo.png", "class": "cavaleiro"},
	"cavaleiro_c_peito": {"name": "Peitoral com avambraços · Estandarte da Aurora", "type": "peito", "grade": "C", "value": 0, "weight": 0.0, "desc": "O heráldico sol nascente marca o juramento de defender os refugiados.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/c/peito.png", "class": "cavaleiro"},
	"cavaleiro_c_luvas": {"name": "Luvas · Estandarte da Aurora", "type": "luvas", "grade": "C", "value": 0, "weight": 0.0, "desc": "O heráldico sol nascente marca o juramento de defender os refugiados.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/c/luvas.png", "class": "cavaleiro"},
	"cavaleiro_c_calca": {"name": "Calça · Estandarte da Aurora", "type": "calca", "grade": "C", "value": 0, "weight": 0.0, "desc": "O heráldico sol nascente marca o juramento de defender os refugiados.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/c/calca.png", "class": "cavaleiro"},
	"cavaleiro_c_botas": {"name": "Botas · Estandarte da Aurora", "type": "botas", "grade": "C", "value": 0, "weight": 0.0, "desc": "O heráldico sol nascente marca o juramento de defender os refugiados.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/c/botas.png", "class": "cavaleiro"},
	"cavaleiro_b_elmo": {"name": "Elmo · Asas da Aliança", "type": "elmo", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas aladas celebram os anjos que lutaram sob a proteção de Nivah.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/b/elmo.png", "class": "cavaleiro"},
	"cavaleiro_b_peito": {"name": "Peitoral com avambraços · Asas da Aliança", "type": "peito", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas aladas celebram os anjos que lutaram sob a proteção de Nivah.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/b/peito.png", "class": "cavaleiro"},
	"cavaleiro_b_luvas": {"name": "Luvas · Asas da Aliança", "type": "luvas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas aladas celebram os anjos que lutaram sob a proteção de Nivah.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/b/luvas.png", "class": "cavaleiro"},
	"cavaleiro_b_calca": {"name": "Calça · Asas da Aliança", "type": "calca", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas aladas celebram os anjos que lutaram sob a proteção de Nivah.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/b/calca.png", "class": "cavaleiro"},
	"cavaleiro_b_botas": {"name": "Botas · Asas da Aliança", "type": "botas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas aladas celebram os anjos que lutaram sob a proteção de Nivah.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/b/botas.png", "class": "cavaleiro"},
	"cavaleiro_a_elmo": {"name": "Elmo · Coroa da Vigília", "type": "elmo", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos dourados guardam a memória das escoltas do Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/a/elmo.png", "class": "cavaleiro"},
	"cavaleiro_a_peito": {"name": "Peitoral com avambraços · Coroa da Vigília", "type": "peito", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos dourados guardam a memória das escoltas do Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/a/peito.png", "class": "cavaleiro"},
	"cavaleiro_a_luvas": {"name": "Luvas · Coroa da Vigília", "type": "luvas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos dourados guardam a memória das escoltas do Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/a/luvas.png", "class": "cavaleiro"},
	"cavaleiro_a_calca": {"name": "Calça · Coroa da Vigília", "type": "calca", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos dourados guardam a memória das escoltas do Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/a/calca.png", "class": "cavaleiro"},
	"cavaleiro_a_botas": {"name": "Botas · Coroa da Vigília", "type": "botas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos dourados guardam a memória das escoltas do Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/a/botas.png", "class": "cavaleiro"},
	"cavaleiro_s_elmo": {"name": "Elmo · Última Aurora de Nivah", "type": "elmo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Forjada como voto de vigília enquanto o destino da deusa permanecer desconhecido.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/s/elmo.png", "class": "cavaleiro"},
	"cavaleiro_s_peito": {"name": "Peitoral com avambraços · Última Aurora de Nivah", "type": "peito", "grade": "S", "value": 0, "weight": 0.0, "desc": "Forjada como voto de vigília enquanto o destino da deusa permanecer desconhecido.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/s/peito.png", "class": "cavaleiro"},
	"cavaleiro_s_luvas": {"name": "Luvas · Última Aurora de Nivah", "type": "luvas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Forjada como voto de vigília enquanto o destino da deusa permanecer desconhecido.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/s/luvas.png", "class": "cavaleiro"},
	"cavaleiro_s_calca": {"name": "Calça · Última Aurora de Nivah", "type": "calca", "grade": "S", "value": 0, "weight": 0.0, "desc": "Forjada como voto de vigília enquanto o destino da deusa permanecer desconhecido.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/s/calca.png", "class": "cavaleiro"},
	"cavaleiro_s_botas": {"name": "Botas · Última Aurora de Nivah", "type": "botas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Forjada como voto de vigília enquanto o destino da deusa permanecer desconhecido.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/cavaleiro/s/botas.png", "class": "cavaleiro"},
	"arqueiro_no_grade_elmo": {"name": "Elmo · Trilha Nova", "type": "elmo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro leve para atravessar as florestas que brotaram após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/no_grade/elmo.png", "class": "arqueiro"},
	"arqueiro_no_grade_peito": {"name": "Peitoral com avambraços · Trilha Nova", "type": "peito", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro leve para atravessar as florestas que brotaram após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/no_grade/peito.png", "class": "arqueiro"},
	"arqueiro_no_grade_luvas": {"name": "Luvas · Trilha Nova", "type": "luvas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro leve para atravessar as florestas que brotaram após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/no_grade/luvas.png", "class": "arqueiro"},
	"arqueiro_no_grade_calca": {"name": "Calça · Trilha Nova", "type": "calca", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro leve para atravessar as florestas que brotaram após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/no_grade/calca.png", "class": "arqueiro"},
	"arqueiro_no_grade_botas": {"name": "Botas · Trilha Nova", "type": "botas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro leve para atravessar as florestas que brotaram após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/no_grade/botas.png", "class": "arqueiro"},
	"arqueiro_d_elmo": {"name": "Elmo · Galho de Cinza", "type": "elmo", "grade": "D", "value": 0, "weight": 0.0, "desc": "Feita para se confundir com os bosques queimados na passagem dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/d/elmo.png", "class": "arqueiro"},
	"arqueiro_d_peito": {"name": "Peitoral com avambraços · Galho de Cinza", "type": "peito", "grade": "D", "value": 0, "weight": 0.0, "desc": "Feita para se confundir com os bosques queimados na passagem dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/d/peito.png", "class": "arqueiro"},
	"arqueiro_d_luvas": {"name": "Luvas · Galho de Cinza", "type": "luvas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Feita para se confundir com os bosques queimados na passagem dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/d/luvas.png", "class": "arqueiro"},
	"arqueiro_d_calca": {"name": "Calça · Galho de Cinza", "type": "calca", "grade": "D", "value": 0, "weight": 0.0, "desc": "Feita para se confundir com os bosques queimados na passagem dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/d/calca.png", "class": "arqueiro"},
	"arqueiro_d_botas": {"name": "Botas · Galho de Cinza", "type": "botas", "grade": "D", "value": 0, "weight": 0.0, "desc": "Feita para se confundir com os bosques queimados na passagem dos Colossais.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/d/botas.png", "class": "arqueiro"},
	"arqueiro_c_elmo": {"name": "Elmo · Pena de Safira", "type": "elmo", "grade": "C", "value": 0, "weight": 0.0, "desc": "A pena azul identifica batedores responsáveis por cartografar os acessos remotos.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/c/elmo.png", "class": "arqueiro"},
	"arqueiro_c_peito": {"name": "Peitoral com avambraços · Pena de Safira", "type": "peito", "grade": "C", "value": 0, "weight": 0.0, "desc": "A pena azul identifica batedores responsáveis por cartografar os acessos remotos.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/c/peito.png", "class": "arqueiro"},
	"arqueiro_c_luvas": {"name": "Luvas · Pena de Safira", "type": "luvas", "grade": "C", "value": 0, "weight": 0.0, "desc": "A pena azul identifica batedores responsáveis por cartografar os acessos remotos.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/c/luvas.png", "class": "arqueiro"},
	"arqueiro_c_calca": {"name": "Calça · Pena de Safira", "type": "calca", "grade": "C", "value": 0, "weight": 0.0, "desc": "A pena azul identifica batedores responsáveis por cartografar os acessos remotos.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/c/calca.png", "class": "arqueiro"},
	"arqueiro_c_botas": {"name": "Botas · Pena de Safira", "type": "botas", "grade": "C", "value": 0, "weight": 0.0, "desc": "A pena azul identifica batedores responsáveis por cartografar os acessos remotos.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/c/botas.png", "class": "arqueiro"},
	"arqueiro_b_elmo": {"name": "Elmo · Rota da Aliança", "type": "elmo", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas folheadas homenageiam os arqueiros que mantiveram abertas as rotas dos conjuradores.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/b/elmo.png", "class": "arqueiro"},
	"arqueiro_b_peito": {"name": "Peitoral com avambraços · Rota da Aliança", "type": "peito", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas folheadas homenageiam os arqueiros que mantiveram abertas as rotas dos conjuradores.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/b/peito.png", "class": "arqueiro"},
	"arqueiro_b_luvas": {"name": "Luvas · Rota da Aliança", "type": "luvas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas folheadas homenageiam os arqueiros que mantiveram abertas as rotas dos conjuradores.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/b/luvas.png", "class": "arqueiro"},
	"arqueiro_b_calca": {"name": "Calça · Rota da Aliança", "type": "calca", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas folheadas homenageiam os arqueiros que mantiveram abertas as rotas dos conjuradores.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/b/calca.png", "class": "arqueiro"},
	"arqueiro_b_botas": {"name": "Botas · Rota da Aliança", "type": "botas", "grade": "B", "value": 0, "weight": 0.0, "desc": "As placas folheadas homenageiam os arqueiros que mantiveram abertas as rotas dos conjuradores.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/b/botas.png", "class": "arqueiro"},
	"arqueiro_a_elmo": {"name": "Elmo · Copa do Céu Partido", "type": "elmo", "grade": "A", "value": 0, "weight": 0.0, "desc": "O bordado reproduz um céu registrado depois que Nark alterou as estrelas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/a/elmo.png", "class": "arqueiro"},
	"arqueiro_a_peito": {"name": "Peitoral com avambraços · Copa do Céu Partido", "type": "peito", "grade": "A", "value": 0, "weight": 0.0, "desc": "O bordado reproduz um céu registrado depois que Nark alterou as estrelas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/a/peito.png", "class": "arqueiro"},
	"arqueiro_a_luvas": {"name": "Luvas · Copa do Céu Partido", "type": "luvas", "grade": "A", "value": 0, "weight": 0.0, "desc": "O bordado reproduz um céu registrado depois que Nark alterou as estrelas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/a/luvas.png", "class": "arqueiro"},
	"arqueiro_a_calca": {"name": "Calça · Copa do Céu Partido", "type": "calca", "grade": "A", "value": 0, "weight": 0.0, "desc": "O bordado reproduz um céu registrado depois que Nark alterou as estrelas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/a/calca.png", "class": "arqueiro"},
	"arqueiro_a_botas": {"name": "Botas · Copa do Céu Partido", "type": "botas", "grade": "A", "value": 0, "weight": 0.0, "desc": "O bordado reproduz um céu registrado depois que Nark alterou as estrelas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/a/botas.png", "class": "arqueiro"},
	"arqueiro_s_elmo": {"name": "Elmo · Horizonte Imóvel", "type": "elmo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia dos vigias que observam as trilhas entre santuários a partir das copas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/s/elmo.png", "class": "arqueiro"},
	"arqueiro_s_peito": {"name": "Peitoral com avambraços · Horizonte Imóvel", "type": "peito", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia dos vigias que observam as trilhas entre santuários a partir das copas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/s/peito.png", "class": "arqueiro"},
	"arqueiro_s_luvas": {"name": "Luvas · Horizonte Imóvel", "type": "luvas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia dos vigias que observam as trilhas entre santuários a partir das copas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/s/luvas.png", "class": "arqueiro"},
	"arqueiro_s_calca": {"name": "Calça · Horizonte Imóvel", "type": "calca", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia dos vigias que observam as trilhas entre santuários a partir das copas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/s/calca.png", "class": "arqueiro"},
	"arqueiro_s_botas": {"name": "Botas · Horizonte Imóvel", "type": "botas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Relíquia dos vigias que observam as trilhas entre santuários a partir das copas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/arqueiro/s/botas.png", "class": "arqueiro"},
	"assassino_no_grade_elmo": {"name": "Elmo · Passo de Cinza", "type": "elmo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro discreto para cruzar as ruínas de cidades abandonadas após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/no_grade/elmo.png", "class": "assassino"},
	"assassino_no_grade_peito": {"name": "Peitoral com avambraços · Passo de Cinza", "type": "peito", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro discreto para cruzar as ruínas de cidades abandonadas após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/no_grade/peito.png", "class": "assassino"},
	"assassino_no_grade_luvas": {"name": "Luvas · Passo de Cinza", "type": "luvas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro discreto para cruzar as ruínas de cidades abandonadas após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/no_grade/luvas.png", "class": "assassino"},
	"assassino_no_grade_calca": {"name": "Calça · Passo de Cinza", "type": "calca", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro discreto para cruzar as ruínas de cidades abandonadas após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/no_grade/calca.png", "class": "assassino"},
	"assassino_no_grade_botas": {"name": "Botas · Passo de Cinza", "type": "botas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Couro discreto para cruzar as ruínas de cidades abandonadas após o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/no_grade/botas.png", "class": "assassino"},
	"assassino_d_elmo": {"name": "Elmo · Véu da Fenda", "type": "elmo", "grade": "D", "value": 0, "weight": 0.0, "desc": "O capuz foi inspirado nas passagens abertas quando a terra se partiu.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/d/elmo.png", "class": "assassino"},
	"assassino_d_peito": {"name": "Peitoral com avambraços · Véu da Fenda", "type": "peito", "grade": "D", "value": 0, "weight": 0.0, "desc": "O capuz foi inspirado nas passagens abertas quando a terra se partiu.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/d/peito.png", "class": "assassino"},
	"assassino_d_luvas": {"name": "Luvas · Véu da Fenda", "type": "luvas", "grade": "D", "value": 0, "weight": 0.0, "desc": "O capuz foi inspirado nas passagens abertas quando a terra se partiu.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/d/luvas.png", "class": "assassino"},
	"assassino_d_calca": {"name": "Calça · Véu da Fenda", "type": "calca", "grade": "D", "value": 0, "weight": 0.0, "desc": "O capuz foi inspirado nas passagens abertas quando a terra se partiu.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/d/calca.png", "class": "assassino"},
	"assassino_d_botas": {"name": "Botas · Véu da Fenda", "type": "botas", "grade": "D", "value": 0, "weight": 0.0, "desc": "O capuz foi inspirado nas passagens abertas quando a terra se partiu.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/d/botas.png", "class": "assassino"},
	"assassino_c_elmo": {"name": "Elmo · Lua Fraturada", "type": "elmo", "grade": "C", "value": 0, "weight": 0.0, "desc": "O emblema da lua quebrada é usado por batedores que estudam os limites dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/c/elmo.png", "class": "assassino"},
	"assassino_c_peito": {"name": "Peitoral com avambraços · Lua Fraturada", "type": "peito", "grade": "C", "value": 0, "weight": 0.0, "desc": "O emblema da lua quebrada é usado por batedores que estudam os limites dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/c/peito.png", "class": "assassino"},
	"assassino_c_luvas": {"name": "Luvas · Lua Fraturada", "type": "luvas", "grade": "C", "value": 0, "weight": 0.0, "desc": "O emblema da lua quebrada é usado por batedores que estudam os limites dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/c/luvas.png", "class": "assassino"},
	"assassino_c_calca": {"name": "Calça · Lua Fraturada", "type": "calca", "grade": "C", "value": 0, "weight": 0.0, "desc": "O emblema da lua quebrada é usado por batedores que estudam os limites dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/c/calca.png", "class": "assassino"},
	"assassino_c_botas": {"name": "Botas · Lua Fraturada", "type": "botas", "grade": "C", "value": 0, "weight": 0.0, "desc": "O emblema da lua quebrada é usado por batedores que estudam os limites dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/c/botas.png", "class": "assassino"},
	"assassino_b_elmo": {"name": "Elmo · Sombra da Vigília", "type": "elmo", "grade": "B", "value": 0, "weight": 0.0, "desc": "O aço escurecido evita reflexos durante o reconhecimento das entradas seladas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/b/elmo.png", "class": "assassino"},
	"assassino_b_peito": {"name": "Peitoral com avambraços · Sombra da Vigília", "type": "peito", "grade": "B", "value": 0, "weight": 0.0, "desc": "O aço escurecido evita reflexos durante o reconhecimento das entradas seladas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/b/peito.png", "class": "assassino"},
	"assassino_b_luvas": {"name": "Luvas · Sombra da Vigília", "type": "luvas", "grade": "B", "value": 0, "weight": 0.0, "desc": "O aço escurecido evita reflexos durante o reconhecimento das entradas seladas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/b/luvas.png", "class": "assassino"},
	"assassino_b_calca": {"name": "Calça · Sombra da Vigília", "type": "calca", "grade": "B", "value": 0, "weight": 0.0, "desc": "O aço escurecido evita reflexos durante o reconhecimento das entradas seladas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/b/calca.png", "class": "assassino"},
	"assassino_b_botas": {"name": "Botas · Sombra da Vigília", "type": "botas", "grade": "B", "value": 0, "weight": 0.0, "desc": "O aço escurecido evita reflexos durante o reconhecimento das entradas seladas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/b/botas.png", "class": "assassino"},
	"assassino_a_elmo": {"name": "Elmo · Limiar Violeta", "type": "elmo", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos registram as rotas por onde vigias se aproximam sem alertar os Guardiões.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/a/elmo.png", "class": "assassino"},
	"assassino_a_peito": {"name": "Peitoral com avambraços · Limiar Violeta", "type": "peito", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos registram as rotas por onde vigias se aproximam sem alertar os Guardiões.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/a/peito.png", "class": "assassino"},
	"assassino_a_luvas": {"name": "Luvas · Limiar Violeta", "type": "luvas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos registram as rotas por onde vigias se aproximam sem alertar os Guardiões.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/a/luvas.png", "class": "assassino"},
	"assassino_a_calca": {"name": "Calça · Limiar Violeta", "type": "calca", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos registram as rotas por onde vigias se aproximam sem alertar os Guardiões.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/a/calca.png", "class": "assassino"},
	"assassino_a_botas": {"name": "Botas · Limiar Violeta", "type": "botas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Os relevos registram as rotas por onde vigias se aproximam sem alertar os Guardiões.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/a/botas.png", "class": "assassino"},
	"assassino_s_elmo": {"name": "Elmo · Silêncio de Nark", "type": "elmo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Seu nome recorda a última palavra de Nith e o instante de silêncio que antecedeu o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/s/elmo.png", "class": "assassino"},
	"assassino_s_peito": {"name": "Peitoral com avambraços · Silêncio de Nark", "type": "peito", "grade": "S", "value": 0, "weight": 0.0, "desc": "Seu nome recorda a última palavra de Nith e o instante de silêncio que antecedeu o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/s/peito.png", "class": "assassino"},
	"assassino_s_luvas": {"name": "Luvas · Silêncio de Nark", "type": "luvas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Seu nome recorda a última palavra de Nith e o instante de silêncio que antecedeu o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/s/luvas.png", "class": "assassino"},
	"assassino_s_calca": {"name": "Calça · Silêncio de Nark", "type": "calca", "grade": "S", "value": 0, "weight": 0.0, "desc": "Seu nome recorda a última palavra de Nith e o instante de silêncio que antecedeu o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/s/calca.png", "class": "assassino"},
	"assassino_s_botas": {"name": "Botas · Silêncio de Nark", "type": "botas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Seu nome recorda a última palavra de Nith e o instante de silêncio que antecedeu o Nascimento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/assassino/s/botas.png", "class": "assassino"},
	"mago_no_grade_elmo": {"name": "Elmo · Linho do Aprendiz", "type": "elmo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Vestes de quem aprende a ler os registros fragmentários da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/no_grade/elmo.png", "class": "mago"},
	"mago_no_grade_peito": {"name": "Peitoral com avambraços · Linho do Aprendiz", "type": "peito", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Vestes de quem aprende a ler os registros fragmentários da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/no_grade/peito.png", "class": "mago"},
	"mago_no_grade_luvas": {"name": "Luvas · Linho do Aprendiz", "type": "luvas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Vestes de quem aprende a ler os registros fragmentários da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/no_grade/luvas.png", "class": "mago"},
	"mago_no_grade_calca": {"name": "Calça · Linho do Aprendiz", "type": "calca", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Vestes de quem aprende a ler os registros fragmentários da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/no_grade/calca.png", "class": "mago"},
	"mago_no_grade_botas": {"name": "Botas · Linho do Aprendiz", "type": "botas", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Vestes de quem aprende a ler os registros fragmentários da Primeira Aliança.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/no_grade/botas.png", "class": "mago"},
	"mago_d_elmo": {"name": "Elmo · Traço de Prata", "type": "elmo", "grade": "D", "value": 0, "weight": 0.0, "desc": "O primeiro círculo de contenção é bordado nas mangas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/d/elmo.png", "class": "mago"},
	"mago_d_peito": {"name": "Peitoral com avambraços · Traço de Prata", "type": "peito", "grade": "D", "value": 0, "weight": 0.0, "desc": "O primeiro círculo de contenção é bordado nas mangas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/d/peito.png", "class": "mago"},
	"mago_d_luvas": {"name": "Luvas · Traço de Prata", "type": "luvas", "grade": "D", "value": 0, "weight": 0.0, "desc": "O primeiro círculo de contenção é bordado nas mangas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/d/luvas.png", "class": "mago"},
	"mago_d_calca": {"name": "Calça · Traço de Prata", "type": "calca", "grade": "D", "value": 0, "weight": 0.0, "desc": "O primeiro círculo de contenção é bordado nas mangas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/d/calca.png", "class": "mago"},
	"mago_d_botas": {"name": "Botas · Traço de Prata", "type": "botas", "grade": "D", "value": 0, "weight": 0.0, "desc": "O primeiro círculo de contenção é bordado nas mangas.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/d/botas.png", "class": "mago"},
	"mago_c_elmo": {"name": "Elmo · Círculo de Safira", "type": "elmo", "grade": "C", "value": 0, "weight": 0.0, "desc": "Os bordados ensinam a distinguir o selo original da segunda magia dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/c/elmo.png", "class": "mago"},
	"mago_c_peito": {"name": "Peitoral com avambraços · Círculo de Safira", "type": "peito", "grade": "C", "value": 0, "weight": 0.0, "desc": "Os bordados ensinam a distinguir o selo original da segunda magia dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/c/peito.png", "class": "mago"},
	"mago_c_luvas": {"name": "Luvas · Círculo de Safira", "type": "luvas", "grade": "C", "value": 0, "weight": 0.0, "desc": "Os bordados ensinam a distinguir o selo original da segunda magia dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/c/luvas.png", "class": "mago"},
	"mago_c_calca": {"name": "Calça · Círculo de Safira", "type": "calca", "grade": "C", "value": 0, "weight": 0.0, "desc": "Os bordados ensinam a distinguir o selo original da segunda magia dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/c/calca.png", "class": "mago"},
	"mago_c_botas": {"name": "Botas · Círculo de Safira", "type": "botas", "grade": "C", "value": 0, "weight": 0.0, "desc": "Os bordados ensinam a distinguir o selo original da segunda magia dos santuários.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/c/botas.png", "class": "mago"},
	"mago_b_elmo": {"name": "Elmo · Rito da Aliança", "type": "elmo", "grade": "B", "value": 0, "weight": 0.0, "desc": "O conjunto reproduz diagramas usados pelos conjuradores durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/b/elmo.png", "class": "mago"},
	"mago_b_peito": {"name": "Peitoral com avambraços · Rito da Aliança", "type": "peito", "grade": "B", "value": 0, "weight": 0.0, "desc": "O conjunto reproduz diagramas usados pelos conjuradores durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/b/peito.png", "class": "mago"},
	"mago_b_luvas": {"name": "Luvas · Rito da Aliança", "type": "luvas", "grade": "B", "value": 0, "weight": 0.0, "desc": "O conjunto reproduz diagramas usados pelos conjuradores durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/b/luvas.png", "class": "mago"},
	"mago_b_calca": {"name": "Calça · Rito da Aliança", "type": "calca", "grade": "B", "value": 0, "weight": 0.0, "desc": "O conjunto reproduz diagramas usados pelos conjuradores durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/b/calca.png", "class": "mago"},
	"mago_b_botas": {"name": "Botas · Rito da Aliança", "type": "botas", "grade": "B", "value": 0, "weight": 0.0, "desc": "O conjunto reproduz diagramas usados pelos conjuradores durante o Grande Selamento.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/b/botas.png", "class": "mago"},
	"mago_a_elmo": {"name": "Elmo · Escritura dos Santuários", "type": "elmo", "grade": "A", "value": 0, "weight": 0.0, "desc": "Runas de ouro velho representam as prisões mantidas distantes umas das outras.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/a/elmo.png", "class": "mago"},
	"mago_a_peito": {"name": "Peitoral com avambraços · Escritura dos Santuários", "type": "peito", "grade": "A", "value": 0, "weight": 0.0, "desc": "Runas de ouro velho representam as prisões mantidas distantes umas das outras.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/a/peito.png", "class": "mago"},
	"mago_a_luvas": {"name": "Luvas · Escritura dos Santuários", "type": "luvas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Runas de ouro velho representam as prisões mantidas distantes umas das outras.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/a/luvas.png", "class": "mago"},
	"mago_a_calca": {"name": "Calça · Escritura dos Santuários", "type": "calca", "grade": "A", "value": 0, "weight": 0.0, "desc": "Runas de ouro velho representam as prisões mantidas distantes umas das outras.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/a/calca.png", "class": "mago"},
	"mago_a_botas": {"name": "Botas · Escritura dos Santuários", "type": "botas", "grade": "A", "value": 0, "weight": 0.0, "desc": "Runas de ouro velho representam as prisões mantidas distantes umas das outras.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/a/botas.png", "class": "mago"},
	"mago_s_elmo": {"name": "Elmo · Equilíbrio de Nivah", "type": "elmo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Vestes cerimoniais dedicadas à decisão de Nivah de conter a corrupção deixada por Nark.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/s/elmo.png", "class": "mago"},
	"mago_s_peito": {"name": "Peitoral com avambraços · Equilíbrio de Nivah", "type": "peito", "grade": "S", "value": 0, "weight": 0.0, "desc": "Vestes cerimoniais dedicadas à decisão de Nivah de conter a corrupção deixada por Nark.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/s/peito.png", "class": "mago"},
	"mago_s_luvas": {"name": "Luvas · Equilíbrio de Nivah", "type": "luvas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Vestes cerimoniais dedicadas à decisão de Nivah de conter a corrupção deixada por Nark.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/s/luvas.png", "class": "mago"},
	"mago_s_calca": {"name": "Calça · Equilíbrio de Nivah", "type": "calca", "grade": "S", "value": 0, "weight": 0.0, "desc": "Vestes cerimoniais dedicadas à decisão de Nivah de conter a corrupção deixada por Nark.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/s/calca.png", "class": "mago"},
	"mago_s_botas": {"name": "Botas · Equilíbrio de Nivah", "type": "botas", "grade": "S", "value": 0, "weight": 0.0, "desc": "Vestes cerimoniais dedicadas à decisão de Nivah de conter a corrupção deixada por Nark.", "sprite_path": "res://assets/game/sprites/arsenal/sprites/mago/s/botas.png", "class": "mago"},
	"hero": {"name": "Hero", "type": "aura", "grade": "NG", "value": 0,
		"weight": 0.0, "desc": "Visual cosmético: brilho dourado animado no torso. Sem bônus de atributos."},
	"roupa_basica": {"name": "Roupa Básica", "type": "armadura", "grade": "NG", "value": 5,
		"weight": 1.0, "desc": "Túnica de tecido, calças e sapatos simples. Pode ser equipada e removida.", "defense": 1.0, "durability": 60},
	"arma_basica": {"name": "Arma de Treino", "type": "arma", "grade": "NG", "value": 5,
		"weight": 1.0, "desc": "Arma simples de aprendiz, adaptada à sua classe. Pode ser equipada e removida.", "damage": 1.0, "durability": 60},
	"presa_lobo": {"name": "Presa de Lobo", "type": "material", "grade": "NG", "value": 12, 
		"weight": 0.2, "desc": "Presa afiada arrancada de um lobo do vale."}, 
	"gosma": {"name": "Gosma Espessa", "type": "material", "grade": "NG", "value": 9, 
		"weight": 0.3, "desc": "Resíduo gelatinoso usado como reagente de curtume."}, 
	"sucata_ferro": {"name": "Sucata de Ferro", "type": "material", "grade": "NG", "value": 15, 
		"weight": 0.6, "desc": "Chapas e rebites recolhidos dos saqueadores."}, 
	"cristal_aurora": {"name": "Cristal de Aurora", "type": "material", "grade": "NG", "value": 60, 
		"weight": 0.4, "desc": "Fragmento luminoso que só aparece perto do santuário."}, 
	"carapaca_branca": {"name": "Carapaça Branca", "type": "material", "grade": "NG", "value": 120, 
		"weight": 1.2, "desc": "Placa da fera da pedreira. Serve de ingrediente ou de armadura."}, 
	"essencia_errante": {"name": "Essência Errante", "type": "material", "grade": "NG", "value": 45, 
		"weight": 0.3, "desc": "Resíduo de um monstro que escapou de uma dungeon."}, 
	"selo_entrada": {"name": "Selo de Entrada", "type": "chave", "grade": "NG", "value": 200, 
		"weight": 0.5, "desc": "Selo que abre o portão do santuário do primeiro Colossal."}, 
	"livro_skill": {"name": "Livro de Skill", "type": "livro", "grade": "NG", "value": 250, 
		"weight": 0.5, "desc": "Aumenta em um nível uma skill própria já aprendida, até o teto da grade."}, 
	"pocao_cura": {"name": "Poção de Cura", "type": "consumivel", "grade": "NG", "value": 40, 
		"weight": 0.4, "desc": "Recupera 60 de HP.", "heal": 60}, 
	"pocao_mana": {"name": "Poção de Mana", "type": "consumivel", "grade": "NG", "value": 40,
		"weight": 0.4, "desc": "Recupera 50 de mana. Acumula no inventário.", "mana": 50},
	"pocao_energia": {"name": "Poção de Energia", "type": "consumivel", "grade": "NG", "value": 40,
		"weight": 0.4, "desc": "Recupera 30 de energia. Acumula no inventário.", "energy": 30},
	"arma_ng": {"name": "Espada de Bronze", "type": "arma", "grade": "NG", "value": 120, 
		"weight": 4.0, "desc": "Arma simples de bronze.", "damage": 4.0, "durability": 100}, 
	"armadura_ng": {"name": "Armadura de Couro", "type": "armadura", "grade": "NG", "value": 110, 
		"weight": 5.0, "desc": "Couro curtido do vale.", "defense": 3.0, "hp": 10.0, "durability": 100}, 
	"colar_simples": {"name": "Colar Simples", "type": "colar", "grade": "NG", "value": 0, "weight": 0.2, "desc": "Um colar simples. Sem bônus de atributos.", "durability": 100, "slot_art": "colar"},
	"talisma_simples": {"name": "Talismã Simples", "type": "talisma", "grade": "NG", "value": 0, "weight": 0.2, "desc": "Um talismã simples. Sem bônus de atributos.", "durability": 100, "slot_art": "talisma"},
	"joia_ng": {"name": "Anel de Cobre", "type": "anel", "grade": "NG", "value": 90,
		"weight": 0.3, "desc": "Anel modesto de cobre.", "crit": 0.02, "durability": 100}, 
	"arma_d": {"name": "Lâmina de Aço", "type": "arma", "grade": "D", "value": 520, 
		"weight": 4.5, "desc": "Aço batido na forja da cidade.", "damage": 11.0, "durability": 140}, 
	"armadura_d": {"name": "Cota de Malha", "type": "armadura", "grade": "D", "value": 480, 
		"weight": 7.0, "desc": "Malha pesada, feita para durar.", "defense": 8.0, "hp": 30.0, "durability": 140}, 
	"joia_d": {"name": "Anel de Prata", "type": "anel", "grade": "D", "value": 380,
		"weight": 0.3, "desc": "Prata lavrada por um ourives do reino.", "crit": 0.04, "durability": 140}, 
	"arma_c": {"name": "Lâmina Rúnica", "type": "arma", "grade": "C", "value": 1400, 
		"weight": 5.0, "desc": "Runas antigas cortam mais fundo.", "damage": 22.0, "durability": 190}, 
	"armadura_c": {"name": "Peitoral Rúnico", "type": "armadura", "grade": "C", "value": 1300, 
		"weight": 8.0, "desc": "Placas gravadas com runas de proteção.", "defense": 15.0, "hp": 60.0, "durability": 190}, 
	"arma_b": {"name": "Lâmina do Colosso", "type": "arma", "grade": "B", "value": 3200, 
		"weight": 5.5, "desc": "Forjada com fragmentos do primeiro Colossal.", "damage": 38.0, "durability": 240}, 
	"armadura_b": {"name": "Armadura do Colosso", "type": "armadura", "grade": "B", "value": 3000, 
		"weight": 9.0, "desc": "Pedra viva presa ao peito.", "defense": 24.0, "hp": 110.0, "durability": 240}, 
		"arsenal_001": {"name": "Espada Curta Enferrujada", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_001"},
		"arsenal_002": {"name": "Sabre de Ferro Velho", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_002"},
		"arsenal_003": {"name": "Espada de Treino da Guarda", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_003"},
		"arsenal_004": {"name": "Espada Larga de Bronze", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_004"},
		"arsenal_005": {"name": "Lâmina Polida de Aço", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_005"},
		"arsenal_006": {"name": "Espada Longa do Cavaleiro", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_006"},
		"arsenal_007": {"name": "Gládio de Aço Temperado", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_007"},
		"arsenal_008": {"name": "Lâmina de Carapaça Branca", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_008"},
		"arsenal_009": {"name": "Espada de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_009"},
		"arsenal_010": {"name": "Sabre Rúnico de Safira", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_010"},
		"arsenal_011": {"name": "Lâmina do Guardião do Santuário", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_011"},
		"arsenal_012": {"name": "Espada de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_012"},
		"arsenal_013": {"name": "Lâmina Arcana do Duelo", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_013"},
		"arsenal_014": {"name": "Espada Real Celestial", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_014"},
		"arsenal_015": {"name": "Soberana das Marés", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_015"},
		"arsenal_016": {"name": "Machado de Lenhador", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_016"},
		"arsenal_017": {"name": "Montante de Ferro Bruto", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_017"},
		"arsenal_018": {"name": "Clava Reforçada", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_018"},
		"arsenal_019": {"name": "Machado de Batalha de Bronze", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_019"},
		"arsenal_020": {"name": "Espadão de Aço Simples", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_020"},
		"arsenal_021": {"name": "Alabarda de Aço Azul", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_021"},
		"arsenal_022": {"name": "Machado Duplo Temperado", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_022"},
		"arsenal_023": {"name": "Quebra-Rochas da Pedreira", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_023"},
		"arsenal_024": {"name": "Montante de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_024"},
		"arsenal_025": {"name": "Machado de Esmeralda Bruta", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_025"},
		"arsenal_026": {"name": "Destruidora de Colossos", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_026"},
		"arsenal_027": {"name": "Espadão de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_027"},
		"arsenal_028": {"name": "Machado Carmesim do Abismo", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_028"},
		"arsenal_029": {"name": "Montante do Rei Antigo", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_029"},
		"arsenal_030": {"name": "Fúria do Leviatã", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_030"},
		"arsenal_031": {"name": "Faca de Caça Enferrujada", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_031"},
		"arsenal_032": {"name": "Punhal de Couro e Ferro", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_032"},
		"arsenal_033": {"name": "Estilete dos Subúrbios", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_033"},
		"arsenal_034": {"name": "Adaga de Bronze Polido", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_034"},
		"arsenal_035": {"name": "Adaga de Aço", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_035"},
		"arsenal_036": {"name": "Punhal de Aço Azulado", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_036"},
		"arsenal_037": {"name": "Adaga Prateada da Sombra", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_037"},
		"arsenal_038": {"name": "Presa da Fera Branca", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_038"},
		"arsenal_039": {"name": "Adaga de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_039"},
		"arsenal_040": {"name": "Adaga de Safira Sombria", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_040"},
		"arsenal_041": {"name": "Lâmina do Nêmesis", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_041"},
		"arsenal_042": {"name": "Adaga de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_042"},
		"arsenal_043": {"name": "Garra do Crepúsculo", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_043"},
		"arsenal_044": {"name": "Adaga Celestial do Silêncio", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_044"},
		"arsenal_045": {"name": "Presa Abissal", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_045"},
		"arsenal_046": {"name": "Arco Curto de Madeira Seca", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_046"},
		"arsenal_047": {"name": "Arco de Caça Rústico", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_047"},
		"arsenal_048": {"name": "Arco Improvisado de Cipó", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_048"},
		"arsenal_049": {"name": "Arco Longo de Freixo", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_049"},
		"arsenal_050": {"name": "Arco Reforçado de Bronze", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_050"},
		"arsenal_051": {"name": "Arco Composto de Aço", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_051"},
		"arsenal_052": {"name": "Arco Prateado da Patrulha", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_052"},
		"arsenal_053": {"name": "Arco de Osso da Pedreira", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_053"},
		"arsenal_054": {"name": "Arco Élfico de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_054"},
		"arsenal_055": {"name": "Arco de Esmeralda do Bosque", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_055"},
		"arsenal_056": {"name": "Arco dos Ventos do Santuário", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_056"},
		"arsenal_057": {"name": "Arco de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_057"},
		"arsenal_058": {"name": "Arco Rúnico do Horizonte", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_058"},
		"arsenal_059": {"name": "Arco Celestial do Reino", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_059"},
		"arsenal_060": {"name": "Arco das Tormentas Marinhas", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_060"},
		"arsenal_061": {"name": "Cajado de Carvalho Velho", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_061"},
		"arsenal_062": {"name": "Varinha de Aprendiz", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_062"},
		"arsenal_063": {"name": "Bastão de Cristal Opaco", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_063"},
		"arsenal_064": {"name": "Cajado de Bronze e Âmbar", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_064"},
		"arsenal_065": {"name": "Cetro de Aço Polido", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_065"},
		"arsenal_066": {"name": "Cajado de Aço Azulado", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_066"},
		"arsenal_067": {"name": "Bastão Prateado de Gelo", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_067"},
		"arsenal_068": {"name": "Cajado de Quartzo Branco", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_068"},
		"arsenal_069": {"name": "Cajado de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_069"},
		"arsenal_070": {"name": "Cetro de Safira Arcana", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_070"},
		"arsenal_071": {"name": "Cajado do Oráculo Antigo", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_071"},
		"arsenal_072": {"name": "Cajado de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_072"},
		"arsenal_073": {"name": "Bastão Astral de Filigrana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_073"},
		"arsenal_074": {"name": "Cajado Celestial Supremo", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_074"},
		"arsenal_075": {"name": "Cetro do Abismo Oceânico", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_075"},
		"arsenal_076": {"name": "Lança de Madeira e Ferro", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_076"},
		"arsenal_077": {"name": "Pique de Milícia", "type": "arma", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_077"},
		"arsenal_078": {"name": "Lança Curta de Bronze", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_078"},
		"arsenal_079": {"name": "Partasana de Aço", "type": "arma", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_079"},
		"arsenal_080": {"name": "Lança de Cavalaria Azul", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_080"},
		"arsenal_081": {"name": "Alabarda Prateada Real", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_081"},
		"arsenal_082": {"name": "Lança de Carapaça Branca", "type": "arma", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_082"},
		"arsenal_083": {"name": "Lança de Mithril", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_083"},
		"arsenal_084": {"name": "Pique Rúnico de Esmeralda", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_084"},
		"arsenal_085": {"name": "Lança do Guardião da Região", "type": "arma", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_085"},
		"arsenal_086": {"name": "Lança de Obsidiana", "type": "arma", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_086"},
		"arsenal_087": {"name": "Lança Dourada da Ordem", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_087"},
		"arsenal_088": {"name": "Tridente do Colossal do Mar", "type": "arma", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_088"},
		"arsenal_089": {"name": "Escudo Redondo de Madeira", "type": "escudo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_089"},
		"arsenal_090": {"name": "Broquel de Ferro Velho", "type": "escudo", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_090"},
		"arsenal_091": {"name": "Escudo de Bronze Reforçado", "type": "escudo", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_091"},
		"arsenal_092": {"name": "Escudo Torre de Aço", "type": "escudo", "grade": "D", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_092"},
		"arsenal_093": {"name": "Escudo de Aço Temperado", "type": "escudo", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_093"},
		"arsenal_094": {"name": "Escudo Prateado do Guarda", "type": "escudo", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_094"},
		"arsenal_095": {"name": "Égide de Carapaça Branca", "type": "escudo", "grade": "C", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_095"},
		"arsenal_096": {"name": "Escudo de Mithril", "type": "escudo", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_096"},
		"arsenal_097": {"name": "Escudo Rúnico de Safira", "type": "escudo", "grade": "B", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_097"},
		"arsenal_098": {"name": "Escudo de Obsidiana", "type": "escudo", "grade": "A", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_098"},
		"arsenal_099": {"name": "Baluarte Celestial do Reino", "type": "escudo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_099"},
		"arsenal_100": {"name": "Égide das Profundezas", "type": "escudo", "grade": "S", "value": 0, "weight": 0.0, "desc": "Arma do catálogo Arsenal RPG. Sem atributos por enquanto.", "catalog_art": "arma_100"},
		"armadura_catalogo_001": {"name": "Aprendiz", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_001"},
		"armadura_catalogo_002": {"name": "Viajante", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_002"},
		"armadura_catalogo_003": {"name": "Acólito", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_003"},
		"armadura_catalogo_004": {"name": "Erudito", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_004"},
		"armadura_catalogo_005": {"name": "Runas Azuis", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_005"},
		"armadura_catalogo_006": {"name": "Tecelão Arcano", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_006"},
		"armadura_catalogo_007": {"name": "Sábio de Mithril", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_007"},
		"armadura_catalogo_008": {"name": "Oráculo", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_008"},
		"armadura_catalogo_009": {"name": "Vestes Astrais", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_009"},
		"armadura_catalogo_010": {"name": "Manto Celestial", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_010"},
		"armadura_catalogo_011": {"name": "Caçador Novato", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_011"},
		"armadura_catalogo_012": {"name": "Explorador", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_012"},
		"armadura_catalogo_013": {"name": "Batedor", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_013"},
		"armadura_catalogo_014": {"name": "Couro Reforçado", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_014"},
		"armadura_catalogo_015": {"name": "Patrulheiro", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_015"},
		"armadura_catalogo_016": {"name": "Couro de Fera", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_016"},
		"armadura_catalogo_017": {"name": "Caçador Rúnico", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_017"},
		"armadura_catalogo_018": {"name": "Rastreador Real", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_018"},
		"armadura_catalogo_019": {"name": "Predador Sombrio", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_019"},
		"armadura_catalogo_020": {"name": "Caçador Celestial", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_020"},
		"armadura_catalogo_021": {"name": "Recruta", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_021"},
		"armadura_catalogo_022": {"name": "Miliciano", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_022"},
		"armadura_catalogo_023": {"name": "Guarda de Bronze", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_023"},
		"armadura_catalogo_024": {"name": "Sentinela", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_024"},
		"armadura_catalogo_025": {"name": "Malha Temperada", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_025"},
		"armadura_catalogo_026": {"name": "Guarda Azul", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_026"},
		"armadura_catalogo_027": {"name": "Malha de Mithril", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_027"},
		"armadura_catalogo_028": {"name": "Defensor Rúnico", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_028"},
		"armadura_catalogo_029": {"name": "Malha de Obsidiana", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_029"},
		"armadura_catalogo_030": {"name": "Sentinela Celestial", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_030"},
		"armadura_catalogo_031": {"name": "Escudeiro", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_031"},
		"armadura_catalogo_032": {"name": "Ferro Gasto", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_032"},
		"armadura_catalogo_033": {"name": "Soldado de Bronze", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_033"},
		"armadura_catalogo_034": {"name": "Cavaleiro de Ferro", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_034"},
		"armadura_catalogo_035": {"name": "Aço Temperado", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_035"},
		"armadura_catalogo_036": {"name": "Cavaleiro Real", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_036"},
		"armadura_catalogo_037": {"name": "Placas de Mithril", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_037"},
		"armadura_catalogo_038": {"name": "Guardião de Safira", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_038"},
		"armadura_catalogo_039": {"name": "Placas de Obsidiana", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_039"},
		"armadura_catalogo_040": {"name": "Soberano Celestial", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_040"},
		"armadura_catalogo_041": {"name": "Andarilho Verde", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_041"},
		"armadura_catalogo_042": {"name": "Coletor do Bosque", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_042"},
		"armadura_catalogo_043": {"name": "Guardião de Casca", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_043"},
		"armadura_catalogo_044": {"name": "Couro de Musgo", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_044"},
		"armadura_catalogo_045": {"name": "Vigia Élfico", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_045"},
		"armadura_catalogo_046": {"name": "Folhas de Prata", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_046"},
		"armadura_catalogo_047": {"name": "Sentinela Esmeralda", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_047"},
		"armadura_catalogo_048": {"name": "Druida Ancestral", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_048"},
		"armadura_catalogo_049": {"name": "Espinhos Sombrios", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_049"},
		"armadura_catalogo_050": {"name": "Coração da Floresta", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_050"},
		"armadura_catalogo_051": {"name": "Minerador", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_051"},
		"armadura_catalogo_052": {"name": "Desbravador", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_052"},
		"armadura_catalogo_053": {"name": "Guarda de Cobre", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_053"},
		"armadura_catalogo_054": {"name": "Ferreiro de Bronze", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_054"},
		"armadura_catalogo_055": {"name": "Guardião de Granito", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_055"},
		"armadura_catalogo_056": {"name": "Carapaça Branca", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_056"},
		"armadura_catalogo_057": {"name": "Forja de Mithril", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_057"},
		"armadura_catalogo_058": {"name": "Defensor de Quartzo", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_058"},
		"armadura_catalogo_059": {"name": "Basalto Rúnico", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_059"},
		"armadura_catalogo_060": {"name": "Rei da Montanha", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_060"},
		"armadura_catalogo_061": {"name": "Viajante do Frio", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_061"},
		"armadura_catalogo_062": {"name": "Caçador da Neve", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_062"},
		"armadura_catalogo_063": {"name": "Pele de Lobo", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_063"},
		"armadura_catalogo_064": {"name": "Guarda Invernal", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_064"},
		"armadura_catalogo_065": {"name": "Aço Glacial", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_065"},
		"armadura_catalogo_066": {"name": "Vigia da Geada", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_066"},
		"armadura_catalogo_067": {"name": "Cristal Ártico", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_067"},
		"armadura_catalogo_068": {"name": "Guardião da Aurora", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_068"},
		"armadura_catalogo_069": {"name": "Soberano do Gelo", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_069"},
		"armadura_catalogo_070": {"name": "Coroa do Inverno", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_070"},
		"armadura_catalogo_071": {"name": "Vigia das Cinzas", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_071"},
		"armadura_catalogo_072": {"name": "Couro Chamuscado", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_072"},
		"armadura_catalogo_073": {"name": "Guarda de Cobre Rubro", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_073"},
		"armadura_catalogo_074": {"name": "Forja Escarlate", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_074"},
		"armadura_catalogo_075": {"name": "Aço Incandescente", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_075"},
		"armadura_catalogo_076": {"name": "Caçador de Brasas", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_076"},
		"armadura_catalogo_077": {"name": "Rubi Rúnico", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_077"},
		"armadura_catalogo_078": {"name": "Guardião Vulcânico", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_078"},
		"armadura_catalogo_079": {"name": "Obsidiana Ardente", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_079"},
		"armadura_catalogo_080": {"name": "Soberano das Chamas", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_080"},
		"armadura_catalogo_081": {"name": "Vigia Noturno", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_081"},
		"armadura_catalogo_082": {"name": "Couro Escuro", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_082"},
		"armadura_catalogo_083": {"name": "Batedor da Névoa", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_083"},
		"armadura_catalogo_084": {"name": "Guarda Crepuscular", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_084"},
		"armadura_catalogo_085": {"name": "Assassino de Prata", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_085"},
		"armadura_catalogo_086": {"name": "Caçador do Eclipse", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_086"},
		"armadura_catalogo_087": {"name": "Safira Sombria", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_087"},
		"armadura_catalogo_088": {"name": "Guardião Lunar", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_088"},
		"armadura_catalogo_089": {"name": "Cavaleiro do Abismo", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_089"},
		"armadura_catalogo_090": {"name": "Soberano da Noite", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_090"},
		"armadura_catalogo_091": {"name": "Marinheiro", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_091"},
		"armadura_catalogo_092": {"name": "Explorador da Costa", "type": "armadura", "grade": "NG", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_092"},
		"armadura_catalogo_093": {"name": "Guarda de Coral", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_093"},
		"armadura_catalogo_094": {"name": "Couro de Arraia", "type": "armadura", "grade": "D", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_094"},
		"armadura_catalogo_095": {"name": "Escamas Azuis", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_095"},
		"armadura_catalogo_096": {"name": "Carapaça Marinha", "type": "armadura", "grade": "C", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_096"},
		"armadura_catalogo_097": {"name": "Mithril das Marés", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_097"},
		"armadura_catalogo_098": {"name": "Guardião de Pérolas", "type": "armadura", "grade": "B", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_098"},
		"armadura_catalogo_099": {"name": "Armadura Abissal", "type": "armadura", "grade": "A", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_099"},
		"armadura_catalogo_100": {"name": "Soberano do Leviatã", "type": "armadura", "grade": "S", "value": 0, "weight": 0.0, "desc": "Conjunto de armadura do catálogo RPG. Sem atributos por enquanto.", "catalog_art": "armadura_100"},

}

const RECIPES: = [
	{"id": "selo_cristal", "name": "Selo de Entrada", "output": "selo_entrada", "qty": 1, 
		"materials": {"sucata_ferro": 6, "cristal_aurora": 1}, "cost": 60, "chance": 0.9, 
		"desc": "Sela o portão com a luz do cristal de Aurora."}, 
	{"id": "selo_carapaca", "name": "Selo de Entrada (carapaça)", "output": "selo_entrada", "qty": 1, 
		"materials": {"sucata_ferro": 4, "carapaca_branca": 1}, "cost": 80, "chance": 0.9, 
		"desc": "A carapaça da fera substitui o cristal."}, 
	{"id": "arma_d", "name": "Lâmina de Aço", "output": "arma_d", "qty": 1, 
		"materials": {"sucata_ferro": 12, "presa_lobo": 3}, "cost": 150, "chance": 0.85, 
		"desc": "Arma da Grade D.", "grade": "D"}, 
	{"id": "armadura_d", "name": "Cota de Malha", "output": "armadura_d", "qty": 1, 
		"materials": {"sucata_ferro": 14, "gosma": 4}, "cost": 150, "chance": 0.85, 
		"desc": "Armadura da Grade D.", "grade": "D"}, 
	{"id": "joia_d", "name": "Anel de Prata", "output": "joia_d", "qty": 1, 
		"materials": {"cristal_aurora": 2, "gosma": 2}, "cost": 120, "chance": 0.9, 
		"desc": "Joia da Grade D.", "grade": "D"}, 
	{"id": "pocao_cura", "name": "Poção de Cura", "output": "pocao_cura", "qty": 1, 
		"materials": {"gosma": 2}, "cost": 20, "chance": 0.95, 
		"desc": "Recupera 60 de HP."}, 
	{"id": "pocao_mana", "name": "Poção de Mana", "output": "pocao_mana", "qty": 1,
		"materials": {"gosma": 2, "cristal_aurora": 1}, "cost": 20, "chance": 0.95,
		"desc": "Recupera 50 de mana."},
	{"id": "pocao_energia", "name": "Poção de Energia", "output": "pocao_energia", "qty": 1,
		"materials": {"gosma": 2, "presa_lobo": 1}, "cost": 20, "chance": 0.95,
		"desc": "Recupera 30 de energia."},
	{"id": "armadura_carapaca", "name": "Peitoral de Carapaça", "output": "armadura_c", "qty": 1, 
		"materials": {"carapaca_branca": 2, "sucata_ferro": 10}, "cost": 400, "chance": 0.8, 
		"desc": "Armadura da Grade C feita com a fera da pedreira.", "grade": "C"}, 
]



const CONTRACTS: = [
	{"id": "contrato_lobos", "name": "Patrulha das Estradas", "difficulty": "Média", 
		"desc": "Lobos cercam a estrada do vale. Abata 5 lobos.", "kind": "kill", 
		"target": "lobo", "count": 5, "fame": 1.0, "coins": 300, "xp": 420}, 
	{"id": "contrato_gosmas", "name": "Praga do Vale", "difficulty": "Média", 
		"desc": "Gosmas avançam sobre a plantação. Elimine 6.", "kind": "kill", 
		"target": "gosma", "count": 6, "fame": 1.0, "coins": 260, "xp": 380}, 
	{"id": "contrato_errantes", "name": "Limpeza de Errantes", "difficulty": "Difícil", 
		"desc": "Monstros escaparam de uma dungeon. Cace 3 errantes.", "kind": "kill", 
		"target": "errante", "count": 3, "fame": 2.0, "coins": 500, "xp": 900, 
		"requires_hostility": true}, 
	{"id": "contrato_fera", "name": "A Fera da Pedreira", "difficulty": "Difícil", 
		"desc": "A fera de carapaça branca ronda a pedreira. Derrube-a.", "kind": "kill", 
		"target": "fera", "count": 1, "fame": 2.0, "coins": 700, "xp": 1400}, 
	{"id": "contrato_diario", "name": "Contrato Diário de Caça", "difficulty": "Diário", 
		"desc": "Elimine 8 monstros em qualquer área do vale.", "kind": "kill", 
		"target": "qualquer", "count": 8, "fame": 0.5, "coins": 220, "xp": 500}, 
]

const QUEST_COLOSSAL: = {"id": "quest_colossal", "name": "O Primeiro Colossal", 
	"desc": "Entre no santuário e derrote o Colossal de Granito.", "fame": 4.0, "coins": 1200, "xp": 3500}

const CLASS_QUEST: = {"id": "class_quest", "name": "Missão de Classe", 
	"desc": "Alcance o nível 20 e derrube o Colossal para receber a terceira skill da classe."}



const REGIONS: = [
	{"id": "aurora", "name": "Vale de Aurora", "desc": "Cidade, fazenda e pedreira. O santuário do primeiro Colossal.", "open": true}, 
	{"id": "vespera", "name": "Bosque de Véspera", "desc": "Floresta onde os errantes se escondem à noite.", "open": false}, 
	{"id": "sal", "name": "Pântano de Sal", "desc": "Águas paradas e criaturas de carapaça.", "open": false}, 
	{"id": "ambar", "name": "Costa do Âmbar", "desc": "Praias douradas e contrabandistas.", "open": false}, 
	{"id": "cinzas", "name": "Deserto de Cinzas", "desc": "Vento quente e ruínas soterradas.", "open": false}, 
	{"id": "gelidos", "name": "Picos Gélidos", "desc": "Montanhas onde o gelo nunca derrete.", "open": false}, 
	{"id": "oren", "name": "Ruínas de Oren", "desc": "Cidade perdida de um reino anterior.", "open": false}, 
	{"id": "dourada", "name": "Planície Dourada", "desc": "Celeiros do reino e estradas reais.", "open": false}, 
	{"id": "mare", "name": "Cais de Maré Alta", "desc": "A maior cidade comercial. De lá parte a expedição ao mar.", "open": false}, 
]



static func race(id: String) -> Dictionary:
	if id == "elarim":
		var data: Dictionary = RACES.elfo.duplicate()
		data.name = "Elarim"
		data.desc = "Habitante ancestral de Aurora, ligado à magia e aos caminhos do vento."
		return data
	return RACES.get(id, RACES["humano"])

static func character_class(id: String) -> Dictionary:
	return CLASSES.get(id, CLASSES["guerreiro"])

static func all_skills(class_id: String) -> Array:
	var data: Dictionary = character_class(class_id)
	return (data["ativas"] as Array) + (data["passivas"] as Array)

static func skill(class_id: String, skill_id: String) -> Dictionary:
	for entry: Dictionary in all_skills(class_id):
		if entry["id"] == skill_id:
			return entry
	return {}

static func grade_for_level(level: int) -> Dictionary:
	var current: Dictionary = GRADES[0]
	for grade: Dictionary in GRADES:
		if level >= int(grade["min"]):
			current = grade
	return current

static func grade_index(grade_id: String) -> int:
	for index in GRADES.size():
		if GRADES[index]["id"] == grade_id:
			return index
	return 0

static func item(id: String) -> Dictionary:
	return ITEMS.get(id, {})

static func xp_to_next(level: int) -> int:
	return int(round(45.0 * pow(float(level), 1.28) + 30.0 * float(level)))

static func item_short_name(id: String) -> String:
	return str(ITEMS.get(id, {}).get("name", id))
