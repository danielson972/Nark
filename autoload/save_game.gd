extends Node


const SAVE_PATH: = "user://rpg_reino_save.json"
const CONFIG_PATH: = "user://rpg_reino_config.json"
const SAVE_VERSION: = 1

signal settings_changed

var autosave: = true
var bindings: Dictionary = Controls.default_bindings()
var resolution_index: = 0
var fullscreen: = false
var show_damage: = true

const RESOLUTIONS: = [
	Vector2i(1280, 720), 
	Vector2i(1600, 900), 
	Vector2i(1920, 1080), 
	Vector2i(1024, 576), 
]


func _ready() -> void :
	load_settings()
	Controls.apply(bindings)


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(player: PlayerState, world_flags: Dictionary = {}) -> bool:
	var payload: = {
		"version": SAVE_VERSION, 
		"saved_at": Time.get_datetime_string_from_system(), 
		"player": player.to_dict(), 
		"world": world_flags, 
	}
	var file: = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível gravar o save")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true


func read_save() -> Dictionary:
	if not has_save():
		return {}
	var file: = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != SAVE_VERSION:
		return {}
	return data


func load_player() -> PlayerState:
	var data: = read_save()
	if data.is_empty():
		return null
	var state: = PlayerState.new()
	state.from_dict(data.get("player", {}) as Dictionary)
	return state


func delete_save() -> void :
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func load_settings() -> void :
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file: = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed
	autosave = bool(data.get("autosave", true))
	resolution_index = clampi(int(data.get("resolution_index", 0)), 0, RESOLUTIONS.size() - 1)
	fullscreen = bool(data.get("fullscreen", false))
	show_damage = bool(data.get("show_damage", true))
	bindings = Controls.merged_bindings(data.get("bindings", {}) as Dictionary)


func save_settings() -> void :
	var payload: = {
		"autosave": autosave, 
		"resolution_index": resolution_index, 
		"fullscreen": fullscreen, 
		"show_damage": show_damage, 
		"bindings": bindings, 
	}
	var file: = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	settings_changed.emit()


func apply_display() -> void :
	var size: Vector2i = RESOLUTIONS[clampi(resolution_index, 0, RESOLUTIONS.size() - 1)]
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if not fullscreen:
		DisplayServer.window_set_size(size)
