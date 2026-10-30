"""Normalize a generated atlas into Codex V1 1536x1872 transparent spritesheet."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "public" / "mascot" / "xiaobing-pet"
SRC_CANDIDATES = [
	Path(r"C:\Users\彭家程\.cursor\projects\d-framework-icejz\assets\xiaobing-atlas-v2.jpg"),
	Path(r"C:\Users\彭家程\.cursor\projects\d-framework-icejz\assets\xiaobing-atlas-v2.png"),
	OUT_DIR / "spritesheet-preview.jpg",
]

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


def to_rgba_knockout(im: Image.Image, thr: int = 245) -> Image.Image:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if r >= thr and g >= thr and b >= thr:
				px[x, y] = (255, 255, 255, 0)
			elif abs(r - g) < 8 and abs(g - b) < 8 and r > 230:
				# near-white / light gray paper
				alpha = max(0, min(255, int((255 - r) * 8)))
				px[x, y] = (r, g, b, alpha)
	return im


def content_bbox(im: Image.Image, alpha_min: int = 24):
	a = im.split()[-1]
	mask = a.point(lambda p: 255 if p >= alpha_min else 0)
	return mask.getbbox()


def fit_subject(cell: Image.Image) -> Image.Image:
	"""Center subject into a clean 192x208 transparent cell."""
	cell = cell.convert("RGBA")
	bbox = content_bbox(cell)
	out = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	if not bbox:
		return out
	sub = cell.crop(bbox)
	pad = 0.1
	max_w = int(CELL_W * (1 - pad * 2))
	max_h = int(CELL_H * (1 - pad * 2))
	scale = min(max_w / sub.width, max_h / sub.height, 1.35)
	nw = max(1, int(sub.width * scale))
	nh = max(1, int(sub.height * scale))
	sub = sub.resize((nw, nh), Image.Resampling.LANCZOS)
	x = (CELL_W - nw) // 2
	y = CELL_H - nh - int(CELL_H * 0.05)
	out.alpha_composite(sub, (x, max(0, y)))
	return out


def slice_grid(src: Image.Image) -> list[list[Image.Image]]:
	src = to_rgba_knockout(src)
	# trim outer empty margins first for tighter grid
	bbox = content_bbox(src, alpha_min=10)
	if bbox:
		# keep a little margin
		l, t, r, b = bbox
		pad = 4
		l = max(0, l - pad)
		t = max(0, t - pad)
		r = min(src.width, r + pad)
		b = min(src.height, b + pad)
		src = src.crop((l, t, r, b))

	cw = src.width / COLS
	rh = src.height / ROWS
	grid: list[list[Image.Image]] = []
	for row in range(ROWS):
		row_cells = []
		for col in range(COLS):
			x0 = int(round(col * cw))
			y0 = int(round(row * rh))
			x1 = int(round((col + 1) * cw))
			y1 = int(round((row + 1) * rh))
			raw = src.crop((x0, y0, x1, y1))
			row_cells.append(fit_subject(raw))
		grid.append(row_cells)
	return grid


def main() -> None:
	src_path = next((p for p in SRC_CANDIDATES if p.exists()), None)
	if not src_path:
		raise SystemExit("No atlas source found")

	OUT_DIR.mkdir(parents=True, exist_ok=True)
	print("source:", src_path)
	src = Image.open(src_path)
	grid = slice_grid(src)

	atlas = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))
	for row, (name, frames) in enumerate(ROW_SPECS):
		for col in range(frames):
			atlas.alpha_composite(grid[row][col], (col * CELL_W, row * CELL_H))

	png_path = OUT_DIR / "spritesheet.png"
	webp_path = OUT_DIR / "spritesheet.webp"
	atlas.save(png_path)
	atlas.save(webp_path, "WEBP", lossless=True, quality=100, method=6)

	preview = Image.new("RGBA", atlas.size, (236, 244, 250, 255))
	preview.alpha_composite(atlas)
	preview.convert("RGB").save(OUT_DIR / "spritesheet-preview.jpg", quality=92)

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
			{"name": n, "row": i, "frames": c, "fps": 6 if n == "idle" else 8}
			for i, (n, c) in enumerate(ROW_SPECS)
		],
	}
	(OUT_DIR / "pet.json").write_text(json.dumps(pet, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"packed {atlas.size} -> {png_path}")
	print(f"webp={webp_path.stat().st_size} png={png_path.stat().st_size}")


if __name__ == "__main__":
	main()
