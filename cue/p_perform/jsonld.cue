package p_perform

#PerformJSONLD: {
	"@context": {
		"ralph": "https://fatb4f.dev/ns/ralph#"
		"run":   "ralph:run"
		"fill":  "ralph:fill"
	}
	"@id":   "ralph:P"
	"@type": "ralph:PhaseNode"

	id:       "P"
	parent:   "root"
	consumes: "ValidationFacts"
	produces: "RunManifest"
}
