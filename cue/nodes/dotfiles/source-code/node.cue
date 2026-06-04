package sourcecode

import nodes "github.com/fatb4f/dotfiles/cue/nodes"

node: nodes.#Node & {
	id:   "dotfiles.source-code"
	kind: "concept"
	namespace: ["dotfiles"]
	name: "source-code"

	summary: "Tracked source tree and code-change surface"

	surfaces: {
		cue: {
			kind: "filesystem"
			path: "cue/"
		}
		shellWrap: {
			kind: "filesystem"
			path: "shell-wrap/"
		}
	}

	relations: [
		{
			type:   "depends-on"
			target: "dotfiles.git"
		},
		{
			type:   "depends-on"
			target: "dotfiles.cue"
		},
	]

	patternRefs: [
		"generated_cli_change",
	]

	contractRefs: [
		"contracts.architecture",
		"contracts.git.mutation",
	]
}
