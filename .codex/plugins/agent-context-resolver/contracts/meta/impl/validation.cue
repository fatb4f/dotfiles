package impl

#ValidationPlanSpec: close({
	path: string & !=""
	validBaselineExpr: string & !=""
	publicExpr: string & !=""
	bottomChecks: [...string & !=""] & [_, ...]
	checkFile: string & !=""
	checkSurface: string & !=""
	forbiddenPattern: string | *_defaultForbiddenPattern
})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...string & !=""]
})

#MakeValidationPlan: {
	in: #ValidationPlanSpec

	out: #ValidationPlan & {
		kind: "validation-plan"
		commands: [
			"cue vet ./\(in.path)",
			"cue export ./\(in.path) -e \(in.validBaselineExpr)",
			"cue export ./\(in.path) -e \(in.publicExpr)",
			for c in in.bottomChecks {
				"! cue export \(in.checkFile) -e '\(in.checkSurface).\(c)'"
			},
			"! rg '\(in.forbiddenPattern)' ./\(in.path)",
		]
	}
}
