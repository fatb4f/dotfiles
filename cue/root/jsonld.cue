package root

#JSONLDID: =~"^[a-zA-Z][a-zA-Z0-9_-]*:[A-Za-z0-9._/-]+$"

#JSONLDBase: {
	"@context": _
	"@id":      #JSONLDID
	"@type":    string
}

#RoundTrip: {
	toNodeContract: string
	toRootGraph:     "root"
	backToLeaf:      string
}

#RootJSONLD: #JSONLDBase & {
	"@type": "ralph:RootLifecycle"
	id:      "root"
	children: ["R", "A", "L", "P", "H"]
}

#PhaseJSONLD: #JSONLDBase & {
	"@type": "ralph:PhaseNode"
	id:      #PhaseID
	parent:  "root"
}

#LeafJSONLD: #JSONLDBase & {
	"@type": "ralph:MetadataLeaf"
	id:         string
	parentNode: #PhaseID
	roundTrip:  #RoundTrip
}
