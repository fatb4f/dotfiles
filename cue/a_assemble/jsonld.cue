package a_assemble

#AssembleJSONLD: {
	"@context": {
		"ralph": "https://fatb4f.dev/ns/ralph#"
		"graph": "ralph:graph"
		"edge":  "ralph:edge"
	}
	"@id":   "ralph:A"
	"@type": "ralph:PhaseNode"

	id:       "A"
	parent:   "root"
	consumes: "RetrievalContract"
	produces: "TaskGraphContract"
}
