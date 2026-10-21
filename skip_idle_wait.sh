#!/usr/bin/env bash
# Skip the 6-hour idle wait: mark every interactive session in the demo
# CODEX_HOME as last updated N hours ago (default 7), so the next startup's
# Phase 1 treats it as idle. Run it after you exit the Day 1 session.
# Usage: bash skip_idle_wait.sh [codex_home] [hours]
set -euo pipefail
home="${1:-${CODEX_HOME:-$HOME/.codex-memory-demo}}"
hours="${2:-7}"

if [ "$(cd "$home" && pwd)" = "$(cd "$HOME/.codex" 2>/dev/null && pwd)" ]; then
  echo "refusing to touch your own ~/.codex; point CODEX_HOME at the demo home" >&2
  exit 1
fi
if [ ! -f "$home/state_5.sqlite" ]; then
  echo "$home/state_5.sqlite not found; run Day 1 first" >&2
  exit 1
fi

python3 -I - "$home/state_5.sqlite" "$hours" <<'PY'
import os, sqlite3, sys, time
db, hours = sys.argv[1], float(sys.argv[2])
t = time.time() - hours * 3600
ms = int(t * 1000)
c = sqlite3.connect(db)
rows = c.execute(
    "SELECT id, rollout_path FROM threads WHERE source IN ('cli', 'vscode')"
).fetchall()
# Phase 1 compares threads.updated_at_ms with now - min_rollout_idle_hours
# (state/src/runtime/memories.rs). Some repair paths reset updated_at from the
# rollout file's mtime, so move that back too.
c.executemany(
    "UPDATE threads SET updated_at_ms = ?, recency_at_ms = ? WHERE id = ?",
    [(ms, ms, tid) for tid, _ in rows],
)
c.commit()
for tid, path in rows:
    if path and os.path.exists(path):
        os.utime(path, (t, t))
    print(f"{tid}  -> {time.strftime('%Y-%m-%d %H:%M', time.localtime(t))}")
print(f"backdated {len(rows)} session(s) by {hours:g} h")
PY
echo "next: start any codex session, keep it open 3-5 minutes, then check \$CODEX_HOME/memories/"
