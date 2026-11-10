#!/usr/bin/env python3
"""Full-text library: what the team needs, what the author has supplied, what has been read.

The repository is public, so copyrighted PDFs never enter git. They live only on the
author's Mac (library/inbox -> library/pdf). What the cloud run can use is the committed
note library/notes/<id>.md written from the PDF (facts with page/table references).

Lifecycle of a catalog entry (library/catalog.json):
  wanted    the team needs the full text and could not get it from open sources
  received  the PDF is on the author's Mac (library/pdf/<id>.pdf), note not written yet
  noted     library/notes/<id>.md exists; the cloud run can use it
  applied   the team has used the note in cards/registries (BACKLOG/DECISIONS updated)
  dropped   no longer needed (reason in "need")

Usage:
  python3 tools/library.py              # status (same as `status`)
  python3 tools/library.py ingest       # file PDFs from library/inbox/ (Mac only)
  python3 tools/library.py assign FILE ID   # file one inbox document under a catalog id
  python3 tools/library.py set ID STATUS    # move an entry to a new status (dates filled in)
  python3 tools/library.py oa-check     # ask Europe PMC whether wanted items became open access
  python3 tools/library.py render       # regenerate library/WANTED.md from the catalog
  python3 tools/library.py check        # consistency check (CI); fails if WANTED.md is stale
"""
import json
import re
import shutil
import subprocess
import sys
import urllib.parse
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "library"
CATALOG = LIB / "catalog.json"
WANTED = LIB / "WANTED.md"
INBOX = LIB / "inbox"
PDF_DIR = LIB / "pdf"
TEXT_DIR = LIB / "text"
NOTES = LIB / "notes"

STATUSES = ["wanted", "received", "noted", "applied", "dropped"]
DATE_FIELD = {"received": "received", "noted": "noted", "applied": "applied"}
PRIORITY_TITLE = {
    1: "Срочно (P1) — блокирует ближайшие задачи",
    2: "Нужно (P2) — проверка уже опубликованного или карточки ближайших блоков",
    3: "Желательно (P3) — уточнения и будущие карточки",
}
DOI_RE = re.compile(r"\b(10\.\d{4,9}/[^\s\"<>]+)", re.I)
FIELDS = ["id", "citation", "doi", "url", "priority", "status", "need", "for",
          "added", "received", "noted", "applied", "oa"]


def today():
    return date.today().isoformat()


def norm_doi(doi):
    doi = (doi or "").strip().lower()
    doi = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:\s*)", "", doi)
    return doi.rstrip(".,;)]")


def load():
    return json.loads(CATALOG.read_text(encoding="utf-8"))


def save(items):
    ordered = [{k: it.get(k) for k in FIELDS} for it in items]
    CATALOG.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def find(items, cid):
    for it in items:
        if it["id"] == cid:
            return it
    sys.exit(f"Unknown id: {cid}")


def link(it):
    if it.get("doi"):
        return f"[doi:{it['doi']}](https://doi.org/{it['doi']})"
    if it.get("url"):
        return f"[ссылка]({it['url']})"
    return "искать по названию"


# ---------- render ----------

def render_text(items):
    by = {s: [i for i in items if i["status"] == s] for s in STATUSES}
    wanted = sorted(by["wanted"], key=lambda i: (i["priority"], i["added"], i["id"]))
    counts = {p: sum(1 for i in wanted if i["priority"] == p) for p in (1, 2, 3)}
    out = [
        "# Нужные полные тексты",
        "",
        "> Файл генерируется командой `python3 tools/library.py render` из `library/catalog.json` — руками не править.",
        "> Как отдать документ — `library/README.md`. Коротко: положи PDF в `library/inbox/` (имя любое) и скажи Claude Code в проекте `/library`.",
        "",
        f"**Нужно:** {len(wanted)} (P1: {counts[1]}, P2: {counts[2]}, P3: {counts[3]}) · "
        f"**Получено, ждёт конспекта:** {len(by['received'])} · "
        f"**Конспект готов:** {len(by['noted'])} · **Учтено в приложении:** {len(by['applied'])}",
        "",
    ]
    for p in (1, 2, 3):
        rows = [i for i in wanted if i["priority"] == p]
        if not rows:
            continue
        out += [f"## {PRIORITY_TITLE[p]}", "", "| Документ | Где взять | Что нужно найти | Для чего |", "|---|---|---|---|"]
        for i in rows:
            need = i["need"].replace("|", "/").replace("\n", " ")
            used = ", ".join(f"`{x}`" for x in i.get("for") or [])
            oa = f" ({i['oa']})" if i.get("oa") else ""
            out.append(f"| **{i['citation']}** <br>`{i['id']}` | {link(i)}{oa} | {need} | {used} |")
        out.append("")
    for status, title in (("received", "Получено — Claude пишет конспект"),
                          ("noted", "Конспект готов — ждёт внесения в приложение"),
                          ("applied", "Учтено в приложении")):
        rows = by[status]
        if not rows:
            continue
        out += [f"## {title}", ""]
        for i in sorted(rows, key=lambda i: i["id"]):
            note = f" — [конспект](notes/{i['id']}.md)" if status in ("noted", "applied") else ""
            when = i.get(DATE_FIELD[status]) or ""
            out.append(f"- `{i['id']}` · {i['citation']}{note} · {when}")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def cmd_render(items):
    WANTED.write_text(render_text(items), encoding="utf-8")
    print(f"WANTED.md updated ({sum(1 for i in items if i['status'] == 'wanted')} wanted).")


