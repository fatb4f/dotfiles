package skill

workflow: {
	id: "bashly"

	contract: {
		role: "Bashly source-edit workflow with integrated shell validation."
		invariants: [
			"Edit Bashly config and source scripts as the durable source of truth.",
			"Treat generated Bashly output as reproducible evidence, not as the durable patch target.",
			"Run validation in the declared order when local tooling is available.",
			"Report remaining failures instead of silently skipping validation.",
		]
	}

	topics: {
		source_edit: {
			description: "Inspect and edit Bashly config/source while preserving generated artifact boundaries."
			triggers: [
				"bashly.yml",
				"bashly.yaml",
				"src/*.sh",
				"bashly generate",
				"generated Bash CLI",
				"Bashly command",
				"Bashly configuration",
			]
			references: [
				"references/upstream/bashly/examples",
				"references/upstream/bashly-book/advanced",
				"references/upstream/bashly-book/configuration",
				"references/upstream/bashly-book/usage",
			]
			sequence: [
				"inspect Bashly config and source",
				"identify source scripts involved in the requested behavior",
				"edit Bashly config or src/*.sh only when needed",
				"treat generated Bashly output as disposable evidence",
				"do not manually patch generated Bashly output as the durable fix",
				"run the source validation sequence",
				"report changed source, local CI result, and remaining failures",
			]
			evidence: [
				"changed Bashly config/source identified",
				"generated output inspected only as evidence when relevant",
				"validation result reported",
			]
		}

		shell_validation: {
			description: "Normalize, format, and lint Bashly source shell files."
			triggers: [
				"shellharden",
				"shfmt",
				"shellcheck",
				"local CI",
				"validate Bashly source",
			]
			tools: [
				"shellharden",
				"shfmt",
				"shellcheck",
				"bashly",
			]
			references: [
				"references/upstream/shellharden",
				"references/upstream/shfmt",
				"references/upstream/shellcheck",
			]
			sequence: [
				"run shellharden when configured or available",
				"run shfmt",
				"run shellcheck on source shell files",
				"run bashly generate after source normalization",
				"capture the CI or local validation report",
			]
			evidence: [
				"shellharden completed or was explicitly unavailable",
				"shfmt completed or diff reported",
				"shellcheck source completed or findings triaged",
				"bashly generate completed or was explicitly not required",
				"CI report captured",
			]
			failure_recovery: {
				missing_tool: [
					"Report the missing shell validation tool as an environment dependency.",
					"Do not silently skip required validation.",
				]
				shellcheck_findings: [
					"Fix source scripts when findings are source-owned.",
					"Do not patch generated Bashly output as the durable fix.",
				]
				generated_drift: [
					"Regenerate with bashly generate.",
					"Compare generated output against the source/config diff.",
				]
			}
		}

		optional_tests: {
			description: "Use Bats or ShellSpec only when tests are explicitly in scope."
			activation: "explicit"
			tools: ["bats", "shellspec"]
			evidence: [
				"Bats or ShellSpec tests were run only when requested or task-scoped.",
			]
		}

		optional_analysis: {
			description: "Use argc, bash-ast, or structural parsing only when directly relevant."
			activation: "explicit"
			tools: ["argc", "bash-ast", "tree-sitter"]
			evidence: [
				"Optional analysis evidence was limited to the task-relevant surface.",
			]
		}
	}

	unison: {
		default_source_edit_validation: {
			description: "Default Bashly edit path with integrated shell validation."
			topics: ["source_edit", "shell_validation"]
			sequence: [
				"inspect",
				"edit_source",
				"shellharden",
				"shfmt",
				"shellcheck source",
				"bashly generate",
				"CI report",
			]
		}
	}

	report: {
		fields: [
			"skill_context",
			"project_root",
			"changed_source",
			"local_ci",
			"remaining_failures",
		]
	}
}
