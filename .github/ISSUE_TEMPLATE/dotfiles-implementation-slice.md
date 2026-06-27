---
name: Dotfiles implementation slice
about: Compact bounded implementation contract for Codex.
title: "dotfiles: "
labels: dotfiles, contract
---

# Dotfiles Implementation Slice

Use the issue body as the compact implementation contract. Do not create an issue-local manifest or check package unless this issue explicitly asks for one.

```cue
issue: {
	id:    "dotfiles.<slice-id>"
	repo:  "fatb4f/dotfiles"
	title: "<issue title>"

	intent: "<one sentence describing the intended state transition>"

	authority: {
		owns: [
			"<owned surface>",
		]
		doesNotOwn: [
			"generated artifacts",
			"runtime state",
			"external workflow authority",
		]
	}

	targets: [
		"<repo path>",
	]

	implement: [
		"<required change>",
	]

	doNotImplement: [
		"<forbidden change>",
	]

	validation: commands: [
		"<command>",
	]

	acceptance: [
		"<observable completion condition>",
	]
}
```

## Workflow

1. Read this issue body.
2. Treat the issue body as the contract seed.
3. Apply bounded repo changes only under declared targets.
4. Keep generated/runtime artifacts as evidence only.
5. Run the declared validation commands.
6. Report summary, changed surfaces, validation, and remaining risks.

## Forbidden attractors

- issue-local manifest scaffolding by default
- issue-local check package scaffolding by default
- generated artifacts as authority
- runtime state as authority
- stringified CUE expressions as proof
- boolean invalidity flags
- alternate tracking surfaces
