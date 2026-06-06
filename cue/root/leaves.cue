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
		newRole:        "contract, gate, and evidence ref vocabulary without legacy loop names"
		reason:         "Keeps enums, removes old loop-shaped authority vocabulary."
	},
	{
		id:             "contracts.agentflow.load_context"
		currentSurface: "cue/contracts/agentflow/schema.cue"
		status:         "split"
		foldInto:       "L"
		newRole:        "bounded context and load evidence"
		reason:         "Declared load materialization belongs to L."
	},
	{
		id:             "contracts.agentflow.promotion_candidate"
		currentSurface: "cue/contracts/agentflow/schema.cue"
		status:         "split"
		foldInto:       "P"
		newRole:        "promotion candidate and observed mutation evidence"
		reason:         "Observed diff validation belongs to P."
	},
	{
		id:             "task_graph.contract"
		currentSurface: "cue/flow/schema.cue"
		status:         "adapt"
		foldInto:       "A"
		newRole:        "candidate task graph assembly contract"
		reason:         "Task graph assembly is an assembly leaf, not root authority."
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
		newRole:        "validation evidence"
		reason:         "Validation evidence belongs to P, not retrieval authority."
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
		newRole:        "bounded context vocabulary"
		reason:         "Load admissibility vocabulary belongs to L."
	},
	{
		id:             "patterns.lifecycle.schema"
		currentSurface: "cue/patterns/lifecycle/schema.cue"
		status:         "adapt"
		foldInto:       "H"
		newRole:        "boundary proof and export evidence"
		reason:         "Final boundary proof consumes accepted promotion evidence."
	},
	{
		id:             "agents.legacy.loop"
		currentSurface: "AGENTS.cue legacyLoopContract"
		status:         "prune"
		foldInto:       "none"
		newRole:        "none"
		reason:         "Old loop-shaped authority conflicts with root lifecycle graph."
	},
]