# ---------- status ----------

def inbox_files():
    if not INBOX.exists():
        return []
    return sorted(p for p in INBOX.iterdir() if p.is_file() and not p.name.startswith("."))


def cmd_status(items):
    by = {s: [i for i in items if i["status"] == s] for s in STATUSES}
    print("LIBRARY STATUS")
    for s in STATUSES:
        print(f"  {s:9} {len(by[s])}")
    for p in (1, 2, 3):
        ids = [i["id"] for i in by["wanted"] if i["priority"] == p]
        if ids:
            print(f"  wanted P{p}: {', '.join(ids)}")
    if by["noted"]:
        print("NOTES READY TO APPLY (cloud team): " + ", ".join(i["id"] for i in by["noted"]))
    if by["received"]:
        print("RECEIVED, NOTE NOT WRITTEN (Mac only — needs the PDF): " + ", ".join(i["id"] for i in by["received"]))
    files = inbox_files()
    if files:
        print(f"INBOX: {len(files)} file(s) waiting — run `python3 tools/library.py ingest` on the Mac")
        for f in files:
            print(f"  - {f.name}")


# ---------- ingest ----------

def pdf_text(path, first=None):
    args = ["pdftotext", "-layout"]
    if first:
        args += ["-f", "1", "-l", str(first)]
    try:
        return subprocess.run(args + [str(path), "-"], check=True, capture_output=True, text=True).stdout
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"  ! pdftotext failed for {path.name}: {e}")
        return ""


def file_one(src, it):
    PDF_DIR.mkdir(parents=True, exist_ok=True)
    TEXT_DIR.mkdir(parents=True, exist_ok=True)
    dest = PDF_DIR / f"{it['id']}{src.suffix.lower()}"
    if dest.exists():
        dest = PDF_DIR / f"{it['id']}-{today()}{src.suffix.lower()}"
    shutil.move(str(src), dest)
    if dest.suffix == ".pdf":
        text = pdf_text(dest)
        (TEXT_DIR / f"{it['id']}.txt").write_text(text, encoding="utf-8")
        words = len(text.split())
        flag = "  ! almost no text — scanned PDF? OCR it before writing the note" if words < 300 else ""
        print(f"  -> {it['id']}: {dest.relative_to(ROOT)} ({words} words of text){flag}")
    else:
        print(f"  -> {it['id']}: {dest.relative_to(ROOT)} (not a PDF — read it directly)")
    if it["status"] in ("wanted", "dropped"):
        it["status"] = "received"
        it["received"] = today()


def cmd_ingest(items):
    files = inbox_files()
    if not files:
        print("Inbox is empty.")
        return
    by_doi = {norm_doi(i["doi"]): i for i in items if i.get("doi")}
    ids = sorted((i["id"] for i in items), key=len, reverse=True)
    unmatched = []
    for f in files:
        print(f"{f.name}")
        it = None
        stem = f.stem.lower()
        for cid in ids:
            if stem.startswith(cid.lower()):
                it = find(items, cid)
                break
        dois = []
        if it is None and f.suffix.lower() == ".pdf":
            head = pdf_text(f, first=3)
            dois = list(dict.fromkeys(norm_doi(d) for d in DOI_RE.findall(head)))
            for d in dois:
                if d in by_doi:
                    it = by_doi[d]
                    break
        if it:
            file_one(f, it)
        else:
            unmatched.append((f, dois))
            print(f"  ? not matched (DOIs on first pages: {', '.join(dois[:5]) or 'none'})")
    save(items)
    cmd_render(items)
    if unmatched:
        print("\nUNMATCHED — identify each file, add a catalog entry if needed, then "
              "`python3 tools/library.py assign <file> <id>`:")
        for f, _ in unmatched:
            print(f"  - {f.relative_to(ROOT)}")


