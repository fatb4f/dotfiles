#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
github_dir="$repo_root/.github"
contracts_dir="$github_dir/contracts"
schema_file="$contracts_dir/lazyvim_project_delta.cue"

command -v cue >/dev/null 2>&1 || {
	echo "required command unavailable: cue" >&2
	exit 1
}

(
	cd "$github_dir"
	cue vet ./contracts
	cue export ./contracts -e _lazyVimProjectDeltaSchemaWitness --out json >/dev/null
)

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/cue.mod"
cat >"$work/cue.mod/module.cue" <<'CUE'
module: "example.com/lazyvim-project-delta-test"
language: version: "v0.17.0"
CUE
cp "$schema_file" "$work/lazyvim_project_delta.cue"
cat >"$work/primitives.cue" <<'CUE'
package impl

#NonEmptyString: string & !=""
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]
CUE

run_case() {
	local name=$1 expected=$2 body=$3 status
	cat >"$work/case.cue" <<CUE
package impl

case: #LazyVimProjectDelta & $body
CUE
	if (cd "$work" && cue export . -e case --out json) >"$work/$name.out" 2>"$work/$name.err"; then
		status=pass
	else
		status=fail
	fi
	if [[ "$status" != "$expected" ]]; then
		echo "$name: expected $expected, observed $status" >&2
		cat "$work/$name.err" >&2
		exit 1
	fi
	printf '%-34s %s\n' "$name" "$status"
}

run_case minimal-valid pass \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test"}'
run_case valid-command-inventory pass \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", overrides: lsp: gopls: command: ["gopls"], requiredExecutables: ["gopls"]}'
run_case empty-plugin-key fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "": {}}'
run_case malformed-plugin-key fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "bad key": {}}'
run_case malformed-lsp-key fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", overrides: lsp: "bad key": {}}'
run_case empty-filetype-key fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", overrides: formatters: "": {names: ["ruff_format"]}}'
run_case absolute-executable fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", requiredExecutables: ["/usr/bin/cue"]}'
run_case dot-executable fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", requiredExecutables: ["."]}'
run_case option-executable fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", requiredExecutables: ["-x"]}'
run_case undeclared-command fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", overrides: lsp: gopls: command: ["gopls"]}'
run_case duplicate-inventory fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", requiredExecutables: ["cue", "cue"]}'
run_case oversized-integer fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "owner/repo": opts: value: 9007199254740992}'
run_case fractional-number fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "owner/repo": opts: value: 0.5}'
run_case null-value fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "owner/repo": opts: value: null}'
run_case malformed-option-path fail \
	'{apiVersion: "term.fatb4f.dev/lazyvim-delta/v1", project: "test", pluginPatches: "owner/repo": optsExtend: ["a..b"]}'
