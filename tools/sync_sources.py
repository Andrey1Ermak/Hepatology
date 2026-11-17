#!/usr/bin/env python3
"""Daily sync with the lesson repository (Andrey1Ermak/reading-final).

Usage (from the Hepatology root):
  python3 tools/sync_sources.py              # pull, report and extract new/changed lessons
  python3 tools/sync_sources.py --done       # record the current lesson commit as processed (also runs --plan)
  python3 tools/sync_sources.py --plan       # stamp "lesson": first-arrival date on plan.json days
  python3 tools/sync_sources.py --extract 02-03 02-07   # extract specific lessons by prefix
  python3 tools/sync_sources.py --extract 02-            # every lesson of block 2

Lessons live in sources/reading-final/hepatology/ as BB-DD_Topic.pptx (deck) and
BB-DD_Topic_audio.pdf (chapter text). Extracted text goes to sources/extracted/
(regenerable, not committed). Processing state lives in sources/sync_state.json.
"""
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPO_URL = "https://github.com/Andrey1Ermak/reading-final.git"
CLONE = ROOT / "sources" / "reading-final"
LESSONS = "hepatology"
PLAN = "Hepatology_Year_Plan.docx"
STATE = ROOT / "sources" / "sync_state.json"
EXTRACTED = ROOT / "sources" / "extracted"
PLAN_JSON = ROOT / "ios" / "HepReference" / "HepReference" / "Content" / "Registry" / "plan.json"


def git(*args):
    return subprocess.run(["git", "-C", str(CLONE), *args], check=True, capture_output=True, text=True).stdout.strip()


def load_state():
    return json.loads(STATE.read_text()) if STATE.exists() else {"last_commit": None, "last_sync": None}


def pull():
    if not CLONE.exists():
        subprocess.run(["git", "clone", "-q", REPO_URL, str(CLONE)], check=True)
    else:
        git("pull", "-q", "--ff-only")
    return git("rev-parse", "HEAD")


def changed_since(commit):
    """(status, path) for lesson files and the year plan changed after `commit`."""
    paths = [LESSONS, PLAN]
    if commit is None:
        out = git("ls-files", *paths)
        return [("A", p) for p in out.splitlines() if p]
    out = git("diff", "--name-status", f"{commit}..HEAD", "--", *paths)
    return [tuple(line.split("\t", 1)) for line in out.splitlines() if line]


def extract_pptx(path):
    from pptx import Presentation

    lines = [f"# {path.stem}", ""]
    for i, slide in enumerate(Presentation(str(path)).slides, 1):
        lines.append(f"## Slide {i}")
        for shape in slide.shapes:
            if shape.has_text_frame:
                text = "\n".join(p.text for p in shape.text_frame.paragraphs if p.text.strip())
                if text:
                    lines.append(text)
            if getattr(shape, "has_table", False) and shape.has_table:
                for row in shape.table.rows:
                    lines.append(" | ".join(c.text.strip() for c in row.cells))
        if slide.has_notes_slide:
            notes = slide.notes_slide.notes_text_frame.text.strip()
            if notes:
                lines.append(f"> Notes: {notes}")
        lines.append("")
    return "\n".join(lines)


def extract_pdf(path):
    return subprocess.run(["pdftotext", "-layout", str(path), "-"], check=True, capture_output=True, text=True).stdout


def extract(rel_path):
    src = CLONE / rel_path
    EXTRACTED.mkdir(parents=True, exist_ok=True)
    if src.suffix == ".pptx":
        text = extract_pptx(src)
    elif src.suffix == ".pdf":
        text = extract_pdf(src)
    else:
        return None
    out = EXTRACTED / f"{src.stem}.md"
    out.write_text(text)
    return out.relative_to(ROOT)


def lesson_id(rel_path):
    """'hepatology/02-07_Metabolic_citrin.pptx' -> (2, 7, 'Metabolic citrin')."""
    stem = Path(rel_path).stem.removesuffix("_audio")
    prefix, _, topic = stem.partition("_")
    block, _, day = prefix.partition("-")
    return int(block), int(day), topic.replace("_", " ")


