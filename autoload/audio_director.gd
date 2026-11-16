extends Node

const BrowserBgmPlayer = preload("res://scripts/manus/browser_bgm_player.gd")
const ProceduralSfx = preload("res://scripts/manus/procedural_sfx.gd")

const MAX_SFX_VOICES: = 8
const MAX_UI_VOICES: = 2


const CUES: = {
	"music.title": {"path": "", "kind": "music"}, 
	"music.gameplay": {"path": "", "kind": "music"}, 
	"ui.confirm": {"path": "", "bus": "UI"}, 
	"ui.cancel": {"path": "", "bus": "UI"}, 
	"player.action": {"path": "", "bus": "SFX"}, 
	"enemy.impact": {"path": "", "bus": "SFX"}, 
	"score.reward": {"path": "", "bus": "SFX"}, 
	"game.pause": {"path": "", "bus": "UI"}, 
	"game.victory": {"path": "", "bus": "SFX"}, 
	"game.defeat": {"path": "", "bus": "SFX"}, 
	"combat.swing": {"path": "", "bus": "SFX"}, 
	"combat.hit": {"path": "", "bus": "SFX"}, 
	"combat.crit": {"path": "", "bus": "SFX"}, 
	"combat.block": {"path": "", "bus": "SFX"}, 
	"combat.dodge": {"path": "", "bus": "SFX"}, 
	"combat.cast": {"path": "", "bus": "SFX"}, 
	"combat.arcane": {"path": "", "bus": "SFX"}, 
	"loot.coin": {"path": "", "bus": "SFX"}, 
	"loot.item": {"path": "", "bus": "SFX"}, 
	"progress.level": {"path": "", "bus": "SFX"}, 
}

var _streams: Dictionary = {}
var _music_players: Array[BrowserBgmPlayer] = []
var _sfx_players: Array[AudioStreamPlayer] = []
var _ui_players: Array[AudioStreamPlayer] = []
var _music_index: = 0
var _music_cue: = ""
var _unlocked: = false
var _headless: = false
var _paused: = false
var _music_tween: Tween


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	_headless = DisplayServer.get_name() == "headless"
	_ensure_buses()
	for index: int in 2:
		var player: = BrowserBgmPlayer.new()
		player.name = "Music%d" % index
		player.bus = "Music"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.force_loop = true
		add_child(player)
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		player.finished.connect(_on_music_finished.bind(player))
		_music_players.append(player)
	for index: int in MAX_SFX_VOICES:
		_sfx_players.append(_make_player("Sfx%d" % index, "SFX"))
	for index: int in MAX_UI_VOICES:
		_ui_players.append(_make_player("Ui%d" % index, "UI"))
	_load_streams()
	_apply_bus_settings()


func _exit_tree() -> void :
	release_streams()


func release_streams() -> void :
	stop_music(0.0)
	for player: AudioStreamPlayer in _sfx_players + _ui_players:
		player.stop()
		player.stream = null
	for stream: AudioStream in _streams.values():
		BrowserBgmPlayer.release_cached_stream(stream)
	_streams.clear()


func register_cue(cue_id: String, resource_path: String) -> bool:
	if not CUES.has(cue_id):
		return false

	if resource_path.is_empty() or not ResourceLoader.exists(resource_path):
		unregister_cue(cue_id)
		return false
	var stream: = ResourceLoader.load(resource_path) as AudioStream
	return register_stream(cue_id, stream)


func register_stream(cue_id: String, stream: AudioStream) -> bool:
	if not CUES.has(cue_id):
		return false
	unregister_cue(cue_id)
	if stream == null:
		return false
	_streams[cue_id] = stream
	return true


func unregister_cue(cue_id: String) -> void :
	if cue_id == _music_cue:
		stop_music(0.0)
	var old_stream: AudioStream = _streams.get(cue_id)
	if old_stream != null:
		for players in [_music_players, _sfx_players, _ui_players]:
			for player in players:
				if player.stream == old_stream:
					player.stop()
					player.stream = null
		BrowserBgmPlayer.release_cached_stream(old_stream)
	_streams.erase(cue_id)


func unlock_audio() -> void :

	_unlocked = true


func play_music(cue_id: String, crossfade_seconds: float = 0.35) -> bool:
	var stream: AudioStream = _streams.get(cue_id)
	if stream == null or CUES.get(cue_id, {}).get("kind", "") != "music":
		stop_music(0.0)
		return false
	if not _unlocked and not _headless:
		return false
	var current: BrowserBgmPlayer = _music_players[_music_index]
	if current.stream == stream and (current.playing or _headless):
		_music_cue = cue_id
		return true
	_kill_music_tween()
	var old_player: = current
	_music_index = 1 - _music_index
	var next_player: BrowserBgmPlayer = _music_players[_music_index]
	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = -40.0 if old_player.playing else 0.0
	_music_cue = cue_id
	if _headless:
		old_player.stop()
		old_player.stream = null
		return true
	next_player.play()
	_music_tween = create_tween().set_parallel(true)
	_music_tween.tween_property(next_player, "volume_db", 0.0, maxf(0.0, crossfade_seconds))
	if old_player.playing:
		_music_tween.tween_property(old_player, "volume_db", -40.0, maxf(0.0, crossfade_seconds))
		_music_tween.chain().tween_callback( func() -> void :
			old_player.stop()
			old_player.stream = null
		)
	return true


