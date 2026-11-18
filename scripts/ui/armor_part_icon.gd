extends RefCounted
## Inventory cutouts use the exact masks of the editable Sprite2D layers.
static var textures: Dictionary = {}
static var images: Dictionary = {}

static func inside(point: Vector2, rect: Vector4) -> bool:
	return rect.z > 0.0 and Rect2(rect.x, rect.y, rect.z, rect.w).has_point(point)

static func texture_for(id: String) -> Texture2D:
	if textures.has(id): return textures[id]
	var item: Dictionary = GameData.item(id)
	var number: int = int(str(item.get("catalog_art", "")).trim_prefix("armadura_"))
	var scene: Node2D = load("res://scenes/armor_parts/catalogo/armadura_%03d.tscn" % number).instantiate()
	var sprite: Sprite2D = scene.get_node(str(item["armor_part"]))
	var texture: AtlasTexture = sprite.texture
	var path: String = texture.atlas.resource_path
	if not images.has(path): images[path] = texture.atlas.get_image()
	var image: Image = images[path].get_region(Rect2i(texture.region))
	image.convert(Image.FORMAT_RGBA8)
	var content: Rect2i = image.get_used_rect()
	if content.has_area(): image = image.get_region(content)
	var mat: ShaderMaterial = sprite.material
	var region: Vector4 = mat.get_shader_parameter("texture_region")
	var layer: int = -1 if item["armor_part"] == "Elmo" else int(mat.get_shader_parameter("armor_layer"))
	var glove_a: Vector4 = Vector4.ZERO if layer < 0 else mat.get_shader_parameter("armor_glove_a")
	var glove_b: Vector4 = Vector4.ZERO if layer < 0 else mat.get_shader_parameter("armor_glove_b")
	var waist: float = 0.60 if layer < 0 else float(mat.get_shader_parameter("armor_waist_y"))
	var boots: float = 0.82 if layer < 0 else float(mat.get_shader_parameter("armor_boots_y"))
	var cutoff: float = float(mat.get_shader_parameter("head_cutoff")) if mat.get_shader_parameter("head_cutoff") != null else 0.0
	var hand_mask: Image = null
	if mat.get_shader_parameter("use_armor_hand_mask") == true:
		var mask_texture: Texture2D = mat.get_shader_parameter("armor_hand_mask")
		var mask_path: String = mask_texture.resource_path
		if not images.has(mask_path): images[mask_path] = mask_texture.get_image()
		hand_mask = images[mask_path]
	var uv_origin: Vector2 = ((texture.region.position + Vector2(content.position)) / texture.atlas.get_size() - Vector2(region.x, region.y)) / Vector2(region.z, region.w)
	var uv_step: Vector2 = Vector2.ONE / texture.atlas.get_size() / Vector2(region.z, region.w)
	for y: int in image.get_height():
		for x: int in image.get_width():
			var color: Color = image.get_pixel(x, y)
			if color.a < 0.75:
				image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var uv: Vector2 = uv_origin + Vector2(x + 0.5, y + 0.5) * uv_step
			var hands: bool = inside(uv, glove_a) or inside(uv, glove_b)
			if hand_mask != null:
				var point: Vector2i = Vector2i(uv * Vector2(hand_mask.get_size())).clamp(Vector2i.ZERO, hand_mask.get_size() - Vector2i.ONE)
				hands = hand_mask.get_pixelv(point).r > 0.5
			var part: int = 1 if hands else (3 if uv.y >= boots else (2 if uv.y >= waist else 0))
			var hollow: bool = maxf(color.r, maxf(color.g, color.b)) < 0.12 or (uv.x > 0.20 and uv.x < 0.93 and uv.y > 0.35 and maxf(color.r, maxf(color.g, color.b)) < 0.28)
			if color.a < 0.75 or (layer >= 0 and layer != part) or (uv.y < cutoff and uv.x > 0.26 and uv.x < 0.74) or (str(item["armor_part"]) == "Elmo" and hollow):
				image.set_pixel(x, y, Color.TRANSPARENT)
	var bounds: Rect2i = image.get_used_rect()
	if bounds.has_area(): image = image.get_region(bounds)
	if item["armor_part"] in ["Luvas", "Botas"]:
		image = _compact_pair(image)
	textures[id] = ImageTexture.create_from_image(image)
	scene.free()
	return textures[id]

static func _compact_pair(image: Image) -> Image:
	# Keep both pieces at their original scale; only remove the empty space
	# between them, which belongs to the character pose rather than the icon.
	var start: int = -1
	var gap_start: int = 0
	var gap_width: int = 0
	for x: int in image.get_width():
		var occupied: bool = false
		for y: int in image.get_height():
			if image.get_pixel(x, y).a >= 0.75:
				occupied = true
				break
		if not occupied and start < 0: start = x
		if occupied and start >= 0:
			if start > 0 and x - start > gap_width:
				gap_start = start
				gap_width = x - start
			start = -1
	var spacing: int = maxi(3, roundi(image.get_height() * 0.06))
	if gap_width <= spacing: return image
	var packed: Image = Image.create(image.get_width() - gap_width + spacing, image.get_height(), false, Image.FORMAT_RGBA8)
	packed.blit_rect(image, Rect2i(0, 0, gap_start, image.get_height()), Vector2i.ZERO)
	var right: int = gap_start + gap_width
	packed.blit_rect(image, Rect2i(right, 0, image.get_width() - right, image.get_height()), Vector2i(gap_start + spacing, 0))
	return packed
