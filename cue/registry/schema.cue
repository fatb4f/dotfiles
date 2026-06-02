package registry

import "list"

#PathRole: "policy" | "adapter" | "bootstrap" | "config" | "generated" | "legacy"

#AuthorityOwner: "dotfiles" | "frame" | "chezmoi" | "shell-wrap"

#RetrievalIntent: "inspect_policy" | "inspect_adapter" | "inspect_bootstrap" | "inspect_config" | "inspect_generated" | "inspect_legacy"

#ValidationGate: {
	id: string
	kind: "path_scope" | "route_scope" | "budget" | "override"
	detail: string
	path?: string
}

#AuthorityNode: {
	id: string
	primaryPath: string
	paths: [...string]
	role: #PathRole
	owner: #AuthorityOwner
	intent: #RetrievalIntent
	routeID: string
	allowedRoutes: [...string]
	forbiddenRoutes: [...string]
	validationGates: [...#ValidationGate]
	maxResults: int & >=0
	tokenBudget: int & >=0
}

#RetrievalRoute: {
	id: string
	intent: #RetrievalIntent
	appliesTo: [...string]
	server_cmd: [...string]
	tool_name: string
	tool_args: [string]: _
	cwd: string
	timeout_ms: int & >=0
	maxTokens: int & >=0
	allowGenerated: *false | bool
	allowLegacy: *false | bool
}

#DotfilesRegistry: {
	nodes: [string]: #AuthorityNode
	routes: [string]: #RetrievalRoute
}

#RegistryQuery: {
	path: string
	objective: #RetrievalIntent
	allowGenerated: *false | bool
	allowLegacy: *false | bool
}

#RetrievalPlan: {
	id: string
	objective: #RetrievalIntent
	node: #AuthorityNode
	route: #RetrievalRoute
	request: {
		request_id: string
		server_cmd: [...string]
		tool_name: string
		tool_args: [string]: _
		cwd: string
		timeout_ms: int & >=0
	}
	gates: [...#ValidationGate]
}

