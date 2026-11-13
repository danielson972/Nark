extends Control


var ui: GameUI
var world: WorldView
var state: PlayerState
var mode: = "title"
var world_flags: Dictionary = {}
var autosave_timer: = 0.0
var rng: = RandomNumberGenerator.new()


func _ready() -> void :
	rng.randomize()
	SaveGame.apply_display()
	ui = GameUI.new()
	add_child(ui)
	ui.new_game_requested.connect(_on_new_game)
	ui.continue_requested.connect(_on_continue)
	ui.quit_requested.connect(_on_quit)
	ui.resume_requested.connect(_resume)
	ui.title_requested.connect(_to_title)
	ui.panel_action.connect(_on_panel_action)
	ui.options_changed.connect(_on_options_changed)
	ui.show_title(SaveGame.has_save())
	AudioDirector.play_music("music.title")


func _process(delta: float) -> void :
	if mode == "playing" and world != null and state != null and world.hero != null:
		ui.refresh(state, world, world.hero, world.current_interaction())
		state.hp = world.hero.hp
		if SaveGame.autosave:
			autosave_timer += delta
			if autosave_timer >= Balance.AUTOSAVE_INTERVAL:
				autosave_timer = 0.0
				_save_game(true)


func _unhandled_input(event: InputEvent) -> void :
	if mode == "panel" and ui.current_panel == "skills" and event.is_action_pressed("skill_menu"):
		_close_panel()
		get_viewport().set_input_as_handled()
		return
	if mode == "panel" and ui.current_panel == "inventory" and event.is_action_pressed("inventory"):
		_close_panel()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if mode == "panel":
			_close_panel()
			get_viewport().set_input_as_handled()
			return
		if mode == "playing":
			_open_pause()
			get_viewport().set_input_as_handled()
			return
	if mode != "playing":
		return
	if event.is_action_pressed("inventory"):
		_open_panel("inventory")
	elif event.is_action_pressed("skill_menu"):
		_open_panel("skills")
	elif event.is_action_pressed("map_region"):
		_open_panel("map_region")
	elif event.is_action_pressed("map_world"):
		_open_panel("map_world")
	elif event.is_action_pressed("interact"):
		if world != null:
			world.use_interaction()
	elif event.is_action_pressed("potion"):
		if world != null:
			world.use_potion()
	if event.is_action_pressed("pause") or event.is_action_pressed("inventory")\
	or event.is_action_pressed("skill_menu") or event.is_action_pressed("map_region")\
	or event.is_action_pressed("map_world") or event.is_action_pressed("interact")\
	or event.is_action_pressed("potion"):
		get_viewport().set_input_as_handled()




func _on_new_game(race_id: String, class_id: String, hero_name: String) -> void :
	state = PlayerState.create(hero_name, race_id, class_id)
	world_flags = {}
	_start_world()
	ui.toast("Bem-vindo, %s. A estátua guarda seu progresso." % state.hero_name, UiKit.GOLD)


func _on_continue() -> void :
	var loaded: = SaveGame.load_player()
	if loaded == null:
		ui.toast("Nenhum save encontrado.", UiKit.BAD)
		return
	state = loaded
	var payload: = SaveGame.read_save()
	world_flags = payload.get("world", {}) as Dictionary
	_start_world()
	ui.toast("Partida restaurada. Bem-vindo de volta, %s." % state.hero_name, UiKit.GOLD)


func _start_world() -> void :
	if world != null:
		world.queue_free()
		world = null
	ui.close_modal()
	ui.close_overlay()
	world = WorldView.new()
	world.name = "Mundo"
	add_child(world)
	world.build(state, world_flags)
	world.prop_used.connect(_on_prop_used)
	world.notice.connect(_on_notice)
	world.hero_died.connect(_on_hero_died)
	world.boss_finished.connect(_on_boss_finished)
	world.level_gained.connect(_on_level_gained)
	world.boss_started.connect(_on_boss_started)
	ui.attach(state, world)
	ui.set_playing(true)
	world.start()
	mode = "playing"
	autosave_timer = 0.0
	AudioDirector.play_music("music.gameplay")
	_refresh_blessings()


func _on_notice(text: String, color: Color) -> void :
	ui.toast(text, color)


func _open_pause() -> void :
	world.set_paused(true)
	mode = "panel"
	ui.show_pause_panel()


