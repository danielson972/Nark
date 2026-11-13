class_name PlayerState
extends RefCounted


const EQUIP_SLOTS: = ["arma", "armadura", "joia"]

var hero_name: = "Herói"
var race_id: = "humano"
var class_id: = "guerreiro"
var level: = 1
var xp: = 0
var fame: = 0.0
var coins: = 0

var hp: = 100.0
var mp: = 40.0
var energy: = 100.0

var skill_levels: Dictionary = {}
var evolutions: Array = []
var hotbar: Array = []
var inventory: Array = []
var stored: Array = []
var equipment: Dictionary = {}
var contracts: Array = []
var flags: Dictionary = {}
var hostility: = 0.0
var errantes_alive: = 0
var play_seconds: = 0.0
var kills: = 0
var time_of_day: = 0.18
var day_count: = 1
var rival_defeated: = 0
var rival_pending: = false

static func create(p_name: String, p_race: String, p_class: String) -> PlayerState:
	var state: = PlayerState.new()
	state.hero_name = p_name.strip_edges().left(14)
	if state.hero_name.is_empty():
		state.hero_name = "Herói"
	state.race_id = p_race
	state.class_id = p_class
	for slot: String in EQUIP_SLOTS:
		state.equipment[slot] = {}
	state.hp = state.max_hp()
	state.mp = state.max_mp()
	state.energy = state.max_energy()
	var class_data: Dictionary = GameData.character_class(p_class)
	var start_actives: Array = class_data["ativas"]
	state.skill_levels[str(start_actives[0]["id"])] = 1
	state.skill_levels[str(start_actives[1]["id"])] = 1
	for passive: Dictionary in class_data["passivas"]:
		if int(passive["unlock"]) <= 1:
			state.skill_levels[str(passive["id"])] = 1
	state.hotbar = [str(start_actives[0]["id"]), str(start_actives[1]["id"]), "", "", "", "", "", "", "", ""]
	state.add_item("arma_ng", 1, true)
	state.add_item("armadura_ng", 1, true)
	state.add_item("pocao_cura", 2, true)
	state.equip("arma_ng")
	state.equip("armadura_ng")
	state.contracts = [
		{"id": "contrato_lobos", "progress": 0, "claimed": false, "done": false}, 
		{"id": "contrato_gosmas", "progress": 0, "claimed": false, "done": false}, 
	]
	state.flags = {
		"gate_open": false, 
		"colossal_defeated": false, 
		"teleport_unlocked": false, 
		"class_quest_done": false, 
		"bef_used": 0, 
		"intro_seen": false, 
	}
	return state



func race() -> Dictionary:
	return GameData.race(race_id)

func class_data() -> Dictionary:
	return GameData.character_class(class_id)

func grade() -> Dictionary:
	return GameData.grade_for_level(level)

func skill_cap() -> int:
	return int(grade()["skill_cap"])

func equipped_bonus(key: String) -> float:
	var total: = 0.0
	for slot: String in EQUIP_SLOTS:
		var entry: Dictionary = equipment.get(slot, {})
		if entry.is_empty():
			continue
		var item: Dictionary = GameData.item(str(entry.get("id", "")))
		if not item.has(key):
			continue
		var factor: = 1.0
		var maximum: = float(entry.get("max", 100.0))
		if maximum > 0.0:
			factor = clampf(float(entry.get("durability", 0.0)) / maximum, 0.0, 1.0)
		total += float(item[key]) * (0.4 + 0.6 * factor)
	return total

func max_hp() -> float:
	var base: Dictionary = class_data()["base"]
	var value: = float(base["hp"]) + (level - 1) * Balance.HP_PER_LEVEL
	value *= 1.0 + float(grade()["hp_bonus"])
	value += float(race()["hp"])
	value += equipped_bonus("hp")
	if is_skill_learned("despertar_heroico"):
		value += 0.0
	return round(value)

func max_mp() -> float:
	var base: Dictionary = class_data()["base"]
	return round(float(base["mp"]) + (level - 1) * Balance.MP_PER_LEVEL)

func max_energy() -> float:
	var base: Dictionary = class_data()["base"]
	return round(float(base["energy"]) + (level - 1) * Balance.ENERGY_PER_LEVEL)

