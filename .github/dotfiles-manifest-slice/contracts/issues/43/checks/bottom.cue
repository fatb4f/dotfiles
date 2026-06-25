package checks

import issue43 "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/issues/43:issue43"
import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

_openIntent: {
	op: "open"
	path: string & =~"^/home/_404/src/dotfiles(/|$)"
	socket: string & !=""
}

_layoutIntent: {
	op: "layout"
	kind: "hide" | "reveal" | "narrow" | "wide"
	socket: string & !=""
}

_intent: _openIntent | _layoutIntent

_negativeFixtureByName: {
	for fixture in issue43.normalizedDotfilesIssueManifest.negativeFixtures {
		"\(fixture.name)": fixture
	}
}

_negativeBottomChecks: {
	for name, fixture in _negativeFixtureByName {
		"\(name)": impl.#MakeBottomCheckProof & {
			in: {
				name: name
				input: {
					evidence: fixture.reason
					value: fixture.input
				}
				target: {
					name: "#XplrProjectTreeIntent"
					contract: {
						evidence: "negative fixtures must not unify with bounded xplr intent contract"
						value: fixture.input & _intent
					}
				}
			}
		}
	}
}
