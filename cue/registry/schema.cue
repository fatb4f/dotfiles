package registry

import "list"

import "strings"

#PathRole: "policy" | "adapter" | "bootstrap" | "config" | "generated" | "legacy"

#AuthorityOwner: "dotfiles" | "frame" | "chezmoi" | "shell-wrap"

#RetrievalIntent: "inspect_policy" | "inspect_adapter" | "inspect_bootstrap" | "inspect_config" | "inspect_generated" | "inspect_legacy"

#ValidationGate: {
	id:     string
	kind:   "path_scope" | "route_scope" | "budget" | "override"
	detail: string
	path?:  string
}

#AuthorityNode: {
	id:          string
	primaryPath: string
	paths: [...string]
	role:    #PathRole
	owner:   #AuthorityOwner
	intent:  #RetrievalIntent
	routeID: string
	allowedRoutes: [...string]
	forbiddenRoutes: [...string]
	validationGates: [...#ValidationGate]
	maxResults:  int & >=0
	tokenBudget: int & >=0
}

#RetrievalRoute: {
	id:     string
	intent: #RetrievalIntent
	appliesTo: [...string]
	server_cmd: [...string]
	tool_name: string
	tool_args: [string]: _
	cwd:            string
	timeout_ms:     int & >=0
	maxTokens:      int & >=0
	allowGenerated: *false | bool
	allowLegacy:    *false | bool
}

#PathMatch: {
	node: #AuthorityNode
	path: string

	matches: path == node.primaryPath || strings.HasPrefix(path, node.primaryPath+"/") || list.Contains(node.paths, path)
}

#DotfilesRegistry: {
	nodes: [string]:  #AuthorityNode
	routes: [string]: #RetrievalRoute
}

#RegistryQuery: {
	path:           string
	objective:      #RetrievalIntent
	allowGenerated: *false | bool
	allowLegacy:    *false | bool
}

#RetrievalPlan: {
	id:        string
	objective: #RetrievalIntent
	node:      #AuthorityNode
	route:     #RetrievalRoute
	request: {
		server_cmd: [...string]
		tool_name: string
		tool_args: [string]: _
		cwd:        string
		timeout_ms: int & >=0
	}
	gates: [...#ValidationGate]
}

#SelectionGate: {
	node:            #AuthorityNode
	route:           #RetrievalRoute
	query:           #RegistryQuery
	pathMatches:     bool
	intentMatches:   bool
	overrideAllowed: bool
	selected:        bool
}

#CandidateSelection: #SelectionGate & {
	node:  #AuthorityNode
	route: #RetrievalRoute
	query: #RegistryQuery
}

#RegistryResolutionError: {
	kind:    "no_match" | "ambiguous" | "blocked"
	message: string
}

#RegistryResolution: {
	registry: #DotfilesRegistry
	query:    #RegistryQuery

	_registry: registry
	_query:    query

	candidates: [...#CandidateSelection] & [
		for _, candidateNode in _registry.nodes {
			_route: _registry.routes[candidateNode.routeID]

			_pathMatches: (#PathMatch & {
				node: candidateNode
				path: _query.path
			}).matches

			_intentMatches: _query.objective == candidateNode.intent && _query.objective == _route.intent

			_overrideAllowed: (candidateNode.role != "generated" && candidateNode.role != "legacy") || (candidateNode.role == "generated" && _query.allowGenerated && _route.allowGenerated) || (candidateNode.role == "legacy" && _query.allowLegacy && _route.allowLegacy)

			{
				node:  candidateNode
				route: _route
				query: _query

				pathMatches:     _pathMatches
				intentMatches:   _intentMatches
				overrideAllowed: _overrideAllowed
				selected:        _pathMatches && _intentMatches && _overrideAllowed
			}
		},
	]

	selected: [...#CandidateSelection] & [
		for _, candidate in candidates if candidate.selected {
			candidate
		},
	]

	blockedCandidates: [...#CandidateSelection] & [
		for _, candidate in candidates if candidate.pathMatches && candidate.intentMatches && !candidate.overrideAllowed {
			candidate
		},
	]

	status: *"none" | "selected" | "ambiguous" | "blocked"
	if len(selected) == 1 {
		status: "selected"
	}
	if len(selected) > 1 {
		status: "ambiguous"
	}
	if len(selected) == 0 && len(blockedCandidates) > 0 {
		status: "blocked"
	}
	if len(selected) == 0 && len(blockedCandidates) == 0 {
		status: "none"
	}

	errors: [...#RegistryResolutionError]
	if len(selected) == 0 && len(blockedCandidates) > 0 {
		errors: [{
			kind:    "blocked"
			message: "matching registry candidate was blocked by override gates"
		}]
	}
	if len(selected) == 0 && len(blockedCandidates) == 0 {
		errors: [{
			kind:    "no_match"
			message: "no registry node matched path and objective"
		}]
	}
	if len(selected) > 1 {
		errors: [{
			kind:    "ambiguous"
			message: "multiple registry nodes matched path and objective"
		}]
	}

	if len(selected) == 1 {
		plan: #SelectedPlan & {
			_candidate: selected[0]
		}
	}
}

#SelectedPlan: #RetrievalPlan & {
	_candidate: #CandidateSelection

	id:        _candidate.node.id
	objective: _candidate.query.objective
	node:      _candidate.node
	route:     _candidate.route
	request: {
		server_cmd: _candidate.route.server_cmd
		tool_name:  _candidate.route.tool_name
		tool_args:  _candidate.route.tool_args
		cwd:        _candidate.route.cwd
		timeout_ms: _candidate.route.timeout_ms
	}
	gates: _candidate.node.validationGates
}

#RegistrySelection: {
	registry: #DotfilesRegistry
	query:    #RegistryQuery

	resolution: #RegistryResolution & {
		registry: registry
		query:    query
	}

	if resolution.status == "selected" {
		plan: resolution.plan
	}
}
