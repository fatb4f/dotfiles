package l_legitimize

#LoadJSONLD: {
	"@context": {
		"ralph":   "https://fatb4f.dev/ns/ralph#"
		"load":    "ralph:load"
		"surface": "ralph:surface"
	}
	"@id":   "ralph:L"
	"@type": "ralph:PhaseNode"

	id:       "L"
	parent:   "root"
	consumes: "TaskGraphContract"
	produces: "LoadedContext"
}
