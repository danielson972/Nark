extends SceneTree
const Scene = preload("res://scenes/ui/skills_panel.tscn")
var events: Array = []

func _initialize() -> void:
	call_deferred("_run")

func settle() -> void:
	for tick in 4:
		await process_frame

func _run() -> void:
	var host := Control.new()
	host.size = Vector2(1280, 720)
	root.add_child(host)
	var variants: int = 0
	for class_id: String in GameData.CLASS_ORDER:
		for level: int in [1, 100]:
			var player := PlayerState.create("Habilidades", "humano", class_id)
			player.level = level
			player.add_item("livro_skill", 2, true)
			var panel = Scene.instantiate()
			var authored_count: int = panel.find_children("*", "", true, false).size()
			panel.configure(player)
			host.add_child(panel)
			panel.action_requested.connect(func(action: String, payload: Dictionary) -> void: events.append([action, payload]))
			await settle()
			assert(panel.skill_grid.columns == 2)
			assert(panel.skill_grid.get_child_count() == 16)
			var authored_cards: Array[Node] = panel.skill_grid.get_children()
			for tab: String in ["ativas", "passivas", "ativas"]:
				panel._switch_tab(tab)
				await settle()
				assert(panel.skill_grid.get_children() == authored_cards, "Switching tabs must reuse the editable scene nodes")
				assert(panel.find_children("*", "", true, false).size() == authored_count)
				assert(panel.skill_buttons.size() == panel._definitions().size())
				for definition: Dictionary in panel._definitions():
					var id: String = definition.id
					var button: Button = panel.skill_buttons[id]
					assert(button.visible)
					button.pressed.emit()
					assert(panel.selected_id == id and panel.selected_name.text == definition.name)
					assert(panel.selected_cost.text == panel.Catalog.cost_text(definition))
					assert(button.get_node("Content/Text/Name").text == definition.name)
					assert(not button.get_node("Content/Icon/EditorArt").visible)
					if tab == "passivas":
						assert(panel.assign_button.disabled)
						var before: int = events.size()
						panel._perform("assign_hotbar")
						assert(events.size() == before)
			panel._select(str(player.class_data().ativas[0].id))
			assert(panel.assign_button.disabled, "Already assigned skills cannot be assigned twice")
			assert(panel.upgrade_button.disabled == (player.skill_cap() <= 1))
			if not panel.upgrade_button.disabled:
				panel.upgrade_button.pressed.emit()
				assert(events.back() == ["upgrade_skill", {"id": panel.selected_id}])
			for available: Vector2 in [Vector2(1280, 720), Vector2(800, 600), Vector2(640, 360)]:
				host.size = available
				await settle()
				assert(panel.position.x >= 0 and panel.position.y >= 0)
				assert(panel.position.x + panel.size.x * panel.scale.x <= available.x + 1)
				assert(panel.position.y + panel.size.y * panel.scale.y <= available.y + 1)
			panel.get_node("%CloseSkills").pressed.emit()
			assert(events.back()[0] == "close_panel")
			host.remove_child(panel)
			panel.queue_free()
			await process_frame
			variants += 1
	host.queue_free()
	await process_frame
	print("EDITABLE_SKILLS_OK: %d class/level variants, native cards, tabs, selection, costs, locking, actions and 3 window sizes" % variants)
	quit()
