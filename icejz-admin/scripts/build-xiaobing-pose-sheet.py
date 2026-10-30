"""Build Petdex sheet from real pose keyframes (not whole-body fake tilts)."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageOps

ASSETS = Path(r"C:\Users\彭家程\.cursor\projects\d-framework-icejz\assets")
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "public" / "mascot" / "xiaobing-pet"
REF = ROOT / "public" / "mascot" / "xiaobing-main.png"

CELL_W, CELL_H = 192, 208
COLS, ROWS = 8, 9
ATLAS_W, ATLAS_H = COLS * CELL_W, ROWS * CELL_H

ROW_SPECS = [
	("idle", 6),
	("running-right", 8),
	("running-left", 8),
	("waving", 4),
	("jumping", 5),
	("failed", 8),
	("waiting", 6),
	("running", 6),
	("review", 6),
]


def knockout_white(im: Image.Image, thr: int = 248) -> Image.Image:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if r >= thr and g >= thr and b >= thr:
				px[x, y] = (0, 0, 0, 0)
	return im


def fit(im: Image.Image, *, pad: float = 0.1, dy: int = 0, scale_mul: float = 1.0) -> Image.Image:
	im = knockout_white(im)
	bbox = im.getbbox()
	out = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	if not bbox:
		return out
	sub = im.crop(bbox)
	max_w = int(CELL_W * (1 - pad * 2) * scale_mul)
	max_h = int(CELL_H * (1 - pad * 2) * scale_mul)
	s = min(max_w / sub.width, max_h / sub.height)
	nw, nh = max(1, int(sub.width * s)), max(1, int(sub.height * s))
	sub = sub.resize((nw, nh), Image.Resampling.LANCZOS)
	# harden semi-transparent fringe from resize → keep character solid
	px = sub.load()
	for y in range(nh):
		for x in range(nw):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			if a < 40:
				px[x, y] = (0, 0, 0, 0)
			elif a < 230:
				px[x, y] = (r, g, b, 255)
	x = (CELL_W - nw) // 2
	y = CELL_H - nh - int(CELL_H * 0.04) + dy
	out.alpha_composite(sub, (x, max(0, min(CELL_H - nh, y))))
	return out


def load_pose(name: str) -> Image.Image:
	path = ASSETS / name
	if not path.exists():
		raise SystemExit(f"missing {path}")
	return Image.open(path)


def bob(cell: Image.Image, dy: int = 0) -> Image.Image:
	"""Vertical bob only — same pose, no cross-fade ghosting."""
	if dy == 0:
		return cell
	out = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	out.alpha_composite(cell, (0, dy))
	return out


def flip_x(cell: Image.Image) -> Image.Image:
	return ImageOps.mirror(cell)


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)

	# Prefer original brand art for idle base
	idle0 = fit(Image.open(REF))
	walk_a = fit(load_pose("xb3-walk-r1.jpg"))
	walk_b = fit(load_pose("xb3-walk-r2.jpg"))
	wave = fit(load_pose("xb3-wave.jpg"))
	jump = fit(load_pose("xb3-jump.jpg"), dy=-16)
	fail = fit(load_pose("xb3-fail.jpg"), dy=4)
	wait = fit(load_pose("xb3-wait.jpg"))
	busy = fit(load_pose("xb3-busy.jpg"))
	review = fit(load_pose("xb3-review.jpg"))
	# landing/crouch from same jump art, lower in cell
	land = fit(load_pose("xb3-jump.jpg"), dy=10, scale_mul=0.98)

	rows: dict[str, list[Image.Image]] = {}

	# idle: original art breathe (tiny bob only)
	rows["idle"] = [bob(idle0, d) for d in (0, -1, -3, -2, -1, 0)]

	# walk: alternate real stride poses only — never blend
	rows["running-right"] = [
		bob(walk_a, 0),
		bob(walk_a, -2),
		bob(walk_b, 0),
		bob(walk_b, -2),
		bob(walk_a, 0),
		bob(walk_a, -2),
		bob(walk_b, 0),
		bob(walk_b, -2),
	]
	rows["running-left"] = [flip_x(f) for f in rows["running-right"]]

	# wave: one raised-hand pose + micro bob
	rows["waving"] = [bob(wave, d) for d in (0, -2, 0, -1)]

	# jump: land → air → peak → air → land (discrete poses)
	rows["jumping"] = [
		bob(land, 2),
		bob(jump, 4),
		bob(jump, 0),
		bob(jump, 6),
		bob(land, 2),
	]

	rows["failed"] = [bob(fail, d) for d in (0, 1, 2, 1, 0, 1, 2, 0)]
	rows["waiting"] = [bob(wait, d) for d in (0, -1, 0, -1, 0, -1)]
	rows["running"] = [bob(busy, d) for d in (0, -2, 0, -3, 0, -2)]
	rows["review"] = [bob(review, d) for d in (0, -1, 0, -1, 0, -1)]

	atlas = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))
	for row, (name, count) in enumerate(ROW_SPECS):
		frames = rows[name][:count]
		for col, fr in enumerate(frames):
			atlas.alpha_composite(fr.convert("RGBA"), (col * CELL_W, row * CELL_H))

	png = OUT / "spritesheet.png"
	webp = OUT / "spritesheet.webp"
	atlas.save(png)
	atlas.save(webp, "WEBP", lossless=True, quality=100, method=6)

	prev = Image.new("RGBA", atlas.size, (236, 244, 250, 255))
	prev.alpha_composite(atlas)
	prev.convert("RGB").save(OUT / "spritesheet-preview.jpg", quality=92)

	samples = OUT / "samples"
	samples.mkdir(exist_ok=True)
	for row, (name, count) in enumerate(ROW_SPECS):
		strip = Image.new("RGBA", (CELL_W * count, CELL_H), (0, 0, 0, 0))
		for c in range(count):
			strip.alpha_composite(
				atlas.crop((c * CELL_W, row * CELL_H, (c + 1) * CELL_W, (row + 1) * CELL_H)),
				(c * CELL_W, 0),
			)
		bg = Image.new("RGBA", strip.size, (240, 248, 255, 255))
		bg.alpha_composite(strip)
		bg.convert("RGB").save(samples / f"{name}.jpg", quality=90)

	pet = {
		"id": "xiaobing",
		"displayName": "小冰",
		"description": "ICEJZ 助手桌宠：真实姿态关键帧九态精灵表。",
		"spritesheetPath": "spritesheet.webp",
		"kind": "robot",
		"frameSize": {"width": CELL_W, "height": CELL_H},
		"atlas": {"columns": COLS, "rows": ROWS, "width": ATLAS_W, "height": ATLAS_H},
		"states": [{"name": n, "row": i, "frames": c, "fps": 6} for i, (n, c) in enumerate(ROW_SPECS)],
	}
	(OUT / "pet.json").write_text(json.dumps(pet, ensure_ascii=False, indent=2), encoding="utf-8")
	print("pose sheet", atlas.size, png.stat().st_size)


if __name__ == "__main__":
	main()
