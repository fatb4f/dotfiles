package impl

#NegativeFixtureSpec: close({
	name: string & !=""
	violates: string & !=""
	refusal: string & !=""
	input: {...}
	isInvalid?: false
	expression?: false
	"\(operatorWord)\(truthWord)\(flagWord)"?: false
	inlineConstructorDefinition?: false
	generatedArtifactsAreAuthority?: false
})

#NegativeFixtureDescriptor: close({
	kind: "negative-fixture"
	id: string & =~"^negative\\..+"
	violates: string & !=""
	expectedRefusal: string & !=""
	input: {...}
	expectedBottom: true
})

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec

	out: #NegativeFixtureDescriptor & {
		kind: "negative-fixture"
		id: "negative.\(in.name)"
		violates: in.violates
		expectedRefusal: in.refusal
		input: in.input
		expectedBottom: true
	}
}
