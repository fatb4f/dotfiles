package impl

#PredicateSetSpec: close({
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	admissibleSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false | *false
	constraints: [...string & !=""] | *[]
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
})

#PredicateSetDescriptor: close({
	kind: "predicate-set"
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	admissibleSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false
	constraints: [...string & !=""]
})

#MakePredicateSet: {
	in: #PredicateSetSpec

	out: #PredicateSetDescriptor & {
		kind: "predicate-set"
		name: in.name
		role: in.role
		observedSurface: in.observedSurface
		admissibleSurface: in.admissibleSurface
		derivedPredicates: in.derivedPredicates
		operatorSupplied: in.operatorSupplied
		constraints: in.constraints
	}
}
