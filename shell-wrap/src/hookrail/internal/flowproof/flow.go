package flowproof

import (
	"context"
	"fmt"
	"path/filepath"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/load"
	"cuelang.org/go/tools/flow"
)

// Run loads the minimal Hookrail CUE flow app, executes its single gopls task,
// and returns the exported JSON report.
func Run(ctx context.Context, repoRoot string) ([]byte, error) {
	if repoRoot == "" {
		return nil, fmt.Errorf("repo root required")
	}

	appDir := filepath.Join(repoRoot, "cue", "hookrail", "flow")
	insts := load.Instances([]string{"."}, &load.Config{Dir: appDir})
	if len(insts) != 1 {
		return nil, fmt.Errorf("expected one CUE instance, got %d", len(insts))
	}
	inst := insts[0]
	if err := inst.Err; err != nil {
		return nil, fmt.Errorf("loading flow app: %w", err)
	}

	cueCtx := cuecontext.New()
	root := cueCtx.BuildInstance(inst)
	if err := root.Err(); err != nil {
		return nil, fmt.Errorf("building flow app: %w", err)
	}

	controller := flow.New(&flow.Config{
		Root: cue.ParsePath("flow"),
	}, root, taskFunc(ctx, repoRoot))
	if err := controller.Run(ctx); err != nil {
		return nil, fmt.Errorf("running flow: %w", err)
	}

	report := controller.Value().LookupPath(cue.ParsePath("report"))
	if !report.Exists() {
		return nil, fmt.Errorf("flow report missing")
	}
	if err := report.Err(); err != nil {
		return nil, fmt.Errorf("flow report invalid: %w", err)
	}
	return report.MarshalJSON()
}