func _resume() -> void :
	ui.close_modal()
	if world != null:
		world.set_paused(false)
	mode = "playing"


func _open_panel(kind: String) -> void :
	if world == null:
		return
	world.set_paused(true)
	mode = "panel"
	match kind:
		"inventory": ui.show_inventory_panel()
		"skills": ui.show_skills_panel()
		"map_region": ui.show_region_map()
		"map_world": ui.show_world_map()
		"forge": ui.show_forge_panel()
		"board": ui.show_board_panel()
		"chest": ui.show_chest_panel()
		"statue": ui.show_statue_panel()
		"blessings": ui.show_blessings_panel()
		"teleport": ui.show_teleport_panel()
		"master": ui.show_master_panel()
		_: ui.show_pause_panel()


func _close_panel() -> void :
	ui.close_modal()
	if world != null:
		world.set_paused(false)
	mode = "playing"
	_refresh_blessings()


func _to_title() -> void :
	if state != null and mode != "title":
		_save_game(false)
	if world != null:
		world.queue_free()
		world = null
	ui.close_modal()
	ui.close_overlay()
	ui.set_playing(false)
	ui.show_title(SaveGame.has_save())
	mode = "title"
	AudioDirector.play_music("music.title")


func _on_quit() -> void :
	get_tree().quit()


func _on_options_changed() -> void :
	if mode == "panel" and world != null:
		world.set_paused(true)


func _on_level_gained(new_level: int) -> void :
	ui.toast("Nível %d! Atributos aumentados." % new_level, UiKit.GOLD)
	if state != null and new_level == 20 and not bool(state.flags.get("class_quest_done", false)):
		ui.toast("Missão de classe: derrube o Colossal para receber sua terceira skill.", UiKit.PARCHMENT)


func _on_boss_started(enemy: Node) -> void :
	ui.toast("%s despertou!" % enemy.display_name(), Color(0.95, 0.7, 0.5))
	AudioDirector.play_cue("game.victory", 0.7)


func _on_hero_died() -> void :
	mode = "dead"
	world.set_paused(true)
	var in_dungeon: = world.region.zone_at(world.hero.global_position) == "santuario"
	var text: = "A estátua de Aurora o trouxe de volta. Você perdeu parte do XP e seu equipamento sofreu desgaste severo."
	if in_dungeon:
		text = "Você caiu no santuário. A fama diminuiu, monstros escaparam para a estrada e os preços subiram. Cace os errantes para restaurar a ordem."
	ui.show_death({"text": text})
	_save_game(false)


func _on_boss_finished(defeated: bool) -> void :
	if not defeated:
		return
	mode = "victory"
	world.set_paused(true)
	ui.show_victory({"text": "O Colossal de Granito foi derrotado. Sua fama alcançou %d pontos, a Guilda registrou o feito e a terceira skill da classe foi desbloqueada. O reino ainda tem mais oito Colossais — e algo antigo dorme no mar." % int(state.fame)})
	_save_game(false)


func _on_prop_used(prop: Dictionary) -> void :
	match str(prop["kind"]):
		"estatua": _open_panel("statue")
		"forja": _open_panel("forge")
		"mural": _open_panel("board")
		"bau": _open_panel("chest")
		"bencao": _open_panel("blessings")
		"teleporte": _open_panel("teleport")
		"mestre": _open_panel("master")
		"portao": _use_gate()
		_: pass


func _use_gate() -> void :
	if state.count_item("selo_entrada") > 0:
		state.remove_item("selo_entrada", 1)
		state.flags["gate_open"] = true
		world.enter_arena()
		if not bool(state.flags.get("colossal_defeated", false)):
			var boss_exists: = false
			for enemy in world.enemies_alive():
				if enemy.is_boss():
					boss_exists = true
			if not boss_exists:
				world.spawn_enemy("colossal", world.region.world_position(Vector2i(46, 32)))
		ui.toast("O selo encaixa no portão. O santuário se abre.", UiKit.GOLD)
		_save_game(false)
		return
	ui.toast("O portão exige um Selo de Entrada. Fabrique na forja (6 sucatas de ferro + 1 cristal).", Color(0.95, 0.8, 0.5))




