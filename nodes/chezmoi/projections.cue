package chezmoi

sourceSurfaceProjection: {
	id:     "chezmoi.source-surface"
	nodeID: node.id

	readRoots: [
		node.surfaces.source.path,
		node.surfaces.config.path,
		node.surfaces.rootMarker.path,
	]

	forbiddenUntilRetrievalAccepted: [
		"recursive chezmoi scan",
		"mutation through chezmoi apply",
		"treat chezmoi source presence as policy authority",
	]
}
