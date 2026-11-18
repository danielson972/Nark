"""Check that the standalone parts preserve visible source pixels in every outfit."""
from pathlib import Path
import re
from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SCENES = ROOT / "scenes/armor_parts"
count = 0
for path in SCENES.rglob("*.tscn"):
    text = path.read_text(encoding="utf-8")
    if "metadata/source_body" not in text:
        continue
    source_path = re.search(r'metadata/source_body = "res://([^"]+)', text)[1]
    x, y, w, h = map(float, re.search(r'metadata/source_region = Rect2\(([^)]+)', text)[1].split(","))
    source = Image.open(ROOT / source_path).convert("RGBA").crop((int(x), int(y), int(x + w), int(y + h)))
    expected = source.getchannel("A").point(lambda value: 255 if value >= 200 else 0)
    draw = ImageDraw.Draw(expected)
    if "catalogo" in path.parts or "classes" in path.parts:
        draw.rectangle((67, 0, 188, 112), fill=0)
    else:
        head = re.search(r'armor_skin_head = Vector4\(([^)]+)', text)
        if head:
            a, b, width, height = map(float, head[1].split(","))
            draw.rectangle((round(a * 256), round(b * 512), round((a + width) * 256) - 1, round((b + height) * 512) - 1), fill=0)
    folder = ROOT / "assets/game/sprites/herois/partes_armaduras" / path.relative_to(SCENES).with_suffix("")
    covered = Image.new("L", (256, 512))
    for name in ("peito", "luvas", "calca", "botas"):
        part = Image.open(folder / (name + ".png")).convert("RGBA")
        assert part.size == (256, 512), (path, name)
        covered = ImageChops.lighter(covered, part.getchannel("A"))
    missing = ImageChops.subtract(expected, covered.point(lambda value: 255 if value else 0))
    assert missing.getbbox() is None, (path, "Missing source pixels", missing.getbbox())
    count += 1
hands = Image.open(ROOT / "assets/game/sprites/herois/partes_armaduras/catalogo/armadura_001/luvas.png").convert("RGBA")
assert hands.getpixel((61, 270))[3] > 0
assert hands.getpixel((84, 270))[3] == 0, "Glove contains tunic pixels"
print(f"PASS: 4 aligned PNGs and complete visible body coverage in {count} outfits; glove excludes tunic")