func _on_panel_action(action: String, payload: Dictionary) -> void :
	match action:
		"close_panel":
			_close_panel()
		"resume":
			_resume()
		"save":
			_save_game(false)
			ui.toast("Jogo salvo na estátua de Aurora.", UiKit.GOOD)
		"to_title":
			_to_title()
		"open_inventory":
			_open_panel("inventory")
		"open_skills":
			_open_panel("skills")
		"equip":
			_equip_item(str(payload.get("id", "")))
		"unequip":
			state.unequip(str(payload.get("slot", "")))
			ui.show_inventory_panel()
		"use_item":
			_use_item(str(payload.get("id", "")))
		"drop_item":
			_drop_item(str(payload.get("id", "")))
		"store":
			_store_item(str(payload.get("id", "")))
		"retrieve":
			_retrieve_item(str(payload.get("id", "")))
		"craft":
			_craft(str(payload.get("id", "")))
		"repair":
			_repair()
		"accept_contract":
			_accept_contract(str(payload.get("id", "")))
		"claim_contract":
			_claim_contract(str(payload.get("id", "")))
		"upgrade_skill":
			_upgrade_skill(str(payload.get("id", "")))
		"assign_hotbar":
			_assign_hotbar(str(payload.get("id", "")))
		"bless":
			_bless(str(payload.get("kind", "")))
		"unlock_teleport":
			_unlock_teleport()
		"teleport_city":
			_teleport_city()
		"claim_class_skill":
			_claim_class_skill()
		"rest":
			_rest()
		"respawn":
			_respawn()
		"continue_after_boss":
			_continue_after_boss()
		_: pass


func _equip_item(item_id: String) -> void :
	var error: = state.equip(item_id)
	if error.is_empty():
		world.hero.sync_from_state()
		ui.toast("Equipado.", UiKit.GOOD)
	else:
		ui.toast(error, UiKit.BAD)
	ui.show_inventory_panel()


func _use_item(item_id: String) -> void :
	var item: = GameData.item(item_id)
	if str(item.get("type", "")) != "consumivel":
		ui.toast("Esse item não pode ser usado agora.", UiKit.BAD)
		return
	state.remove_item(item_id, 1)
	if item_id == "pocao_cura":
		world.hero.heal(60.0)
		ui.toast("Poção de cura: +60 HP", UiKit.GOOD)
	elif item_id == "pocao_mana":
		world.hero.mp = minf(state.max_mp(), world.hero.mp + 50.0)
		ui.toast("Poção de mana: +50 mana", UiKit.GOOD)
	elif item_id == "livro_skill":
		state.add_item(item_id, 1, true)
		ui.toast("Abra o menu de skills para usar o livro.", UiKit.PARCHMENT)
	else:
		ui.toast("Item consumido.", UiKit.PARCHMENT)
	ui.show_inventory_panel()


func _drop_item(item_id: String) -> void :
	state.remove_item(item_id, 1)
	ui.show_inventory_panel()


func _store_item(item_id: String) -> void :
	if not state.remove_item(item_id, 1):
		return
	for entry: Dictionary in state.stored:
		if str(entry["id"]) == item_id:
			entry["qty"] = int(entry["qty"]) + 1
			_refresh_storage_panel()
			return
	state.stored.append({"id": item_id, "qty": 1})
	_refresh_storage_panel()


func _refresh_storage_panel() -> void:
	if ui.current_panel == "inventory":
		ui.show_inventory_panel()
	else:
		ui.show_chest_panel()


func _retrieve_item(item_id: String) -> void :
	if state.carried_weight() + float(GameData.item(item_id).get("weight", 0.0)) > state.weight_capacity():
		ui.toast("Peso máximo atingido.", UiKit.BAD)
		return
	for index in range(state.stored.size() - 1, -1, -1):
		var entry: Dictionary = state.stored[index]
		if str(entry["id"]) != item_id:
			continue
		entry["qty"] = int(entry["qty"]) - 1
		if int(entry["qty"]) <= 0:
			state.stored.remove_at(index)
		state.add_item(item_id, 1, true)
		break
	ui.show_chest_panel()


