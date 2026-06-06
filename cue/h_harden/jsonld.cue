package h_harden

#HardenJSONLD: {
	"@context": {
		"ralph":  "https://fatb4f.dev/ns/ralph#"
		"proof":  "ralph:proof"
		"export": "ralph:export"
	}
	"@id":   "ralph:H"
	"@type": "ralph:PhaseNode"

	id:       "H"
	parent:   "root"
	consumes: "PromotionCandidate"
	produces: "AcceptedRunManifest"
}
