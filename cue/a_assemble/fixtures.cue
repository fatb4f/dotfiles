package a_assemble

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

badCyclicGraph: #TaskGraphContract & {
	id:                      "taskGraph.bad.cyclic"
	sourceRetrievalContract: "retrieval.good"
	tasks: {}
	graph: {cyclic: true, edges: []}
	ambiguity: ["task_graph_cyclic"]
}
