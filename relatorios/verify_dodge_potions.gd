extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Poções")
	var hero = game.world.hero
	var state = game.state
	game.world.set_paused(true)
	assert(state.count_item("pocao_mana") == 2 and state.count_item("pocao_energia") == 2)
	state.add_item("pocao_energia", 3, true)
	assert(state.count_item("pocao_energia") == 5)
	assert(state.inventory.filter(func(entry): return entry.id == "pocao_energia").size() == 1)
	hero.energy = 55.0
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 37.0 and hero.dodge_cooldown_left == 1.0)
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 37.0)
	hero._tick_timers(0.3)
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 37.0)
	hero._tick_timers(0.71)
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 19.0)
	hero._tick_timers(1.01)
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 1.0)
	hero._tick_timers(1.01)
	hero._try_dodge(Vector2.RIGHT)
	assert(hero.energy == 1.0)
	hero._regen(1.0)
	assert(is_equal_approx(hero.energy, 3.5))
	assert(game.world.use_consumable("pocao_energia"))
	assert(is_equal_approx(hero.energy, 33.5) and state.count_item("pocao_energia") == 4)
	assert(game.world.use_consumable("pocao_energia"))
	assert(hero.energy == 55.0)
	assert(not game.world.use_consumable("pocao_energia"))
	assert(state.count_item("pocao_energia") == 3)
	hero.mp = 0.0
	assert(game.world.use_consumable("pocao_mana"))
	assert(hero.mp == state.max_mp() and state.count_item("pocao_mana") == 1)
	assert(not game.world.use_consumable("pocao_mana"))
	state.remove_item("pocao_mana", 1)
	hero.mp = 0.0
	assert(not game.world.use_consumable("pocao_mana") and hero.mp == 0.0)
	hero.hp = 10.0
	assert(game.world.use_consumable("pocao_cura") and hero.hp == 70.0)
	game.ui.refresh(state, game.world, hero, {})
	assert(game.ui.energy_usage_text.text.contains("pronta"))
	hero.dodge_cooldown_left = 0.8
	game.ui.refresh(state, game.world, hero, {})
	assert(game.ui.energy_usage_text.text.contains("recarga"))
	var cooldown_before: float = hero.dodge_cooldown_left
	hero._process(0.5)
	assert(hero.dodge_cooldown_left == cooldown_before)
	var loaded := PlayerState.new()
	loaded.from_dict(state.to_dict())
	assert(loaded.count_item("pocao_energia") == 3)
	game.queue_free()
	await process_frame
	print("DODGE_POTIONS_OK: cooldown, energy cost, slow regeneration, stacking, full/empty checks, life/mana/energy, UI and save roundtrip")
	quit()