package codeintel

#CodeIntelBoundary: close({
	generatedAuthority?: false
	mcpOutputIsAuthority?: false
	lspDiagnosticsAreAuthority?: false
	weztermTypesAreAuthority?: false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?: false
})

codeIntelBoundary: #CodeIntelBoundary & {
	generatedAuthority: false
	mcpOutputIsAuthority: false
	lspDiagnosticsAreAuthority: false
	weztermTypesAreAuthority: false
	luaWorkflowGeneratedAsAuthority: false
	resolverContractsLeak: false
}

_negativeBottomChecks: {
	generatedAsAuthority: *(#CodeIntelBoundary & {generatedAuthority: true}) | _
	mcpOutputAsAuthority: *(#CodeIntelBoundary & {mcpOutputIsAuthority: true}) | _
	lspDiagnosticsAsAuthority: *(#CodeIntelBoundary & {lspDiagnosticsAreAuthority: true}) | _
	weztermTypesAsAuthority: *(#CodeIntelBoundary & {weztermTypesAreAuthority: true}) | _
	luaWorkflowGeneratedAsAuthority: *(#CodeIntelBoundary & {luaWorkflowGeneratedAsAuthority: true}) | _
	resolverContractsLeak: *(#CodeIntelBoundary & {resolverContractsLeak: true}) | _
}

codeIntelBoundaryReport: {
	schema: "factory.plugin-bundle.code-intel.boundary-report.v1"
	status: "admitted"
	authority: codeIntelBoundary
	checks: [
		"generatedAsAuthority",
		"mcpOutputAsAuthority",
		"lspDiagnosticsAsAuthority",
		"weztermTypesAsAuthority",
		"luaWorkflowGeneratedAsAuthority",
		"resolverContractsLeak",
	]
}
