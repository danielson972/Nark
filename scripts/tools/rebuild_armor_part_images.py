"""Bake editable, aligned armor parts without modifying the original body art."""
from pathlib import Path
import re
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
SCENES = ROOT / "scenes/armor_parts"
OUTPUT = ROOT / "assets/game/sprites/herois/partes_armaduras"
NAMES = ("Peito", "Luvas", "Calca", "Botas")

def vector(text, key, default):
    match = re.search(r"shader_parameter/" + key + r" = Vector4\(([^)]+)\)", text)
    return tuple(map(float, match[1].split(","))) if match else default

def scalar(text, key, default):
    match = re.search(r"shader_parameter/" + key + r" = ([\d.]+)", text)
    return float(match[1]) if match else default

def set_parameter(text, key, value):
    line = f"shader_parameter/{key} = {value}"
    pattern = r"shader_parameter/" + key + r" = [^\n]+"
    return re.sub(pattern, line, text) if re.search(pattern, text) else text.rstrip() + "\n" + line + "\n\n"

count = 0
for path in sorted(SCENES.rglob("*.tscn")):
    text = path.read_text(encoding="utf-8")
    if "metadata/source_body" not in text:
        continue
    source_path = re.search(r'metadata/source_body = "res://([^"]+)"', text)[1]
    x, y, width, height = map(float, re.search(r'metadata/source_region = Rect2\(([^)]+)', text)[1].split(","))
    assert (width, height) == (256, 512), path
    source = Image.open(ROOT / source_path).convert("RGBA").crop((int(x), int(y), int(x + width), int(y + height)))
    node = text[text.index('[node name="Peito"'):].split("\n[node ", 1)[0]
    material_id = re.search(r'material = SubResource\("([^"]+)', node)[1]
    material = text[text.index(f'[sub_resource type="ShaderMaterial" id="{material_id}"'):].split("\n[", 1)[0]
    waist = scalar(material, "armor_waist_y", .60) * 512
    boots = scalar(material, "armor_boots_y", .82) * 512
    cutoff = .22 if "catalogo" in path.parts or "classes" in path.parts else 0
    head = vector(material, "armor_skin_head", (0, 0, 0, 0))
    head = (head[0] * 256, head[1] * 512, head[2] * 256, head[3] * 512)
    hand_mask_path = ROOT / f"assets/game/sprites/herois/mascaras_maos/{path.stem}.png"
    if "basicos" in path.parts:
        hand_mask_path = ROOT / f"assets/game/sprites/herois/mascaras_maos/basicos/{path.stem}.png"
    if ("catalogo" in path.parts or "basicos" in path.parts) and hand_mask_path.exists():
        hands = Image.open(hand_mask_path).convert("L")
    else:
        hands = Image.new("L", (256, 512))
        draw = ImageDraw.Draw(hands)
        for key in ("armor_glove_a", "armor_glove_b"):
            a, b, w, h = vector(material, key, (0, 0, 0, 0))
            draw.rectangle((round(a * 256), round(b * 512), round((a + w) * 256) - 1, round((b + h) * 512) - 1), fill=255)
    inner_hands = hands.filter(ImageFilter.MinFilter(3))
    images = [Image.new("RGBA", (256, 512)) for _ in NAMES]
    for py in range(512):
        for px in range(256):
            r, g, b, alpha = source.getpixel((px, py))
            if alpha / 255 <= .75:
                continue
            if head[2] and head[0] <= px + .5 < head[0] + head[2] and head[1] <= py + .5 < head[1] + head[3]:
                continue
            if (py + .5) / 512 < cutoff and .26 < (px + .5) / 256 < .74:
                continue
            edge = min(1, max(0, (alpha / 255 - .75) / .20))
            color = (r, g, b, round(255 * edge * edge * (3 - 2 * edge)))
            if hands.getpixel((px, py)) > 128:
                images[1].putpixel((px, py), color)
            if inner_hands.getpixel((px, py)) > 128:
                continue
            part = 3 if py + .5 >= boots else 2 if py + .5 >= waist else 0
            images[part].putpixel((px, py), color)
            if abs(py + .5 - waist) < 1:
                images[0].putpixel((px, py), color)
                images[2].putpixel((px, py), color)
            if abs(py + .5 - boots) < 1:
                images[2].putpixel((px, py), color)
                images[3].putpixel((px, py), color)
    folder = OUTPUT / path.relative_to(SCENES).with_suffix("")
    folder.mkdir(parents=True, exist_ok=True)
    for name, image in zip(NAMES, images):
        image_path = folder / (name.lower() + ".png")
        image.save(image_path)
        node = text[text.index(f'[node name="{name}"'):].split("\n[node ", 1)[0]
        texture_id = re.search(r'texture = SubResource\("([^"]+)', node)[1]
        material_id = re.search(r'material = SubResource\("([^"]+)', node)[1]
        old = tuple(map(float, re.search(r'(?m)^position = Vector2\(([^)]+)', node)[1].split(",")))
        origin = tuple(map(float, re.search(r'metadata/source_position = Vector2\(([^)]+)', node)[1].split(",")))
        replacement = re.sub(r'(?m)^position = Vector2\([^)]+\)', f'position = Vector2({old[0] - origin[0]}, {old[1] - origin[1]})', node)
        replacement = re.sub(r'metadata/source_position = Vector2\([^)]+\)', 'metadata/source_position = Vector2(0, 0)', replacement)
        text = text.replace(node, replacement)
        resource_id = "PartImage" + name
        resource_path = "res://" + image_path.relative_to(ROOT).as_posix()
        external = f'[ext_resource type="Texture2D" path="{resource_path}" id="{resource_id}"]\n\n'
        if f'id="{resource_id}"' not in text:
            text = text.replace("[sub_resource ", external + "[sub_resource ", 1)
        pattern = r'\[sub_resource type="AtlasTexture" id="' + re.escape(texture_id) + r'"\][^\[]+'
        text = re.sub(pattern, f'[sub_resource type="AtlasTexture" id="{texture_id}"]\natlas = ExtResource("{resource_id}")\nregion = Rect2(0, 0, 256, 512)\nfilter_clip = true\n\n', text)
        pattern = r'\[sub_resource type="ShaderMaterial" id="' + re.escape(material_id) + r'"\][^\[]+'
        def raster_material(match):
            result = match[0]
            for key, value in (("texture_region", "Vector4(0, 0, 1, 1)"), ("armor_layer", "-1"), ("head_cutoff", "0.0"), ("use_armor_hand_mask", "false"), ("raster_armor", "true")):
                result = set_parameter(result, key, value)
            return result
        text = re.sub(pattern, raster_material, text)
    path.write_text(text, encoding="utf-8")
    count += 1
print(f"Rebuilt {count * 4} aligned PNG parts in {count} scenes")
