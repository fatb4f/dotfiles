#!/usr/bin/env bash

set -euo pipefail

sid=${1:?usage: review-surface-collect.sh <codex-session-id> <git-commit> [output-dir]}
commit=${2:?usage: review-surface-collect.sh <codex-session-id> <git-commit> [output-dir]}
out_dir=${3:-"$PWD/review-surface-${sid}-${commit:0:12}"}
codex_home=${CODEX_HOME:-$HOME/.local/share/codex}

repo_root=$(git rev-parse --show-toplevel)
short_commit=${commit:0:12}

mkdir -p \
  "$out_dir/codex" \
  "$out_dir/derived" \
  "$out_dir/git" \
  "$out_dir/hooks" \
  "$out_dir/objects"

capture_or_empty() {
  local out_file=$1
  shift
  if "$@" >"$out_file" 2>/dev/null; then
    return 0
  fi
  : >"$out_file"
}

capture_or_empty "$out_dir/git/repo-root.txt" git -C "$repo_root" rev-parse --show-toplevel
capture_or_empty "$out_dir/git/status.txt" git -C "$repo_root" status --short
capture_or_empty "$out_dir/git/commit-type.txt" git -C "$repo_root" cat-file -t "$commit"
capture_or_empty "$out_dir/git/commit-object.txt" git -C "$repo_root" cat-file -p "$commit"
capture_or_empty "$out_dir/git/show-full.txt" git -C "$repo_root" show --decorate --stat --summary --date=iso-strict --format=fuller "$commit"
capture_or_empty "$out_dir/git/name-status.txt" git -C "$repo_root" show --name-status --format=fuller "$commit"

if ! git -C "$repo_root" diff "$commit^!" >"$out_dir/git/patch.diff" 2>/dev/null; then
  capture_or_empty "$out_dir/git/patch.diff" git -C "$repo_root" show --format=medium --patch "$commit"
fi

capture_or_empty "$out_dir/git/tree.txt" git -C "$repo_root" ls-tree -r --full-tree "$commit"
capture_or_empty "$out_dir/git/commit-time.txt" git -C "$repo_root" show -s --format='%cI' "$commit"

relevant_paths_file="$out_dir/objects/relevant-paths-at-commit.txt"
capture_or_empty "$relevant_paths_file" git -C "$repo_root" ls-tree -r --name-only "$commit"
rg --hidden -F 'context-frame-input.json' "$relevant_paths_file" >"$out_dir/objects/relevant-paths-filtered.txt" 2>/dev/null || true
rg --hidden -F 'closeout-packet' "$relevant_paths_file" >>"$out_dir/objects/relevant-paths-filtered.txt" 2>/dev/null || true
sort -u "$out_dir/objects/relevant-paths-filtered.txt" -o "$relevant_paths_file"

: >"$out_dir/objects/relevant-path-history.txt"
: >"$out_dir/objects/relevant-files.txt"
while IFS= read -r path; do
  [ -n "$path" ] || continue
  mkdir -p "$out_dir/objects/$(dirname "$path")"
  capture_or_empty "$out_dir/objects/$path" git -C "$repo_root" show "$commit:$path"
  printf '%s\n' "$path" >>"$out_dir/objects/relevant-files.txt"
  {
    printf '===== %s =====\n' "$path"
    git -C "$repo_root" log --date=iso-strict --format=fuller -- "$path" 2>/dev/null || true
    printf '\n'
  } >>"$out_dir/objects/relevant-path-history.txt"
done <"$relevant_paths_file"

capture_or_empty "$out_dir/codex/session-id-matches.txt" rg -n --hidden -F "$sid" "$codex_home" "$repo_root"
capture_or_empty "$out_dir/codex/session-id-files.txt" rg -l --hidden -F "$sid" "$codex_home" "$repo_root"
capture_or_empty "$out_dir/codex/session-id-context-window.txt" rg -n --hidden -C 80 -F "$sid" "$codex_home" "$repo_root"

