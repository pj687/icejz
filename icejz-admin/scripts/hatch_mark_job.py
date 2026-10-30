"""Helpers for hatch-pet run: white→green chroma + mark jobs complete."""
from __future__ import annotations

import argparse
import collections
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image


def white_to_green(im: Image.Image, thr: int = 235) -> Image.Image:
	im = im.convert("RGBA")
	w, h = im.size
	px = im.load()
	q: collections.deque[tuple[int, int]] = collections.deque()
	seen = [[False] * w for _ in range(h)]
	for x in range(w):
		q.append((x, 0))
		q.append((x, h - 1))
	for y in range(h):
		q.append((0, y))
		q.append((w - 1, y))
	while q:
		x, y = q.popleft()
		if x < 0 or y < 0 or x >= w or y >= h or seen[y][x]:
			continue
		seen[y][x] = True
		r, g, b, a = px[x, y]
		if min(r, g, b) >= thr and abs(r - g) < 18 and abs(g - b) < 18:
			px[x, y] = (0, 255, 0, 255)
			q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
	return im


def mark_complete(run_dir: Path, job_id: str, source: Path) -> None:
	jobs_path = run_dir / "imagegen-jobs.json"
	jobs = json.loads(jobs_path.read_text(encoding="utf-8"))
	now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
	job = next(j for j in jobs["jobs"] if j["id"] == job_id)
	out_rel = Path(job["output_path"])
	out_abs = run_dir / out_rel
	out_abs.parent.mkdir(parents=True, exist_ok=True)

	im = white_to_green(Image.open(source))
	im.save(out_abs)
	if job_id == "base":
		canon = run_dir / "references" / "canonical-base.png"
		canon.parent.mkdir(parents=True, exist_ok=True)
		shutil.copy2(out_abs, canon)

	job["status"] = "complete"
	job["source_path"] = str(source)
	job["completed_at"] = now
	jobs_path.write_text(json.dumps(jobs, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"complete {job_id} -> {out_abs}")


def ready_jobs(run_dir: Path) -> list[str]:
	jobs = json.loads((run_dir / "imagegen-jobs.json").read_text(encoding="utf-8"))
	done = {j["id"] for j in jobs["jobs"] if j["status"] == "complete"}
	ready = []
	for j in jobs["jobs"]:
		if j["status"] == "complete":
			continue
		deps = j.get("depends_on") or []
		if all(d in done for d in deps):
			ready.append(j["id"])
	return ready


def main() -> None:
	ap = argparse.ArgumentParser()
	ap.add_argument("--run-dir", required=True)
	ap.add_argument("--job-id", required=True)
	ap.add_argument("--source", required=True)
	args = ap.parse_args()
	run_dir = Path(args.run_dir)
	mark_complete(run_dir, args.job_id, Path(args.source))
	print("ready", ready_jobs(run_dir))


if __name__ == "__main__":
	main()
