"""Build 小冰奶龙舞逐帧精灵：关键姿势 + 过渡帧，右×2、左×2。"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "public" / "mascot" / "xiaobing-dance"
POSE_DIR = ROOT / "public" / "mascot" / "xiaobing-dance" / "poses"
ASSETS = Path.home() / ".cursor" / "projects" / "d-customer-icejz" / "assets"

# 优先项目内姿势图，其次 Cursor assets
POSE_FILES = {
	"neutral": [
		POSE_DIR / "nailong-neutral.jpg",
		ASSETS / "nailong-neutral.jpg",
		ROOT / "public" / "mascot" / "xiaobing-pet" / "poses" / "idle.png",
	],
	"right": [
		POSE_DIR / "nailong-right-mirrored.jpg",
		ASSETS / "nailong-right-mirrored.jpg",
		ASSETS / "nailong-right.jpg",
	],
	"left": [POSE_DIR / "nailong-left.jpg", ASSETS / "nailong-left.jpg"],
}

CELL_W, CELL_H = 192, 208
FPS = 8


def find_pose(key: str) -> Path:
	for p in POSE_FILES[key]:
		if p.exists():
			return p
	raise FileNotFoundError(key)


def chroma_key(im: Image.Image, thr: int = 70) -> Image.Image:
	"""抠掉绿幕，保留角色（含青蓝手套）。"""
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			# 纯绿 / 高绿低红蓝
			if g > 90 and g - r > 35 and g - b > 35:
				px[x, y] = (0, 0, 0, 0)
				continue
			# 过亮近似背景
			if r > 230 and g > 230 and b > 230 and abs(r - g) < 8:
				px[x, y] = (0, 0, 0, 0)
	return im


def trim_alpha(im: Image.Image) -> Image.Image:
	bbox = im.getbbox()
	return im.crop(bbox) if bbox else im


def fit_to_cell(im: Image.Image, pad: float = 0.05) -> Image.Image:
	im = trim_alpha(im.convert("RGBA"))
	max_w = int(CELL_W * (1 - pad * 2))
	max_h = int(CELL_H * (1 - pad * 2))
	scale = min(max_w / max(1, im.width), max_h / max(1, im.height))
	nw, nh = max(1, int(im.width * scale)), max(1, int(im.height * scale))
	im = im.resize((nw, nh), Image.Resampling.LANCZOS)
	cell = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
	cell.alpha_composite(im, ((CELL_W - nw) // 2, CELL_H - nh - 2))
	return cell


def load_cell(path: Path) -> Image.Image:
	return fit_to_cell(chroma_key(Image.open(path)))


def nudge(im: Image.Image, dx: int = 0, dy: int = 0, rot: float = 0) -> Image.Image:
	"""同姿势微位移，避免连续两帧完全静止。"""
	canvas = Image.new("RGBA", (CELL_W * 2, CELL_H * 2), (0, 0, 0, 0))
	canvas.alpha_composite(im, (CELL_W // 2, CELL_H // 2))
	if rot:
		canvas = canvas.rotate(rot, resample=Image.Resampling.BICUBIC, center=(CELL_W, int(CELL_H * 1.2)))
	return canvas.crop(
		(CELL_W // 2 - dx, CELL_H // 2 - dy, CELL_W // 2 - dx + CELL_W, CELL_H // 2 - dy + CELL_H)
	)


def build_cycle(n: Image.Image, r: Image.Image, l: Image.Image) -> list[Image.Image]:
	"""
	经典奶龙节奏：右、右、左、左（每拍到边再回中）
	R → N → R → N → L → N → L → N
	"""
	r2 = nudge(r, dx=2, rot=1.5)
	l2 = nudge(l, dx=-2, rot=-1.5)
	return [
		r,  # 右 1
		nudge(n, dy=1),
		r2,  # 右 2
		n,
		l,  # 左 1
		nudge(n, dy=1),
		l2,  # 左 2
		n,
	]


def main() -> None:
	OUT_DIR.mkdir(parents=True, exist_ok=True)
	n = load_cell(find_pose("neutral"))
	r = load_cell(find_pose("right"))
	l = load_cell(find_pose("left"))

	# 若 right/left 差异太弱，用镜像补一边
	# （left 图本身已是侧摆，保留原图）

	frames = build_cycle(n, r, l)
	cols = len(frames)
	atlas = Image.new("RGBA", (cols * CELL_W, CELL_H), (0, 0, 0, 0))
	for i, fr in enumerate(frames):
		atlas.alpha_composite(fr, (i * CELL_W, 0))

	png = OUT_DIR / "spritesheet.png"
	webp = OUT_DIR / "spritesheet.webp"
	atlas.save(png)
	atlas.save(webp, "WEBP", lossless=True, quality=100, method=6)

	preview = Image.new("RGBA", atlas.size, (245, 250, 255, 255))
	preview.alpha_composite(atlas)
	preview.convert("RGB").save(OUT_DIR / "spritesheet-preview.jpg", quality=92)

	meta = {
		"id": "xiaobing-nailong-dance",
		"displayName": "小冰奶龙舞",
		"frames": cols,
		"fps": FPS,
		"cell": {"w": CELL_W, "h": CELL_H},
		"pattern": "right x2, left x2 with in-betweens",
		"width": cols * CELL_W,
		"height": CELL_H,
	}
	(OUT_DIR / "dance.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"wrote {cols} frames @ {FPS}fps -> {webp}")


if __name__ == "__main__":
	main()
