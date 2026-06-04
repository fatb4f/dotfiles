package workflows

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

_sourceCodeCard: domain.sourceCode
_shellWrapCard:  domain.shellWrap
_cueCard:        domain.cue
_gitCard:        domain.git

generatedCliChange: #WorkflowPattern & {
	id:      "generated-cli-change"
	area:    "workflow"
	summary: "Generated CLI change workflow across source, shell-wrap, cue, and git"

	lifecycle: [
		"start",
		"review",
		"gate",
		"eval",
	]

	cards: {
		sourceCode: _sourceCodeCard
		shellWrap:  _shellWrapCard
		cue:        _cueCard
		git:        _gitCard
	}

	edges: [
		{
			id:      "source-code-to-shell-wrap"
			from:    "source-code"
			to:      "shell-wrap"
			summary: "source changes flow into shell-wrap adapters"
		},
		{
			id:      "shell-wrap-to-cue"
			from:    "shell-wrap"
			to:      "cue"
			summary: "shell-wrap keeps the slice CUE-authored"
		},
		{
			id:      "cue-to-git"
			from:    "cue"
			to:      "git"
			summary: "git owns staging and commit closeout"
		},
	]

	knownGoodPatterns: [
		{
			id:      "workflow-reuses-domain-cards"
			summary: "The workflow references domain cards instead of duplicating them."
		},
	]

	knownFailures: [
		{
			id:        "workflow-pulls-in-unrelated-domains"
			symptom:   "The workflow starts collecting unrelated cards."
			avoidance: "Keep the slice limited to the nodes actually involved."
		},
	]

	invariants: [
		{
			id:       "workflow-is-cross-domain-only"
			mustHold: "The workflow composes existing domain cards and does not execute them."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "workflow-export"
			requiredBefore: "review"
			proof:          "The generated CLI change workflow exports successfully."
			factRefs: [
				"fixture.fact_rooted_cue_flow_relation_slice_exports",
			]
		},
	]
}
