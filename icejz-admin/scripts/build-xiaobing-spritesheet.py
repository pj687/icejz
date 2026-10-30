"""Build Codex/Petdex V1 spritesheet (1536x1872, 8x9, 192x208) for 小冰."""
from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "public" / "mascot" / "xiaobing-main.png"
OUT_DIR = ROOT / "public" / "mascot" / "xiaobing-pet"

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


def trim_alpha(im: Image.Image) -> Image.Image:
	im = im.convert("RGBA")
	bbox = im.getbbox()
	return im.crop(bbox) if bbox else im


def fit_to_cell(im: Image.Image, pad_ratio: float = 0.08) -> Image.Image:
	im = trim_alpha(im)
	max_w = int(CELL_W * (1 - pad_ratio * 2))
	max_h = int(CELL_H * (1 - pad_ratio * 2))
	scale = min(max_w / im.width, max_h / im.height)
	nw, nh = max(1, int(im.width * scale)), max(1, int(im.height * scale))
	im = im.resize((nw, nh), Image.Resampling.LANCZOS)
	cell = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	cell.alpha_composite(im, ((CELL_W - nw) // 2, CELL_H - nh - int(CELL_H * 0.04)))
	return cell


def transform(
	base: Image.Image,
	*,
	dx: float = 0,
	dy: float = 0,
	rot: float = 0,
	sx: float = 1.0,
	sy: float = 1.0,
	bright: float = 1.0,
) -> Image.Image:
	canvas = Image.new("RGBA", (CELL_W * 2, CELL_H * 2), (0, 0, 0, 0))
	ox = (CELL_W * 2 - CELL_W) // 2
	oy = (CELL_H * 2 - CELL_H) // 2
	canvas.alpha_composite(base, (ox, oy))
	if sx != 1.0 or sy != 1.0:
		nw = max(1, int(canvas.width * sx))
		nh = max(1, int(canvas.height * sy))
		scaled = canvas.resize((nw, nh), Image.Resampling.LANCZOS)
		canvas = Image.new("RGBA", (CELL_W * 2, CELL_H * 2), (0, 0, 0, 0))
		canvas.alpha_composite(scaled, ((CELL_W * 2 - nw) // 2, CELL_H * 2 - nh))
	if rot:
		canvas = canvas.rotate(
			rot,
			resample=Image.Resampling.BICUBIC,
			center=(CELL_W, CELL_H * 1.15),
			expand=False,
		)
	if bright != 1.0:
		rgb = canvas.convert("RGB")
		a = canvas.split()[-1]
		rgb = ImageEnhance.Brightness(rgb).enhance(bright)
		canvas = Image.merge("RGBA", (*rgb.split(), a))
	left = CELL_W // 2 - int(dx)
	top = CELL_H // 2 - int(dy)
	return canvas.crop((left, top, left + CELL_W, top + CELL_H))


def frames_idle(base: Image.Image) -> list[Image.Image]:
	out = []
	for i in range(6):
		t = i / 5
		dy = -round(3 * math.sin(t * math.pi * 2))
		sy = 1.0 + 0.015 * math.sin(t * math.pi * 2)
		rot = 1.2 * math.sin(t * math.pi * 2)
		out.append(transform(base, dy=dy, sy=sy, sx=1 / sy, rot=rot))
	return out


def frames_run_right(base: Image.Image) -> list[Image.Image]:
	out = []
	for i in range(8):
		t = i / 8
		dy = -abs(round(8 * math.sin(t * math.pi * 2)))
		rot = 6 + 4 * math.sin(t * math.pi * 2)
		dx = round(6 * math.sin(t * math.pi * 2))
		sx = 1.0 + 0.02 * math.sin(t * math.pi * 2)
		out.append(transform(base, dx=dx, dy=dy, rot=rot, sx=sx, sy=1 / sx))
	return out


def frames_run_left(base: Image.Image) -> list[Image.Image]:
	return [fr.transpose(Image.Transpose.FLIP_LEFT_RIGHT) for fr in frames_run_right(base)]


def frames_wave(base: Image.Image) -> list[Image.Image]:
	amps = [-12, 14, -14, 12]
	return [
		transform(base, rot=rot, dy=(-2 if i % 2 else 0), sx=1.02, sy=0.98)
		for i, rot in enumerate(amps)
	]


def frames_jump(base: Image.Image) -> list[Image.Image]:
	specs = [
		dict(dy=10, sx=1.08, sy=0.88, rot=-2),
		dict(dy=-18, sx=0.95, sy=1.08, rot=0),
		dict(dy=-36, sx=0.92, sy=1.12, rot=2),
		dict(dy=-14, sx=0.96, sy=1.06, rot=-1),
		dict(dy=8, sx=1.06, sy=0.9, rot=0),
	]
	return [transform(base, **s) for s in specs]


def frames_failed(base: Image.Image) -> list[Image.Image]:
	out = []
	for i in range(8):
		t = i / 7
		rot = -4 - 6 * t
		dy = round(4 + 10 * t)
		bright = 1.0 - 0.12 * t
		sx = 1.0 + 0.04 * t
		sy = 1.0 - 0.05 * t
		out.append(transform(base, rot=rot, dy=dy, bright=bright, sx=sx, sy=sy))
	return out


def frames_waiting(base: Image.Image) -> list[Image.Image]:
	seq = [(-8, -6), (-10, 0), (-4, 6), (8, 6), (10, 0), (4, -4)]
	return [transform(base, dx=dx, rot=rot, dy=-1) for dx, rot in seq]


def frames_running(base: Image.Image) -> list[Image.Image]:
	out = []
	for i in range(6):
		t = i / 6
		dy = -round(6 * abs(math.sin(t * math.pi * 2)))
		rot = 3 * math.sin(t * math.pi * 4)
		sx = 1.0 + 0.03 * math.sin(t * math.pi * 2)
		out.append(transform(base, dy=dy, rot=rot, sx=sx, sy=1 / sx))
	return out


def frames_review(base: Image.Image) -> list[Image.Image]:
	out = []
	for i in range(6):
		t = i / 5
		rot = -6 + 12 * t if i < 3 else 6 - 8 * (t - 0.5)
		dy = -round(2 * math.sin(t * math.pi))
		out.append(transform(base, rot=rot, dy=dy))
	return out


BUILDERS = {
	"idle": frames_idle,
	"running-right": frames_run_right,
	"running-left": frames_run_left,
	"waving": frames_wave,
	"jumping": frames_jump,
	"failed": frames_failed,
	"waiting": frames_waiting,
	"running": frames_running,
	"review": frames_review,
}


def main() -> None:
	OUT_DIR.mkdir(parents=True, exist_ok=True)
	base_img = fit_to_cell(Image.open(SRC))
	atlas = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))

	for row, (state, count) in enumerate(ROW_SPECS):
		frames = BUILDERS[state](base_img)[:count]
		for col, fr in enumerate(frames):
			atlas.alpha_composite(fr.convert("RGBA"), (col * CELL_W, row * CELL_H))

	png_path = OUT_DIR / "spritesheet.png"
	webp_path = OUT_DIR / "spritesheet.webp"
	atlas.save(png_path)
	atlas.save(webp_path, "WEBP", lossless=True, quality=100, method=6)

	preview = Image.new("RGBA", atlas.size, (245, 250, 255, 255))
	preview.alpha_composite(atlas)
	preview.convert("RGB").save(OUT_DIR / "spritesheet-preview.jpg", quality=90)

	pet = {
		"id": "xiaobing",
		"displayName": "小冰",
		"description": "ICEJZ 助手桌宠：青蓝白机体，九态 Codex 精灵表。",
		"spritesheetPath": "spritesheet.webp",
		"kind": "robot",
		"credits": "ICEJZ",
		"frameSize": {"width": CELL_W, "height": CELL_H},
		"atlas": {"columns": COLS, "rows": ROWS, "width": ATLAS_W, "height": ATLAS_H},
		"states": [
			{"name": name, "row": i, "frames": count, "fps": 8 if name != "idle" else 6}
			for i, (name, count) in enumerate(ROW_SPECS)
		],
	}
	(OUT_DIR / "pet.json").write_text(json.dumps(pet, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"atlas {atlas.size} -> {png_path}")
	print(f"webp {webp_path.stat().st_size} bytes, png {png_path.stat().st_size} bytes")


if __name__ == "__main__":
	main()
