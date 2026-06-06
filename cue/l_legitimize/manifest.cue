package l_legitimize

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/load/v0"
	"@id":      "ralph:L"
	"@type":    "ralph:PhaseManifest"

	id:    "L"
	label: "Load"

	scope: {
		owns: ["bounded context materialization", "declared load evidence", "denied load evidence", "tool surface binding"]
		mayRead: ["A.output.TaskGraphContract", "root.AGENTS", "selected leaf schemas"]
		mayWrite: ["LoadedContext"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["A"]
		downstream: ["P"]
		forbidden: ["execute adapter", "authorize mutation", "load unselected sibling repo", "perform unbounded scan", "accept hidden authority load"]
		authorityMode: "contract"
	}

	inputs: [{id: "taskGraphContract", from: "A", kind: "TaskGraphContract", acceptedRequired: true}]
	outputs: [{id: "loadedContext", to: "P", kind: "LoadedContext", acceptedBy: "L.accepted"}]

	control: {
		invariants: ["loadedFiles are declared or root-authorized", "deniedLoads remain denied", "no unbounded scan", "readyForMutation is false"]
		rejects: ["undeclared_loaded_file", "sibling_repo_loadable", "unbounded_home_src_scan", "unvetted_leaf_loaded", "tool_surface_not_declared"]
		acceptance: ["A.accepted == true", "context accepted", "ambiguityCount == 0", "readyForMutation == false"]
	}
}
