extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func stats(state: PlayerState) -> Array:
	return [state.max_hp(), state.max_mp(), state.max_energy(), state.damage_power(), state.defense_power(), state.crit_physical(), state.move_speed(), state.weight_capacity(), state.durability_ratio()]
func _run() -> void:
	var count: int = 0
	for race_id: String in GameData.RACES:
		for class_id: String in GameData.CLASS_ORDER:
			var state = PlayerState.create("Visual", race_id, class_id)
			var hero = load("res://scenes/hero.tscn").instantiate()
			hero.bind_state(state)
			hero.setup(null, "", 92.0)
			assert(state.count_item("hero") == 0)
			state.add_item("hero", 1, true)
			var before: Array = stats(state)
			assert(not hero.aura_effect.visible)
			assert(state.equip("hero").is_empty())
			assert(hero.aura_effect.visible and stats(state) == before)
			assert(hero.aura_effect.hframes == 6 and hero.aura_effect.vframes == 2)
			hero.aura_effect._process(0.11)
			assert(hero.aura_effect.frame == 1)
			hero.aura_effect._process(1.1)
			assert(hero.aura_effect.frame == 0)
			assert(hero.aura_effect.back_sprite.visible)
			assert(hero.aura_effect.back_sprite.get_parent() == hero.sprite)
			assert(hero.aura_effect.back_sprite.z_index < 0 and hero.aura_effect.z_index > 0)
			assert(hero.aura_effect.back_sprite.scale == hero.aura_effect.scale)
			hero.aura_effect.elapsed = 0.0
			for quarter in range(1, 5):
				hero.aura_effect._process(hero.aura_effect.orbit_seconds / 4.0)
				var phase: float = hero.aura_effect.material.get_shader_parameter("orbit_phase")
				var expected: float = fposmod(float(quarter) * PI / 2.0, TAU)
				assert(absf(phase - expected) < 0.001)
				assert(is_equal_approx(phase, hero.aura_effect.back_sprite.material.get_shader_parameter("orbit_phase")))
			var loaded := PlayerState.new()
			loaded.from_dict(state.to_dict())
			assert(loaded.equipment.aura.id == "hero")
			state.unequip("aura")
			assert(not hero.aura_effect.visible)
			assert(not hero.aura_effect.back_sprite.visible)
			hero.free()
			count += 1
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._on_new_game("humano", "guerreiro", "Hero")
	game.state.add_item("hero", 1, true)
	game.state.equip("hero")
	game.ui.show_inventory_panel()
	await process_frame
	assert(game.ui.inventory_view.get_node_or_null(".") != null)
	game.queue_free()
	await process_frame
	print("HERO_AURA_OK: %d race/class combinations, equip/unequip, animation loop, unchanged attributes, save and inventory" % count)
	quit()
