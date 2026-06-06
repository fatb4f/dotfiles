package a_assemble

import retrieve "github.com/fatb4f/dotfiles/cue/r_retrieve"

goodAssembly: #AssemblePhase & {
	input: {
		retrieval: {id: "retrieval.good"}
		retrievalAccepted: true
	}
	output: {
		id:                      "taskGraph.good"
		sourceRetrievalContract: "retrieval.good"
		tasks: {}
		graph: {cyclic: false, edges: []}
		ambiguity: []
	}
}

goodAssembleFromChezmoiRetrieval: #AssemblePhase & {
	input: {
		retrieval:         retrieve.goodChezmoiRetrieval.output
		retrievalAccepted: retrieve.goodChezmoiRetrieval.accepted
	}

	output: {
		id:                      "assemble.chezmoi.good"
		sourceRetrievalContract: "retrieval.chezmoi.good"
		graph: {
			cyclic: false
			edges: []
		}
		tasks: {}
		ambiguity: []
	}
}

badAssembleFromLegacyChezmoiRetrieval: {
	input: {
		retrieval:         retrieve.badLegacyChezmoiSource.output
		retrievalAccepted: retrieve.badLegacyChezmoiSource.accepted
	}

	output: {
		id:                      "assemble.chezmoi.bad.legacy"
		sourceRetrievalContract: "retrieval.chezmoi.bad.legacy"
		graph: {
			cyclic: false
			edges: []
		}
		tasks: {}
		ambiguity: []
	}
}

badCyclicGraph: #TaskGraphContract & {
	id:                      "taskGraph.bad.cyclic"
	sourceRetrievalContract: "retrieval.good"
	tasks: {}
	graph: {cyclic: true, edges: []}
	ambiguity: ["task_graph_cyclic"]
}

badAmbiguousGraph: #TaskGraphContract & {
	id:                      "taskGraph.bad.ambiguity"
	sourceRetrievalContract: "retrieval.good"
	tasks: {}
	graph: {cyclic: false, edges: []}
	ambiguity: ["task_graph_ambiguous"]
}

badAdapterTaskShape: {
	id:                      "taskGraph.bad.adapter_shape"
	sourceRetrievalContract: "retrieval.good"
	tasks: {
		adapterDefined: {
			id:   "adapterDefined"
			kind: "compose_task_graph_contract"
			dependsOn: []
			runner:                  "pure-cue"
			authority:               "cue"
			shapeOwner:              "cue"
			adapterOwnsPolicy:       false
			adapterDefinesTaskShape: true
		}
	}
	graph: {cyclic: false, edges: []}
	ambiguity: ["adapter_task_shape"]
}

badProjectionEvidenceEdge: {
	id:                      "taskGraph.bad.projection_edge"
	sourceRetrievalContract: "retrieval.good"
	tasks: {}
	graph: {
		cyclic: false
		edges: [{from: "a", to: "b", via: "projection-evidence"}]
	}
	ambiguity: ["graph_edge_not_cue_reference"]
}
