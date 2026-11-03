"""Build 小冰「奶龙合拍手势舞」spritesheet from hatch-pet style chroma poses."""
from __future__ import annotations

import json
import math
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "public" / "mascot" / "xiaobing-dance"
RUN = OUT / "run"
ASSETS = Path.home() / ".cursor" / "projects" / "d-customer-icejz" / "assets"

CELL_W, CELL_H = 192, 208
CHROMA = (0, 255, 0)
THRESHOLD = 78.0

# Unique key poses → sheet columns 0..7
POSE_SOURCES = {
	"cry_high": ASSETS / "xiaobing-dance-strip-a.jpg",
	"cry_low": ASSETS / "xiaobing-dance-cry-low.jpg",
	"cross": ASSETS / "xiaobing-dance-strip-a.jpg",
	"open": ASSETS / "xiaobing-dance-strip-a.jpg",
	"grab_l": ASSETS / "xiaobing-pose-grab-l.jpg",
	"grab_r": ASSETS / "xiaobing-pose-grab-r.jpg",
	"circle_l": ASSETS / "xiaobing-pose-circle-l.jpg",
	"circle_r": ASSETS / "xiaobing-pose-circle-r.jpg",
}

STRIP_A_INDEX = {"cry_high": 0, "cross": 2, "open": 3}

# Playback: 5 groups per 合拍手势舞
# 0 cry_high, 1 cry_low, 2 cross, 3 open, 4 grab_l, 5 grab_r, 6 circle_l, 7 circle_r
SEQUENCE = [
	# 右手哭两次
	0, 1, 0, 1,
	# 交叉再打开
	2, 3,
	# 依次抓手（左→右）
	4, 3, 5, 3,
	# 交叉四次
	2, 3, 2, 3, 2, 3, 2, 3,
	# 左右画圈三次
	6, 7, 6, 7, 6, 7,
]

POSE_NAMES = [
	"cry_high",
	"cry_low",
	"cross",
	"open",
	"grab_l",
	"grab_r",
	"circle_l",
	"circle_r",
]


def color_distance(r: int, g: int, b: int) -> float:
	return math.sqrt((r - CHROMA[0]) ** 2 + (g - CHROMA[1]) ** 2 + (b - CHROMA[2]) ** 2)


def remove_chroma(im: Image.Image) -> Image.Image:
	rgba = im.convert("RGBA")
	px = rgba.load()
	for y in range(rgba.height):
		for x in range(rgba.width):
			r, g, b, a = px[x, y]
			# green screen + soft greenish floor shadow bleed
			if color_distance(r, g, b) <= THRESHOLD:
				px[x, y] = (0, 0, 0, 0)
				continue
			if g > 110 and g - r > 28 and g - b > 28:
				px[x, y] = (0, 0, 0, 0)
	return rgba


def slice_strip(path: Path, index: int, count: int = 4) -> Image.Image:
	im = Image.open(path).convert("RGBA")
	w, h = im.size
	slot = w // count
	return im.crop((index * slot, 0, (index + 1) * slot, h))


def fit_to_cell(im: Image.Image) -> Image.Image:
	im = remove_chroma(im)
	bbox = im.getbbox()
	target = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	if not bbox:
		return target
	sprite = im.crop(bbox)
	max_w, max_h = CELL_W - 10, CELL_H - 10
	scale = min(max_w / sprite.width, max_h / sprite.height)
	nw = max(1, round(sprite.width * scale))
	nh = max(1, round(sprite.height * scale))
	sprite = sprite.resize((nw, nh), Image.Resampling.LANCZOS)
	# bottom-align for stable dance baseline
	left = (CELL_W - nw) // 2
	top = CELL_H - nh - 4
	target.alpha_composite(sprite, (left, top))
	return target


def load_pose(name: str) -> Image.Image:
	src = POSE_SOURCES[name]
	if not src.exists():
		raise FileNotFoundError(src)
	if name in STRIP_A_INDEX:
		return fit_to_cell(slice_strip(src, STRIP_A_INDEX[name]))
	return fit_to_cell(Image.open(src))


def main() -> None:
	frames_dir = RUN / "frames" / "hepai"
	decoded = RUN / "decoded"
	final = RUN / "final"
	qa = RUN / "qa"
	poses_dir = OUT / "poses"
	for d in (frames_dir, decoded, final, qa, poses_dir):
		d.mkdir(parents=True, exist_ok=True)

	cells: list[Image.Image] = []
	for i, name in enumerate(POSE_NAMES):
		cell = load_pose(name)
		cells.append(cell)
		cell.save(frames_dir / f"{i:02d}.png")
		cell.save(poses_dir / f"{name}.png")

	sheet = Image.new("RGBA", (CELL_W * len(cells), CELL_H), (0, 0, 0, 0))
	for i, cell in enumerate(cells):
		sheet.alpha_composite(cell, (i * CELL_W, 0))

	png_path = final / "spritesheet.png"
	webp_path = final / "spritesheet.webp"
	sheet.save(png_path)
	sheet.save(webp_path, "WEBP", quality=92, method=6)

	# Publish to public dance pack
	shutil.copy2(png_path, OUT / "spritesheet.png")
	shutil.copy2(webp_path, OUT / "spritesheet.webp")

	# Contact sheet (simple)
	contact = Image.new("RGBA", (CELL_W * 4, CELL_H * 2), (24, 28, 36, 255))
	for i, cell in enumerate(cells):
		contact.alpha_composite(cell, ((i % 4) * CELL_W, (i // 4) * CELL_H))
	contact.convert("RGB").save(qa / "contact-sheet.png", quality=90)
	contact.convert("RGB").save(OUT / "spritesheet-preview.jpg", quality=88)

	fps = 5
	meta = {
		"id": "xiaobing-hepai-dance",
		"displayName": "小冰·奶龙合拍手势舞",
		"description": "右手哭×2 → 交叉打开 → 依次抓手 → 交叉×4 → 左右画圈×3",
		"spritesheetPath": "spritesheet.webp",
		"cellW": CELL_W,
		"cellH": CELL_H,
		"cols": len(cells),
		"rows": 1,
		"width": CELL_W * len(cells),
		"height": CELL_H,
		"frames": len(cells),
		"fps": fps,
		"poses": POSE_NAMES,
		"sequence": SEQUENCE,
		"groups": [
			{"name": "右手哭两次", "repeats": 2, "poseKeys": ["cry_high", "cry_low"]},
			{"name": "交叉再打开", "repeats": 1, "poseKeys": ["cross", "open"]},
			{"name": "依次抓手", "repeats": 1, "poseKeys": ["grab_l", "open", "grab_r", "open"]},
			{"name": "交叉四次", "repeats": 4, "poseKeys": ["cross", "open"]},
			{"name": "左右画圈三次", "repeats": 3, "poseKeys": ["circle_l", "circle_r"]},
		],
		"holdMs": int(len(SEQUENCE) / fps * 1000) + 200,
	}
	(OUT / "dance.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
	(RUN / "qa" / "run-summary.json").write_text(
		json.dumps(
			{
				"ok": True,
				"spritesheet": str(OUT / "spritesheet.webp"),
				"contact_sheet": str(qa / "contact-sheet.png"),
				"frames": len(SEQUENCE),
				"unique_poses": len(cells),
			},
			ensure_ascii=False,
			indent=2,
		),
		encoding="utf-8",
	)
	print(f"poses={len(cells)} sequence={len(SEQUENCE)} holdMs={meta['holdMs']}")
	print(f"wrote {OUT / 'spritesheet.webp'}")


if __name__ == "__main__":
	main()