func damage_power() -> float:
	var base: Dictionary = class_data()["base"]
	var value: = float(base["damage"]) + (level - 1) * Balance.DAMAGE_PER_LEVEL
	value += equipped_bonus("damage")
	return value

func defense_power() -> float:
	var base: Dictionary = class_data()["base"]
	return float(base["defense"]) + (level - 1) * Balance.DEFENSE_PER_LEVEL + equipped_bonus("defense")

func crit_physical() -> float:
	var base: Dictionary = class_data()["base"]
	return float(base["crit_phys"]) + (level - 1) * Balance.CRIT_PER_LEVEL + equipped_bonus("crit")

func crit_magical() -> float:
	var base: Dictionary = class_data()["base"]
	return float(base["crit_magic"]) + (level - 1) * Balance.CRIT_PER_LEVEL * 0.5

func move_speed() -> float:
	var base: Dictionary = class_data()["base"]
	var value: = float(base["speed"])
	value *= 1.0 + float(grade()["speed_bonus"])
	value *= 1.0 + float(race()["speed"])
	return value

func strength() -> float:
	return float(class_data()["base"]["strength"]) + (level - 1) * 0.4

func weight_capacity() -> float:
	return Balance.WEIGHT_BASE + strength() * Balance.WEIGHT_PER_STRENGTH

func attack_range() -> float:
	return float(class_data()["range"])

func fame_cap() -> float:
	return Balance.FAME_CAP_S if str(grade()["id"]) == "S" else Balance.FAME_CAP_DEFAULT

func resist_wanderers() -> float:
	return float(grade()["resist"])

func regen_multiplier() -> float:
	return float(race()["regen"])



func unlock_level_of(skill_id: String) -> int:
	for entry: Dictionary in GameData.all_skills(class_id):
		if str(entry["id"]) == skill_id:
			var unlock: = int(entry["unlock"])
			if unlock <= 1:
				return 1
			if unlock >= 60:
				return 60
			return unlock
	return 99

func is_skill_learned(skill_id: String) -> bool:
	if skill_id == "explosao_aura":
		return level >= 80
	if skill_id == "despertar_heroico":
		return level >= 100
	return skill_levels.has(skill_id)

func skill_level(skill_id: String) -> int:
	return int(skill_levels.get(skill_id, 0))

func available_skill_ids() -> Array:
	var ids: Array = []
	for entry: Dictionary in GameData.all_skills(class_id):
		if is_skill_learned(str(entry["id"])):
			ids.append(str(entry["id"]))
	if level >= 80:
		ids.append("explosao_aura")
	if level >= 100:
		ids.append("despertar_heroico")
	return ids

func add_xp(amount: int) -> Array:
	var levels_gained: Array = []
	xp += maxi(0, amount)
	while level < 100 and xp >= GameData.xp_to_next(level):
		xp -= GameData.xp_to_next(level)
		level += 1
		levels_gained.append(level)
	if level >= 100:
		level = 100
		xp = 0
	_sync_evolution_skills()
	return levels_gained

func _sync_evolution_skills() -> void :
	var class_info: Dictionary = class_data()
	var actives: Array = class_info["ativas"]
	var passives: Array = class_info["passivas"]


	if level >= 20 and bool(flags.get("class_quest_done", false)):
		skill_levels[str(actives[2]["id"])] = maxi(1, skill_level(actives[2]["id"]))
	if level >= 40:
		skill_levels[str(passives[1]["id"])] = maxi(1, skill_level(passives[1]["id"]))
	if level >= 60:
		skill_levels[str(actives[3]["id"])] = maxi(1, skill_level(actives[3]["id"]))
	for skill_id: String in available_skill_ids():
		if str(skill_id).begins_with("explosao") or str(skill_id).begins_with("despertar"):
			continue
		if not hotbar_has(skill_id) and hotbar_has_free_slot():
			hotbar[first_free_hotbar_slot()] = skill_id
	for universal: String in ["explosao_aura", "despertar_heroico"]:
		if is_skill_learned(universal) and not hotbar_has(universal) and hotbar_has_free_slot():
			hotbar[first_free_hotbar_slot()] = universal

func add_fame(amount: float) -> float:
	var cap: = fame_cap()
	var before: = fame
	fame = clampf(fame + amount, 0.0, cap)
	return fame - before

