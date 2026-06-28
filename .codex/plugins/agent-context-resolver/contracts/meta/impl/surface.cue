package impl

#ObservedSurfaceSpec: close({
	name: string & !=""
	role: string & !=""
	factFields: [...string & !=""] & [_, ...]
	mayRepresentInvalid: true | *true
	constraints: [...string & !=""] | *[]
	generatedArtifactsAreAuthority?: false
})

#ObservedSurfaceDescriptor: close({
	kind: "observed-surface"
	name: string & !=""
	role: string & !=""
	factFields: [...string & !=""] & [_, ...]
	mayRepresentInvalid: true
	constraints: [...string & !=""]
})

#MakeObservedSurface: {
	in: #ObservedSurfaceSpec

	out: #ObservedSurfaceDescriptor & {
		kind: "observed-surface"
		name: in.name
		role: in.role
		factFields: in.factFields
		mayRepresentInvalid: in.mayRepresentInvalid
		constraints: in.constraints
	}
}

#AdmissibleSurfaceSpec: close({
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	rejectedFields: [...string & !=""] | *[]
	closed: true | *true
	constraints: [...string & !=""] | *[]
	generatedArtifactsAreAuthority?: false
	stringifiedCueExpression?: false
})

#AdmissibleSurfaceDescriptor: close({
	kind: "admissible-surface"
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	rejectedFields: [...string & !=""]
	closed: true
	constraints: [...string & !=""]
})

#MakeAdmissibleSurface: {
	in: #AdmissibleSurfaceSpec

	out: #AdmissibleSurfaceDescriptor & {
		kind: "admissible-surface"
		name: in.name
		role: in.role
		observedSurface: in.observedSurface
		requiredFields: in.requiredFields
		rejectedFields: in.rejectedFields
		closed: in.closed
		constraints: in.constraints
	}
}

#SurfaceSetSpec: close({
	admissible: [...string & !=""] & [_, ...]
	observed: [...string & !=""] & [_, ...]
	candidates: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	publicExports: [...string & !=""] & [_, ...]
	manifestExecutableProofObject?: false
})

#SurfaceSetDescriptor: close({
	kind: "surface-set"
	admissible: [...string & !=""]
	observed: [...string & !=""]
	candidates: [...string & !=""]
	fixtures: [...string & !=""]
	checks: [...string & !=""]
	publicExports: [...string & !=""]
})

#MakeSurfaceSet: {
	in: #SurfaceSetSpec

	out: #SurfaceSetDescriptor & {
		kind: "surface-set"
		admissible: in.admissible
		observed: in.observed
		candidates: in.candidates
		fixtures: in.fixtures
		checks: in.checks
		publicExports: in.publicExports
	}
}
