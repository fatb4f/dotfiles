package checks

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

#NeovimQolSurface: {
	host: "neovim"
	scope: "editor-local" | "invocation-only"
	ownsProjectTopology: bool | *false
	persistsWorkspaceModel: bool | *false
	ownsProjectTopology: false
	persistsWorkspaceModel: false
}

#XplrIntentSurface: {
	host: "xplr"
	intent: "open" | "layout"
	route: "wezterm-user-var"
	directPaneDependency: bool | *false
	directPaneDependency: false
}

#EvidenceSurface: {
	path: string
	isGenerated: bool | *false
	decisionSource: bool | *false
	if isGenerated {
		decisionSource: false
	}
}

_negativeBottomChecks: {
	"neovim-topology-owner-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "neovim-topology-owner-rejected"
			input: {
				evidence: "Neovim QoL must stay editor-local or invocation-only"
				value: {
					host: "neovim"
					scope: "project-session"
					ownsProjectTopology: true
					persistsWorkspaceModel: true
				}
			}
			target: {
				name: "#NeovimQolSurface"
				contract: {
					evidence: "project/session ownership and persisted workspace models are outside the Neovim QoL boundary"
					value: #NeovimQolSurface & {
						host: "neovim"
						scope: "project-session"
						ownsProjectTopology: true
						persistsWorkspaceModel: true
					}
				}
			}
		}
	}
	"xplr-direct-pane-bridge-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "xplr-direct-pane-bridge-rejected"
			input: {
				evidence: "xplr may emit open or layout intent only"
				value: {
					host: "xplr"
					intent: "layout"
					route: "direct-pane-plugin"
					directPaneDependency: true
				}
			}
			target: {
				name: "#XplrIntentSurface"
				contract: {
					evidence: "xplr intent must route through WezTerm before pane mechanics execute"
					value: #XplrIntentSurface & {
						host: "xplr"
						intent: "layout"
						route: "direct-pane-plugin"
						directPaneDependency: true
					}
				}
			}
		}
	}
	"generated-decision-source-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "generated-decision-source-rejected"
			input: {
				evidence: "generated projections and runtime state are evidence only"
				value: {
					path: "cache/project-sessions.json"
					isGenerated: true
					decisionSource: true
				}
			}
			target: {
				name: "#EvidenceSurface"
				contract: {
					evidence: "generated projections cannot define workflow decisions"
					value: #EvidenceSurface & {
						path: "cache/project-sessions.json"
						isGenerated: true
						decisionSource: true
					}
				}
			}
		}
	}
}
