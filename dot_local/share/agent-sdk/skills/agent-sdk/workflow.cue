package skill

workflow: {
	id: "agent-sdk"

	contract: {
		role: "Agent SDK projection, MCP, and agent onboarding control workflow."
		invariants: [
			"CUE manifests are source authority.",
			"project-skills rebuilds the XDG-owned projected skill tree.",
			"agent-sdk-mcp is read-only over projected skill-tree state.",
			"Codex onboarding configures MCP access; it does not make Codex own the projection tree.",
		]
	}

	topics: {
		project_skills: {
			description: "Regenerate the canonical projected skill-tree from source manifests."
			triggers: [
				"agentctl project-skills",
				"projection-manifest.json",
				"XDG_DATA_HOME/agent-sdk/skills",
				"projected skill tree",
			]
			sequence: [
				"inspect source manifests under skills/*/manifest.cue",
				"validate CUE schemas before projection changes",
				"run agentctl project-skills",
				"verify projection-manifest.json exists in the XDG-owned skill-tree root",
				"verify source-only artifacts are absent from projected skills",
			]
			evidence: [
				"cue vet ./skills/... ./cue/schemas/... passed or findings reported",
				"agentctl project-skills completed",
				"projection-manifest.json records projected skills and file hashes",
			]
		}

		check_refs: {
			description: "Validate projected reference manifests and materialized documentation references."
			triggers: [
				"agentctl check refs",
				"references/provenance.json",
				"reference-index.json",
				"materialized docs",
			]
			sequence: [
				"run agentctl check refs against the project root",
				"confirm provenance entries match manifest-declared upstream references",
				"report missing, stale, or mismatched materialized references",
			]
			evidence: [
				"check refs passed or specific reference failures were reported",
			]
		}

		mcp_read_adapter: {
			description: "Expose the projected skill-tree through the read-only Agent SDK MCP server."
			triggers: [
				"agent-sdk-mcp serve",
				"--skill-tree",
				"MCP skill discovery",
				"projection status",
			]
			sequence: [
				"ensure project-skills has generated the XDG-owned skill-tree",
				"start agent-sdk-mcp with --skill-tree pointing at that tree",
				"verify MCP reads projection-manifest.json",
				"verify MCP does not read source manifests or fetch upstream docs",
			]
			evidence: [
				"agent-sdk-mcp doctor or equivalent read check succeeded",
				"MCP skill list came from projection-manifest.json",
			]
		}

		codex_add_agent: {
			description: "Onboard Codex by configuring the agent-sdk MCP server."
			triggers: [
				"agentctl add-agent codex",
				"Codex MCP config",
				"~/.codex/config.toml",
				"mcp_servers.agent-sdk",
			]
			sequence: [
				"run or require project-skills before onboarding",
				"resolve the XDG-owned skill-tree path",
				"resolve the agent-sdk-mcp executable path",
				"write or update the Codex config.toml MCP server entry",
				"preserve unrelated Codex config",
				"run a check mode that confirms projection and MCP config are discoverable",
			]
			evidence: [
				"Codex config contains exactly one mcp_servers.agent-sdk entry",
				"entry launches agent-sdk-mcp serve --skill-tree <xdg-data>/agent-sdk/skills",
				"enabled_tools are constrained to Agent SDK read-only tools",
			]
		}
	}

	unison: {
		codex_onboarding: {
			description: "Build projected skills and configure Codex to discover them through MCP."
			topics: [
				"project_skills",
				"mcp_read_adapter",
				"codex_add_agent",
			]
			sequence: [
				"agentctl project-skills",
				"agentctl add-agent codex",
				"agent-sdk-mcp doctor --skill-tree ${XDG_DATA_HOME:-$HOME/.local/share}/agent-sdk/skills",
				"codex mcp list or Codex /mcp verification when Codex is installed",
			]
		}
	}

	report: {
		fields: [
			"project_root",
			"skill_tree",
			"projection_status",
			"mcp_config",
			"remaining_failures",
		]
	}
}
