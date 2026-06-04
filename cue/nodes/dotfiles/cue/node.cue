package cue

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.cue"
	kind: "surface"
	namespace: ["dotfiles"]
	name: "cue"

	summary: "CUE contracts, schemas, projections, nodes, registry, and flow"

	surfaces: {
		root: {
			kind: "filesystem"
			path: "cue/"
		}
		contracts: {
			kind: "filesystem"
			path: "cue/contracts/"
		}
		nodes: {
			kind: "filesystem"
			path: "cue/nodes/"
		}
		patterns: {
			kind: "filesystem"
			path: "cue/patterns/"
		}
		registry: {
			kind: "filesystem"
			path: "cue/registry/"
		}
		flow: {
			kind: "filesystem"
			path: "cue/flow/"
		}
	}

	relations: [
		{
			type:   "uses"
			target: "contracts.architecture"
		},
		{
			type:   "projects-to"
			target: "dotfiles.registry"
		},
	]

	patternRefs: [
		"generated_cli_change",
		"agentflow_mutation_gate",
	]

	contractRefs: [
		"contracts.architecture",
		"contracts.cue-flow.loop",
	]
}
