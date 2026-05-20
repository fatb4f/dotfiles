# Bats-core instructions

Use Bats for generated CLI behavior and black-box command contracts.

Prefer tests that show:

```txt
setup fixture
run command
assert status
assert stdout/stderr/files
cleanup
```

Use ShellSpec instead for sourceable function or helper-library tests.
