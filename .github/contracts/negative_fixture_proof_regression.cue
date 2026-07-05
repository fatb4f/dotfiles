@if(negativeproof)

package impl

_negativeFixtureProbeBinding: (#MakeNegativeFixture & {
	in: {
		id:          "negative-conflict"
		description: "Negative fixture derives paired destructive probe input"
		authority:   _validState
		invalid:     _invalidState
	}
}).out
