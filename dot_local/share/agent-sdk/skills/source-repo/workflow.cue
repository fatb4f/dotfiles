package skill

workflow: {
	id: "source-repo"

	contract: {
		role: "Bounded source repository search, semantic diffing, and evidence gathering workflow."
		invariants: [
			"Prefer narrow repository-scoped evidence before broad file reads.",
			"Do not crawl $HOME or unrelated repositories.",
			"Stop searching once enough evidence exists for the current slice.",
			"Use semantic context when text search is insufficient.",
		]
	}

	topics: {
		bounded_search: {
			description: "Find exact text, files, commands, and configuration surfaces in a repository."
			triggers: [
				"repo-rg",
				"ripgrep",
				"find usages",
				"search repository",
			]
			references: [
				"references/upstream/ripgrep/README.md",
				"references/upstream/ripgrep/GUIDE.md",
				"references/upstream/ripgrep/FAQ.md",
			]
			sequence: [
				"identify repository root",
				"choose bounded include/exclude patterns",
				"search exact symbols, file names, or command strings",
				"open only the smallest relevant file set",
				"report evidence paths and remaining unknowns",
			]
			evidence: [
				"repo root identified",
				"search surface bounded",
				"evidence files listed",
			]
		}

		semantic_diff: {
			description: "Use sem for semantic diffs, entity context, impact checks, and review evidence."
			triggers: [
				"sem diff",
				"semantic diff",
				"blast radius",
				"impact analysis",
				"symbol context",
			]
			references: [
				"references/upstream/sem/README.md",
				"references/upstream/sem/docs/llms.txt",
				"references/upstream/sem/docs/agents.html",
				"references/upstream/sem/docs/details.html",
			]
			sequence: [
				"inspect the current diff or target range",
				"extract semantic context for changed entities",
				"check impact and related files",
				"summarize semantic evidence before editing further",
			]
			evidence: [
				"semantic diff or equivalent context captured",
				"impacted files/entities listed",
			]
		}
	}

	unison: {
		search_then_semantic_review: {
			description: "Combine bounded textual search with semantic repository inspection."
			topics: ["bounded_search", "semantic_diff"]
			sequence: [
				"use bounded search to locate the relevant surface",
				"use semantic diff/context for change impact",
				"report evidence and remaining unknowns",
			]
		}
	}

	report: {
		fields: [
			"repo_root",
			"search_surface",
			"evidence",
			"semantic_context",
			"remaining_unknowns",
		]
	}
}