#RegistrySelection: {
	registry: #DotfilesRegistry
	query: #RegistryQuery

	plan: #RetrievalPlan & {}

	if query.objective == registry.nodes.cuePolicy.intent && list.Contains(registry.nodes.cuePolicy.paths, query.path) {
		plan: {
			id:       registry.nodes.cuePolicy.id
			objective: query.objective
			node:     registry.nodes.cuePolicy
			route:    registry.routes.inspectCuePolicy
			request: {
				request_id: "\(query.objective)-\(registry.nodes.cuePolicy.id)"
				server_cmd: registry.routes.inspectCuePolicy.server_cmd
				tool_name:  registry.routes.inspectCuePolicy.tool_name
				tool_args:  registry.routes.inspectCuePolicy.tool_args
				cwd:        registry.routes.inspectCuePolicy.cwd
				timeout_ms: registry.routes.inspectCuePolicy.timeout_ms
			}
			gates: registry.nodes.cuePolicy.validationGates
		}
	}

	if query.objective == registry.nodes.dotctlAdapter.intent && list.Contains(registry.nodes.dotctlAdapter.paths, query.path) {
		plan: {
			id:       registry.nodes.dotctlAdapter.id
			objective: query.objective
			node:     registry.nodes.dotctlAdapter
			route:    registry.routes.inspectDotctlAdapter
			request: {
				request_id: "\(query.objective)-\(registry.nodes.dotctlAdapter.id)"
				server_cmd: registry.routes.inspectDotctlAdapter.server_cmd
				tool_name:  registry.routes.inspectDotctlAdapter.tool_name
				tool_args:  registry.routes.inspectDotctlAdapter.tool_args
				cwd:        registry.routes.inspectDotctlAdapter.cwd
				timeout_ms: registry.routes.inspectDotctlAdapter.timeout_ms
			}
			gates: registry.nodes.dotctlAdapter.validationGates
		}
	}

	if query.objective == registry.nodes.bootstrap.intent && list.Contains(registry.nodes.bootstrap.paths, query.path) {
		plan: {
			id:       registry.nodes.bootstrap.id
			objective: query.objective
			node:     registry.nodes.bootstrap
			route:    registry.routes.inspectBootstrap
			request: {
				request_id: "\(query.objective)-\(registry.nodes.bootstrap.id)"
				server_cmd: registry.routes.inspectBootstrap.server_cmd
				tool_name:  registry.routes.inspectBootstrap.tool_name
				tool_args:  registry.routes.inspectBootstrap.tool_args
				cwd:        registry.routes.inspectBootstrap.cwd
				timeout_ms: registry.routes.inspectBootstrap.timeout_ms
			}
			gates: registry.nodes.bootstrap.validationGates
		}
	}

	if query.objective == registry.nodes.hyprlandConfig.intent && list.Contains(registry.nodes.hyprlandConfig.paths, query.path) {
		plan: {
			id:       registry.nodes.hyprlandConfig.id
			objective: query.objective
			node:     registry.nodes.hyprlandConfig
			route:    registry.routes.inspectHyprlandConfig
			request: {
				request_id: "\(query.objective)-\(registry.nodes.hyprlandConfig.id)"
				server_cmd: registry.routes.inspectHyprlandConfig.server_cmd
				tool_name:  registry.routes.inspectHyprlandConfig.tool_name
				tool_args:  registry.routes.inspectHyprlandConfig.tool_args
				cwd:        registry.routes.inspectHyprlandConfig.cwd
				timeout_ms: registry.routes.inspectHyprlandConfig.timeout_ms
			}
			gates: registry.nodes.hyprlandConfig.validationGates
		}
	}

	if query.objective == registry.nodes.weztermConfig.intent && list.Contains(registry.nodes.weztermConfig.paths, query.path) {
		plan: {
			id:       registry.nodes.weztermConfig.id
			objective: query.objective
			node:     registry.nodes.weztermConfig
			route:    registry.routes.inspectWeztermConfig
			request: {
				request_id: "\(query.objective)-\(registry.nodes.weztermConfig.id)"
				server_cmd: registry.routes.inspectWeztermConfig.server_cmd
				tool_name:  registry.routes.inspectWeztermConfig.tool_name
				tool_args:  registry.routes.inspectWeztermConfig.tool_args
				cwd:        registry.routes.inspectWeztermConfig.cwd
				timeout_ms: registry.routes.inspectWeztermConfig.timeout_ms
			}
			gates: registry.nodes.weztermConfig.validationGates
		}
	}

	if query.objective == registry.nodes.zshConfig.intent && list.Contains(registry.nodes.zshConfig.paths, query.path) {
		plan: {
			id:       registry.nodes.zshConfig.id
			objective: query.objective
			node:     registry.nodes.zshConfig
			route:    registry.routes.inspectZshConfig
			request: {
				request_id: "\(query.objective)-\(registry.nodes.zshConfig.id)"
				server_cmd: registry.routes.inspectZshConfig.server_cmd
				tool_name:  registry.routes.inspectZshConfig.tool_name
				tool_args:  registry.routes.inspectZshConfig.tool_args
				cwd:        registry.routes.inspectZshConfig.cwd
				timeout_ms: registry.routes.inspectZshConfig.timeout_ms
			}
			gates: registry.nodes.zshConfig.validationGates
		}
	}

	if query.objective == registry.nodes.nvimConfig.intent && list.Contains(registry.nodes.nvimConfig.paths, query.path) {
		plan: {
			id:       registry.nodes.nvimConfig.id
			objective: query.objective
			node:     registry.nodes.nvimConfig
			route:    registry.routes.inspectNvimConfig
			request: {
				request_id: "\(query.objective)-\(registry.nodes.nvimConfig.id)"
				server_cmd: registry.routes.inspectNvimConfig.server_cmd
				tool_name:  registry.routes.inspectNvimConfig.tool_name
				tool_args:  registry.routes.inspectNvimConfig.tool_args
				cwd:        registry.routes.inspectNvimConfig.cwd
				timeout_ms: registry.routes.inspectNvimConfig.timeout_ms
			}
			gates: registry.nodes.nvimConfig.validationGates
		}
	}

	if query.objective == registry.nodes.generatedProjections.intent && list.Contains(registry.nodes.generatedProjections.paths, query.path) && query.allowGenerated {
		plan: {
			id:       registry.nodes.generatedProjections.id
			objective: query.objective
			node:     registry.nodes.generatedProjections
			route:    registry.routes.inspectGeneratedProjections
			request: {
				request_id: "\(query.objective)-\(registry.nodes.generatedProjections.id)"
				server_cmd: registry.routes.inspectGeneratedProjections.server_cmd
				tool_name:  registry.routes.inspectGeneratedProjections.tool_name
				tool_args:  registry.routes.inspectGeneratedProjections.tool_args
				cwd:        registry.routes.inspectGeneratedProjections.cwd
				timeout_ms: registry.routes.inspectGeneratedProjections.timeout_ms
			}
			gates: registry.nodes.generatedProjections.validationGates
		}
	}

	if query.objective == registry.nodes.yaziConfig.intent && list.Contains(registry.nodes.yaziConfig.paths, query.path) {
		plan: {
			id:       registry.nodes.yaziConfig.id
			objective: query.objective
			node:     registry.nodes.yaziConfig
			route:    registry.routes.inspectYaziConfig
			request: {
				request_id: "\(query.objective)-\(registry.nodes.yaziConfig.id)"
				server_cmd: registry.routes.inspectYaziConfig.server_cmd
				tool_name:  registry.routes.inspectYaziConfig.tool_name
				tool_args:  registry.routes.inspectYaziConfig.tool_args
				cwd:        registry.routes.inspectYaziConfig.cwd
				timeout_ms: registry.routes.inspectYaziConfig.timeout_ms
			}
			gates: registry.nodes.yaziConfig.validationGates
		}
	}

	if query.objective == registry.nodes.legacySessionSurfaces.intent && list.Contains(registry.nodes.legacySessionSurfaces.paths, query.path) && query.allowLegacy {
		plan: {
			id:       registry.nodes.legacySessionSurfaces.id
			objective: query.objective
			node:     registry.nodes.legacySessionSurfaces
			route:    registry.routes.inspectLegacySessionSurfaces
			request: {
				request_id: "\(query.objective)-\(registry.nodes.legacySessionSurfaces.id)"
				server_cmd: registry.routes.inspectLegacySessionSurfaces.server_cmd
				tool_name:  registry.routes.inspectLegacySessionSurfaces.tool_name
				tool_args:  registry.routes.inspectLegacySessionSurfaces.tool_args
				cwd:        registry.routes.inspectLegacySessionSurfaces.cwd
				timeout_ms: registry.routes.inspectLegacySessionSurfaces.timeout_ms
			}
			gates: registry.nodes.legacySessionSurfaces.validationGates
		}
	}
}
