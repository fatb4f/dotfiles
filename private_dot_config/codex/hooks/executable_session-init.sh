#!/usr/bin/env sh
# generated Codex SessionStart hook
# shellcheck shell=sh
set -eu

input="$(cat)"

: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${CODEX_HOME:=$XDG_CONFIG_HOME/codex}"

export XDG_STATE_HOME XDG_CONFIG_HOME CODEX_HOME CODEX_HOOK_INPUT="$input"

if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' '{"continue":true}'
  exit 0
fi

python3 - <<'PY'
import json
import os
import re
import subprocess
import time
from pathlib import Path

raw = os.environ.get("CODEX_HOOK_INPUT", "")
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

sid = event.get("session_id") or ""
source = event.get("source") or ""
model = event.get("model") or ""
cwd = event.get("cwd") or os.getcwd()

xdg_state = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")))
state_dir = xdg_state / "_404" / "codex"
state_dir.mkdir(parents=True, exist_ok=True)

def run_git(args, repo_cwd):
    try:
        out = subprocess.check_output(
            ["git", "-C", repo_cwd, *args],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return out.strip()
    except Exception:
        return ""

repo_root = run_git(["rev-parse", "--show-toplevel"], cwd)
if not repo_root:
    msg = (
        f"No git root detected for cwd `{cwd}`. "
        "Start Codex from a specific repository/subtree. "
        "Do not crawl from `$HOME` to infer context."
    )
    print(json.dumps({
        "continue": True,
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": msg,
        },
    }))
    raise SystemExit(0)

repo = Path(repo_root)
frames_dir = repo / ".codex" / "frames"
frames_dir.mkdir(parents=True, exist_ok=True)

session_frame = frames_dir / "session-frame.md"
session_log = state_dir / "session-init.jsonl"
pre_log = state_dir / "pre-tool-use.jsonl"
post_log = state_dir / "post-tool-use.jsonl"

def mask_remote(url: str) -> str:
    return re.sub(r"(https?://)([^/@:]+)(:[^/@]+)?@", r"\1***@", url)

def lines(text: str, limit: int):
    return [line for line in text.splitlines() if line.strip()][:limit]

def read_jsonl(path: Path):
    if not path.exists():
        return []
    rows = []
    with path.open("r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            try:
                rows.append(json.loads(line))
            except Exception:
                continue
    return rows

branch = run_git(["branch", "--show-current"], repo_root) or "detached-or-unknown"
head = run_git(["rev-parse", "--short", "HEAD"], repo_root) or "unknown"
upstream = run_git(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], repo_root) or "none"
status = run_git(["status", "--short"], repo_root)

remotes_raw = run_git(["remote", "-v"], repo_root)
remotes = []
seen_remotes = set()
for line in remotes_raw.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[2] == "(fetch)":
        item = f"- `{parts[0]}` {mask_remote(parts[1])}"
        if item not in seen_remotes:
            remotes.append(item)
            seen_remotes.add(item)

branches_raw = run_git([
    "for-each-ref",
    "--sort=-committerdate",
    "--format=%(refname:short) %(committerdate:short) %(subject)",
    "refs/heads",
    "refs/remotes",
], repo_root)

commits_raw = run_git([
    "log",
    "--date=short",
    "--pretty=format:%h %ad %s",
    "-n",
    "16",
], repo_root)

previous_sid = ""
session_rows = [row for row in read_jsonl(session_log) if row.get("event") == "SessionStart"]
for row in session_rows:
    row_sid = row.get("session_id") or ""
    if row_sid and row_sid != sid:
        previous_sid = row_sid

pre_rows = [r for r in read_jsonl(pre_log) if r.get("session_id") == previous_sid][-24:]
post_rows = [r for r in read_jsonl(post_log) if r.get("session_id") == previous_sid][-24:]

def md_command(cmd: str, limit=220):
    cmd = (cmd or "").replace("`", "\\`").replace("\n", " ")
    return cmd[:limit]

parts = [
    "# Codex session frame",
    "",
    "## Startup",
    "",
    f"- session: `{sid or 'unknown'}`",
    f"- source: `{source or 'unknown'}`",
    f"- model: `{model or 'unknown'}`",
    f"- cwd: `{cwd}`",
    f"- repo: `{repo_root}`",
    "",
    "## Git state",
    "",
    f"- branch: `{branch}`",
    f"- head: `{head}`",
    f"- upstream: `{upstream}`",
    "",
    "## Remotes",
    "",
]

parts += remotes[:12] if remotes else ["- none"]
parts += ["", "## Recent branches", ""]
parts += [f"- `{line}`" for line in lines(branches_raw, 20)] or ["- none"]
parts += ["", "## Recent commits", ""]
parts += [f"- `{line}`" for line in lines(commits_raw, 16)] or ["- none"]
parts += ["", "## Working tree", ""]
parts += [f"- `{line}`" for line in lines(status, 80)] if status else ["- clean: true"]
parts += ["", "## Previous session history", ""]

if previous_sid:
    parts += [f"- previous session: `{previous_sid}`", "", "### Previous Bash decisions", ""]
    parts += [
        f"- [{r.get('decision') or 'unknown'}] `{md_command(r.get('command'))}`"
        for r in pre_rows
    ] or ["- none"]
    parts += ["", "### Previous tool results", ""]
    parts += [
        f"- {r.get('tool_name') or 'tool'}: {r.get('response_type') or 'unknown'}"
        + (f" — `{md_command(r.get('command'), 180)}`" if r.get("command") else "")
        for r in post_rows
    ] or ["- none"]
else:
    parts += ["- no previous session found"]

parts += [
    "",
    "## Operating rule",
    "",
    "- Use this frame before broad repo inspection.",
    "- Prefer git log, repo-frame, and context-frame over transcript resume.",
    "- Do not crawl from `$HOME`.",
    "- Ask for an exact slice if the next task is broad.",
]

session_frame.write_text("\n".join(parts) + "\n", encoding="utf-8")

with session_log.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps({
        "ts": int(time.time()),
        "event": "SessionStart",
        "session_id": sid,
        "source": source,
        "model": model,
        "cwd": cwd,
        "repo_root": repo_root,
        "frame": str(session_frame),
        "previous_session": previous_sid,
    }, sort_keys=True) + "\n")

excerpt = "\n".join(parts[:180])
ctx = (
    "Compact startup context loaded from `.codex/frames/session-frame.md`.\n"
    "Use it before repo-wide discovery. Do not resume old transcript unless explicitly requested.\n\n"
    + excerpt
)

print(json.dumps({
    "continue": True,
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": ctx,
    },
}))
PY
