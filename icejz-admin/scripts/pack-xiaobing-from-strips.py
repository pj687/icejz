"""Pack per-state AI strips into Codex V1 1536x1872 spritesheet."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageFilter

ASSETS = Path(r"C:\Users\彭家程\.cursor\projects\d-framework-icejz\assets")
ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "public" / "mascot" / "xiaobing-pet"
REF = ROOT / "public" / "mascot" / "xiaobing-main.png"

CELL_W, CELL_H = 192, 208
COLS, ROWS = 8, 9
ATLAS_W, ATLAS_H = COLS * CELL_W, ROWS * CELL_H

ROW_SPECS: list[tuple[str, int, str]] = [
	("idle", 6, "xb2-idle.jpg"),
	("running-right", 8, "xb2-run-right.jpg"),
	("running-left", 8, "xb2-run-left.jpg"),
	("waving", 4, "xb2-wave.jpg"),
	("jumping", 5, "xb2-jump.jpg"),
	("failed", 8, "xb2-fail.jpg"),
	("waiting", 6, "xb2-wait.jpg"),
	("running", 6, "xb2-running.jpg"),
	("review", 6, "xb2-review.jpg"),
]


def knockout_white(im: Image.Image, thr: int = 242) -> Image.Image:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			# white / near-white paper
			if r >= thr and g >= thr and b >= thr:
				px[x, y] = (255, 255, 255, 0)
				continue
			# soft edge fade for light gray
			if min(r, g, b) > 220 and abs(r - g) < 12 and abs(g - b) < 12:
				alpha = max(0, min(255, (255 - min(r, g, b)) * 10))
				px[x, y] = (r, g, b, alpha)
	return im


def content_bbox(im: Image.Image, alpha_min: int = 20):
	a = im.split()[-1]
	return a.point(lambda p: 255 if p >= alpha_min else 0).getbbox()


def fit_to_cell(im: Image.Image) -> Image.Image:
	im = im.convert("RGBA")
	bbox = content_bbox(im)
	out = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	if not bbox:
		return out
	sub = im.crop(bbox)
	# slight feather cleanup
	sub = sub.filter(ImageFilter.SMOOTH_MORE)
	pad = 0.08
	max_w = int(CELL_W * (1 - pad * 2))
	max_h = int(CELL_H * (1 - pad * 2))
	scale = min(max_w / sub.width, max_h / sub.height)
	nw, nh = max(1, int(sub.width * scale)), max(1, int(sub.height * scale))
	sub = sub.resize((nw, nh), Image.Resampling.LANCZOS)
	x = (CELL_W - nw) // 2
	y = CELL_H - nh - int(CELL_H * 0.04)
	out.alpha_composite(sub, (x, max(0, y)))
	return out


def fit_ref_idle() -> Image.Image:
	"""Use original mascot as first idle frame for brand lock."""
	im = Image.open(REF).convert("RGBA")
	bbox = content_bbox(im) or im.getbbox()
	if bbox:
		im = im.crop(bbox)
	return fit_to_cell(im)


def extract_frames(strip: Image.Image, count: int) -> list[Image.Image]:
	strip = knockout_white(strip)
	bbox = content_bbox(strip, alpha_min=8)
	if bbox:
		l, t, r, b = bbox
		pad_x = max(2, int((r - l) * 0.01))
		pad_y = max(2, int((b - t) * 0.01))
		strip = strip.crop((max(0, l - pad_x), max(0, t - pad_y), min(strip.width, r + pad_x), min(strip.height, b + pad_y)))

	# equal-width slice across content, with strong inset to kill neighbor bleed
	w, h = strip.size
	frames: list[Image.Image] = []
	for i in range(count):
		x0 = int(round(i * w / count))
		x1 = int(round((i + 1) * w / count))
		span = max(1, x1 - x0)
		inset = max(3, int(span * 0.06))
		cell = strip.crop((x0 + inset, 0, max(x0 + inset + 1, x1 - inset), h))
		frames.append(fit_to_cell(cell))
	return frames


def main() -> None:
	OUT_DIR.mkdir(parents=True, exist_ok=True)
	atlas = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))

	for row, (state, count, filename) in enumerate(ROW_SPECS):
		path = ASSETS / filename
		if not path.exists():
			raise SystemExit(f"missing strip: {path}")
		print("pack", state, path.name)
		frames = extract_frames(Image.open(path), count)
		if state == "idle" and REF.exists():
			frames[0] = fit_ref_idle()
		for col, fr in enumerate(frames):
			atlas.alpha_composite(fr, (col * CELL_W, row * CELL_H))

	png_path = OUT_DIR / "spritesheet.png"
	webp_path = OUT_DIR / "spritesheet.webp"
	atlas.save(png_path)
	atlas.save(webp_path, "WEBP", lossless=True, quality=100, method=6)

	preview = Image.new("RGBA", atlas.size, (236, 244, 250, 255))
	preview.alpha_composite(atlas)
	preview.convert("RGB").save(OUT_DIR / "spritesheet-preview.jpg", quality=92)

	# sample strips for QA
	samples = OUT_DIR / "samples"
	samples.mkdir(exist_ok=True)
	for row, (state, count, _) in enumerate(ROW_SPECS):
		strip = Image.new("RGBA", (CELL_W * count, CELL_H), (0, 0, 0, 0))
		for c in range(count):
			strip.alpha_composite(atlas.crop((c * CELL_W, row * CELL_H, (c + 1) * CELL_W, (row + 1) * CELL_H)), (c * CELL_W, 0))
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
			{"name": n, "row": i, "frames": c, "fps": 6 if n == "idle" else 8}
			for i, (n, c, _) in enumerate(ROW_SPECS)
		],
	}
	(OUT_DIR / "pet.json").write_text(json.dumps(pet, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"done {atlas.size} png={png_path.stat().st_size} webp={webp_path.stat().st_size}")


if __name__ == "__main__":
	main()