func _craft(recipe_id: String) -> void :
	var recipe: Dictionary = {}
	for candidate: Dictionary in GameData.RECIPES:
		if str(candidate["id"]) == recipe_id:
			recipe = candidate
	if recipe.is_empty():
		return
	var cost: = state.price(int(recipe.get("cost", 0)))
	if state.coins < cost:
		ui.toast("Moedas insuficientes.", UiKit.BAD)
		return
	var materials: Dictionary = recipe["materials"]
	for item_id: String in materials.keys():
		if state.count_item(item_id) < int(materials[item_id]):
			ui.toast("Materiais insuficientes: %s" % GameData.item_short_name(item_id), UiKit.BAD)
			return
	state.coins -= cost
	for item_id: String in materials.keys():
		state.remove_item(item_id, int(materials[item_id]))
	var chance: = clampf(float(recipe.get("chance", 0.9)) + float(state.race()["craft_bonus"]), 0.05, 1.0)
	if rng.randf() <= chance:
		state.add_item(str(recipe["output"]), int(recipe.get("qty", 1)), true)
		ui.toast("Forjado: %s" % str(recipe["name"]), UiKit.GOOD)
		AudioDirector.play_cue("loot.item")
	else:
		ui.toast("A forja falhou e os materiais se perderam.", UiKit.BAD)
	ui.show_forge_panel()
	_save_game(false)


func _repair() -> void :
	var cost: = state.repair_cost()
	if cost <= 0:
		ui.toast("Nada para reparar.", UiKit.PARCHMENT)
		return
	if state.coins < cost:
		ui.toast("Moedas insuficientes para o reparo.", UiKit.BAD)
		return
	state.coins -= cost
	state.repair_all()
	world.hero.sync_from_state()
	ui.toast("Equipamento reparado.", UiKit.GOOD)
	ui.show_forge_panel()


func _accept_contract(contract_id: String) -> void :
	if not state.accepts_contract(contract_id):
		ui.toast("Contrato indisponível.", UiKit.BAD)
		return
	state.contracts.append({"id": contract_id, "progress": 0, "claimed": false, "done": false})
	ui.toast("Contrato aceito.", UiKit.GOOD)
	ui.show_board_panel()


func _claim_contract(contract_id: String) -> void :
	var definition: Dictionary = {}
	for candidate: Dictionary in GameData.CONTRACTS:
		if str(candidate["id"]) == contract_id:
			definition = candidate
	if definition.is_empty():
		return
	var entry: = state.contract_state(contract_id)
	if entry.is_empty() or not bool(entry.get("done", false)):
		ui.toast("Contrato ainda não concluído.", UiKit.BAD)
		return
	entry["claimed"] = true
	var fame_gain: = float(definition.get("fame", 1.0))
	if state.race_id == "humano":
		fame_gain *= 1.1
	var gained: = state.add_fame(fame_gain)
	state.coins += int(definition.get("coins", 0))
	var levels: Array = state.add_xp(int(definition.get("xp", 0)))
	ui.toast("Contrato entregue: +%.1f fama, +%s" % [gained, UiKit.money_text(int(definition.get("coins", 0)))], UiKit.GOLD)
	if state.fame >= state.fame_cap() - 0.01:
		ui.toast("Fama no limite da grade. Suba de grade para avançar.", UiKit.PARCHMENT)
	for _level in levels:
		world.hero.sync_from_state()
		world.hero.hp = state.max_hp()
	ui.show_board_panel()
	_save_game(false)


func _upgrade_skill(skill_id: String) -> void :
	if state.count_item("livro_skill") <= 0:
		ui.toast("Você não tem Livro de Skill.", UiKit.BAD)
		return
	if state.skill_level(skill_id) >= state.skill_cap():
		ui.toast("Teto da grade atingido para essa skill.", UiKit.BAD)
		return
	if not state.upgrade_skill(skill_id):
		ui.toast("Não foi possível aprimorar.", UiKit.BAD)
		return
	state.remove_item("livro_skill", 1)
	ui.toast("Skill aprimorada para nível %d." % state.skill_level(skill_id), UiKit.GOOD)
	ui.show_skills_panel()


func _assign_hotbar(skill_id: String) -> void :
	var slot: = state.first_free_hotbar_slot()
	if slot < 0:
		ui.toast("Hotbar cheia. Libere um espaço.", UiKit.BAD)
		return
	if state.hotbar.has(skill_id):
		ui.toast("Skill já está na hotbar.", UiKit.PARCHMENT)
		return
	state.hotbar[slot] = skill_id
	ui.toast("Skill adicionada ao espaço %d." % ((slot + 1) % 10), UiKit.GOOD)
	ui.show_skills_panel()


