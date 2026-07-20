package sufficientwithgap

import model "github.com/fatb4f/dotfiles/context-model:contextmodel"

invalid: model.#ContextSufficiency & {
	state:                 "sufficient"
	reasons:               ["Incorrectly claims sufficiency."]
	blockingGapIDs:        ["gap.missing-source"]
	unresolvedConflictIDs: []
}
