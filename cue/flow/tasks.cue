package flow

defaultTaskChain: #FlowContract & {
	objective: "assemble selected patterns into a vetted contract run"

	tasks: {
		objective: {
			id:        "objective"
			kind:      "resolve_patterns"
			dependsOn: []
			input:     {}
			runner:    "pure-cue"
			authority: "cue"
		}

		resolvePatterns: {
			id:        "resolve_patterns"
			kind:      "resolve_patterns"
			dependsOn: ["objective"]
			input:     {}
			runner:    "pure-cue"
			authority: "cue"
		}

		assemblePatternBundle: {
			id:        "assemble_pattern_bundle"
			kind:      "assemble_pattern_bundle"
			dependsOn: ["resolve_patterns"]
			input:     {}
			runner:    "cue-export"
			authority: "cue"
		}

		composeContract: {
			id:        "compose_contract"
			kind:      "compose_contract"
			dependsOn: ["assemble_pattern_bundle"]
			input:     {}
			runner:    "pure-cue"
			authority: "cue"
		}

		vetContract: {
			id:        "vet_contract"
			kind:      "vet_contract"
			dependsOn: ["compose_contract"]
			input:     {}
			runner:    "cue-vet"
			authority: "cue"
		}

		projectAgentContext: {
			id:        "project_agent_context"
			kind:      "project_agent_context"
			dependsOn: ["vet_contract"]
			input:     {}
			runner:    "cue-export"
			authority: "cue"
		}

		checkGitMutation: {
			id:        "check_git_mutation"
			kind:      "check_git_mutation"
			dependsOn: ["project_agent_context"]
			input:     {}
			runner:    "mcp-git"
			authority: "cue"
		}

		recordLifecycle: {
			id:        "record_lifecycle"
			kind:      "record_lifecycle"
			dependsOn: ["check_git_mutation"]
			input:     {}
			runner:    "pure-cue"
			authority: "cue"
		}
	}
}
