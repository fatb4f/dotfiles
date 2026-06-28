package agentcontextresolver

_negativeBottomChecks: {
	routeOnlyPacket: negativeFixtures.routeOnlyPacket.input & #IssueMaterializationCandidate
	missingContractPath: negativeFixtures.missingContractPath.input & #IssueMaterializationCandidate
	staticEvalPlan: negativeFixtures.staticEvalPlan.input & #IssueMaterializationCandidate
	missingNegativeCheckExpression: negativeFixtures.missingNegativeCheckExpression.input & #IssueMaterializationCandidate
	anyNonzeroAsPass: negativeFixtures.anyNonzeroAsPass.input & #IssueMaterializationCandidate
}
