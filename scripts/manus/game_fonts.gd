extends RefCounted



static func create_theme(regular: Font, medium: Font = null, bold: Font = null) -> Theme:
	assert (regular != null, "A project font is required")
	var theme: = Theme.new()
	theme.default_font = regular
	if medium != null:
		for control_type: String in ["Button", "CheckButton", "CheckBox", "OptionButton", "MenuButton"]:
			theme.set_font("font", control_type, medium)
	if bold != null:
		theme.set_font("normal_font", "RichTextLabel", regular)
		theme.set_font("bold_font", "RichTextLabel", bold)
	return theme

static func apply_world_label(label: Label3D, font: Font) -> void :
	assert (font != null, "A project font is required")

	label.font = font









class BindingProbe extends Node:
	var _nodes: Dictionary = {}
	var _pending: Dictionary = {}
	var _fonts: Dictionary = {}
	var _font_resources: Dictionary = {}
	var _checked: Dictionary = {}
	var _own_fonts: Dictionary = {}
	var _texts: Dictionary = {}
	var _missing: Dictionary = {}

	func _ready() -> void :
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().node_added.connect(_observe)
		_visit(get_tree().root)

	func _process(_delta: float) -> void :


		for identity: int in _nodes:
			var node: Node = _nodes[identity].get_ref() as Node
			if node == null:
				continue
			if _visible_text(node) != _texts.get(identity, ""):
				_schedule(node)
			var own: Font = _own_font(node)
			if own != _own_fonts.get(identity):
				_own_fonts[identity] = own
				_schedule(node)

	func _visit(node: Node) -> void :
		_observe(node)
		for child: Node in node.get_children():
			_visit(child)

	func _observe(node: Node) -> void :
		if not (node is Label or node is Button or node is LineEdit or node is TextEdit or node is RichTextLabel or node is ItemList or node is Tree or node is PopupMenu or node is Label3D):
			return
		var identity: int = node.get_instance_id()
		if not _nodes.has(identity):
			_nodes[identity] = weakref(node)
			if node is Control:
				node.theme_changed.connect(_schedule.bind(node))
			_own_fonts[identity] = _own_font(node)
		_schedule(node)

	func _visible_text(node: Node) -> String:
		if not node.is_inside_tree():
			return ""
		if node is CanvasItem and not node.is_visible_in_tree():
			return ""
		if node is Label3D:
			return node.text if node.is_visible_in_tree() else ""
		if node is Label or node is Button:
			return node.text
		if node is LineEdit or node is TextEdit:
			return node.text + node.placeholder_text
		if node is RichTextLabel:
			return node.get_parsed_text()
		var parts: PackedStringArray = []
		if node is ItemList or node is PopupMenu:
			if node is PopupMenu and not node.visible:
				return ""
			for index: int in range(node.item_count):
				parts.append(node.get_item_text(index))
		if node is Tree:
			var item: TreeItem = node.get_root()
			if item != null and node.hide_root:
				item = item.get_next_visible()
			while item != null:
				for column: int in range(node.columns):
					parts.append(item.get_text(column))
				item = item.get_next_visible()
		return "\n".join(parts)


	static func _draws_glyph(codepoint: int) -> bool:
		if codepoint <= 32 or (codepoint >= 127 and codepoint <= 160) or codepoint == 173:
			return false
		if codepoint == 847 or codepoint == 1564 or codepoint == 5760 or codepoint == 12288 or codepoint == 65279:
			return false
		if (codepoint >= 6155 and codepoint <= 6159) or (codepoint >= 8192 and codepoint <= 8207):
			return false
		if (codepoint >= 8232 and codepoint <= 8239) or (codepoint >= 8287 and codepoint <= 8303):
			return false
		return not ((codepoint >= 65024 and codepoint <= 65039) or (codepoint >= 917504 and codepoint <= 921599))


	static func _own_font(node: Node) -> Font:
		if node is Label3D:
			return node.font
		if node is Label and node.label_settings != null:
			return node.label_settings.font
		return null


	func _drawing_fonts(node: Node, binding: Font) -> Array[Font]:
		var fonts: Array[Font] = []
		if node is Label and _own_font(node) != null:
			fonts.append(_own_font(node))
		elif not node is RichTextLabel:
			fonts.append(binding)
		elif not (_built_outside_text(node as RichTextLabel) or node.text.contains("[font=") or node.text.contains("[font ")):
			fonts.append(binding)
			if node.bbcode_enabled:
				var bold: bool = node.text.contains("[b]")
				var italics: bool = node.text.contains("[i]")
				if bold:
					fonts.append(node.get_theme_font("bold_font"))
				if italics:
					fonts.append(node.get_theme_font("italics_font"))
				if bold and italics:
					fonts.append(node.get_theme_font("bold_italics_font"))
				if node.text.contains("[code]"):
					fonts.append(node.get_theme_font("mono_font"))
		return fonts



	static func _built_outside_text(node: RichTextLabel) -> bool:
		var parsed: = RichTextLabel.new()
		parsed.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		parsed.bbcode_enabled = node.bbcode_enabled
		parsed.custom_effects = node.custom_effects
		parsed.text = node.atr(node.text)
		var differs: bool = parsed.get_parsed_text() != node.get_parsed_text()
		parsed.free()
		return differs


	func _record_missing(node: Node, fonts: Array[Font], text: String) -> void :
		if fonts.all( func(font: Font) -> bool: return font == null):
			return
		for index: int in range(text.length()):
			var codepoint: int = text.unicode_at(index)
			if _missing.has(codepoint) or not _draws_glyph(codepoint):
				continue
			var drawn: bool = false
			for font: Font in fonts:
				if font != null and font.has_char(codepoint):
					drawn = true
					break
			if not drawn:
				_missing[codepoint] = str(node.get_path())

	func _schedule(node: Node) -> void :
		if not is_instance_valid(node):
			return
		var identity: int = node.get_instance_id()
		if _pending.has(identity):
			return
		_pending[identity] = true
		_check.call_deferred(identity)

	func _font_changed() -> void :
		_font_resources.clear()
		for reference: WeakRef in _nodes.values():
			var node: Node = reference.get_ref() as Node
			if node != null:
				_schedule(node)

	func _record_font(font: Font, seen: Dictionary) -> void :
		if font == null or seen.has(font):
			return
		seen[font] = true
		if not _fonts.has(font):
			_fonts[font] = true
			font.changed.connect(_font_changed)
		if font is FontVariation:
			_record_font(font.base_font, seen)
		else:
			_font_resources[font] = true
		for fallback: Font in font.fallbacks:
			_record_font(fallback, seen)

	func _check(identity: int) -> void :
		_pending.erase(identity)
		var node: Node = _nodes[identity].get_ref() as Node
		if node == null or not node.is_inside_tree():
			return
		var text: String = _visible_text(node)
		_texts[identity] = text
		if text.strip_edges().is_empty():
			return
		_checked[identity] = true
		var bindings: Dictionary = {}
		if node is Label3D:
			bindings["font"] = node.font
		elif node is RichTextLabel:
			bindings["normal_font"] = node.get_theme_font("normal_font")
		else:
			bindings["font"] = node.get_theme_font("font")
		for slot: String in bindings:
			_record_font(bindings[slot], {})
			_record_missing(node, _drawing_fonts(node, bindings[slot]), text)

	func _exit_tree() -> void :

		for identity: int in _nodes:
			_check(identity)
		var samples: Array[Dictionary] = []
		for codepoint: int in _missing:
			if samples.size() == 20:
				break
			samples.append({"codepoint": "U+%04X" % codepoint, "char": String.chr(codepoint), "node": _missing[codepoint]})
		print("[MANUS_FONT_BINDINGS]" + JSON.stringify({"scope": "boot-encountered-theme-and-Label3D-bindings", "nodes": _checked.size(), "fontResources": _font_resources.size(), "missingGlyphs": _missing.size(), "missingSamples": samples, "errors": 0}))
		for font: Font in _fonts:
			font.changed.disconnect(_font_changed)
		_fonts.clear()
		_font_resources.clear()
		_own_fonts.clear()
		_texts.clear()
		_missing.clear()










