package l_legitimize

#LegitimizeJSONLD: {
	"@context": {
		"ralph":  "https://fatb4f.dev/ns/ralph#"
		"gate":   "ralph:gate"
		"policy": "ralph:policy"
	}
	"@id":   "ralph:L"
	"@type": "ralph:PhaseNode"

	id:       "L"
	parent:   "root"
	consumes: "TaskGraphContract"
	produces: "ValidationFacts"
}
