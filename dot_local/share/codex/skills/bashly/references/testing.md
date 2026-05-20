# Testing Bashly projects

Bashly does not automatically create Bats or ShellSpec suites. Implementation work in this repository still includes test work.

## Bats

Use Bats for generated CLI behavior:

- root `--help`
- command `--help`
- success path
- missing required input
- invalid flags or args
- stdout/stderr split
- exit status

Use `assets/bats-cli-contract.bats` as a starter.

## ShellSpec

Use ShellSpec for source-level shell logic:

- helper functions
- command implementation functions
- branch behavior
- mocks/stubs
- edge cases awkward to exercise through the generated CLI

Use `assets/shellspec-helper-spec.sh` as a starter.

## Coverage rule

If CLI behavior changes, add or update a CLI contract test.

If reusable shell logic changes, add or update a source-level spec when practical.

If no test is added, state whether existing coverage proves the change or why the change is not testable.
