"""Export clean opaque pose PNGs for runtime pose-swap animation."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageOps

ASSETS = Path(r"C:\Users\彭家程\.cursor\projects\d-framework-icejz\assets")
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "public" / "mascot" / "xiaobing-pet" / "poses"
REF = ROOT / "public" / "mascot" / "xiaobing-main.png"

SIZE = 256


def knockout(im: Image.Image, thr: int = 246) -> Image.Image:
	im = im.convert("RGBA")
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if r >= thr and g >= thr and b >= thr:
				px[x, y] = (0, 0, 0, 0)
				continue
			# soft contact shadow under feet (darkish gray, low chroma)
			if a > 0 and abs(r - g) < 12 and abs(g - b) < 12 and 80 < r < 210 and y > h * 0.72:
				if a < 200:
					px[x, y] = (0, 0, 0, 0)
	return im


def harden(im: Image.Image) -> Image.Image:
	px = im.load()
	w, h = im.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if a == 0:
				continue
			if a < 50:
				px[x, y] = (0, 0, 0, 0)
			elif a < 245:
				px[x, y] = (r, g, b, 255)
	return im


def export_one(src: Path, dest: Path) -> None:
	im = knockout(Image.open(src))
	bbox = im.getbbox()
	if not bbox:
		raise SystemExit(f"empty {src}")
	im = im.crop(bbox)
	# pad square
	side = max(im.width, im.height)
	canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
	canvas.alpha_composite(im, ((side - im.width) // 2, side - im.height))
	canvas = harden(canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS))
	canvas = harden(canvas)
	dest.parent.mkdir(parents=True, exist_ok=True)
	canvas.save(dest)
	print("wrote", dest.name, canvas.size)


def main() -> None:
	OUT.mkdir(parents=True, exist_ok=True)
	export_one(REF, OUT / "idle.png")
	export_one(ASSETS / "xb3-walk-r1.jpg", OUT / "walk-a.png")
	export_one(ASSETS / "xb3-walk-r2.jpg", OUT / "walk-b.png")
	# left walks = mirrored
	a = Image.open(OUT / "walk-a.png")
	b = Image.open(OUT / "walk-b.png")
	ImageOps.mirror(a).save(OUT / "walk-left-a.png")
	ImageOps.mirror(b).save(OUT / "walk-left-b.png")
	export_one(ASSETS / "xb3-wave.jpg", OUT / "wave.png")
	export_one(ASSETS / "xb3-jump.jpg", OUT / "jump.png")
	export_one(ASSETS / "xb3-fail.jpg", OUT / "fail.png")
	export_one(ASSETS / "xb3-wait.jpg", OUT / "wait.png")
	export_one(ASSETS / "xb3-busy.jpg", OUT / "busy.png")
	export_one(ASSETS / "xb3-review.jpg", OUT / "review.png")
	print("done", OUT)


if __name__ == "__main__":
	main()
