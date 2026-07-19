# go-lang

## Path

```text id="xvmzgx"
1. Go module basics
2. Go structs/errors/tests
3. Tiny CLI emits JSON
4. go-git reads repo facts
5. CUE validates emitted facts
6. CUE defines request/result contracts
7. Go adapter conforms to those contracts
8. Optional: projected Go types/codegen later
```

## Why not add CUE immediately?

Because you need one concrete thing for CUE to constrain.

First target:

```bash id="lvfluw"
gitfacts inspect --path .
```

Emits:

```json id="w7a785"
{
  "path": ".",
  "headRef": "refs/heads/main",
  "headHash": "abc123",
  "isClean": true
}
```

Then CUE becomes useful.

## Minimal CUE phase

Learn only these first:

| CUE item                 | Purpose                      |
| ------------------------ | ---------------------------- |
| definitions: `#RepoFact` | schema/contract              |
| unification              | combine constraints + values |
| closed structs           | prevent extra fields         |
| regex/string constraints | validate refs, hashes, paths |
| `cue vet`                | validate JSON against CUE    |
| `cue export`             | emit concrete validated data |

CUE positions itself as a tool for validating data, writing schemas, and enforcing policy, which matches your adapter-boundary use case. `cue vet` validates CUE and non-CUE data files, while `cue export` evaluates CUE and emits concrete JSON/YAML-style data for other tools. ([CUE][1])

## First CUE contract

```cue id="0s8psi"
package contracts

#NonEmptyString: string & !=""

#GitRef: string & =~"^refs/(heads|tags)/.+$"
#GitHash: string & =~"^[0-9a-f]{40}$"

#RepoFact: {
	path:     #NonEmptyString
	headRef:  #GitRef
	headHash: #GitHash
	isClean:  bool
}
```

Validate Go output:

```bash id="9vy8dd"
go run ./cmd/gitfacts inspect --path . > /tmp/repo-fact.json

cue vet /tmp/repo-fact.json contracts/repo_fact.cue -d '#RepoFact'
```

## Then add request contracts

```cue id="9b0w92"
package contracts

#InspectRequest: {
	path:          string & !=""
	includeStatus: bool | *true
}

#InspectResult: #RepoFact
```

Then your control plane becomes:

```text id="1cwqq6"
request.json
  ↓ cue vet against #InspectRequest
Go CLI
  ↓ go-git
result.json
  ↓ cue vet against #InspectResult
```

## Codegen comes later

Do **manual Go structs first**:

```go id="p5ev0j"
type InspectRequest struct {
	Path          string `json:"path"`
	IncludeStatus bool `json:"includeStatus"`
}

type RepoFact struct {
	Path     string `json:"path"`
	HeadRef  string `json:"headRef"`
	HeadHash string `json:"headHash"`
	IsClean  bool   `json:"isClean"`
}
```

Then later investigate CUE’s experimental Go type generation path. The CUE command docs list `exp gengotypes` under experimental commands, so treat it as useful but not as your foundation. ([CUE][2])

## Final learning stack

```text id="dh1m5g"
Go tutorial:
  modules
  packages
  errors
  tests

Go by Example:
  structs
  interfaces
  JSON
  CLI flags
  files
  directories
  testing

go-git:
  PlainOpen
  Head
  Worktree
  Status
  Add
  Commit
  Log

CUE:
  definitions
  unification
  closed structs
  constraints
  cue vet
  cue export
```

Rule of thumb:

```text id="i0eyhh"
Go performs.
go-git observes/mutates.
CUE admits, rejects, and projects.
```

[1]: https://cuelang.org/docs/reference/command/cue-help/?utm_source=chatgpt.com "cue help"
[2]: https://cuelang.org/docs/reference/command/cue-help-exp/?utm_source=chatgpt.com "cue help exp"
