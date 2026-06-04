package contracts

#ContractRef:
	"contracts.architecture" |
	"contracts.architecture.foundation" |
	"contracts.cue-flow.loop" |
	"contracts.agentflow.premutation" |
	"contracts.git.mutation" |
	"contracts.git.evidence" |
	"contracts.git.worktree" |
	"contracts.git.patch_stack" |
	"contracts.lifecycle.proof"

#GateRef:
	"architecture-boundary" |
	"root-schema-vet" |
	"promo-gate-vet" |
	"cue-flow-import" |
	"agentflow-premutation" |
	"git-mutation-admission" |
	"git-closeout" |
	"lifecycle-proof"

#EvidenceRef:
	"loaded-files" |
	"denied-loads" |
	"required-mcp-tools" |
	"mcp-rag-resolution" |
	"mcp-flow-composer" |
	"validation-commands" |
	"git-status" |
	"git-diff" |
	"lifecycle-record"

#ContractBundle: {
	id: string

	contracts: [...#ContractRef]
	gates: [...#GateRef]
	evidence: [...#EvidenceRef]

	invariants: #ArchitectureContract
}