def cmd_assign(items, file, cid):
    src = Path(file)
    if not src.is_absolute():
        src = (ROOT / file) if (ROOT / file).exists() else INBOX / file
    if not src.exists():
        sys.exit(f"No such file: {file}")
    file_one(src, find(items, cid))
    save(items)
    cmd_render(items)


def cmd_set(items, cid, status):
    if status not in STATUSES:
        sys.exit(f"Status must be one of {STATUSES}")
    it = find(items, cid)
    if status in ("noted", "applied") and not (NOTES / f"{cid}.md").exists():
        sys.exit(f"library/notes/{cid}.md does not exist — write the note first")
    it["status"] = status
    if status in DATE_FIELD:
        it[DATE_FIELD[status]] = it.get(DATE_FIELD[status]) or today()
    save(items)
    cmd_render(items)


# ---------- open-access check ----------

def cmd_oa_check(items):
    changed = False
    for it in items:
        if it["status"] != "wanted" or not it.get("doi"):
            continue
        q = urllib.parse.quote(f'DOI:"{it["doi"]}"')
        url = f"https://www.ebi.ac.uk/europepmc/webservices/rest/search?query={q}&format=json&resultType=lite"
        try:
            # curl, not urllib: python.org builds on macOS often lack root certificates
            raw = subprocess.run(["curl", "-sSf", "--max-time", "20", url],
                                 check=True, capture_output=True, text=True).stdout
            res = json.loads(raw).get("resultList", {}).get("result", [])
        except Exception as e:  # network problems must not break the daily run
            print(f"  {it['id']}: check failed ({e})")
            continue
        hit = res[0] if res else {}
        pmcid = hit.get("pmcid")
        free = hit.get("isOpenAccess") == "Y" or hit.get("inEPMC") == "Y"
        if pmcid and free:
            note = f"есть в PMC: {pmcid} — читать там"
            print(f"  {it['id']}: OPEN — https://europepmc.org/article/PMC/{pmcid}")
        else:
            note = f"Europe PMC {today()}: закрыт"
            print(f"  {it['id']}: closed")
        if it.get("oa") != note:
            it["oa"] = note
            changed = True
    if changed:
        save(items)
        cmd_render(items)


# ---------- check ----------

def cmd_check(items):
    errors = []
    seen = set()
    for it in items:
        cid = it.get("id", "")
        if not re.fullmatch(r"[a-z0-9_]+", cid):
            errors.append(f"bad id: {cid!r}")
        if cid in seen:
            errors.append(f"duplicate id: {cid}")
        seen.add(cid)
        if it.get("status") not in STATUSES:
            errors.append(f"{cid}: bad status {it.get('status')!r}")
        if it.get("priority") not in (1, 2, 3):
            errors.append(f"{cid}: priority must be 1, 2 or 3")
        for f in ("citation", "need", "added"):
            if not it.get(f):
                errors.append(f"{cid}: missing {f}")
        if it.get("status") in ("noted", "applied") and not (NOTES / f"{cid}.md").exists():
            errors.append(f"{cid}: status {it['status']} but library/notes/{cid}.md is missing")
    for note in NOTES.glob("*.md"):
        if note.stem not in seen:
            errors.append(f"note without catalog entry: {note.name}")
    if WANTED.read_text(encoding="utf-8") != render_text(items):
        errors.append("library/WANTED.md is stale — run `python3 tools/library.py render`")
    if errors:
        print("LIBRARY CHECK FAILED")
        for e in errors:
            print("  - " + e)
        sys.exit(1)
    print(f"LIBRARY OK ({len(items)} entries)")


def main(argv):
    items = load()
    cmd = argv[0] if argv else "status"
    if cmd == "status":
        cmd_status(items)
    elif cmd == "ingest":
        cmd_ingest(items)
    elif cmd == "assign" and len(argv) == 3:
        cmd_assign(items, argv[1], argv[2])
    elif cmd == "set" and len(argv) == 3:
        cmd_set(items, argv[1], argv[2])
    elif cmd == "oa-check":
        cmd_oa_check(items)
    elif cmd == "render":
        cmd_render(items)
    elif cmd == "check":
        cmd_check(items)
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