def lesson_dates():
    """{(block, day): 'YYYY-MM-DD'} — the date each lesson first appeared in the lessons repo."""
    out = git("log", "--diff-filter=A", "--no-renames", "--reverse", "--name-only", "--format=@%cs", "--", LESSONS)
    dates, current = {}, None
    for line in out.splitlines():
        if line.startswith("@"):
            current = line[1:]
        elif (line.startswith(LESSONS + "/") and re.match(r"\d{2}-\d{2}_", Path(line).name)
              and (CLONE / line).exists()):
            block, day, _ = lesson_id(line)
            dates.setdefault((block, day), current)
    return dates


def write_plan(plan):
    """plan.json in its hand-kept layout: one line per block header, one per day."""
    def compact(obj):
        return json.dumps(obj, ensure_ascii=False, separators=(", ", ": "))
    blocks = []
    for b in plan:
        head = compact({k: v for k, v in b.items() if k != "days"})[:-1] + ', "days": ['
        days = ",\n".join("    " + compact(d) for d in b["days"])
        blocks.append(f"  {head}\n{days}\n  ]}}")
    PLAN_JSON.write_text("[\n" + ",\n".join(blocks) + "\n]\n", encoding="utf-8")


def stamp_plan():
    """Record on each plan.json day whether (and when) its lesson has arrived; the Study tab shows it."""
    if not CLONE.exists():
        sys.exit(f"No lessons clone at {CLONE} — run python3 tools/sync_sources.py first.")
    dates = lesson_dates()
    plan = json.loads(PLAN_JSON.read_text(encoding="utf-8"))
    stamped = 0
    for b in plan:
        for d in b["days"]:
            arrived = dates.get((b["block"], d["day"]))
            d.pop("lesson", None)
            if arrived:
                d["lesson"] = arrived
                stamped += 1
    write_plan(plan)
    print(f"plan.json: {stamped} lesson day(s) marked as arrived.")


def main(argv):
    state = load_state()

    if "--done" in argv:
        stamp_plan()
        state["last_commit"] = git("rev-parse", "HEAD")
        state["last_sync"] = date.today().isoformat()
        STATE.write_text(json.dumps(state, indent=2) + "\n")
        print(f"Recorded lessons commit {state['last_commit'][:7]} as processed ({state['last_sync']}).")
        return

    if "--plan" in argv:
        stamp_plan()
        return

    if "--extract" in argv:
        if not CLONE.exists():
            pull()
        prefixes = argv[argv.index("--extract") + 1:]
        files = sorted(p for p in (CLONE / LESSONS).iterdir() if any(p.name.startswith(x) for x in prefixes))
        for f in files:
            print(extract(f.relative_to(CLONE)))
        if not files:
            print("No lessons match", prefixes)
        return

    head = pull()
    changes = changed_since(state["last_commit"])
    print(f"Lessons repo HEAD: {head[:7]} · last processed: {(state['last_commit'] or 'never')[:7]} on {state['last_sync']}")
    if not changes:
        print("NO NEW MATERIAL — nothing to sync today.")
        return

    plan_changed = any(p == PLAN for _, p in changes)
    lessons = {}
    for status, path in changes:
        if path.startswith(LESSONS + "/") and status != "D":
            lessons.setdefault(lesson_id(path), []).append(extract(path))
    for (block, day, topic), outs in sorted(lessons.items()):
        print(f"NEW/CHANGED  block {block} day {day}: {topic}")
        for out in outs:
            print(f"    {out}")
    for status, path in changes:
        if status == "D":
            print(f"DELETED  {path}")
    if plan_changed:
        print(f"YEAR PLAN CHANGED: {PLAN} — update Content/Registry/plan.json (if it exists yet).")
    print("After integrating, run: python3 tools/sync_sources.py --done")


if __name__ == "__main__":
    main(sys.argv[1:])
