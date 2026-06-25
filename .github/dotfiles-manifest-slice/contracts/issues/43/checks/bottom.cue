package checks

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

#XplrPayload: {
	op: "open"
	path: string
} | {
	op: "layout"
	kind: "hide" | "reveal" | "narrow" | "wide"
}

#WeztermDispatchContract: {
	root: "/home/_404/src/dotfiles"
	socket: string & !=""
}

#ValidatedDispatch: {
	payload: #XplrPayload
	contract: #WeztermDispatchContract
	if payload.op == "open" {
		payload: path: =~"^/home/_404/src/dotfiles(/|$)"
	}
}

_validContract: {
	root: "/home/_404/src/dotfiles"
	socket: "/run/user/1000/nvim/dotfiles.sock"
}

_negativeBottomChecks: {
	"outside-project-root-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "outside-project-root-rejected"
			input: {
				evidence: "xplr open must not dispatch paths outside TERM_PROJECT_ROOT"
				value: {op: "open", path: "/tmp/outside-project"}
			}
			target: {
				name: "#ValidatedDispatch"
				contract: {
					evidence: "open payload is paired with a valid WezTerm dispatch contract but must remain under root"
					value: #ValidatedDispatch & {
						payload: {op: "open", path: "/tmp/outside-project"}
						contract: _validContract
					}
				}
			}
		}
	}
	"unknown-layout-kind-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "unknown-layout-kind-rejected"
			input: {
				evidence: "layout kind must be one of hide, reveal, narrow, or wide"
				value: {op: "layout", kind: "fullscreen"}
			}
			target: {
				name: "#XplrPayload"
				contract: {
					evidence: "layout payload must use a bounded kind before WezTerm dispatch"
					value: #XplrPayload & {op: "layout", kind: "fullscreen"}
				}
			}
		}
	}
	"missing-nvim-socket-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "missing-nvim-socket-rejected"
			input: {
				evidence: "missing Neovim socket must stop dispatch"
				value: {
					payload: {op: "open", path: "/home/_404/src/dotfiles/README.md"}
					contract: {root: "/home/_404/src/dotfiles", socket: ""}
				}
			}
			target: {
				name: "#WeztermDispatchContract"
				contract: {
					evidence: "WezTerm dispatch contract requires a non-empty Neovim socket"
					value: #ValidatedDispatch & {
						payload: {op: "open", path: "/home/_404/src/dotfiles/README.md"}
						contract: {root: "/home/_404/src/dotfiles", socket: ""}
					}
				}
			}
		}
	}
}
