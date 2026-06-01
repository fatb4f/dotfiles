# AGENTS Transcript

This file records the discovery steps and the reasoning behind the repository
root agent guide.

## Step 1: Locate existing agent guidance

- Command used: `rg --files -g 'AGENTS.md'`
- Result: a subtree-local agent file already exists at
  `chezmoi/dot_local/share/codex/AGENTS.md`.
- Reasoning: a root guide should not duplicate or contradict more specific
  guidance. The existing file was the first reference point for the repo's
  Codex workflow.

## Step 2: Read the local policy and adjacent docs

- Commands used:
  - `sed -n '1,220p' chezmoi/dot_local/share/codex/AGENTS.md`
  - `sed -n '1,220p' chezmoi/dot_local/share/codex/tools/hookrail/README.md`
  - `sed -n '1,220p' chezmoi/dot_local/share/codex/tools/hookrail/config/README.md`
  - `sed -n '1,220p' shell-wrap/src/session/system/tomat/README.md`
- Reasoning: these files describe the repo's existing operational boundaries,
  especially around hookrail and session tooling. The new root guide should
  align with those boundaries instead of introducing a generic policy.

## Step 3: Map the top-level repository shape

- Command used: `rg --files | awk -F/ '{print $1}' | sort -u`
- Result: the repository is primarily organized around `chezmoi/`,
  `shell-wrap/`, and `cue.mods/`.
- Reasoning: the root guide should name the real subsystems so future agents can
  orient quickly without scanning the tree again.

## Step 4: Inspect the file inventory for key touchpoints

- Command used: `rg --files -g 'chezmoi/**' -g 'shell-wrap/**' -g 'cue.mods/**'`
- Reasoning: this confirmed where hookrail policy, shell tooling, generated
  fixtures, and Codex assets live. That informed the "Tree Shape" and
  "Hookrail Notes" sections in the new `AGENTS.md`.

## Step 5: Write the root guidance

- Files added:
  - `AGENTS.md`
  - `AGENTS.transcript.md`
- Reasoning: the root guide provides repository-wide entry rules and the
  transcript preserves the discovery path so future work can reuse it without
  repeating the same search.
