package contracts

#ArchitectureContract: {
	contracts: {
		bindAgent:     true
		ownInvariants: true
	}

	nodes: {
		areEntities:       true
		areAuthority:      false
		authorizeLoads:    false
		authorizeMutation: false
	}

	patterns: {
		areTaskCentricSkillProjections: true
		areAuthority:                   false
	}

	registry: {
		isPatternInterface: true
		isAuthority:        false
	}

	flow: {
		ownsFSM:            true
		composesContracts:  true
		vetsSelectedBundle: true
	}

	lifecycle: {
		recordsEvidence: true
		isAuthority:     false
	}

	adapters: {
		areAuthority: false
		ownPolicy:    false
	}
}

architecture: #ArchitectureContract
