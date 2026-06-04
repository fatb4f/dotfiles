package root

#InventoryStatus: "stay" | "adapt" | "compress" | "prune" | "split"

#InventoryItem: {
	id:             string
	currentSurface: string
	status:         #InventoryStatus
	foldInto:       "root" | "R" | "A" | "L" | "P" | "H" | "none"
	newRole:        string
	reason:         string
}

foldInventory: [...#InventoryItem] & [
	{
		id:             "contracts.architecture"
		currentSurface: "cue/contracts/architecture.cue"
		status:         "adapt"
		foldInto:       "root"
		newRole:        "root authority matrix and surface boundary law"
		reason:         "Defines which surfaces own policy and which are non-authority."
	},
	{
		id:             "contracts.schema"
		currentSurface: "cue/contracts/schema.cue"
		status:         "adapt"
		foldInto:       "root"
		newRole:        "contract, gate, and evidence ref vocabulary without cue-flow legacy names"
		reason:         "Keeps enums, removes old loop-shaped authority vocabulary."
	},
	{
		id:             "contracts.agentflow.legitimation"
		currentSurface: "cue/contracts/agentflow/schema.cue"
		status:         "split"
		foldInto:       "L"
		newRole:        "root response, promo gate, mutation admissibility"
		reason:         "Pre-execution legitimacy belongs to L."
	},
	{
		id:             "contracts.agentflow.run_manifest"
		currentSurface: "cue/contracts/agentflow/schema.cue"
		status:         "split"
		foldInto:       "P"
		newRole:        "run manifest and execution evidence"
		reason:         "Execution evidence belongs to P."
	},
	{
		id:             "flow.contract"
		currentSurface: "cue/flow/schema.cue"
		status:         "adapt"
		foldInto:       "A"
		newRole:        "candidate graph assembly contract"
		reason:         "Flow is an assembly leaf, not root authority."
	},
	{
		id:             "registry.schema"
		currentSurface: "cue/registry/schema.cue"
		status:         "adapt"
		foldInto:       "R"
		newRole:        "retrieval interface and ambiguity classifier"
		reason:         "Registry may select candidates but cannot authorize behavior."
	},
	{
		id:             "registry.resolutions"
		currentSurface: "cue/registry/resolutions.cue"
		status:         "compress"
		foldInto:       "R"
		newRole:        "retrieval fixtures and examples"
		reason:         "Examples are folded into node fixtures."
	},
	{
		id:             "registry.execution"
		currentSurface: "cue/registry/evidence.cue"
		status:         "adapt"
		foldInto:       "P"
		newRole:        "adapter execution evidence"
		reason:         "Runtime evidence belongs to P, not retrieval authority."
	},
	{
		id:             "nodes.schema"
		currentSurface: "cue/nodes/schema.cue"
		status:         "adapt"
		foldInto:       "R"
		newRole:        "entity fact catalog schema"
		reason:         "Nodes classify facts but do not authorize loads or mutation."
	},
	{
		id:             "patterns.domain.schema"
		currentSurface: "cue/patterns/domain/schema.cue"
		status:         "adapt"
		foldInto:       "L"
		newRole:        "promotion and validation vocabulary"
		reason:         "Promotion gates are legitimacy facts."
	},
	{
		id:             "patterns.lifecycle.schema"
		currentSurface: "cue/patterns/lifecycle/schema.cue"
		status:         "adapt"
		foldInto:       "H"
		newRole:        "closeout and lifecycle evidence"
		reason:         "Durable hardening consumes accepted process evidence."
	},
	{
		id:             "agents.cueflow.loop"
		currentSurface: "AGENTS.cue cueFlowLoopContract"
		status:         "prune"
		foldInto:       "none"
		newRole:        "none"
		reason:         "Old loop-shaped authority conflicts with root lifecycle graph."
	},
]
