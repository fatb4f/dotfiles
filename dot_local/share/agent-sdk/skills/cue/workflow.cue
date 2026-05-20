package skill

workflow: {
	id: "cue"

	contract: {
		role: "CUE schema, projection, validation, and generated-surface workflow."
		invariants: [
			"Treat CUE as the authority plane.",
			"Treat generated files as projections from authority data.",
			"Keep schema changes paired with validation evidence.",
			"Do not encode runtime policy in shell init when CUE authority exists.",
		]
	}

	topics: {
		schema_change: {
			description: "Modify CUE schemas or manifest contracts."
			triggers: [
				"cue/schemas",
				"manifest.cue",
				"schema validation",
				"CUE contract",
			]
			references: [
				"references/upstream/cue/doc/ref/spec.md",
				"references/upstream/cue/doc/ref/impl.md",
				"references/upstream/cue/doc/context/language-features.md",
			]
			sequence: [
				"identify the authoritative schema package",
				"make the smallest schema-compatible change",
				"run cue fmt on affected CUE files",
				"run cue vet/export checks against representative manifests",
				"report compatibility impact",
			]
			evidence: [
				"cue fmt completed",
				"cue vet or cue export completed",
				"affected manifests remain valid or required migrations are listed",
			]
		}

		projection_contract: {
			description: "Update CUE-backed projection contracts and generated-surface checks."
			triggers: [
				"project-skills",
				"projection manifest",
				"generated surface",
				"materialized references",
			]
			sequence: [
				"inspect manifest fields that drive projection",
				"update schema and projector together when the ABI changes",
				"regenerate projected output",
				"compare projection manifest and file hashes",
			]
			evidence: [
				"project-skills completed",
				"projection manifest changed only as expected",
			]
		}
	}

	unison: {
		schema_projection_change: {
			description: "Coordinate schema changes with projection behavior."
			topics: ["schema_change", "projection_contract"]
			sequence: [
				"change schema",
				"change projector if needed",
				"format and vet CUE",
				"regenerate projection",
				"inspect generated diff",
			]
		}
	}

	report: {
		fields: [
			"schema_surface",
			"projection_surface",
			"validation",
			"compatibility_notes",
		]
	}
}
