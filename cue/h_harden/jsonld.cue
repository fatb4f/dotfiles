package h_harden

#HardenJSONLD: {
	"@context": {
		"ralph":  "https://fatb4f.dev/ns/ralph#"
		"record": "ralph:record"
		"memory": "ralph:memory"
	}
	"@id":   "ralph:H"
	"@type": "ralph:PhaseNode"

	id:       "H"
	parent:   "root"
	consumes: "RunManifest"
	produces: "LifecycleRecord"
}