capture_or_empty "$out_dir/hooks/candidate-dirs.txt" find "$repo_root" "$codex_home" -type d \( -iname '*hook*' -o -iname '*trace*' -o -iname '*run*' -o -iname '*closeout*' -o -iname '*context*' \)
capture_or_empty "$out_dir/hooks/matches-session-id.txt" rg -n --hidden -F "$sid" "$repo_root" "$codex_home"
capture_or_empty "$out_dir/hooks/matches-full-commit.txt" rg -n --hidden -F "$commit" "$repo_root" "$codex_home"
capture_or_empty "$out_dir/hooks/matches-short-commit.txt" rg -n --hidden -F "$short_commit" "$repo_root" "$codex_home"
capture_or_empty "$out_dir/hooks/matches-artifact-names.txt" rg -n --hidden 'context-frame-input\.json|closeout-packet|hook|trace|manifest|run' "$repo_root" "$codex_home"
if find "$repo_root" "$codex_home" -type f \( -iname '*.json' -o -iname '*.jsonl' -o -iname '*.log' -o -iname '*.txt' \) -printf '%TY-%Tm-%TdT%TH:%TM:%TS %p\n' 2>/dev/null | sort >"$out_dir/hooks/mtime-listing.txt"; then
  :
else
  : >"$out_dir/hooks/mtime-listing.txt"
fi

relevant_paths_json=$(jq -R -s 'split("\n") | map(select(length > 0))' "$relevant_paths_file")
jq -n \
  --arg sid "$sid" \
  --arg commit "$commit" \
  --arg repo_root "$repo_root" \
  --arg codex_home "$codex_home" \
  --arg short_commit "$short_commit" \
  --argjson relevant_paths "$relevant_paths_json" \
  '{
    schema: "hookrail.review_surface.v1",
    codexSessionID: $sid,
    gitCommit: $commit,
    repoRoot: $repo_root,
    codexHome: $codex_home,
    joinOrder: [
      "commit hash",
      "file path",
      "timestamp proximity",
      "cwd",
      "generated artifact names"
    ],
    git: {
      repoRootPath: "git/repo-root.txt",
      statusPath: "git/status.txt",
      commitTypePath: "git/commit-type.txt",
      commitObjectPath: "git/commit-object.txt",
      showFullPath: "git/show-full.txt",
      nameStatusPath: "git/name-status.txt",
      patchPath: "git/patch.diff",
      treePath: "git/tree.txt",
      commitTimePath: "git/commit-time.txt",
      relevantPathsAtCommitPath: "objects/relevant-paths-at-commit.txt",
      relevantPathHistoryPath: "objects/relevant-path-history.txt"
    },
    codex: {
      sessionIdMatchesPath: "codex/session-id-matches.txt",
      sessionIdFilesPath: "codex/session-id-files.txt",
      sessionIdContextWindowPath: "codex/session-id-context-window.txt"
    },
    hooks: {
      candidateDirsPath: "hooks/candidate-dirs.txt",
      matchesSessionIDPath: "hooks/matches-session-id.txt",
      matchesFullCommitPath: "hooks/matches-full-commit.txt",
      matchesShortCommitPath: "hooks/matches-short-commit.txt",
      matchesArtifactNamesPath: "hooks/matches-artifact-names.txt",
      mtimeListingPath: "hooks/mtime-listing.txt"
    },
    objects: {
      relevantPathsAtCommit: $relevant_paths,
      relevantFiles: ($relevant_paths | map("objects/" + .))
    },
    derived: {
      bundleDir: ".",
      reviewSurfacePath: "review-surface.json",
      shortCommit: $short_commit,
      knownGap: "Hook artifacts do not need to store the Codex session id; join by commit hash, path, cwd, timestamps, and artifact names."
    }
  }' >"$out_dir/review-surface.json"
