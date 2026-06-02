package flowproof

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"
	"github.com/modelcontextprotocol/go-sdk/mcp"
)

func taskFunc(ctx context.Context, repoRoot string, responses projectionResponses) flow.TaskFunc {
	return func(v cue.Value) (flow.Runner, error) {
		kind, err := v.LookupPath(cue.ParsePath("kind")).String()
		if err != nil {
			return nil, fmt.Errorf("task kind: %w", err)
		}
		if kind != "gopls" {
			return nil, nil
		}
		return flow.RunnerFunc(func(t *flow.Task) error {
			return runGoplsTask(ctx, repoRoot, t, responses)
		}), nil
	}
}

func runGoplsTask(ctx context.Context, repoRoot string, task *flow.Task, responses projectionResponses) error {
	if repoRoot == "" {
		return fmt.Errorf("repo root required")
	}

	value := task.Value()
	moduleRel, err := value.LookupPath(cue.ParsePath("moduleDir")).String()
	if err != nil {
		return fmt.Errorf("task moduleDir: %w", err)
	}
	moduleDir := filepath.Join(repoRoot, filepath.FromSlash(moduleRel))

	filesVal := value.LookupPath(cue.ParsePath("checkedFiles"))
	iter, err := filesVal.List()
	if err != nil {
		return fmt.Errorf("task checkedFiles: %w", err)
	}
	var files []string
	for iter.Next() {
		name, err := iter.Value().String()
		if err != nil {
			return fmt.Errorf("task checkedFiles entry: %w", err)
		}
		files = append(files, filepath.Join(moduleDir, filepath.FromSlash(name)))
	}
	if len(files) == 0 {
		return fmt.Errorf("task checkedFiles required")
	}

	workspaceSummary, diagnostics, err := collectGoplsFacts(ctx, moduleDir, files)
	if err != nil {
		return err
	}

	evidence := map[string]any{
		"schemaVersion":    "cuerail.hookrailFlowEvidence.v1",
		"source":           "gopls-mcp",
		"status":           "ok",
		"moduleDir":        moduleRel,
		"checkedFiles":     relPaths(moduleDir, files),
		"workspaceSummary": workspaceSummary,
		"diagnostics":      diagnostics,
		"runtimeTrace":     buildRuntimeTrace(repoRoot, responses),
	}

	return task.Fill(map[string]any{
		"workspaceSummary": workspaceSummary,
		"diagnostics":      diagnostics,
		"evidence":         evidence,
	})
}

func buildRuntimeTrace(repoRoot string, responses projectionResponses) map[string]any {
	broadPaths := []string{
		"cue/patterns/domain/schema.cue",
		"cue/patterns/projections/codex-slice.cue",
		"cue/patterns/projections/cue-flow-fact-slice.cue",
		"cue/patterns/projections/authorization-evidence-slice.cue",
		"cue/patterns/projections/promotion-by-unification-slice.cue",
		"cue/patterns/projections/promoted-projection-binding-slice.cue",
		"shell-wrap/src/hookrail/cmd/hookrail-flow/main.go",
		"shell-wrap/src/hookrail/internal/flowproof/flow.go",
		"shell-wrap/src/hookrail/internal/flowproof/mcp.go",
		"shell-wrap/src/hookrail/internal/flowproof/flow_test.go",
	}
	goodProjected := loadedFilePaths(responses.Good.Promotion.ExposedFiles)

	return map[string]any{
		"schemaVersion": "cuerail.runtimeTraceBundle.v1",
		"method":        "rough byte/line/file estimate; not tokenizer exact",
		"good": map[string]any{
			"runID":                       "fixture.good.selected-pattern",
			"selectedPatternIDs":          responses.Good.Promotion.SelectedPatterns,
			"promotionOutcome":            responses.Good.Promotion.PromotionOutcome,
			"exposedFiles":                responses.Good.Promotion.ExposedFiles,
			"deniedLoads":                 []deniedLoadEvidence{},
			"relationRefs":                relationRefs(responses.Good.Promotion.ExposedFiles),
			"factRefs":                    factRefs(responses.Good.Promotion.ExposedFiles),
			"adapterActionClassification": "adapter-emits-root-shaped-evidence",
			"broadInputSurface":           estimatePaths(repoRoot, broadPaths),
			"projectedContextSurface":     estimatePaths(repoRoot, goodProjected),
		},
		"rejected": map[string]any{
			"runID":                       "fixture.bad.keyword-relevance",
			"promotionOutcome":            responses.Rejected.Promotion.PromotionOutcome,
			"exposedFiles":                []loadedFileEvidence{},
			"deniedLoads":                 responses.Rejected.Promotion.Diagnostics.DeniedLoads,
			"relationRefs":                responses.Rejected.Promotion.Diagnostics.RelationRefs,
			"factRefs":                    responses.Rejected.Promotion.Diagnostics.FactRefs,
			"adapterActionClassification": "diagnostics-only-no-context-exposure",
			"broadInputSurface":           estimatePaths(repoRoot, broadPaths),
			"projectedContextSurface":     estimatePaths(repoRoot, nil),
		},
	}
}

