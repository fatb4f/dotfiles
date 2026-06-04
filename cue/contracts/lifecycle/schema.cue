package lifecycle

#LifecycleProof: {
	id:        string
	objective: string

	loadedFiles: [...{
		path:         string
		authorizedBy: string
		reason:       string
	}]

	deniedLoads: [...{
		path:   string
		reason: string
	}]

	requiredTools: [...string]
	validations: [...{
		command: string
		result:  "passed" | "failed" | "not-run"
		evidence?: string
	}]

	closeout: {
		gitStatusObserved: bool
		diffObserved:      bool
		commitRequired:    bool
		commitPerformed:   bool
	}
}
