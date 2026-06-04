package r_retrieve

#JSONLDID: =~"^[a-zA-Z][a-zA-Z0-9_-]*:[A-Za-z0-9._/-]+$"

jsonld: {
	"@context": {
		"ralph": "https://fatb4f.dev/ns/ralph#"
		"leaf":  "ralph:leaf"
		"fact":  "ralph:fact"
	}

	"@id":   "ralph:R"
	"@type": "ralph:PhaseNode"

	id:     "R"
	parent: "root"

	leaves: [...#JSONLDID] & [
		"ralph:leaf.chezmoi.source",
	]
}
