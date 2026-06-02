package flowproof

import (
	"context"
	"encoding/json"
	"path/filepath"
	"strings"
	"testing"
)

func TestRunProducesReport(t *testing.T) {
	repoRoot, err := FindRepoRoot()
	if err != nil {
		t.Fatal(err)
	}

	reportJSON, err := Run(context.Background(), repoRoot)
	if err != nil {
		t.Fatal(err)
	}

	var report map[string]any
	if err := json.Unmarshal(reportJSON, &report); err != nil {
		t.Fatal(err)
	}
	if report["schemaVersion"] != "cuerail.hookrailFlowReport.v1" {
		t.Fatalf("schemaVersion = %v", report["schemaVersion"])
	}
	if report["taskKind"] != "gopls" {
		t.Fatalf("taskKind = %v", report["taskKind"])
	}

	evidence, ok := report["evidence"].(map[string]any)
	if !ok {
		t.Fatalf("evidence has type %T", report["evidence"])
	}
	if evidence["source"] != "gopls-mcp" {
		t.Fatalf("evidence.source = %v", evidence["source"])
	}
	if evidence["status"] != "ok" {
		t.Fatalf("evidence.status = %v", evidence["status"])
	}
	if got := evidence["diagnostics"].(string); !strings.Contains(got, "No diagnostics.") {
		t.Fatalf("diagnostics = %q", got)
	}

	trace, ok := evidence["runtimeTrace"].(map[string]any)
	if !ok {
		t.Fatalf("runtimeTrace has type %T", evidence["runtimeTrace"])
	}
	good := trace["good"].(map[string]any)
	broad := good["broadInputSurface"].(map[string]any)
	projected := good["projectedContextSurface"].(map[string]any)
	if projected["bytes"].(float64) >= broad["bytes"].(float64) {
		t.Fatalf("projected bytes = %v, broad bytes = %v", projected["bytes"], broad["bytes"])
	}
	if len(good["exposedFiles"].([]any)) == 0 {
		t.Fatalf("accepted trace exposed no files")
	}

	rejected := trace["rejected"].(map[string]any)
	if got := len(rejected["exposedFiles"].([]any)); got != 0 {
		t.Fatalf("rejected trace exposed %d files", got)
	}
	if rejected["projectedContextSurface"].(map[string]any)["bytes"].(float64) != 0 {
		t.Fatalf("rejected projected bytes = %v", rejected["projectedContextSurface"])
	}
}

func TestFindRepoRoot(t *testing.T) {
	repoRoot, err := FindRepoRoot()
	if err != nil {
		t.Fatal(err)
	}
	if got, want := filepath.Base(repoRoot), "dotfiles"; got != want {
		t.Fatalf("repo root = %s, want basename %s", repoRoot, want)
	}
}
