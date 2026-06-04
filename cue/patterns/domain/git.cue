package domain

import gitcontract "github.com/fatb4f/dotfiles/cue/contracts/git"

git: #EntityProjection & {
	id:   "git"
	area: "git"

	_contract: gitcontract.#GitContract

	surface: {
		summary: "git state, branch, and closeout surface"
		paths: [
			".",
		]
		commands: [
			"git status",
			"git diff",
			"git commit",
		]
	}
	scopes: {
		owned: [
			"repository state",
			"staging",
			"commit history",
		]
		adjacent: [
			"source-code",
			"cue",
			"chezmoi",
		]
		forbidden: [
			"workflow execution",
			"eval generation",
			"dotfile materialization",
		]
	}

	discovery: {
		referencePaths: [
			".git/",
			"cue/patterns/domain/git.cue",
			"cue/contracts/git/schema.cue",
			"cue/contracts/git/worktree.cue",
			"cue/contracts/git/patch_stack.cue",
			"cue/contracts/git/evidence.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]
		startPoints: [
			"git status",
			"git diff",
			"git commit",
		]
		suggestedLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/git.cue",
			"cue/contracts/git/schema.cue",
			"cue/contracts/git/worktree.cue",
			"cue/contracts/git/patch_stack.cue",
			"cue/contracts/git/evidence.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]
		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"dotfile materialization",
		]
		staleSignals: [
			"closeout is asking about workflow behavior instead of repo state",
			"repo state is being inferred from history instead of git output",
			"patch stack validity is inferred from final tree validation instead of ordered admissible transitions",
		]
	}

	knownGoodPatterns: [
		{
			id:      "git-state-is-observable"
			summary: "Git state is observed before any closeout decision."
		},
		{
			id:      "git-contract-types-state-evidence"
			summary: "Git facts unify with typed repository, worktree, patch-stack, and evidence contracts."
		},
	]

	knownFailures: [
		{
			id:        "git-owns-workflow-execution"
			symptom:   "Git starts to encode workflow behavior."
			avoidance: "Keep git as repository-state authority only."
		},
		{
			id:        "final-tree-only-patch-stack"
			symptom:   "A patch stack is treated as valid because the final tree validates."
			avoidance: "Require each patch to be an admissible ordered state transition with evidence."
		},
	]

	invariants: [
		{
			id:       "git-state-is-local-authority"
			mustHold: "Git owns repository state, staging, and commit history."
		},
		{
			id:       "git-is-evidence-rail-not-workflow-authority"
			mustHold: "Git is the temporal state/evidence rail and must not own workflow execution."
		},
		{
			id:       "linked-worktrees-use-git-file"
			mustHold: ".git directories and .git files are both valid repository admission signals."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "git-surface-export"
			requiredBefore: "review"
			proof:          "The git domain card exports successfully."
		},
		{
			id:             "git-contract-vet"
			requiredBefore: "gate"
			proof:          "cue vet ./cue/contracts/git/... passes."
		},
	]

	proofs: {
		commands: [
			"git status --short",
			"git diff --staged",
			"git diff",
			"cue vet ./cue/contracts/git/...",
		]
		artifacts: [
			"git status output",
			"staged diff",
			"commit SHA",
			"typed git contract fixture",
		]
	}
}
