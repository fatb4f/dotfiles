package skill

skill: {
	id: "bashly"
	required_tools: ["bashly"]
	optional_tools: ["ruby", "argc", "bash-ast", "tree-sitter", "sem"]
	phases: ["inspect", "edit_source", "generate", "report"]
	gate_contribution: {
		blocks_on: ["bashly_generate_failed", "generated_bash_edited"]
	}
}
