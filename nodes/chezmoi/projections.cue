package chezmoi

retrieveLeaf: {
	id:            "leaf.chezmoi.source"
	parentNode:    "R"
	nodeID:        node.id
	nodeRoot:      node.root
	sourceSurface: node.surfaces.source.path

	claim: "chezmoi is the dotfiles source/materialization surface"
}
