#!/usr/bin/env bash
set -euo pipefail

expected_remote='https://github.com/kevs-mist/KTECH_PROJECT_004_DEMO.git'
root="$(git rev-parse --show-toplevel)"
cd "$root"

remote="$(git remote get-url origin)"
if [[ "${remote%/}" != "${expected_remote%/}" ]]; then
  printf 'origin must point to %s\n' "$expected_remote" >&2
  exit 1
fi

git_dir="$(git rev-parse --git-dir)"
state_file="$git_dir/push-next-state.json"
today="$(date +%F)"

next_branch="$(python3 - "$state_file" "$today" <<'PY'
import json
import os
import sys

state_path, today = sys.argv[1:]
plan = [
    ("ui", "main"),
    ("backend", "main"),
    ("ui-screens", "sub"),
    ("ui-components", "sub"),
    ("mock-api", "main"),
]
state = {"pushes": []}
if os.path.exists(state_path):
    with open(state_path, encoding="utf-8-sig") as state_file:
        state = json.load(state_file)

pushes = state.get("pushes", [])
pushed = {item["branch"] for item in pushes}
next_item = next(((branch, kind) for branch, kind in plan if branch not in pushed), None)
if next_item is None:
    print("All scheduled feature branches have been pushed.")
    sys.exit(3)

branch, kind = next_item
today_pushes = [item for item in pushes if item["date"] == today]
main_count = sum(item["kind"] == "main" for item in today_pushes)
sub_count = sum(item["kind"] == "sub" for item in today_pushes)
if kind == "main" and main_count >= 1:
    print("Daily limit reached: only one main-level feature branch may be pushed per day.", file=sys.stderr)
    sys.exit(4)
if kind == "sub" and sub_count >= 2:
    print("Daily limit reached: only two UI sub-branches may be pushed per day.", file=sys.stderr)
    sys.exit(4)
print(branch)
PY
)" || exit_code=$?

if [[ "${exit_code:-0}" == '3' ]]; then
  printf '%s\n' "$next_branch"
  exit 0
fi
if [[ "${exit_code:-0}" != '0' ]]; then
  exit "${exit_code:-1}"
fi

if ! git show-ref --verify --quiet "refs/heads/$next_branch"; then
  printf "Local branch '%s' does not exist. Create it from PUSH_PLAN.md first.\n" "$next_branch" >&2
  exit 1
fi

printf 'Pushing %s to origin on %s.\n' "$next_branch" "$today"
git push --set-upstream origin "$next_branch"

python3 - "$state_file" "$today" "$next_branch" <<'PY'
import json
import os
import sys

state_path, today, branch = sys.argv[1:]
kind = "sub" if branch in {"ui-screens", "ui-components"} else "main"
state = {"pushes": []}
if os.path.exists(state_path):
    with open(state_path, encoding="utf-8-sig") as state_file:
        state = json.load(state_file)
state.setdefault("pushes", []).append({"date": today, "branch": branch, "kind": kind})
with open(state_path, "w", encoding="utf-8") as state_file:
    json.dump(state, state_file, indent=2)
    state_file.write("\n")
PY
printf 'Recorded successful push in %s.\n' "$state_file"