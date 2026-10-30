"""Clean atlas cells: strip edge boxes, neighbor bleed, residual gray frames."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "public" / "mascot" / "xiaobing-pet"
SRC = OUT_DIR / "spritesheet.png"
REF = ROOT / "public" / "mascot" / "xiaobing-main.png"

CELL_W, CELL_H = 192, 208
COLS, ROWS = 8, 9
ATLAS_W, ATLAS_H = COLS * CELL_W, ROWS * CELL_H

ROW_SPECS: list[tuple[str, int]] = [
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


def knockout(im: Image.Image) -> Image.Image:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			# white / paper
			if r >= 235 and g >= 235 and b >= 235:
				px[x, y] = (0, 0, 0, 0)
				continue
			# light gray frame lines / boxes
			if abs(r - g) < 10 and abs(g - b) < 10 and 160 <= r <= 235 and a < 220:
				px[x, y] = (0, 0, 0, 0)
				continue
			# near-black thin borders that aren't character eyes
			if r < 40 and g < 40 and b < 40 and a < 180:
				px[x, y] = (0, 0, 0, 0)
	return im


def clear_edge_ring(im: Image.Image, ring: int = 3) -> Image.Image:
	"""Wipe outer ring that often holds box artifacts."""
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			if x < ring or y < ring or x >= w - ring or y >= h - ring:
				px[x, y] = (0, 0, 0, 0)
	return im


def largest_bbox(im: Image.Image, alpha_min: int = 28):
	a = im.split()[-1]
	mask = a.point(lambda p: 255 if p >= alpha_min else 0)
	# slight close to connect subject
	mask = mask.filter(ImageFilter.MaxFilter(3))
	return mask.getbbox()


def fit_subject(cell: Image.Image) -> Image.Image:
	cell = knockout(cell)
	cell = clear_edge_ring(cell, 2)
	bbox = largest_bbox(cell)
	out = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	if not bbox:
		return out
	sub = cell.crop(bbox)
	# trim again after crop
	sub = knockout(sub)
	bb2 = largest_bbox(sub, 20)
	if bb2:
		sub = sub.crop(bb2)

	pad = 0.1
	max_w = int(CELL_W * (1 - pad * 2))
	max_h = int(CELL_H * (1 - pad * 2))
	scale = min(max_w / max(1, sub.width), max_h / max(1, sub.height))
	nw = max(1, int(sub.width * scale))
	nh = max(1, int(sub.height * scale))
	sub = sub.resize((nw, nh), Image.Resampling.LANCZOS)
	# hard-clear any residual low-alpha haze that causes ghosting
	px = sub.load()
	for y in range(nh):
		for x in range(nw):
			r, g, b, a = px[x, y]
			if a < 40:
				px[x, y] = (0, 0, 0, 0)
			elif a < 90 and r > 200 and g > 200 and b > 200:
				px[x, y] = (0, 0, 0, 0)
	x = (CELL_W - nw) // 2
	y = CELL_H - nh - int(CELL_H * 0.05)
	out.alpha_composite(sub, (x, max(0, y)))
	return clear_edge_ring(out, 1)


def fit_ref_idle() -> Image.Image:
	im = Image.open(REF).convert("RGBA")
	return fit_subject(im)


def main() -> None:
	src = Image.open(SRC).convert("RGBA")
	atlas = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))

	for row, (state, frames) in enumerate(ROW_SPECS):
		for col in range(frames):
			cell = src.crop((col * CELL_W, row * CELL_H, (col + 1) * CELL_W, (row + 1) * CELL_H))
			cleaned = fit_ref_idle() if state == "idle" and col == 0 and REF.exists() else fit_subject(cell)
			atlas.alpha_composite(cleaned, (col * CELL_W, row * CELL_H))

	png = OUT_DIR / "spritesheet.png"
	webp = OUT_DIR / "spritesheet.webp"
	atlas.save(png)
	atlas.save(webp, "WEBP", lossless=True, quality=100, method=6)

	preview = Image.new("RGBA", atlas.size, (236, 244, 250, 255))
	preview.alpha_composite(atlas)
	preview.convert("RGB").save(OUT_DIR / "spritesheet-preview.jpg", quality=92)

	samples = OUT_DIR / "samples"
	samples.mkdir(exist_ok=True)
	for row, (state, frames) in enumerate(ROW_SPECS):
		strip = Image.new("RGBA", (CELL_W * frames, CELL_H), (0, 0, 0, 0))
		for c in range(frames):
			strip.alpha_composite(
				atlas.crop((c * CELL_W, row * CELL_H, (c + 1) * CELL_W, (row + 1) * CELL_H)),
				(c * CELL_W, 0),
			)
		bg = Image.new("RGBA", strip.size, (240, 248, 255, 255))
		bg.alpha_composite(strip)
		bg.convert("RGB").save(samples / f"{state}.jpg", quality=90)

	pet = {
		"id": "xiaobing",
		"displayName": "小冰",
		"description": "ICEJZ 助手桌宠：青蓝白机体，Codex 九态精灵表。",
		"spritesheetPath": "spritesheet.webp",
		"kind": "robot",
		"credits": "ICEJZ",
		"frameSize": {"width": CELL_W, "height": CELL_H},
		"atlas": {"columns": COLS, "rows": ROWS, "width": ATLAS_W, "height": ATLAS_H},
		"states": [
			{"name": n, "row": i, "frames": c, "fps": 3 if n == "idle" else 2.5}
			for i, (n, c) in enumerate(ROW_SPECS)
		],
	}
	(OUT_DIR / "pet.json").write_text(json.dumps(pet, ensure_ascii=False, indent=2), encoding="utf-8")
	print("cleaned", atlas.size, "png", png.stat().st_size)


if __name__ == "__main__":
	main()
