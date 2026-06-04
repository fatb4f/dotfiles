package a_assemble

goodAssembly: #AssemblePhase & {
	input: {
		retrieval: {id: "retrieval.good"}
		retrievalAccepted: true
	}
	output: {
		id: "flow.good"
		sourceRetrieval: "retrieval.good"
		tasks: {}
		graph: {cyclic: false, edges: []}
		ambiguity: []
	}
}

badCyclicGraph: #FlowContract & {
	id: "flow.bad.cyclic"
	sourceRetrieval: "retrieval.good"
	tasks: {}
	graph: {cyclic: true, edges: []}
	ambiguity: ["flow_graph_cyclic"]
}
