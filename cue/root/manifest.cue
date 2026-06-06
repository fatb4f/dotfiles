package root

rootManifest: {
	"@context": "https://fatb4f.dev/ns/ralph/root/v0"
	"@id":      "ralph:root"
	"@type":    "ralph:RootLifecycleManifest"

	id:    "root.lifecycle"
	label: "Root lifecycle"

	graph: {
		ast: ["R", "A", "L", "P", "H"]
		cstRoots: [
			"cue/root",
			"cue/r_retrieve",
			"cue/a_assemble",
			"cue/l_legitimize",
			"cue/p_perform",
			"cue/h_harden",
		]
	}

	scope: {
		owns: [
			"horizontal lifecycle span",
			"phase ordering",
			"vertical authority designation",
			"cross-phase admissibility law",
		]
		mayRead: ["phase manifests", "leaf metadata"]
		mayWrite: ["root graph acceptance"]
		mayExecute: false
		mayPersist: false
	}

	control: {
		invariants: [
			"filesystem tree mirrors lifecycle graph",
			"each metadata leaf belongs to exactly one RALPH node",
			"each leaf round-trips to node contract and root graph",
			"root never executes adapters",
			"root never exports a manifest directly",
		]
	}
}