func hotbar_has(skill_id: String) -> bool:
	return hotbar.has(skill_id)

func hotbar_has_free_slot() -> bool:
	return first_free_hotbar_slot() >= 0

func first_free_hotbar_slot() -> int:
	for index in hotbar.size():
		if str(hotbar[index]).is_empty():
			return index
	return -1

func upgrade_skill(skill_id: String) -> bool:
	if not skill_levels.has(skill_id):
		return false
	if skill_level(skill_id) >= skill_cap():
		return false
	skill_levels[skill_id] = skill_level(skill_id) + 1
	return true



func item_weight(entry: Dictionary) -> float:
	return float(GameData.item(str(entry.get("id", ""))).get("weight", 0.0)) * int(entry.get("qty", 1))

func carried_weight() -> float:
	var total: = 0.0
	for entry: Dictionary in inventory:
		total += item_weight(entry)
	return total

func count_item(item_id: String) -> int:
	var total: = 0
	for entry: Dictionary in inventory:
		if str(entry.get("id", "")) == item_id:
			total += int(entry.get("qty", 0))
	return total

func add_item(item_id: String, qty: int = 1, silent: bool = false) -> bool:
	if qty <= 0:
		return true
	if not silent and carried_weight() + float(GameData.item(item_id).get("weight", 0.0)) * qty > weight_capacity():
		return false
	for entry: Dictionary in inventory:
		if str(entry.get("id", "")) == item_id:
			entry["qty"] = int(entry["qty"]) + qty
			return true
	inventory.append({"id": item_id, "qty": qty})
	return true

func remove_item(item_id: String, qty: int = 1) -> bool:
	if count_item(item_id) < qty:
		return false
	var remaining: = qty
	for index in range(inventory.size() - 1, -1, -1):
		var entry: Dictionary = inventory[index]
		if str(entry.get("id", "")) != item_id:
			continue
		var take: int = mini(remaining, int(entry["qty"]))
		entry["qty"] = int(entry["qty"]) - take
		remaining -= take
		if int(entry["qty"]) <= 0:
			inventory.remove_at(index)
		if remaining <= 0:
			break
	return true

func equip(item_id: String) -> String:
	var item: Dictionary = GameData.item(item_id)
	var slot: = str(item.get("type", ""))
	if not EQUIP_SLOTS.has(slot):
		return "Esse item não pode ser equipado."
	if count_item(item_id) <= 0:
		return "Você não possui esse item."
	remove_item(item_id, 1)
	var previous: Dictionary = equipment.get(slot, {})
	if not previous.is_empty():
		add_item(str(previous["id"]), 1, true)
	equipment[slot] = {"id": item_id, "durability": float(item.get("durability", 100.0)), "max": float(item.get("durability", 100.0))}
	return ""

func unequip(slot: String) -> void :
	var entry: Dictionary = equipment.get(slot, {})
	if entry.is_empty():
		return
	if add_item(str(entry["id"]), 1, true):
		equipment[slot] = {}

func wear_equipment(amount: float) -> void :
	for slot: String in EQUIP_SLOTS:
		var entry: Dictionary = equipment.get(slot, {})
		if entry.is_empty():
			continue
		entry["durability"] = maxf(0.0, float(entry["durability"]) - amount)

func durability_ratio() -> float:
	var total: = 0.0
	var count: = 0
	for slot: String in EQUIP_SLOTS:
		var entry: Dictionary = equipment.get(slot, {})
		if entry.is_empty():
			continue
		total += clampf(float(entry["durability"]) / float(entry["max"]), 0.0, 1.0)
		count += 1
	return total / float(count) if count > 0 else 1.0

func repair_cost() -> int:
	var total: = 0
	for slot: String in EQUIP_SLOTS:
		var entry: Dictionary = equipment.get(slot, {})
		if entry.is_empty():
			continue
		var missing: = float(entry["max"]) - float(entry["durability"])
		var item: Dictionary = GameData.item(str(entry["id"]))
		var grade_value: = maxi(1, int(item.get("value", 100)))
		total += int(round(missing * float(grade_value) * 0.06))
	return total

func repair_all() -> void :
	for slot: String in EQUIP_SLOTS:
		var entry: Dictionary = equipment.get(slot, {})
		if entry.is_empty():
			continue
		entry["durability"] = float(entry["max"])

