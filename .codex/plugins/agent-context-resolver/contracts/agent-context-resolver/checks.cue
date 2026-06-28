package agentcontextresolver

_negativeBottomChecks: {
	routeOnlyPacket: {
		kind: "issue-materialization-negative-check"
		fixture: "negativeFixtures.routeOnlyPacket"
		reasonClass: "structural_bottom"
		result: bool
	}
	missingContractPath: {
		kind: "issue-materialization-negative-check"
		fixture: "negativeFixtures.missingContractPath"
		reasonClass: "structural_bottom"
		result: bool
	}
	staticEvalPlan: {
		kind: "issue-materialization-negative-check"
		fixture: "negativeFixtures.staticEvalPlan"
		reasonClass: "structural_bottom"
		result: bool
	}
	missingNegativeCheckExpression: {
		kind: "issue-materialization-negative-check"
		fixture: "negativeFixtures.missingNegativeCheckExpression"
		reasonClass: "structural_bottom"
		result: bool
	}
	anyNonzeroAsPass: {
		kind: "issue-materialization-negative-check"
		fixture: "negativeFixtures.anyNonzeroAsPass"
		reasonClass: "structural_bottom"
		result: bool
	}
}
