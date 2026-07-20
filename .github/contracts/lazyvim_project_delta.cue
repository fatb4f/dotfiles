package impl

// Project-owned, data-only delta projected to a trusted project .lazy.lua.
//
// The project delta is authority. Generated Lua is a disposable projection.
// Plugin installation mechanisms and executable locations remain outside this
// contract.

#ExecutableName: #NonEmptyString & =~"^[A-Za-z0-9._+-]+$"

#ExecutableCommand: [#ExecutableName, ...#NonEmptyString]

// Values accepted by the deterministic CUE-to-Lua renderer. Functions, CUE
// bytes, references to runtime Lua values, and raw Lua expressions are not
// representable here.
#LuaValue:
	bool |
		number |
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

	filetypes?: [...#NonEmptyString]
	commands?:  [...#NonEmptyString]
	events?:    [...#NonEmptyString]

	opts?:       #LuaObject
	optsExtend?: [...#OptionPath]
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
	filetypes?:   [...#NonEmptyString]
	rootMarkers?: [...#NonEmptyString]

	// The first element is an executable name resolved from project PATH.
	// Remaining elements are arguments and may contain paths.
	command?: #ExecutableCommand
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
	pluginPatches?: [string]: #PluginPatch

	overrides?: close({
		[Field=!~"^(lsp|formatters|linters)$"]: {
			_invalidField: Field & =~"^(lsp|formatters|linters)$"
		}

		lsp?: [string]:        #LSPOverride
		formatters?: [string]: #FormatterOverride
		linters?: [string]:    #LinterOverride
	})

	// Every entry must resolve as an executable from the project environment.
	requiredExecutables?: [...#ExecutableName]
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
