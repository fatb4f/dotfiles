package issue

import impl "github.com/fatb4f/dotfiles/github/contracts/meta/impl"

_contractSeed: close({
	id: "github-issue-template-contract"
	version: "v0.1.0"
	owner: "contract.cuemod"
	idempotent: true
})

#RepoIssueTemplateInput: close({
	repository: string & !=""
	module: string & !=""
	constructorLibrary: string & !=""
	issueRoot: string & !=""
	templatePath: string & !=""
	publicExports: close({
		manifest: string & !=""
		validationPlan: string & !=""
		completionReport: string & !=""
	})
})

_repo: #RepoIssueTemplateInput & {
	repository: "fatb4f/dotfiles"
	module: "github.com/fatb4f/dotfiles/github"
	constructorLibrary: "contracts/meta/impl"
	issueRoot: ".github/ISSUE_TEMPLATE/contracts"
	templatePath: ".github/ISSUE_TEMPLATE/contracts/_template/manifest.cue"
	publicExports: {
		manifest: "normalizedIssueTemplateManifest"
		validationPlan: "issueTemplateValidationPlan"
		completionReport: "issueTemplateCompletionReportContract"
	}
}

_issue: {
	number: 0
	title: "template"
	path: _repo.templatePath
}

validIssueTemplateSeed: close({
	seed: _contractSeed
	issue: _issue
	repository: _repo.repository
	module: _repo.module
	constructorLibrary: _repo.constructorLibrary
	issueRoot: _repo.issueRoot
	templatePath: _repo.templatePath
	repoLocalOverlay: true
	constructorCallsOnly: true
	inlineConstructorDefinitions: false
	generatedArtifactsAreAuthority: false
})

_workflowIndex: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 4, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
	{order: 5, id: "#MakeValidationPlan", instantiateAt: "_validation"},
	{order: 6, id: "#MakeCompletionReport", instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#RepoIssueTemplateInput"
			role: "repo-local input contract for idempotent issue-template installation"
			requiredFields: ["repository", "module", "constructorLibrary", "issueRoot", "templatePath", "publicExports"]
			constraints: [
				"repo identity is input data",
				"module path is repo-local",
				"public export names are deterministic",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "validIssueTemplateSeed"
			role: "normalized seed manifest for a repository issue-template contract"
			requiredFields: ["seed", "issue", "repository", "module", "constructorLibrary", "issueRoot", "templatePath"]
			constraints: [
				"constructor bodies stay in the repo-local implementation package",
				"generated artifacts are evidence only",
			]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["validIssueTemplateSeed"]
		observed: ["_repo"]
		candidates: ["normalizedIssueTemplateManifest"]
		fixtures: ["negativeIssueTemplateFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: [
			_repo.publicExports.manifest,
			_repo.publicExports.validationPlan,
			_repo.publicExports.completionReport,
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "generatedAuthorityAccepted"
			violates: "generated artifact authority boundary"
			refusal: "generated artifacts are projection evidence only"
			input: {
				repository: _repo.repository
				module: _repo.module
				templatePath: "generated/issue-template/manifest.cue"
				generatedArtifactsAreAuthority: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "inlineConstructorDefinitionsAccepted"
			violates: "constructor call compactness boundary"
			refusal: "installed issue templates carry constructor calls, not constructor definitions"
			input: {
				repository: _repo.repository
				module: _repo.module
				templatePath: _repo.templatePath
				inlineConstructorDefinitions: true
			}
		}
	},
]

negativeIssueTemplateFixtures: {
	generatedAuthorityAccepted: _negativeFixtures[0].out
	inlineConstructorDefinitionsAccepted: _negativeFixtures[1].out
}

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "generatedAuthorityAccepted"
			fixture: negativeIssueTemplateFixtures.generatedAuthorityAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile: "./\(_repo.issueRoot)/_template/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "inlineConstructorDefinitionsAccepted"
			fixture: negativeIssueTemplateFixtures.inlineConstructorDefinitionsAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile: "./\(_repo.issueRoot)/_template/checks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "\(_repo.issueRoot)/_template"
		validBaselineExpr: "validIssueTemplateSeed"
		publicExpr: _repo.publicExports.manifest
		bottomChecks: [for plan in _bottomCheckPlans {plan.out.name}]
		checkFile: "./\(_repo.issueRoot)/_template/checks"
		checkSurface: "_negativeBottomChecks"
		forbiddenPattern: "[i]nlineConstructorDefinitions: true|[g]eneratedArtifactsAreAuthority: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["repo-local input", "repo-local constructor import", "deterministic public exports"]
	}
}

normalizedIssueTemplateManifest: {
	seed: _contractSeed
	repo: _repo
	issue: _issue
	workflow: _workflowIndex
	validBaseline: validIssueTemplateSeed
	primitives: [for item in _primitives {item.out}]
	surfaces: _surfaces.out
	negativeFixtures: negativeIssueTemplateFixtures
	bottomCheckPlans: [for item in _bottomCheckPlans {item.out}]
}

issueTemplateValidationPlan: _validation.out
issueTemplateCompletionReportContract: _completion.out

// Compatibility exports for existing dotfiles-oriented issue-manifest workflows.
normalizedDotfilesIssueManifest: normalizedIssueTemplateManifest
dotfilesValidationPlan: issueTemplateValidationPlan
dotfilesCompletionReportContract: issueTemplateCompletionReportContract
