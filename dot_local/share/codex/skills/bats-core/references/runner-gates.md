# Bats runner gates and troubleshooting

## Commands

Typical local gates:

```sh
bats tests
bats test
bats --jobs 4 tests
bats --formatter tap tests
bats --formatter junit tests > test-results/bats.xml
```

Use `--jobs` for Bats parallelism.

## Serial tests

Parallel execution is only safe when tests do not share mutable state.

Mark or isolate tests that touch:

- fixed filesystem paths
- fixed ports
- shared caches
- global environment files
- singleton background services

## Tags

Use tags to separate normal contract tests from heavier probes when the repo
already uses a tag convention.

Recommended categories:

```txt
contract
smoke
integration
network
system
slow
```

Normal validation should run contract/smoke tests only unless the task requires
a heavier gate.

## Common failures

| Symptom | Likely cause | Repair |
|---|---|---|
| test passes alone but fails in suite | shared state | move state into `$BATS_TEST_TMPDIR` |
| command not found | PATH fixture missing | set CLI path in `setup_file` or `setup` |
| mock ignored | PATH order wrong | prepend mock bin before system PATH |
| output mismatch with colors | ANSI output | disable color or strip only if non-contractual |
| flaky parallel run | shared resources | isolate or run affected tests serially |
