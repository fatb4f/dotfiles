package nodes

#JSONLDID: =~"^[a-zA-Z][a-zA-Z0-9_-]*:[A-Za-z0-9._/-]+$"

#EntityJSONLD: {
	"@context"?: _
	"@id":       #JSONLDID
	"@type":     "Entity"

	name: string

	labels?: [...string]

	surfaces?: [...{
		kind: "filesystem" | "config" | "runtime" | "mcp" | "docs"
		ref:  string
	}]

	relations?: [...{
		type:   "uses" | "wraps" | "configures" | "projects-to" | "depends-on" | "observes" | "contains"
		target: #JSONLDID
	}]

	invariants: {
		isAuthority:        false
		authorizesLoads:    false
		authorizesMutation: false
	}
}
