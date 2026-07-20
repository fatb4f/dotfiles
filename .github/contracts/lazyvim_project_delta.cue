package impl

import "list"

// Project-owned, data-only delta projected to a trusted project .lazy.lua.
//
// The project delta is authority. Generated Lua is a disposable projection.
// Plugin installation mechanisms and executable locations remain outside this
// contract.

// v1 executable references are bare PATH-resolved command names. A command may
// not be a path, dot entry, or option-like token.
#ExecutableName: #NonEmptyString & =~"^[A-Za-z0-9_][A-Za-z0-9._+-]*$"

#ExecutableCommand: [#ExecutableName, ...#NonEmptyString]

#PluginRepositoryID: #NonEmptyString &
	=~"^[A-Za-z0-9][A-Za-z0-9._-]*/[A-Za-z0-9][A-Za-z0-9._-]*$"

#LSPServerID: #NonEmptyString & =~"^[A-Za-z_][A-Za-z0-9_-]*$"

#FiletypeName: #NonEmptyString & =~"^[A-Za-z0-9][A-Za-z0-9._+-]*$"

// Lua 5.1/LuaJIT numbers are IEEE-754 doubles. v1 admits only integers that
// round-trip exactly through the deterministic CUE-to-Lua projection.
#LuaNumber: int & >=-9007199254740991 & <=9007199254740991

// Values accepted by the deterministic CUE-to-Lua renderer. Functions, CUE
// bytes, references to runtime Lua values, raw Lua expressions, null, and
// non-round-trippable numbers are not representable here.
#LuaValue:
	bool |
		#LuaNumber |
		string |
		[...#LuaValue] |
		{[string]: #LuaValue}

#LuaObject: {
	[string]: #LuaValue
}

// lazy.nvim uses dotted option paths for opts_extend.
#OptionPath: #NonEmptyString &
	=~"^[A-Za-z_][A-Za-z0-9_]*(\\.[A-Za-z_][A-Za-z0-9_]*)*$"

#LazyImport: close({
	[Field=!~"^(module)$"]: {
		_invalidField: Field & =~"^(module)$"
	}

	module: #NonEmptyString
})

// Native lazy.nvim patch surface. Nested maps deep-merge. Nested lists replace
// by default and append only when their dotted path occurs in optsExtend.
#PluginPatch: close({
	[Field=!~"^(filetypes|commands|events|opts|optsExtend)$"]: {
		_invalidField: Field & =~"^(filetypes|commands|events|opts|optsExtend)$"
	}

	filetypes?: [...#FiletypeName]
	commands?:  [...#NonEmptyString]
	events?:    [...#NonEmptyString]

	opts?:       #LuaObject
	optsExtend?: [...#OptionPath]
})

#PluginPatchMap: close({
	[Repository=!~"^[A-Za-z0-9][A-Za-z0-9._-]*/[A-Za-z0-9][A-Za-z0-9._-]*$"]: {
		_invalidRepository: Repository & #PluginRepositoryID
	}
	[string]: #PluginPatch
})

#FormatterOverride: close({
	[Field=!~"^(names)$"]: {
		_invalidField: Field & =~"^(names)$"
	}

	names: #NonEmptyStringList
})

#LinterOverride: close({
	[Field=!~"^(names)$"]: {
		_invalidField: Field & =~"^(names)$"
	}

	names: #NonEmptyStringList
})

#LSPOverride: close({
	[Field=!~"^(settings|filetypes|rootMarkers|command)$"]: {
		_invalidField: Field & =~"^(settings|filetypes|rootMarkers|command)$"
	}

	settings?:    #LuaObject
	filetypes?:   [...#FiletypeName]
	rootMarkers?: [...#NonEmptyString]

	// The first element is an executable name resolved from project PATH.
	// Remaining elements are arguments and may contain paths.
	command?: #ExecutableCommand
})

#LSPOverrideMap: close({
	[Server=!~"^[A-Za-z_][A-Za-z0-9_-]*$"]: {
		_invalidServer: Server & #LSPServerID
	}
	[string]: #LSPOverride
})

#FiletypeFormatterMap: close({
	[Filetype=!~"^[A-Za-z0-9][A-Za-z0-9._+-]*$"]: {
		_invalidFiletype: Filetype & #FiletypeName
	}
	[string]: #FormatterOverride
})

#FiletypeLinterMap: close({
	[Filetype=!~"^[A-Za-z0-9][A-Za-z0-9._+-]*$"]: {
		_invalidFiletype: Filetype & #FiletypeName
	}
	[string]: #LinterOverride
})

#LazyVimProjectDelta: close({
	[Field=!~"^(apiVersion|project|imports|pluginPatches|overrides|requiredExecutables)$"]: {
		_invalidField: Field & =~"^(apiVersion|project|imports|pluginPatches|overrides|requiredExecutables)$"
	}

	apiVersion: "term.fatb4f.dev/lazyvim-delta/v1"
	project:    #NonEmptyString

	// Import order is significant and is preserved in generated Lua.
	imports?: [...#LazyImport]

	// Keys are canonical lazy.nvim repository identifiers. The renderer sorts
	// keys and emits one consolidated patch per repository.
	pluginPatches?: #PluginPatchMap

	overrides?: close({
		[Field=!~"^(lsp|formatters|linters)$"]: {
			_invalidField: Field & =~"^(lsp|formatters|linters)$"
		}

		lsp?:        #LSPOverrideMap
		formatters?: #FiletypeFormatterMap
		linters?:    #FiletypeLinterMap
	})

	// Complete, duplicate-free PATH inventory for generated executable calls.
	requiredExecutables: [...#ExecutableName] | *[]
	for i, executable in requiredExecutables {
		for j, other in requiredExecutables if i < j {
			if executable == other {
				_duplicateExecutable: executable & !=other
			}
		}
	}

	if overrides != _|_ {
		if overrides.lsp != _|_ {
			for _, server in overrides.lsp {
				if server.command != _|_ {
					_commandDeclared: list.Contains(requiredExecutables, server.command[0]) & true
				}
			}
		}
	}
})

// Concrete witness for schema validation. It also documents the intended
// nested projection without becoming a project-specific authority instance.
_lazyVimProjectDeltaSchemaWitness: #LazyVimProjectDelta & {
	apiVersion: "term.fatb4f.dev/lazyvim-delta/v1"
	project:    "schema-witness"

	imports: [{
		module: "lazyvim.plugins.extras.lang.python"
	}]

	pluginPatches: {
		"nvim-treesitter/nvim-treesitter": {
			opts: {
				ensure_installed: ["cue"]
			}
			optsExtend: ["ensure_installed"]
		}
	}

	overrides: {
		lsp: basedpyright: {
			filetypes:   ["python"]
			rootMarkers: ["pyproject.toml", ".git"]
			command:     ["basedpyright-langserver", "--stdio"]
			settings: {
				basedpyright: {
					analysis: {
						typeCheckingMode: "standard"
					}
				}
			}
		}
		formatters: {
			python: names: ["ruff_format"]
			cue: names:    ["cue_fmt"]
		}
		linters: {
			python: names: ["ruff"]
			cue: names:    ["cue"]
		}
	}

	requiredExecutables: ["basedpyright-langserver", "ruff", "cue"]
}
