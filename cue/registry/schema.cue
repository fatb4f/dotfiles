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
	node:           #AuthorityNode
	route:          #RetrievalRoute
	query:          #RegistryQuery
	pathMatches:    bool
	intentMatches:  bool
	overrideAllowed: bool
	selected:       bool
}

#CandidateSelection: #SelectionGate & {
	node:  #AuthorityNode
	route: #RetrievalRoute
	query: #RegistryQuery
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

	_registry: registry
	_query:    query

	plan: #SelectedPlan & {
		for _, candidateNode in _registry.nodes if (#PathMatch & { node: candidateNode, path: _query.path }).matches && _query.objective == candidateNode.intent && _query.objective == _registry.routes[candidateNode.routeID].intent && ((candidateNode.role != "generated" && candidateNode.role != "legacy") || (candidateNode.role == "generated" && _query.allowGenerated && _registry.routes[candidateNode.routeID].allowGenerated) || (candidateNode.role == "legacy" && _query.allowLegacy && _registry.routes[candidateNode.routeID].allowLegacy)) {
			_candidate: #CandidateSelection & {
				node:  candidateNode
				route: _registry.routes[candidateNode.routeID]
				query: _query
				pathMatches: (#PathMatch & {
					node: candidateNode
					path: _query.path
				}).matches
				intentMatches: _query.objective == candidateNode.intent && _query.objective == _registry.routes[candidateNode.routeID].intent
				overrideAllowed: true
				if candidateNode.role == "generated" {
					overrideAllowed: _query.allowGenerated && _registry.routes[candidateNode.routeID].allowGenerated
				}
				if candidateNode.role == "legacy" {
					overrideAllowed: _query.allowLegacy && _registry.routes[candidateNode.routeID].allowLegacy
				}
				selected: pathMatches && intentMatches && overrideAllowed
			}
		}
	}
}
