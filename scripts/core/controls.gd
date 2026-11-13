class_name Controls
extends RefCounted



const ACTIONS: = [
	"move_up", "move_down", "move_left", "move_right", 
	"attack", "block", "dodge", "dash", "sprint", "interact", 
	"inventory", "skill_menu", "map_region", "map_world", "pause", 
	"hotbar_1", "hotbar_2", "hotbar_3", "hotbar_4", "hotbar_5", 
	"hotbar_6", "hotbar_7", "hotbar_8", "hotbar_9", "hotbar_10", 
]

const REBINDABLE: = [
	"move_up", "move_down", "move_left", "move_right", 
	"attack", "block", "dodge", "dash", "sprint", "interact", 
	"inventory", "skill_menu", "map_region", "map_world", "pause", "potion", 
]

const LABELS: = {
	"move_up": "Mover para cima", 
	"move_down": "Mover para baixo", 
	"move_left": "Mover para a esquerda", 
	"move_right": "Mover para a direita", 
	"attack": "Ataque básico", 
	"block": "Bloquear", 
	"dodge": "Esquiva", 
	"dash": "Dash", 
	"sprint": "Correr", 
	"interact": "Interagir", 
	"inventory": "Inventário", 
	"skill_menu": "Skills", 
	"map_region": "Mapa da região", 
	"map_world": "Mapa do reino", 
	"pause": "Pausa", 
"potion": "Poção de cura", 
}

const DEFAULT_BINDINGS: = {
	"move_up": ["key:87", "key:4194320"], 
	"move_down": ["key:83", "key:4194322"], 
	"move_left": ["key:65", "key:4194319"], 
	"move_right": ["key:68", "key:4194321"], 
	"attack": ["mouse:1", "key:74"], 
	"block": ["mouse:2", "key:66"], 
	"dodge": ["key:32"], 
	"dash": ["key:81"], 
	"sprint": ["key:4194325"], 
	"interact": ["key:69"], 
	"inventory": ["key:73"], 
	"skill_menu": ["key:75"], 
	"map_region": ["key:77"], 
	"map_world": ["key:4194334"], 
	"pause": ["key:4194305"], 
"potion": ["key:82"], 
	"hotbar_1": ["key:49"], "hotbar_2": ["key:50"], "hotbar_3": ["key:51"], 
	"hotbar_4": ["key:52"], "hotbar_5": ["key:53"], "hotbar_6": ["key:54"], 
	"hotbar_7": ["key:55"], "hotbar_8": ["key:56"], "hotbar_9": ["key:57"], 
	"hotbar_10": ["key:48"], 
}


static func default_bindings() -> Dictionary:
	return DEFAULT_BINDINGS.duplicate(true)


static func merged_bindings(saved: Dictionary) -> Dictionary:
	var result: = default_bindings()
	for action: String in saved.keys():
		if result.has(action):
			result[action] = (saved[action] as Array).duplicate()
	return result


static func apply(bindings: Dictionary) -> void :
	for action: String in ACTIONS:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action, 0.3)
		var list: Array = bindings.get(action, DEFAULT_BINDINGS.get(action, []))
		for entry: Variant in list:
			var event: = _to_event(str(entry))
			if event != null:
				InputMap.action_add_event(action, event)


static func _to_event(entry: String) -> InputEvent:
	if entry.begins_with("key:"):
		var event: = InputEventKey.new()
		event.physical_keycode = int(entry.substr(4)) as Key
		return event
	if entry.begins_with("mouse:"):
		var event: = InputEventMouseButton.new()
		event.button_index = int(entry.substr(6)) as MouseButton
		return event
	return null


static func event_to_binding(event: InputEvent) -> String:
	if event is InputEventKey and event.pressed and not event.echo:
		return "key:%d" % int(event.physical_keycode)
	if event is InputEventMouseButton and event.pressed:
		return "mouse:%d" % int(event.button_index)
	return ""


static func describe(action: String, bindings: Dictionary) -> String:
	var list: Array = bindings.get(action, [])
	var parts: Array = []
	for entry: Variant in list:
		parts.append(describe_binding(str(entry)))
	return " ou ".join(parts)


static func describe_binding(entry: String) -> String:
	if entry.begins_with("mouse:"):
		match int(entry.substr(6)):
			1: return "Botão esq."
			2: return "Botão dir."
			3: return "Botão central"
			_: return "Botão %s" % entry.substr(6)
	if entry.begins_with("key:"):
		var code: = int(entry.substr(4))
		match code:
			32: return "Espaço"
			4194305: return "Esc"
			4194320: return "Seta ↑"
			4194321: return "Seta →"
			4194322: return "Seta ↓"
			4194319: return "Seta ←"
			4194325: return "Shift"
			4194326: return "Ctrl"
			4194334: return "Menos (−)"
			4194332: return "Mais (+)"
		var text: = OS.get_keycode_string(code as Key)
		return text if not text.is_empty() else "Tecla %d" % code
	return "—"
