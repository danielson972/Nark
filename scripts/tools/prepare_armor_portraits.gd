extends SceneTree
## Authors per-item AtlasTextures without changing the generated RGBA pixels.
const FOLDER = "res://assets/game/ui/items/armor_portraits/"
const LEGACY_IDS = ["roupa_basica", "armadura_ng", "armadura_d", "armadura_c", "armadura_b"]
const PAIRS = [["atirador", "mago"], ["guerreiro", "assassino"], ["tank", "cavaleiro"]]
var layout: Dictionary = {}
func _initialize() -> void: call_deferred("_run")
func create_sheet(name: String, ids: Array[String]) -> void:
	var texture: Texture2D = load(FOLDER + name + ".png")
	var image: Image = texture.get_image()
	assert(image.detect_alpha() != Image.ALPHA_NONE)
	for index in ids.size():
		var start := Vector2i(floori((index % 5) * image.get_width() / 5.0), floori((index / 5) * image.get_height() / 2.0))
		var end := Vector2i(floori((index % 5 + 1) * image.get_width() / 5.0), floori((index / 5 + 1) * image.get_height() / 2.0))
		var minimum: Vector2i = end
		var maximum: Vector2i = start
		var transparent: int = 0
		for y in range(start.y, end.y):
			for x in range(start.x, end.x):
				var alpha: float = image.get_pixel(x,y).a
				if alpha <= 0.01: transparent += 1
				if alpha > 0.04:
					minimum = Vector2i(mini(minimum.x,x),mini(minimum.y,y))
					maximum = Vector2i(maxi(maximum.x,x),maxi(maximum.y,y))
		assert(maximum.x > minimum.x and maximum.y > minimum.y, ids[index] + " is empty")
		assert(transparent > (end.x-start.x)*(end.y-start.y)*0.15, ids[index] + " needs alpha background")
		minimum = Vector2i(maxi(start.x,minimum.x-2),maxi(start.y,minimum.y-2))
		maximum = Vector2i(mini(end.x-1,maximum.x+2),mini(end.y-1,maximum.y+2))
		var icon := AtlasTexture.new()
		icon.atlas = texture
		icon.region = Rect2(Vector2(minimum),Vector2(maximum-minimum+Vector2i.ONE))
		icon.filter_clip = true
		var path: String = FOLDER + "icons/" + ids[index] + ".tres"
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		assert(ResourceSaver.save(icon,path) == OK)
		layout[ids[index]] = {"atlas": name+".png", "region": [minimum.x,minimum.y,maximum.x-minimum.x+1,maximum.y-minimum.y+1], "resource": "icons/"+ids[index]+".tres"}
func _run() -> void:
	for group in 10:
		var ids: Array[String] = []
		for offset in 10: ids.append("armadura_catalogo_%03d" % (group*10+offset+1))
		create_sheet("%03d-%03d" % [group*10+1,group*10+10],ids)
	for pair: Array in PAIRS:
		var ids: Array[String] = []
		for job: String in pair:
			for id: String in LEGACY_IDS: ids.append(job+"/"+id)
		create_sheet("classes-%s-%s" % [pair[0],pair[1]],ids)
	var file := FileAccess.open(FOLDER + "icon_manifest.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(layout,"\t"))
	file.close()
	print("ARMOR_PORTRAITS_AUTHORED: %d transparent torso icons" % layout.size())
	quit()
