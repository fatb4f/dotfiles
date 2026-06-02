package workspaces

#Workspace: {
	id:    =~"^[a-z0-9][a-z0-9._-]*$"
	label: string | *id
	root:  string

	wezterm: {
		workspace: string | *id
	}

	managed: bool | *true
}

#ScratchDiscovery: {
	fd: {
		roots: [...string]
		excludes: [...string]
	}
	zoxide:  bool | *true
	history: bool | *true
}

manifest: {
	workspaces: {
		dots: #Workspace & {
			id:    "dots"
			label: "dotfiles"
			root:  "$HOME/src/dotfiles"
			wezterm: workspace: "dots"
		}
	}

	scratch: #ScratchDiscovery & {
		fd: {
			roots: [
				"$HOME/src",
			]
			excludes: [
				"node_modules",
				".cache",
				".venv",
				"target",
				"vendor",
			]
		}

		zoxide:  true
		history: true
	}
}
