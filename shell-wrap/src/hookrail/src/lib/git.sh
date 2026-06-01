# shellcheck shell=bash

hookrail_enrich_input() {
  local input_file output_file event_name facts_file hints_file

  input_file="${1:?input JSON path required}"
  output_file="${2:?output JSON path required}"

  event_name="$(jq -r '.hook_event_name // ""' "$input_file")"
  if [[ "$event_name" != "SessionStart" ]]; then
    cp "$input_file" "$output_file"
    return 0
  fi

  facts_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-git-facts.XXXXXX.json")"
  hints_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-repo-hints.XXXXXX.json")"

  if ! hookrail_git_facts "$(jq -r '.cwd // "."' "$input_file")" >"$facts_file"; then
    rm -f "$facts_file" "$hints_file"
    return 1
  fi
  if ! hookrail_repo_hints "$(jq -r '.cwd // "."' "$input_file")" "$facts_file" >"$hints_file"; then
    rm -f "$facts_file" "$hints_file"
    return 1
  fi

  jq -c --slurpfile gitFacts "$facts_file" --slurpfile repoHints "$hints_file" '
    .hookrail = (.hookrail // {})
    | .hookrail.gitFacts = $gitFacts[0]
    | .hookrail.repoHints = $repoHints[0]
  ' "$input_file" >"$output_file"
  rm -f "$facts_file" "$hints_file"
}

hookrail_git_facts() {
  local cwd helper

  cwd="${1:-.}"
  helper="${HOOKRAIL_GIT_FACTS_HELPER:-}"
  if [[ -n "$helper" ]]; then
    [[ -x "$helper" ]] || {
      printf 'hookrail: missing git facts helper: %s\n' "$helper" >&2
      return 127
    }
    "$helper" "$cwd"
    return $?
  fi

  hookrail_git_facts_builtin "$cwd"
}

hookrail_git_facts_builtin() {
  local cwd abs_cwd root home repo_name branch head upstream sample_limit
  local status_file op_file last_subject last_date last_author

  cwd="${1:-.}"
  sample_limit="${HOOKRAIL_GIT_SAMPLE_LIMIT:-20}"
  abs_cwd="$(cd "$cwd" 2>/dev/null && pwd -P)" || {
    jq -n --arg cwd "$cwd" '{isRepo: false, cwd: $cwd, unsafeRoot: false, error: "cwd-not-found"}'
    return 0
  }

  if ! git -C "$abs_cwd" rev-parse --show-toplevel >/dev/null 2>&1; then
    jq -n --arg cwd "$abs_cwd" '{isRepo: false, cwd: $cwd, unsafeRoot: false}'
    return 0
  fi

  root="$(git -C "$abs_cwd" rev-parse --show-toplevel)"
  home=""
  [[ -z "${HOME:-}" ]] || home="$(cd "$HOME" 2>/dev/null && pwd -P || true)"
  if [[ "$root" == "/" || ( -n "$home" && "$root" == "$home" ) ]]; then
    jq -n --arg cwd "$abs_cwd" --arg root "$root" '{isRepo: true, cwd: $cwd, root: $root, unsafeRoot: true}'
    return 2
  fi

  repo_name="${root##*/}"
  branch="$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  head="$(git -C "$root" rev-parse --short HEAD 2>/dev/null || true)"
  upstream="$(git -C "$root" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  last_subject="$(git -C "$root" log -1 --format=%s 2>/dev/null || true)"
  last_date="$(git -C "$root" log -1 --format=%cI 2>/dev/null || true)"
  last_author="$(git -C "$root" log -1 --format=%an 2>/dev/null || true)"

  status_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-git-status.XXXXXX.txt")"
  op_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-git-op.XXXXXX.json")"

  git -C "$root" -c core.quotePath=false status --porcelain=v1 >"$status_file"
  hookrail_git_operation_state "$root" >"$op_file"

  jq -n \
    --arg cwd "$abs_cwd" \
    --arg root "$root" \
    --arg name "$repo_name" \
    --arg branch "$branch" \
    --arg head "$head" \
    --arg upstream "$upstream" \
    --arg lastSubject "$last_subject" \
    --arg lastDate "$last_date" \
    --arg lastAuthor "$last_author" \
    --argjson sampleLimit "$sample_limit" \
    --rawfile status "$status_file" \
    --slurpfile operation "$op_file" '
      def rows:
        $status
        | split("\n")
        | map(select(length > 0))
        | map({
            code: .[0:2],
            path: (.[3:] | if contains(" -> ") then split(" -> ")[-1] else . end),
            index: .[0:1],
            worktree: .[1:2]
          });
      def status_name($code):
        if ($code | contains("A")) then "added"
        elif ($code | contains("M")) then "modified"
        elif ($code | contains("D")) then "deleted"
        elif ($code | contains("R")) then "renamed"
        else "unknown"
        end;
      rows as $rows
      | ($rows | map(select(.code != "??"))) as $changed
      | ($rows | map(select(.code == "??"))) as $untracked
      | {
          isRepo: true,
          cwd: $cwd,
          root: $root,
          name: $name,
          branch: (if $branch == "" then null else $branch end),
          head: (if $head == "" then null else $head end),
          upstream: (if $upstream == "" then null else $upstream end),
          unsafeRoot: false,
          clean: (($changed | length) == 0 and ($untracked | length) == 0),
          counts: {
            staged: ($rows | map(select(.code != "??" and .index != " ")) | length),
            unstaged: ($rows | map(select(.code != "??" and .worktree != " ")) | length),
            untracked: ($untracked | length)
          },
          changedSample: (
            ($changed + $untracked)[0:$sampleLimit]
            | map({
                path,
                status: (if .code == "??" then "untracked" else status_name(.code) end)
              })
          ),
          sampleLimit: $sampleLimit,
          truncated: (($changed | length) + ($untracked | length)) > $sampleLimit,
          operation: $operation[0],
          lastCommit: {
            subject: (if $lastSubject == "" then null else $lastSubject end),
            date: (if $lastDate == "" then null else $lastDate end),
            author: (if $lastAuthor == "" then null else $lastAuthor end)
          }
        }
    '
  rm -f "$status_file" "$op_file"
}

hookrail_git_operation_state() {
  local root git_dir state

  root="${1:?repo root required}"
  git_dir="$(git -C "$root" rev-parse --git-dir 2>/dev/null || true)"
  [[ "$git_dir" == /* ]] || git_dir="$root/$git_dir"
  state="normal"
  [[ -f "$git_dir/MERGE_HEAD" ]] && state="merge"
  [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]] && state="rebase"
  [[ -f "$git_dir/CHERRY_PICK_HEAD" ]] && state="cherry-pick"
  [[ -f "$git_dir/REVERT_HEAD" ]] && state="revert"
  [[ -f "$git_dir/BISECT_LOG" ]] && state="bisect"
  jq -n --arg state "$state" '{state: $state}'
}

hookrail_repo_hints() {
  local cwd facts_file root config_path agents_file packages_file

  cwd="${1:-.}"
  facts_file="${2:?git facts JSON path required}"
  root="$(jq -r 'if .isRepo == true and .unsafeRoot != true then .root else empty end' "$facts_file")"
  if [[ -z "$root" ]]; then
    jq -n '{agentsPath: null, codexConfigPath: null, packageFiles: []}'
    return 0
  fi

  agents_file="$(hookrail_nearest_file "$cwd" "$root" "AGENTS.md" || true)"
  config_path=""
  [[ -f "$root/.codex/config.toml" ]] && config_path="$root/.codex/config.toml"
  packages_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-package-files.XXXXXX.txt")"
  (
    cd "$root"
    for candidate in package.json pyproject.toml go.mod Cargo.toml flake.nix Makefile justfile; do
      [[ -e "$candidate" ]] && printf '%s\n' "$candidate"
    done
  ) >"$packages_file"

  jq -n \
    --arg agents "$agents_file" \
    --arg codex "$config_path" \
    --rawfile packages "$packages_file" '
      {
        agentsPath: (if $agents == "" then null else $agents end),
        codexConfigPath: (if $codex == "" then null else $codex end),
        packageFiles: ($packages | split("\n") | map(select(length > 0)))
      }
    '
  rm -f "$packages_file"
}

hookrail_nearest_file() {
  local cwd root name dir

  cwd="${1:-.}"
  root="${2:?repo root required}"
  name="${3:?file name required}"
  dir="$(cd "$cwd" 2>/dev/null && pwd -P)" || return 1
  while [[ "$dir" == "$root"* ]]; do
    if [[ -f "$dir/$name" ]]; then
      printf '%s\n' "$dir/$name"
      return 0
    fi
    [[ "$dir" != "$root" ]] || break
    dir="${dir%/*}"
  done
  return 1
}
