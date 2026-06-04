package nodes

#NodeKind: "repo" | "tool" | "adapter" | "concept" | "surface" | "service"

#SurfaceKind: "filesystem" | "config" | "runtime" | "mcp" | "docs"

#RelationType: "uses" | "wraps" | "configures" | "projects-to" | "depends-on" | "observes" | "mutates"

#Node: {
	id:   string
	kind: #NodeKind

	namespace: [...string]

	name:     string
	summary?: string

	surfaces?: [string]: #Surface
	relations?: [...#Relation]

	patternRefs?: [...string]
	contractRefs?: [...string]

	invariants: {
		isAuthority:        false
		authorizesLoads:    false
		authorizesMutation: false
	}
}

#Surface: {
	kind:  #SurfaceKind
	path?: string
	ref?:  string
}

#Relation: {
	type:   #RelationType
	target: string
}
