package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#CodexSlice: {
	schemaVersion: "cuerail.codexSlice.v1"
	selected:      domain.#DomainNodePattern
}

shellWrapSlice: #CodexSlice & {
	selected: domain.shellWrap
}
