package impl

import "list"

// Exit-gate witnesses: validation and completion reports project kernel results.
#ValidationCommandKind:
	"cue-vet" |
	"cue-eval" |
	"cue-export" |
	"cue-export-expected-failure" |
	"cue-export-expected-success" |
	"cue-export-package-expected-success" |
	"matrix-assertion"

#CueExportExpectedFailure: close({
	kind: "cue-export-expected-failure"

	package: #NonEmptyString | *"./contracts"
	expr:    #CueSelectorExpr
	out:     "cue" | "json" | *"cue"
	tags: [...#NonEmptyString] | *[]

	expectedFailure: true

	let tagArgs = list.FlattenN([for tag in tags {["-t", tag]}], 1)
	argv: list.Concat([[
		"cue",
		"export",
	], tagArgs, [
		package,
		"-e",
		expr,
		"--out",
		out,
	]])
})

#CueExportExpectedSuccess: close({
	kind: "cue-export-expected-success"

	package: #NonEmptyString | *"./contracts"
	expr:    #CueSelectorExpr
	out:     "cue" | "json" | *"cue"
	tags: [...#NonEmptyString] | *[]

	expectedFailure: false

	let tagArgs = list.FlattenN([for tag in tags {["-t", tag]}], 1)
	argv: list.Concat([[
		"cue",
		"export",
	], tagArgs, [
		package,
		"-e",
		expr,
		"--out",
		out,
	]])
})

#CueExportPackageExpectedSuccess: close({
	kind: "cue-export-package-expected-success"

	package: #NonEmptyString | *"./contracts"
	tags: [...#NonEmptyString] | *[]

	expectedFailure: false

	let tagArgs = list.FlattenN([for tag in tags {["-t", tag]}], 1)
	argv: list.Concat([[
		"cue",
		"export",
	], tagArgs, [
		package,
	]])
})

#ValidationCommand:
	close({
		kind: "cue-vet"
		argv: #NonEmptyStringList
	}) |
	close({
		kind: "cue-eval"
		argv: #NonEmptyStringList
	}) |
	close({
		kind: "cue-export"
		argv: #NonEmptyStringList
	}) |
	#CueExportExpectedFailure |
	#CueExportExpectedSuccess |
	#CueExportPackageExpectedSuccess |
	close({
		kind:      "matrix-assertion"
		argv:      #NonEmptyStringList
		assertion: #KebabIdentifier
	})

#ValidationCase: close({
	id:          #KebabIdentifier
	description: #NonEmptyString
	command:     #ValidationCommand
})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...#ValidationCommand] & [_, ...]
	assertions: close(#KebabMapKeyGuard & {
		[string]: #Assertion
	})
})

#MakeValidationPlan: {
	in: close({
		commands: [...#ValidationCommand] & [_, ...]
		assertions: close(#KebabMapKeyGuard & {
			[string]: #Assertion
		})
	})
	out: #ValidationPlan & {
		kind:       "validation-plan"
		commands:   in.commands
		assertions: in.assertions
	}
}

#CompletionReportContract: close({
	kind:             "completion-report-contract"
	requiredSections: #NonEmptyStringList
	expected: close({
		state: #KebabIdentifier
		assertions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		fixtures: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		subsumptions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		commands: [...#ValidationCommand] & [_, ...]
		evidence: close(#KebabMapKeyGuard & {
			[string]: bool
		})
	})
})

#MakeCompletionReport: {
	in: close({
		state: #KebabIdentifier
		assertions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		fixtures: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		subsumptions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		commands: [...#ValidationCommand] & [_, ...]
		evidence: close(#KebabMapKeyGuard & {
			[string]: bool
		})
	})
	out: #CompletionReportContract & {
		kind: "completion-report-contract"
		requiredSections: [
			"summary",
			"obligation state",
			"assertions",
			"negative fixtures",
			"subsumptions",
			"generated matrix",
			"validation",
			"evidence",
			"final result",
		]
		expected: in
	}
}
