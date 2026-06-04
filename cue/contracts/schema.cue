package contracts

#ContractRef:
	"contracts.architecture" |
	"contracts.agentflow.premutation" |
	"contracts.git.mutation" |
	"contracts.git.evidence" |
	"contracts.git.worktree" |
	"contracts.git.patch_stack" |
	"contracts.lifecycle.proof"

#GateRef:
	"architecture-boundary" |
	"agentflow-premutation" |
	"git-mutation-admission" |
	"git-closeout" |
	"lifecycle-proof"

#EvidenceRef:
	"loaded-files" |
	"denied-loads" |
	"required-mcp-tools" |
	"validation-commands" |
	"git-status" |
	"git-diff" |
	"lifecycle-record"

#ContractBundle: {
	id: string

	contracts: [...#ContractRef]
	gates:     [...#GateRef]
	evidence:  [...#EvidenceRef]

	invariants: #ArchitectureContract
}