func _bless(kind: String) -> void :
	var costs: = {"vigor": 90, "furia": 160, "fortuna": 140}
	if not costs.has(kind):
		return
	var cost: = state.price(int(costs[kind]))
	if state.coins < cost:
		ui.toast("Moedas insuficientes.", UiKit.BAD)
		return
	state.coins -= cost
	match kind:
		"vigor":
			world.hero.hp = state.max_hp()
			world.hero.mp = state.max_mp()
			world.hero.energy = state.max_energy()
			state.hp = world.hero.hp
			ui.toast("Bênção do Vigor: corpo restaurado.", UiKit.GOOD)
		"furia":
			world.hero.buff_damage = 0.2
			world.hero.buff_time = 180.0
			state.flags["bencao_furia"] = state.play_seconds + 180.0
			ui.toast("Bênção da Fúria: +20% de dano por 3 minutos.", UiKit.GOLD)
		"fortuna":
			state.flags["bencao_fortuna"] = state.play_seconds + 180.0
			ui.toast("Bênção da Fortuna: +25% de moedas por 3 minutos.", UiKit.GOLD)
	AudioDirector.play_cue("ui.confirm")
	ui.show_blessings_panel()
	_save_game(false)


func _unlock_teleport() -> void :
	var cost: = state.price(400)
	if state.coins < cost:
		ui.toast("Moedas insuficientes.", UiKit.BAD)
		return
	state.coins -= cost
	state.flags["teleport_unlocked"] = true
	ui.toast("Círculo de teleporte liberado.", UiKit.GOOD)
	ui.show_teleport_panel()


func _teleport_city() -> void :
	if state.hostility > 50.0:
		ui.toast("Teleporte bloqueado pela hostilidade.", UiKit.BAD)
		return
	var cost: = state.price(30)
	if state.coins < cost:
		ui.toast("Moedas insuficientes.", UiKit.BAD)
		return
	state.coins -= cost
	world.hero.global_position = world.region.hero_spawn_position()
	world.camera.global_position = world.hero.global_position
	ui.toast("Você emergiu na estátua de Aurora.", UiKit.GOLD)
	_close_panel()


func _claim_class_skill() -> void :
	if state.level < 20:
		ui.toast("Requer nível 20.", UiKit.BAD)
		return
	if not bool(state.flags.get("class_quest_done", false)):
		ui.toast("Conclua a missão de classe: derrube o Colossal.", UiKit.BAD)
		return
	state._sync_evolution_skills()
	var actives: Array = state.class_data()["ativas"]
	var skill_id: = str(actives[2]["id"])
	state.skill_levels[skill_id] = maxi(1, state.skill_level(skill_id))
	ui.toast("Nova skill: %s" % str(actives[2]["name"]), UiKit.GOLD)
	ui.show_master_panel()


func _rest() -> void :
	world.hero.hp = state.max_hp()
	world.hero.mp = state.max_mp()
	world.hero.energy = state.max_energy()
	state.hp = world.hero.hp
	ui.toast("Descanso: recursos restaurados.", UiKit.GOOD)
	ui.show_statue_panel()


func _respawn() -> void :
	world.respawn_hero()
	ui.close_overlay()
	world.set_paused(false)
	mode = "playing"
	ui.toast("Você retorna à estátua de Aurora.", UiKit.PARCHMENT)
	_save_game(false)


func _continue_after_boss() -> void :
	ui.close_overlay()
	world.leave_arena()
	world.set_paused(false)
	mode = "playing"




func _save_game(silent: bool) -> void :
	if state == null:
		return
	if world != null and world.hero != null:
		state.hp = maxf(1.0, world.hero.hp)
	world_flags = {"errantes_alive": state.errantes_alive}
	var ok: = SaveGame.save_game(state, world_flags)
	if not silent:
		ui.toast("Jogo salvo." if ok else "Falha ao salvar.", UiKit.GOOD if ok else UiKit.BAD)


func _refresh_blessings() -> void :
	if state == null or world == null or world.hero == null:
		return
	var furia_until: = float(state.flags.get("bencao_furia", 0.0))
	if furia_until > state.play_seconds:
		world.hero.buff_damage = 0.2
		world.hero.buff_time = maxf(world.hero.buff_time, furia_until - state.play_seconds)