const GLYPH_PACK_URL: = "manus-glyph-pack/"
const GLYPH_PACK_FACES: PackedStringArray = ["NotoSansSC-Supplement.woff2", "NotoEmoji.woff2"]
static var _glyph_pack_fonts: Array[Font] = []
static var _glyph_pack_faces: Array[Font] = []
static var _glyph_pack_requested: = false
static var _glyph_pack_pending: = 0
static var _glyph_pack_waiting: Array[Callable] = []

static func load_glyph_pack(fonts: Array[Font], on_ready: = Callable()) -> void :
	for font: Font in fonts:
		assert (font != null, "A project font is required")
		if not _glyph_pack_fonts.has(font):
			_glyph_pack_fonts.append(font)
			_add_fallbacks(font, _glyph_pack_faces)
	if not _glyph_pack_requested and OS.has_feature("web"):
		_glyph_pack_requested = true
		_glyph_pack_pending = GLYPH_PACK_FACES.size()
		var base: String = JavaScriptBridge.eval("new URL('%s', document.baseURI).href" % GLYPH_PACK_URL)
		var root: Window = (Engine.get_main_loop() as SceneTree).root
		for face_name: String in GLYPH_PACK_FACES:
			var request: = HTTPRequest.new()
			request.request_completed.connect(_glyph_face_loaded.bind(request))
			request.ready.connect( func() -> void : request.request(base + face_name), CONNECT_ONE_SHOT)
			root.add_child.call_deferred(request)
	if not on_ready.is_valid():
		return
	if _glyph_pack_pending > 0:
		_glyph_pack_waiting.append(on_ready)
	else:
		on_ready.call_deferred()

static func _glyph_face_loaded(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, request: HTTPRequest) -> void :
	request.queue_free()
	_glyph_pack_pending -= 1
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var face: = FontFile.new()
		face.data = body
		_glyph_pack_faces.append(face)
		for font: Font in _glyph_pack_fonts:
			_add_fallbacks(font, [face])
	else:
		push_warning("Glyph pack face is unavailable (%d, HTTP %d)" % [result, code])
	if _glyph_pack_pending > 0:
		return
	var waiting: = _glyph_pack_waiting
	_glyph_pack_waiting = []
	for callback: Callable in waiting:
		if callback.is_valid():
			callback.call()


static func _add_fallbacks(font: Font, faces: Array[Font]) -> void :
	if faces.is_empty():
		return
	var chain: Array[Font] = font.fallbacks.duplicate()
	chain.append_array(faces)
	font.fallbacks = chain






static func clean_text(text: String, font: Font) -> String:
	assert (font != null, "A project font is required")
	var cleaned: = ""
	for index: int in range(text.length()):
		var codepoint: int = text.unicode_at(index)
		if font.has_char(codepoint) or not BindingProbe._draws_glyph(codepoint):
			cleaned += String.chr(codepoint)
		elif OS.has_feature("web"):
			var compatible: String = JavaScriptBridge.eval("String.fromCodePoint(%d).normalize('NFKC')" % codepoint)
			if compatible != String.chr(codepoint) and clean_text(compatible, font) == compatible:
				cleaned += compatible
	return cleaned
