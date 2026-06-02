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
