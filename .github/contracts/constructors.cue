package impl

// Compatibility entrypoint for the lattice TDD/BDD constructor package.
//
// The implementation is intentionally split by surface:
// - kernel.cue: bounded vocabulary, resource/operation/evidence graph, closure, no-widening proofs
// - fixtures.cue: assertions, positive fixtures, negative fixture specs/probes, subsumptions
// - projections.cue: generated assertion matrices and TDD/BDD projections
// - validation.cue: validation commands and completion report witnesses
//
// Negative-fixture contract note:
// #MakeNegativeFixture and #MakeUncheckedNegativeFixture create exportable spec metadata only.
// Bottom proof is exclusively performed by evaluating #NegativeFixtureConflictProbe.proof as an
// expected-failure validation path.
