package hookrail

#ReviewSurface: {
	schema:       "hookrail.review_surface.v1"
	codexSessionID: string
	gitCommit:    string
	repoRoot:     string
	codexHome:    string

	joinOrder: [...string]

	git: {
		repoRootPath:           string
		statusPath:             string
		commitTypePath:         string
		commitObjectPath:       string
		showFullPath:           string
		nameStatusPath:         string
		patchPath:              string
		treePath:               string
		commitTimePath:         string
		relevantPathsAtCommitPath: string
		relevantPathHistoryPath: string
	}

	codex: {
		sessionIdMatchesPath:    string
		sessionIdFilesPath:      string
		sessionIdContextWindowPath: string
	}

	hooks: {
		candidateDirsPath:       string
		matchesSessionIDPath:    string
		matchesFullCommitPath:   string
		matchesShortCommitPath:  string
		matchesArtifactNamesPath: string
		mtimeListingPath:        string
	}

	objects: {
		relevantPathsAtCommit: [...string]
		relevantFiles:         [...string]
	}

	derived: {
		bundleDir:        string
		reviewSurfacePath: string
		shortCommit:      string
		knownGap:         string
	}
}