func stop_music(fade_seconds: float = 0.25) -> void :
	_music_cue = ""
	_kill_music_tween()
	if fade_seconds <= 0.0 or _headless:
		for player: BrowserBgmPlayer in _music_players:
			player.stop()
			player.stream = null
		return
	_music_tween = create_tween().set_parallel(true)
	for player: BrowserBgmPlayer in _music_players:
		_music_tween.tween_property(player, "volume_db", -40.0, fade_seconds)
	_music_tween.chain().tween_callback( func() -> void :
		for player: BrowserBgmPlayer in _music_players:
			player.stop()
			player.stream = null
	)


func _kill_music_tween() -> void :
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null


func play_cue(cue_id: String, pitch_scale: float = 1.0) -> bool:
	var stream: AudioStream = _streams.get(cue_id)
	if stream == null or CUES.get(cue_id, {}).get("kind", "") == "music":
		return false
	if not _unlocked and not _headless:
		return false
	if _headless:
		return true
	var cue: Dictionary = CUES[cue_id]
	var players: = _ui_players if str(cue.get("bus", "SFX")) == "UI" else _sfx_players
	var player: = _claim_voice(players)
	player.stream = stream
	player.pitch_scale = clampf(pitch_scale, 0.75, 1.35)
	player.play()
	return true


func play_skill_sfx(skill_id: String, pitch_scale: float = 1.0) -> bool:
	var profile := _skill_sfx_profile(skill_id)
	if profile.is_empty():
		return false
	if not _unlocked and not _headless:
		return false
	if _headless:
		return true
	var stream := ProceduralSfx.tone(float(profile[0]), float(profile[1]), float(profile[2]), float(profile[3]))
	var player := _claim_voice(_sfx_players)
	player.stream = stream
	player.pitch_scale = clampf(pitch_scale, 0.75, 1.35)
	player.play()
	return true


func _skill_sfx_profile(skill_id: String) -> Array:
	var profiles := {
		"tiro_preciso": [740.0, 0.11, 0.22, 360.0], "disparo_leque": [560.0, 0.18, 0.24, 280.0],
		"flecha_contencao": [410.0, 0.2, 0.24, 170.0], "chuva_flechas": [520.0, 0.3, 0.2, 900.0],
		"projetil_arcano": [360.0, 0.22, 0.22, 920.0], "campo_gelido": [980.0, 0.34, 0.2, 390.0],
		"passo_arcano": [260.0, 0.19, 0.2, 1150.0], "cometa_arcano": [180.0, 0.42, 0.28, 760.0],
		"talho_circular": [300.0, 0.16, 0.2, 110.0], "quebra_guarda": [180.0, 0.22, 0.28, 85.0],
		"investida": [150.0, 0.25, 0.26, 420.0], "golpe_ruptura": [120.0, 0.4, 0.3, 55.0],
		"corte_duplo": [390.0, 0.16, 0.2, 150.0], "adaga_arremesso": [820.0, 0.12, 0.18, 490.0],
		"passo_sombrio": [220.0, 0.23, 0.22, 680.0], "execucao": [170.0, 0.3, 0.28, 65.0],
		"pancada_escudo": [145.0, 0.2, 0.28, 70.0], "abalo_sismico": [110.0, 0.34, 0.28, 42.0],
		"bastiao": [200.0, 0.25, 0.23, 280.0], "revanche_ferro": [130.0, 0.38, 0.28, 48.0],
		"estocada": [470.0, 0.14, 0.2, 170.0], "selo_desafio": [620.0, 0.25, 0.22, 1040.0],
		"carga_real": [160.0, 0.28, 0.27, 390.0], "estandarte_real": [420.0, 0.36, 0.2, 850.0],
		"explosao_aura": [220.0, 0.38, 0.28, 680.0], "despertar_heroico": [330.0, 0.45, 0.22, 990.0]
	}
	return profiles.get(skill_id, [])


func register_button(button: Button, cancel_cue: bool = false) -> void :
	if button == null or button.has_meta("audio_registered"):
		return
	button.set_meta("audio_registered", true)
	button.pressed.connect( func() -> void :
		unlock_audio()
		play_cue("ui.cancel" if cancel_cue else "ui.confirm")
	)


func set_game_paused(paused: bool) -> void :
	if _paused == paused:
		return
	_paused = paused
	_apply_bus_settings()
	if paused:
		play_cue("game.pause")


func get_cue_ids() -> Array:
	return CUES.keys()


func get_voice_capacity() -> Dictionary:
	return {"music": _music_players.size(), "sfx": _sfx_players.size(), "ui": _ui_players.size()}


func _make_player(player_name: String, bus_name: String) -> AudioStreamPlayer:
	var player: = AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus_name
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player


func _claim_voice(players: Array) -> AudioStreamPlayer:
	for value: Variant in players:
		var player: AudioStreamPlayer = value
		if not player.playing:
			return player
	var recycled: AudioStreamPlayer = players[0]
	recycled.stop()
	return recycled


func _load_streams() -> void :
	for cue_id: String in CUES:
		register_cue(cue_id, str(CUES[cue_id].path))


func _ensure_buses() -> void :
	for bus_name: String in ["Music", "SFX", "UI"]:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func _apply_bus_settings() -> void :
	for bus_name: String in ["Master", "Music", "SFX", "UI"]:
		var index: = AudioServer.get_bus_index(bus_name)
		if index >= 0:
			var duck: = 8.0 if bus_name == "Music" and _paused else 0.0
			AudioServer.set_bus_volume_db(index, - duck)


func _on_music_finished(player: BrowserBgmPlayer) -> void :
	if player == _music_players[_music_index] and not _music_cue.is_empty() and player.stream != null:
		player.play()
