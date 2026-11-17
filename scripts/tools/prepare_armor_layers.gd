extends SceneTree
## Builds editable Sprite2D parts while referencing the original, unchanged pixels.
const Appearance = preload("res://scripts/actors/hero_appearance.gd")
const Custom = preload("res://scripts/actors/character_customization.gd")
const Assembly = preload("res://scripts/actors/armor_parts.gd")
const ROOT = "res://scenes/armor_parts/"
const PART_NAMES = ["Peito", "Luvas", "Calca", "Botas"]
var sheet_cache: Dictionary = {}
var manifest: Dictionary = {}

func _initialize() -> void: call_deferred("_run")
func rect_vector(rect: Rect2) -> Vector4:
	return Vector4(rect.position.x,rect.position.y,rect.size.x,rect.size.y)
func texture_region(texture: AtlasTexture) -> Vector4:
	var dimensions := texture.atlas.get_size()
	return Vector4(texture.region.position.x/dimensions.x,texture.region.position.y/dimensions.y,texture.region.size.x/dimensions.x,texture.region.size.y/dimensions.y)
func skin(color: Color) -> bool:
	return color.a > 0.85 and color.r > 0.65 and color.b > 0.32 and color.r > color.g*1.13 and color.r < color.g*1.6 and color.b > color.g*0.64
func hand_box(image: Image, center: Vector2, far: bool = false) -> Rect2:
	var half := Vector2i(38 if far else 25,32)
	var area := Rect2i(Vector2i(center)-half,half*2).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
	var visited: Dictionary = {}
	var best := Rect2i()
	var best_score: float = INF
	for y in range(area.position.y,area.end.y):
		for x in range(area.position.x,area.end.x):
			var point := Vector2i(x,y)
			if visited.has(point) or not skin(image.get_pixelv(point)): continue
			var pending: Array[Vector2i] = [point]
			visited[point] = true
			var lo: Vector2i = point
			var hi: Vector2i = point
			var count: int = 0
			while not pending.is_empty():
				var current: Vector2i = pending.pop_back()
				count += 1
				lo = Vector2i(mini(lo.x,current.x),mini(lo.y,current.y))
				hi = Vector2i(maxi(hi.x,current.x),maxi(hi.y,current.y))
				for delta: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var next: Vector2i = current+delta
					if area.has_point(next) and not visited.has(next) and skin(image.get_pixelv(next)):
						visited[next] = true
						pending.append(next)
			if count < 12: continue
			var candidate := Rect2i(lo,hi-lo+Vector2i.ONE)
			var score: float = Vector2(candidate.get_center()).distance_to(center)
			if score < best_score:
				best_score = score
				best = candidate
	if best.size != Vector2i.ZERO:
		return Rect2(best.grow(2).intersection(Rect2i(Vector2i.ZERO,image.get_size())))
	return Rect2(center-Vector2(15,20),Vector2(30,42)).intersection(Rect2(Vector2.ZERO,image.get_size()))
func part_at(point: Vector2, gloves: Array[Rect2], head: Rect2, waist: float, boots: float) -> int:
	if head.has_point(point): return -1
	if gloves[0].has_point(point) or gloves[1].has_point(point): return 1
	if point.y >= boots: return 3
	if point.y >= waist: return 2
	return 0
