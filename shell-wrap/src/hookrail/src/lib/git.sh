# shellcheck shell=bash

hookrail_enrich_input() {
  local input_file output_file event_name facts_file hints_file validation_file
  local cwd commit_before_summary user_opted_out evidence_exists trace_head_changed feed_sentinel

  input_file="${1:?input JSON path required}"
  output_file="${2:?output JSON path required}"

  event_name="$(jq -r '.hook_event_name // ""' "$input_file")"
  case "$event_name" in
    SessionStart|UserPromptSubmit|PostToolUse|Stop) ;;
    *)
      cp "$input_file" "$output_file"
      return 0
      ;;
  esac

  cwd="$(jq -r '.cwd // "."' "$input_file")"

  facts_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-git-facts.XXXXXX.json")"
  hints_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-repo-hints.XXXXXX.json")"
  validation_file="$(mktemp "${TMPDIR:-/tmp}/hookrail-validation.XXXXXX.json")"

  if ! hookrail_git_facts "$cwd" >"$facts_file"; then
    rm -f "$facts_file" "$hints_file" "$validation_file"
    return 1
  fi
  if ! hookrail_repo_hints "$cwd" "$facts_file" >"$hints_file"; then
    rm -f "$facts_file" "$hints_file" "$validation_file"
    return 1
  fi
  hookrail_validation_statuses "$facts_file" >"$validation_file"

  commit_before_summary="$(hookrail_commit_before_summary_enabled)"
  user_opted_out="$(hookrail_user_opted_out_of_commit "$input_file")"
  evidence_exists="$(hookrail_closeout_evidence_exists "$input_file" "$facts_file")"
  trace_head_changed="$(hookrail_prior_trace_head_changed "$input_file" "$facts_file")"
  case "$event_name" in
    SessionStart)
      feed_sentinel="${HOOKRAIL_SESSION_START_FEED_SENTINEL:-${HOOKRAIL_FEED_SENTINEL:-}}"
      ;;
    UserPromptSubmit)
      feed_sentinel="${HOOKRAIL_USER_PROMPT_FEED_SENTINEL:-${HOOKRAIL_FEED_SENTINEL:-}}"
      ;;
    PostToolUse)
      feed_sentinel="${HOOKRAIL_POST_TOOL_FEED_SENTINEL:-${HOOKRAIL_FEED_SENTINEL:-}}"
      ;;
    *)
      feed_sentinel="${HOOKRAIL_FEED_SENTINEL:-}"
      ;;
  esac

  jq -c \
    --arg commitBeforeSummary "$commit_before_summary" \
    --arg userOptedOut "$user_opted_out" \
    --arg evidenceExists "$evidence_exists" \
    --arg traceHeadChanged "$trace_head_changed" \
    --arg feedSentinel "$feed_sentinel" \
    --slurpfile gitFacts "$facts_file" \
    --slurpfile repoHints "$hints_file" \
    --slurpfile validation "$validation_file" '
    .hookrail = (.hookrail // {})
    | .hookrail.gitFacts = $gitFacts[0]
    | .hookrail.repoHints = $repoHints[0]
    | .hookrail.validation = $validation[0]
    | .hookrail.git = {
        isRepo: ($gitFacts[0].isRepo // false),
        dirty: (if ($gitFacts[0].isRepo // false) then (if (($gitFacts[0] | has("clean")) and ($gitFacts[0].clean == false)) then true else false end) else false end),
        head: ($gitFacts[0].head // null),
        root: ($gitFacts[0].root // null),
        branch: ($gitFacts[0].branch // null),
        statusSummary: ($gitFacts[0].statusSummary // null)
      }
    | .hookrail.closeout = {
        evidenceExists: ($evidenceExists == "true"),
        priorTraceHeadChanged: ($traceHeadChanged == "true")
      }
    | .hookrail.env = ((.hookrail.env // {}) + {
        commitBeforeSummary: ($commitBeforeSummary == "true"),
        userOptedOut: ($userOptedOut == "true")
      })
    | .hookrail.feedSentinel = (if $feedSentinel == "" then null else $feedSentinel end)
  ' "$input_file" >"$output_file"
  rm -f "$facts_file" "$hints_file" "$validation_file"
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
      | ($rows | map(select(.code != "??" and .index != " "))) as $stagedRows
      | ($rows | map(select(.code != "??" and .worktree != " "))) as $unstagedRows
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
            staged: ($stagedRows | length),
            unstaged: ($unstagedRows | length),
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
          },
          statusSummary: (
            if (($changed | length) + ($untracked | length)) == 0 then
              "clean working tree"
            else
              "\($stagedRows | length) staged, \($unstagedRows | length) unstaged, \($untracked | length) untracked"
            end
          )
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

hookrail_validation_statuses() {
  local facts_file

  facts_file="${1:?git facts JSON path required}"
  jq -n --slurpfile gitFacts "$facts_file" '
    ($gitFacts[0]) as $git
    | {
        statuses: [
          {
            name: "gitFacts",
            status: (if ($git.isRepo // false) and ($git.unsafeRoot // false) then "red" else "green" end),
            detail: (if ($git.isRepo // false) then "captured" else "cwd is not a git repository" end)
          },
          {
            name: "dirtyState",
            status: (if ($git.isRepo // false) then (if (($git | has("clean")) and ($git.clean == false)) then "red" else "green" end) else "unknown" end),
            detail: (if ($git.isRepo // false) then "from git status --porcelain=v1" else "not applicable" end)
          }
        ]
      }
  '
}

hookrail_commit_before_summary_enabled() {
  local raw_env policy_path

  raw_env="${HOOKRAIL_COMMIT_BEFORE_SUMMARY:-}"
  if [[ -n "$raw_env" ]]; then
    case "${raw_env,,}" in
      0|false|no|off) printf 'false\n' ;;
      *) printf 'true\n' ;;
    esac
    return 0
  fi

  policy_path="$(hookrail_state_dir)/policy.json"
  if [[ -f "$policy_path" ]]; then
    jq -r 'if (has("commitBeforeSummary") and (.commitBeforeSummary == false)) then "false" else "true" end' "$policy_path" 2>/dev/null || {
      printf 'true\n'
    }
    return 0
  fi

  printf 'true\n'
}

hookrail_user_opted_out_of_commit() {
  local input_file

  input_file="${1:?input JSON path required}"
  jq -r 'if (.commit_before_summary == false or .commitBeforeSummary == false) then "true" else "false" end' "$input_file"
}

hookrail_turn_dir_from_input() {
  local input_file state_dir session_id turn_id safe_session safe_turn

  input_file="${1:?input JSON path required}"
  state_dir="$(hookrail_state_dir)"
  session_id="$(jq -r '.session_id // "unknown-session"' "$input_file")"
  turn_id="$(jq -r '.turn_id // "session"' "$input_file")"
  safe_session="$(hookrail_safe_component "$session_id")"
  safe_turn="$(hookrail_safe_component "$turn_id")"
  printf '%s/runs/%s/%s\n' "$state_dir" "$safe_session" "$safe_turn"
}

hookrail_closeout_evidence_exists() {
  local input_file facts_file turn_dir head

  input_file="${1:?input JSON path required}"
  facts_file="${2:?git facts JSON path required}"
  turn_dir="$(hookrail_turn_dir_from_input "$input_file")"
  [[ -f "$turn_dir/git-closeout.json" ]] && {
    printf 'true\n'
    return 0
  }

  head="$(jq -r '.head // empty' "$facts_file")"
  if [[ -n "$head" ]] && [[ "$(hookrail_prior_trace_head_changed "$input_file" "$facts_file")" == "true" ]]; then
    printf 'true\n'
    return 0
  fi

  printf 'false\n'
}

hookrail_prior_trace_head_changed() {
  local input_file facts_file state_dir session_id safe_session trace_file cwd turn_id head

  input_file="${1:?input JSON path required}"
  facts_file="${2:?git facts JSON path required}"
  head="$(jq -r '.head // empty' "$facts_file")"
  [[ -n "$head" ]] || {
    printf 'false\n'
    return 0
  }

  state_dir="$(hookrail_state_dir)"
  session_id="$(jq -r '.session_id // "unknown-session"' "$input_file")"
  safe_session="$(hookrail_safe_component "$session_id")"
  trace_file="$state_dir/trace/$safe_session.jsonl"
  [[ -f "$trace_file" ]] || {
    printf 'false\n'
    return 0
  }

  cwd="$(jq -r '.cwd // ""' "$input_file")"
  turn_id="$(jq -r '.turn_id // "session"' "$input_file")"
  jq -e --arg cwd "$cwd" --arg turnID "$turn_id" --arg head "$head" '
    select((.cwd // "") == $cwd)
    | select((.turnID // "session") == $turnID or (.turnID // "session") == "session")
    | select((.git.head // null) != null and (.git.head // null) != $head)
  ' "$trace_file" >/dev/null 2>&1 && printf 'true\n' || printf 'false\n'
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