func price(base: int) -> int:
	var factor: = 1.0 - float(race()["discount"])
	factor *= 1.0 + Balance.HOSTILITY_PRICE_FACTOR * (hostility / 100.0)
	return maxi(1, int(round(float(base) * factor)))



func contract_state(contract_id: String) -> Dictionary:
	for entry: Dictionary in contracts:
		if str(entry.get("id", "")) == contract_id:
			return entry
	return {}

func register_kill(monster_kind: String) -> Array:
	var completed: Array = []
	for entry: Dictionary in contracts:
		if bool(entry.get("claimed", false)):
			continue
		var definition: Dictionary = {}
		for candidate: Dictionary in GameData.CONTRACTS:
			if str(candidate["id"]) == str(entry["id"]):
				definition = candidate
		if definition.is_empty():
			continue
		var target: = str(definition["target"])
		if target == "qualquer" or target == monster_kind:
			entry["progress"] = int(entry.get("progress", 0)) + 1
			if int(entry["progress"]) >= int(definition["count"]):
				entry["done"] = true
				completed.append(str(entry["id"]))
	return completed

func accepts_contract(contract_id: String) -> bool:
	for entry: Dictionary in contracts:
		if str(entry.get("id", "")) == contract_id:
			return false
	var definition: Dictionary = {}
	for candidate: Dictionary in GameData.CONTRACTS:
		if str(candidate["id"]) == contract_id:
			definition = candidate
	if definition.is_empty():
		return false
	if bool(definition.get("requires_hostility", false)) and errantes_alive <= 0:
		return false
	return true



func to_dict() -> Dictionary:
	return {
		"hero_name": hero_name, "race_id": race_id, "class_id": class_id, 
		"level": level, "xp": xp, "fame": fame, "coins": coins, 
		"hp": hp, "mp": mp, "energy": energy, 
		"skill_levels": skill_levels.duplicate(true), "evolutions": evolutions.duplicate(true), 
		"hotbar": hotbar.duplicate(true), "inventory": inventory.duplicate(true), 
		"stored": stored.duplicate(true), "equipment": equipment.duplicate(true), 
		"contracts": contracts.duplicate(true), "flags": flags.duplicate(true), 
		"hostility": hostility, "errantes_alive": errantes_alive, 
		"play_seconds": play_seconds, "kills": kills, "time_of_day": time_of_day, 
		"day_count": day_count, "rival_defeated": rival_defeated, "rival_pending": rival_pending, 
	}

func from_dict(data: Dictionary) -> void :
	hero_name = str(data.get("hero_name", "Herói"))
	race_id = str(data.get("race_id", "humano"))
	class_id = str(data.get("class_id", "guerreiro"))
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	fame = float(data.get("fame", 0.0))
	coins = int(data.get("coins", 0))
	hp = float(data.get("hp", max_hp()))
	mp = float(data.get("mp", max_mp()))
	energy = float(data.get("energy", max_energy()))
	skill_levels = (data.get("skill_levels", {}) as Dictionary).duplicate(true)
	evolutions = (data.get("evolutions", []) as Array).duplicate(true)
	hotbar = (data.get("hotbar", []) as Array).duplicate(true)
	while hotbar.size() < 10:
		hotbar.append("")
	inventory = (data.get("inventory", []) as Array).duplicate(true)
	stored = (data.get("stored", []) as Array).duplicate(true)
	equipment = (data.get("equipment", {}) as Dictionary).duplicate(true)
	for slot: String in EQUIP_SLOTS:
		if not equipment.has(slot):
			equipment[slot] = {}
	contracts = (data.get("contracts", []) as Array).duplicate(true)
	flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	hostility = float(data.get("hostility", 0.0))
	errantes_alive = int(data.get("errantes_alive", 0))
	play_seconds = float(data.get("play_seconds", 0.0))
	kills = int(data.get("kills", 0))
	time_of_day = float(data.get("time_of_day", 0.18))
	day_count = int(data.get("day_count", 1))
	rival_defeated = int(data.get("rival_defeated", 0))
	rival_pending = bool(data.get("rival_pending", false))
	hp = clampf(hp, 1.0, max_hp())
