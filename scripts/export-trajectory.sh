#!/usr/bin/env bash
# Export an opencode session as JSONL for fine-tuning (SFT) datasets.
# Sessions live in ~/.local/share/opencode/opencode.db (tables: session, message, part).
#
# Usage:
#   export-trajectory.sh                 # list 15 most recent sessions
#   export-trajectory.sh <session-id> [outdir]   # export one session (default outdir: ./trajectories)
#
# Privacy: review the JSONL for secrets BEFORE training or sharing —
# transcripts contain everything typed, including any key that ever hit a prompt.
set -euo pipefail

DB="$HOME/.local/share/opencode/opencode.db"

list_sessions() {
  python3 - "$DB" <<'PY'
import sqlite3, sys, datetime
db = sqlite3.connect(sys.argv[1])
rows = db.execute("""
  SELECT id, time_created, title, model, tokens_input, tokens_output
  FROM session ORDER BY time_created DESC LIMIT 15""").fetchall()
for sid, ts, title, model, ti, to in rows:
    d = datetime.datetime.fromtimestamp(ts/1000).strftime('%Y-%m-%d %H:%M') if ts else '?'
    print(f"{sid}  {d}  in={ti or 0:>9}  out={to or 0:>8}  {(model or '?'):<28}  {(title or '')[:60]}")
PY
}

export_session() {
  local sid="$1" outdir="${2:-$PWD/trajectories}"
  mkdir -p "$outdir"
  python3 - "$DB" "$sid" "$outdir" <<'PY'
import sqlite3, sys, json, datetime, subprocess, os
db, sid, outdir = sqlite3.connect(sys.argv[1]), sys.argv[2], sys.argv[3]
s = db.execute("SELECT id, slug, title, model, directory, tokens_input, tokens_output, time_created FROM session WHERE id=? OR slug=?", (sid, sid)).fetchone()
if not s:
    sys.exit(f"no session matching '{sid}' — run with no args to list")
sid, slug, title, model, directory, ti, to, created = s
try:
    model_id = json.loads(model).get("id", model) if model and model.startswith("{") else (model or "?")
except Exception:
    model_id = model or "?"
date = datetime.datetime.fromtimestamp(created/1000).strftime('%Y-%m-%d') if created else 'undated'
safe = "".join(c if c.isalnum() or c in '-_' else '-' for c in (slug or title or 'session'))[:48]
path = os.path.join(outdir, f"{date}-{safe}.jsonl")
msgs = db.execute("SELECT id, time_created, data FROM message WHERE session_id=? ORDER BY time_created", (sid,)).fetchall()
n = 0
with open(path, "w") as f:
    for mid, ts, data in msgs:
        rec = {"message": json.loads(data), "parts": []}
        for (pdata,) in db.execute("SELECT data FROM part WHERE message_id=? ORDER BY time_created", (mid,)):
            rec["parts"].append(json.loads(pdata))
        f.write(json.dumps(rec, ensure_ascii=False) + "\n"); n += 1
manifest = os.path.join(outdir, "manifest.csv")
new = not os.path.exists(manifest)
with open(manifest, "a") as m:
    w = m.write if new else (lambda line: m.write(line))
    if new:
        m.write("file,session_id,title,model,tokens_in,tokens_out,created,directory\n")
    m.write(f'{os.path.basename(path)},{sid},"{(title or "")[:80]}","{model_id}",{ti or 0},{to or 0},{date},{directory or ""}\n')
print(f"exported {n} messages -> {path}")
print("REVIEW FOR SECRETS before training/sharing.")
PY
}

case "${1:-}" in
  ""|-l|--list) list_sessions ;;
  -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//' ;;
  *) export_session "$1" "${2:-}" ;;
esac
