package adapter

#AccessMode: "read-only"

#AuthorityOwner: "cue"

#AdapterAuthority: "runtime-containment"

#ArgumentType: "string" | "boolean"

#ToolArgument: {
	name:        string
	type:        #ArgumentType
	required:    bool | *false
	description: string
}

#MCPTool: {
	name:        string
	description: string
	mode:        #AccessMode
	arguments: [...#ToolArgument]
	handler:     string
	projection?: string
}

#SurfaceBinding: {
	name:              string
	canonical:         true
	mode:              #AccessMode
	policyAuthority:   #AuthorityOwner
	adapterAuthority:  #AdapterAuthority
	adapterOwnsPolicy: false
	lspSymbol:         "ralphMCPBinding.tools.\(name)"
	evidenceOnly:      true
}

#AdapterExtraction: {
	id:            string
	sourceRepo:    string
	destination:   "cue/adapter"
	sourcePackage: string

	tools: [...#MCPTool]

	ralphMCPBinding: {
		authorityPackage: string
		tools: {
			[string]: #SurfaceBinding
		}
		deniedAuthoritySurfaces: [...string]
		invariant: string
	}

	runtimeProjections: {
		runtimePreflight: string
		gitMCPAllowlist:  string
	}

	boundaries: {
		cueOwnsPolicy:               true
		adapterOwnsPolicy:           false
		semanticResolutionAuthority: "evidence-only"
		adapterExecutionAuthority:   "runtime-containment"
	}

	sourceEvidence: [...{
		path: string
		role: string
	}]
}
