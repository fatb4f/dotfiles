---
name: repo-search
description: Use repo-rg for targeted repository search before broad code inspection. Trigger for exact keyword lookup, bounded literal or regex search, and quick evidence gathering inside one git repository. Do not use for home-wide crawling or ad hoc find|grep chains when repo-rg is available.
---

# Repo Search Skill

Use this skill when targeted repository search is needed.

## Contract

Use `repo-rg` as the bounded search adapter.

Do not rediscover search tooling.
Do not use ad hoc `find | grep` chains unless `repo-rg` fails.
Do not search from `$HOME`.

## Tool

```sh
repo-rg KEYWORD [ROOT]
```

## Examples

```sh
repo-rg CODEX_PROFILE_FILES /home/x404/.local/share/_404/init
repo-rg codex_profile /home/x404/.local/share/_404/init
repo-rg "session-init.sh" /home/x404/.local/share/_404/init
repo-rg override.py /home/x404/.local/share/_404/init
```

## Modes

Literal search is the default:

```sh
repo-rg codex_profile init/src
```

Regex mode is explicit:

```sh
REPO_RG_MODE=regex repo-rg 'CODEX_.*FILES' init/src
```

Limit output for normal slices:

```sh
REPO_RG_MAX_RESULTS=80 repo-rg codex_profile init
```

## Search policy

Before searching:

1. Prefer the current git root.
2. Prefer the narrowest known subdirectory.
3. Use exact keywords.
4. Stop after relevant hits.
5. Read only the matching files required by the slice.

Forbidden:

* Do not search `$HOME`.
* Do not crawl unrelated repositories.
* Do not use broad searches like `repo-rg codex /`.
* Do not continue searching after enough evidence is found.

## Failure handling

If `repo-rg` fails because `rg` is unavailable, report that directly.

Expected `rg` location:

```txt
$HOME/.local/bin/rg
```

Fallback to PATH is allowed only if that file is missing and `repo-rg` has already checked the absolute path.

Do not claim `rg` is unavailable until `repo-rg` has failed.

## Recommended prompt behavior

When a task requires lookup, use:

```txt
I will use repo-rg with an exact keyword and narrow root, then inspect only the matching files needed for this slice.
```
