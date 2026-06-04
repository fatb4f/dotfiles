package patterns

#SkillRole: "primary" | "support" | "validator" | "closeout"

#Pattern: {
	id:      string
	summary: string

	task: {
		objectiveClass: string
		action:         string
	}

	entities: [...string]

	skills: [...{
		id:   string
		role: #SkillRole
	}]

	requires: {
		contracts?: [...string]
		gates?:     [...string]
		evidence?:  [...string]
	}

	produces: {
		flowTasks?:  [...string]
		projection?: string
	}

	mutation: {
		allowed:            bool
		admissionContract?: string
	}
}
