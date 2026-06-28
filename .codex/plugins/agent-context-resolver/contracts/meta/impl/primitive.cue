package impl

#PrimitiveSpec: close({
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	constraints: [...string & !=""] | *[]
	closed: bool | *true
	observedPhase?: false
	admissiblePhase?: false
	loweredObject?: false
	proofObject?: false
	materializedSurface?: false
})

#PrimitiveDescriptor: close({
	kind: "primitive-spec"
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""]
	constraints: [...string & !=""]
	closed: bool
})

#MakePrimitive: {
	in: #PrimitiveSpec

	out: #PrimitiveDescriptor & {
		kind: "primitive-spec"
		name: in.name
		role: in.role
		requiredFields: in.requiredFields
		constraints: in.constraints
		closed: in.closed
	}
}
