# Issue-local Checks

Executable bottom-check proofs live here for a concrete issue slice when an issue explicitly requests a manifest/check artifact.

Expected file:

```text
bottom.cue
```

Rules:

- The main `manifest.cue` carries bottom-check plans only.
- This package binds concrete proof targets internally.
- Negative checks should fail by structural conflict or bottom.
- Do not rely on missing selectors, stringified expressions, or boolean `isInvalid` flags.

This template directory intentionally does not include an executable bottoming CUE file, so broad repo validation does not fail by default.
