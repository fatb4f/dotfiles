package p_perform

#PromoteJSONLD: {
	"@context": {
		"ralph":    "https://fatb4f.dev/ns/ralph#"
		"promote":  "ralph:promote"
		"evidence": "ralph:evidence"
	}
	"@id":   "ralph:P"
	"@type": "ralph:PhaseNode"

	id:       "P"
	parent:   "root"
	consumes: "LoadedContext"
	produces: "PromotionCandidate"
}