func loadedFilePaths(files []loadedFileEvidence) []string {
	paths := make([]string, 0, len(files))
	for _, file := range files {
		paths = append(paths, file.Path)
	}
	return paths
}

func relationRefs(files []loadedFileEvidence) []string {
	seen := map[string]bool{}
	var refs []string
	for _, file := range files {
		if file.RelationRef == "" || seen[file.RelationRef] {
			continue
		}
		seen[file.RelationRef] = true
		refs = append(refs, file.RelationRef)
	}
	return refs
}

func factRefs(files []loadedFileEvidence) []string {
	seen := map[string]bool{}
	var refs []string
	for _, file := range files {
		for _, ref := range file.FactRefs {
			if ref == "" || seen[ref] {
				continue
			}
			seen[ref] = true
			refs = append(refs, ref)
		}
	}
	return refs
}

func estimatePaths(repoRoot string, relPaths []string) map[string]any {
	var bytesTotal, linesTotal int
	var filesTotal int
	for _, rel := range relPaths {
		path := filepath.Join(repoRoot, filepath.FromSlash(rel))
		data, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		filesTotal++
		bytesTotal += len(data)
		linesTotal += bytes.Count(data, []byte("\n"))
		if len(data) > 0 && data[len(data)-1] != '\n' {
			linesTotal++
		}
	}
	return map[string]any{
		"method": "rough bytes and newline-counted lines from repo files",
		"bytes":  bytesTotal,
		"lines":  linesTotal,
		"files":  filesTotal,
	}
}

func collectGoplsFacts(ctx context.Context, moduleDir string, files []string) (string, string, error) {
	cmd := exec.CommandContext(ctx, "gopls", "mcp")
	cmd.Dir = moduleDir
	cmd.Env = os.Environ()

	client := mcp.NewClient(&mcp.Implementation{
		Name:    "hookrail-flow",
		Version: "v0.1.0",
	}, nil)
	session, err := client.Connect(ctx, &mcp.CommandTransport{Command: cmd}, nil)
	if err != nil {
		return "", "", fmt.Errorf("connect to gopls mcp: %w", err)
	}
	defer func() {
		_ = session.Close()
	}()

	workspaceSummary, err := callToolText(ctx, session, "go_workspace", map[string]any{})
	if err != nil {
		return "", "", err
	}
	if strings.Contains(workspaceSummary, "This is not a Go workspace") {
		return "", "", fmt.Errorf("gopls reported non-workspace: %s", workspaceSummary)
	}

	diagnostics, err := callToolText(ctx, session, "go_diagnostics", map[string]any{
		"files": files,
	})
	if err != nil {
		return "", "", err
	}
	if !strings.Contains(diagnostics, "No diagnostics.") {
		return "", "", fmt.Errorf("gopls diagnostics were not clean: %s", diagnostics)
	}

	return workspaceSummary, diagnostics, nil
}

func callToolText(ctx context.Context, session *mcp.ClientSession, name string, args any) (string, error) {
	res, err := session.CallTool(ctx, &mcp.CallToolParams{Name: name, Arguments: args})
	if err != nil {
		return "", fmt.Errorf("%s call failed: %w", name, err)
	}
	var buf bytes.Buffer
	for _, content := range res.Content {
		text, ok := content.(*mcp.TextContent)
		if !ok {
			continue
		}
		buf.WriteString(text.Text)
		if !strings.HasSuffix(text.Text, "\n") {
			buf.WriteByte('\n')
		}
	}
	result := strings.TrimSpace(buf.String())
	if res.IsError {
		return "", fmt.Errorf("%s returned error: %s", name, result)
	}
	if result == "" {
		return "", fmt.Errorf("%s returned empty text", name)
	}
	return result, nil
}

func relPaths(moduleDir string, absFiles []string) []string {
	rel := make([]string, 0, len(absFiles))
	for _, abs := range absFiles {
		if r, err := filepath.Rel(moduleDir, abs); err == nil {
			rel = append(rel, filepath.ToSlash(r))
			continue
		}
		rel = append(rel, filepath.ToSlash(abs))
	}
	return rel
}

func findUp(start, target string) (string, error) {
	dir := start
	for {
		if _, err := os.Stat(filepath.Join(dir, target)); err == nil {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("could not find %s from %s", target, start)
		}
		dir = parent
	}
}

// FindRepoRoot locates the repository root by walking upward until cue.mod/module.cue is found.
func FindRepoRoot() (string, error) {
	start, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("determine working directory: %w", err)
	}
	return findUp(start, filepath.Join("cue.mod", "module.cue"))
}