func helmet_texture(number: int) -> AtlasTexture:
	var first: int = int((number-1)/10)*10+1
	var path := "res://assets/game/sprites/Armaduras_RPG/pranchas/%03d-%03d.png" % [first,first+9]
	if not sheet_cache.has(path): sheet_cache[path] = load(path)
	var texture: Texture2D = sheet_cache[path]
	var image: Image = texture.get_image()
	var index: int = number-first
	# The second row's helmets begin above the sheet's geometric halfway point.
	var start := Vector2i(floori((index%5)*image.get_width()/5.0),0 if index < 5 else 470)
	var end := Vector2i(floori((index%5+1)*image.get_width()/5.0),start.y+180)
	var area := Rect2i(start,end-start)
	var visited: Dictionary = {}
	var lo := end
	var hi := start
	var largest: int = 0
	for y in range(start.y,end.y):
		for x in range(start.x,end.x):
			var point := Vector2i(x,y)
			if visited.has(point) or image.get_pixelv(point).a <= 0.80: continue
			var pending: Array[Vector2i] = [point]
			visited[point] = true
			var minimum := point
			var maximum := point
			var count: int = 0
			while not pending.is_empty():
				var current: Vector2i = pending.pop_back()
				count += 1
				minimum = Vector2i(mini(minimum.x,current.x),mini(minimum.y,current.y))
				maximum = Vector2i(maxi(maximum.x,current.x),maxi(maximum.y,current.y))
				for dy in range(-1,2):
					for dx in range(-1,2):
						var next := current+Vector2i(dx,dy)
						if area.has_point(next) and not visited.has(next) and image.get_pixelv(next).a > 0.80:
							visited[next] = true
							pending.append(next)
			# Ignore text and thin label borders remaining above the second row.
			if maximum.y-minimum.y < 30 or maximum.x-minimum.x < 30: continue
			if minimum.y < start.y+75 and (largest == 0 or minimum.y < lo.y or (minimum.y == lo.y and count > largest)):
				largest = count
				lo = minimum
				hi = maximum
	if largest < 100 or hi.x <= lo.x or hi.y <= lo.y: return null
	# Connected fur collars can join the headgear to the shoulders. End at the
	# narrowest neck row instead of bringing the chest into the helmet sprite.
	if hi.y-lo.y > 110:
		var narrowest: int = 100000
		var neck_y: int = lo.y+100
		for y in range(lo.y+78,mini(lo.y+120,end.y-1)):
			var ink: int = 0
			for x in range(lo.x,hi.x+1):
				for dy in range(-1,2):
					if image.get_pixel(x,y+dy).a > 0.80: ink += 1
			if ink < narrowest:
				narrowest = ink
				neck_y = y
		hi.y = neck_y-1
	var helmet := AtlasTexture.new()
	helmet.atlas = texture
	helmet.region = Rect2(Vector2(lo),Vector2(hi-lo+Vector2i.ONE))
	helmet.filter_clip = true
	return helmet
func sprite(root: Node2D, name: String, texture: AtlasTexture, position: Vector2, material: ShaderMaterial) -> Sprite2D:
	var node := Sprite2D.new()
	node.name = name
	node.centered = false
	node.texture = texture
	node.position = position
	node.material = material
	if material != null: material.resource_local_to_scene = true
	node.set_meta("source_position",position)
	root.add_child(node)
	node.owner = root
	return node
func material_for(body: AtlasTexture) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = Appearance.CUTOUT_SHADER
	material.set_shader_parameter("texture_region",texture_region(body))
	return material
