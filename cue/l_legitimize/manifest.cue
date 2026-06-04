package l_legitimize

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/legitimize/v0"
	"@id":      "ralph:L"
	"@type":    "ralph:PhaseManifest"

	id: "L"
	label: "Legitimize"

	scope: {
		owns: ["root schema vet", "promotion gate vet", "runner boundary vet", "mutation admissibility"]
		mayRead: ["A.output.FlowContract", "leaf.architecture.boundary", "leaf.agentflow.legitimation", "leaf.promotion"]
		mayWrite: ["ValidationFacts"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["A"]
		downstream: ["P"]
		forbidden: ["execute adapter", "write durable memory", "accept runner-owned policy", "accept agent-selected workflow without root response"]
		authorityMode: "contract"
	}

	inputs: [{id: "flowContract", from: "A", kind: "FlowContract", acceptedRequired: true}]
	outputs: [{id: "validationFacts", to: "P", kind: "ValidationFacts", acceptedBy: "L.accepted"}]

	control: {
		invariants: ["root schema accepted", "promotion gate accepted", "runner boundary accepted", "mutation admissibility accepted"]
		rejects: ["agent_claims_policy", "runner_claims_policy", "adapter_claims_policy", "mutation_before_legitimation", "post_mutation_projection"]
		acceptance: ["A.accepted == true", "all gates accepted", "len(ambiguity) == 0"]
	}
}