func build(state: PlayerState, path: String) -> void:
	var body: AtlasTexture = Appearance.body_texture(state)
	var image: Image = body.get_image()
	var dimensions: Vector2 = image.get_size()
	assert(dimensions == Vector2(256,512))
	var gloves: Array[Rect2] = []
	var near: Vector2 = Appearance.hand_position(state)*dimensions
	gloves.append(hand_box(image,near))
	gloves.append(hand_box(image,Vector2(dimensions.x-near.x,near.y),true))
	var armored: bool = Custom.armored(state)
	var head: Rect2 = Rect2() if armored else Custom.head_rect(state)
	var waist: float = 306.0 if armored else 300.0
	if not armored and state.race_id == "anao" and state.gender_id == "masculino": waist = 378.0
	var boots: float = 420.0
	if state.class_id == "mago" and armored: waist = 320.0
	var id: String = str(state.equipment.armadura.id)
	if id.begins_with("armadura_catalogo_"):
		var number: int = int(str(GameData.item(id).get("catalog_art", "")).trim_prefix("armadura_"))
		if number <= 10: waist = 312.0
	var lows: Array[Vector2i] = []
	var highs: Array[Vector2i] = []
	for index in 4:
		lows.append(image.get_size())
		highs.append(Vector2i.ZERO)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a <= 0.04: continue
			if armored and y+0.5 < 512*0.22 and x+0.5 > 256*0.26 and x+0.5 < 256*0.74: continue
			var part: int = part_at(Vector2(x+0.5,y+0.5),gloves,head,waist,boots)
			if part < 0: continue
			lows[part] = Vector2i(mini(lows[part].x,x),mini(lows[part].y,y))
			highs[part] = Vector2i(maxi(highs[part].x,x),maxi(highs[part].y,y))
	var root := Node2D.new()
	root.name = "ArmaduraEmPartes"
	root.set_script(Assembly)
	root.armor_id = id
	root.reference_head = Custom.head_destination(state)
	root.set_meta("source_body",body.atlas.resource_path)
	root.set_meta("source_region",body.region)
	if head.size != Vector2.ZERO:
		var patch := AtlasTexture.new()
		patch.atlas = body.atlas
		patch.region = Rect2(body.region.position+head.position,head.size)
		patch.filter_clip = true
		sprite(root,"Pele",patch,head.position,material_for(body))
	else:
		var reference := sprite(root,"Pele",null,Vector2.ZERO,null)
		reference.visible = false
	if armored:
		var reference_head := Rect2(60,0,136,113)
		var reference_texture := AtlasTexture.new()
		reference_texture.atlas = body.atlas
		reference_texture.region = Rect2(body.region.position+reference_head.position,reference_head.size)
		reference_texture.filter_clip = true
		var reference := sprite(root,"ReferenciaCabeca",reference_texture,reference_head.position,material_for(body))
		reference.set_meta("editor_only",true)
	for index in 4:
		assert(highs[index].x > lows[index].x and highs[index].y > lows[index].y, path+" "+PART_NAMES[index])
		var bounds := Rect2i(lows[index],highs[index]-lows[index]+Vector2i.ONE).grow(6).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
		var texture := AtlasTexture.new()
		texture.atlas = body.atlas
		texture.region = Rect2(body.region.position+Vector2(bounds.position),Vector2(bounds.size))
		texture.filter_clip = true
		var material := material_for(body)
		material.set_shader_parameter("armor_layer",index)
		material.set_shader_parameter("armor_glove_a",rect_vector(Rect2(gloves[0].position/dimensions,gloves[0].size/dimensions)))
		material.set_shader_parameter("armor_glove_b",rect_vector(Rect2(gloves[1].position/dimensions,gloves[1].size/dimensions)))
		material.set_shader_parameter("armor_skin_head",rect_vector(Rect2(head.position/dimensions,head.size/dimensions)))
		material.set_shader_parameter("armor_waist_y",waist/512.0)
		material.set_shader_parameter("armor_boots_y",boots/512.0)
		material.set_shader_parameter("head_cutoff",0.22 if armored else 0.0)
		var node := sprite(root,PART_NAMES[index],texture,Vector2(bounds.position),material)
		if index == 0: node.set_meta("includes","Torso, ombreiras e avambraços")
		if index == 1: node.set_meta("includes","Mãos/luvas; preserva as mãos nos conjuntos sem luvas desenhadas")
	var helmet: AtlasTexture
	if id.begins_with("armadura_catalogo_"):
		helmet = helmet_texture(int(str(GameData.item(id).get("catalog_art", "")).trim_prefix("armadura_")))
	var helmet_material: ShaderMaterial = material_for(helmet) if helmet != null else null
	if helmet_material != null: helmet_material.set_shader_parameter("helmet_hollow",true)
	var helm := sprite(root,"Elmo",helmet,Vector2.ZERO,helmet_material)
	helm.visible = false
	helm.z_index = 4
	if helmet != null:
		var destination: Rect2 = Custom.head_destination(state)
		var factor: float = minf(destination.size.x*1.35/helmet.get_width(),destination.size.y*1.12/helmet.get_height())
		helm.scale = Vector2.ONE*factor
		helm.position = Vector2(destination.get_center().x-helmet.get_width()*factor*0.5,destination.position.y-4)
		helm.set_meta("source_position",helm.position)
	var scene := PackedScene.new()
	assert(scene.pack(root) == OK)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	assert(ResourceSaver.save(scene,path) == OK)
	manifest[path.trim_prefix(ROOT)] = {"item":id,"source":body.atlas.resource_path,"hands":[rect_vector(gloves[0]),rect_vector(gloves[1])],"waist_y":waist,"boots_y":boots,"has_helmet":helmet!=null}
	root.free()
func _run() -> void:
	for number in range(1,101):
		var state := PlayerState.create("Camadas","humano","guerreiro")
		var id := "armadura_catalogo_%03d" % number
		state.add_item(id,1,true)
		state.equip(id)
		build(state,ROOT+"catalogo/armadura_%03d.tscn" % number)
	for job: String in GameData.CLASS_ORDER:
		for id: String in ["armadura_ng","armadura_d","armadura_c","armadura_b"]:
			var state := PlayerState.create("Camadas","humano",job)
			state.add_item(id,1,true)
			state.equip(id)
			build(state,ROOT+"classes/%s/%s.tscn" % [job,id])
	for race: String in GameData.RACE_ORDER:
		for gender: String in ["masculino","feminino"]:
			var state := PlayerState.create("Camadas",race,"guerreiro")
			state.gender_id = gender
			build(state,ROOT+"basicos/%s_%s.tscn" % [race,gender])
	var file := FileAccess.open(ROOT+"manifest.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	file.close()
	print("ARMOR_LAYERS_AUTHORED: %d native scenes, five armor parts and original source pixels" % manifest.size())
	quit()
