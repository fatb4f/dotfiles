package hydrator

import (
	"bytes"
	"encoding/json"
	"os"
	"sort"
	"strings"
	"testing"

	"github.com/fatb4f/dotfiles/.codex/context-hydrators/git/internal/testfixture"

	"github.com/fatb4f/dotfiles/.codex/context-hydrators/git/internal/identity"
)

func TestHydrateCommittedRepresentsCommittedTreeWithoutTraversal(t *testing.T) {
	fixture := newFixtureRepository(t)
	observation := hydrateFixture(t, fixture, fixture.Commits["F"])

	if observation.ResolvedRevision.Hex != fixture.Commits["F"] {
		t.Fatalf("resolved revision = %s, want %s", observation.ResolvedRevision.Hex, fixture.Commits["F"])
	}
	if observation.RequestedRevision != fixture.Commits["F"] {
		t.Fatalf("requested revision was not preserved: %q", observation.RequestedRevision)
	}

	byPath := occurrenceMap(observation)
	assertOccurrence(t, byPath, "docs", "040000", "tree")
	assertOccurrence(t, byPath, "docs/guide.txt", "100644", "blob")
	assertOccurrence(t, byPath, "src", "040000", "tree")
	assertOccurrence(t, byPath, "src/main.sh", "100755", "blob")
	assertOccurrence(t, byPath, "guide-link", "120000", "symlink")
	assertOccurrence(t, byPath, "vendor/dependency", "160000", "submodule")

	if byPath["guide-link"].Size == nil || *byPath["guide-link"].Size != int64(len("docs/guide.txt")) {
		t.Fatalf("symlink payload size = %v, want %d", byPath["guide-link"].Size, len("docs/guide.txt"))
	}
	if byPath["vendor/dependency"].Size != nil {
		t.Fatal("submodule occurrence must not carry blob size")
	}
	for path := range byPath {
		if strings.HasPrefix(path, "vendor/dependency/") || strings.HasPrefix(path, "guide-link/") {
			t.Fatalf("hydrator traversed an opaque entry: %s", path)
		}
	}

	paths := make([]string, 0, len(observation.Occurrences))
	for _, occurrence := range observation.Occurrences {
		paths = append(paths, occurrence.Path)
	}
	if !sort.StringsAreSorted(paths) {
		t.Fatalf("occurrences are not canonically sorted: %v", paths)
	}
}

func TestHydrateCommittedIsByteDeterministic(t *testing.T) {
	fixture := newFixtureRepository(t)
	request := fixtureRequest(fixture, fixture.Commits["F"])

	first, err := HydrateCommitted(request, DefaultConfig())
	if err != nil {
		t.Fatalf("first hydration: %v", err)
	}
	firstJSON, err := MarshalCanonical(first)
	if err != nil {
		t.Fatalf("marshal first hydration: %v", err)
	}

	t.Setenv("TZ", "Pacific/Kiritimati")
	t.Setenv("LC_ALL", "C")
	t.Setenv("LANG", "C")
	second, err := HydrateCommitted(request, DefaultConfig())
	if err != nil {
		t.Fatalf("second hydration: %v", err)
	}
	secondJSON, err := MarshalCanonical(second)
	if err != nil {
		t.Fatalf("marshal second hydration: %v", err)
	}
	if !bytes.Equal(firstJSON, secondJSON) {
		t.Fatalf("normalized output changed:\nfirst:  %s\nsecond: %s", firstJSON, secondJSON)
	}
	if bytes.Contains(firstJSON, []byte(fixture.Path)) {
		t.Fatal("normalized output leaked a host path")
	}
}

func TestRevisionSelectorsBindToExactCommit(t *testing.T) {
	fixture := newFixtureRepository(t)

	branch := hydrateFixture(t, fixture, "main")
	if branch.ResolvedRevision.Hex != fixture.Commits["F"] {
		t.Fatalf("branch resolved to %s, want %s", branch.ResolvedRevision.Hex, fixture.Commits["F"])
	}
	tag := hydrateFixture(t, fixture, "fixture-a")
	if tag.ResolvedRevision.Hex != fixture.Commits["A"] {
		t.Fatalf("tag resolved to %s, want %s", tag.ResolvedRevision.Hex, fixture.Commits["A"])
	}

	boundRequest := fixtureRequest(fixture, branch.ResolvedRevision.Hex)
	before, err := HydrateCommitted(boundRequest, DefaultConfig())
	if err != nil {
		t.Fatalf("hydrate bound commit before branch move: %v", err)
	}
	if err := testfixture.UpdateRef(fixture, "refs/heads/main", fixture.Commits["A"]); err != nil {
		t.Fatalf("move fixture branch: %v", err)
	}
	after, err := HydrateCommitted(boundRequest, DefaultConfig())
	if err != nil {
		t.Fatalf("hydrate bound commit after branch move: %v", err)
	}
	beforeJSON, _ := MarshalCanonical(before)
	afterJSON, _ := MarshalCanonical(after)
	if !bytes.Equal(beforeJSON, afterJSON) {
		t.Fatal("exact-commit hydration changed when branch moved")
	}
}

func TestContentAndPathIdentityProperties(t *testing.T) {
	fixture := newFixtureRepository(t)
	observations := map[string]Observation{}
	for _, name := range []string{"A", "B", "C", "D", "E", "F"} {
		observations[name] = hydrateFixture(t, fixture, fixture.Commits[name])
	}

	aReadme := occurrenceMap(observations["A"])["docs/readme.txt"]
	bGuide := occurrenceMap(observations["B"])["docs/guide.txt"]
	if identity.ContentID(aReadme.ObjectID) != identity.ContentID(bGuide.ObjectID) {
		t.Fatal("rename-only mutation changed content identity")
	}
	if identity.PathID("repo.fixture", aReadme.Path) == identity.PathID("repo.fixture", bGuide.Path) {
		t.Fatal("rename-only mutation preserved path identity")
	}

	cGuide := occurrenceMap(observations["C"])["docs/guide.txt"]
	if identity.ContentID(bGuide.ObjectID) == identity.ContentID(cGuide.ObjectID) {
		t.Fatal("content edit preserved blob identity")
	}
	if identity.PathID("repo.fixture", bGuide.Path) != identity.PathID("repo.fixture", cGuide.Path) {
		t.Fatal("content edit changed path identity")
	}

	cMain := occurrenceMap(observations["C"])["src/main.sh"]
	dMain := occurrenceMap(observations["D"])["src/main.sh"]
	if identity.ContentID(cMain.ObjectID) != identity.ContentID(dMain.ObjectID) || identity.PathID("repo.fixture", cMain.Path) != identity.PathID("repo.fixture", dMain.Path) {
		t.Fatal("unrelated addition changed unaffected entry identities")
	}

	dMain = occurrenceMap(observations["D"])["src/main.sh"]
	eMain := occurrenceMap(observations["E"])["src/main.sh"]
	if identity.ContentID(dMain.ObjectID) != identity.ContentID(eMain.ObjectID) {
		t.Fatal("mode-only change changed blob identity")
	}
	if dMain.Mode == eMain.Mode {
		t.Fatal("mode-only change did not change occurrence metadata")
	}
	if identity.PathID("repo.fixture", dMain.Path) != identity.PathID("repo.fixture", eMain.Path) {
		t.Fatal("mode-only change changed path identity")
	}

	if identity.OccurrenceID("repo.fixture", observations["D"].ResolvedRevision, dMain.Path) == identity.OccurrenceID("repo.fixture", observations["E"].ResolvedRevision, eMain.Path) {
		t.Fatal("snapshot occurrence identity did not bind resolved revision")
	}
}

func TestDecodeRequestIsClosed(t *testing.T) {
	valid := `{"schema":"kernel.git-committed-snapshot-request.v0","repositoryID":"repo.fixture","path":".","revision":"HEAD"}`
	request, err := DecodeRequest(strings.NewReader(valid))
	if err != nil {
		t.Fatalf("decode valid request: %v", err)
	}
	if request.RepositoryID != "repo.fixture" {
		t.Fatalf("repository ID = %q", request.RepositoryID)
	}

	invalid := []string{
		`{"schema":"kernel.git-committed-snapshot-request.v0","repositoryID":"repo.fixture","path":".","revision":"HEAD","extra":true}`,
		valid + ` {}`,
		`{"schema":"wrong","repositoryID":"repo.fixture","path":".","revision":"HEAD"}`,
		`{"schema":"kernel.git-committed-snapshot-request.v0","repositoryID":"INVALID","path":".","revision":"HEAD"}`,
		`{"schema":"kernel.git-committed-snapshot-request.v0","repositoryID":"repo.fixture","path":"../repo","revision":"HEAD"}`,
	}
	for _, document := range invalid {
		if _, err := DecodeRequest(strings.NewReader(document)); err == nil {
			t.Fatalf("invalid request accepted: %s", document)
		}
	}
}

func TestDeclaredGeneratedExecutedReportedPropertySetEquality(t *testing.T) {
	fixture := newFixtureRepository(t)
	declared := append([]string(nil), DeclaredPropertyIDs...)
	generated := append([]string(nil), declared...)
	executed := make([]string, 0, len(generated))

	for _, property := range generated {
		switch property {
		case "determinism", "rename-content-preserved", "content-edit-content-changed", "unrelated-entry-preserved", "mode-change-content-preserved", "symlink-not-traversed", "submodule-not-traversed", "revision-bound":
			_ = hydrateFixture(t, fixture, fixture.Commits["F"])
			executed = append(executed, property)
		default:
			t.Fatalf("generated unknown property %q", property)
		}
	}
	reported := append([]string(nil), executed...)
	assertStringSetEqual(t, "declared/generated", declared, generated)
	assertStringSetEqual(t, "declared/executed", declared, executed)
	assertStringSetEqual(t, "declared/reported", declared, reported)

	report, err := json.Marshal(map[string][]string{
		"declared":  declared,
		"generated": generated,
		"executed":  executed,
		"reported":  reported,
	})
	if err != nil || len(report) == 0 {
		t.Fatalf("marshal property report: %v", err)
	}
}

func hydrateFixture(t *testing.T, fixture testfixture.Repository, revision string) Observation {
	t.Helper()
	observation, err := HydrateCommitted(fixtureRequest(fixture, revision), DefaultConfig())
	if err != nil {
		t.Fatalf("hydrate fixture revision %s: %v", revision, err)
	}
	return observation
}

func fixtureRequest(fixture testfixture.Repository, revision string) Request {
	return Request{
		Schema:       RequestSchema,
		RepositoryID: "repo.fixture",
		Path:         fixture.Path,
		Revision:     revision,
	}
}

func occurrenceMap(observation Observation) map[string]Occurrence {
	result := make(map[string]Occurrence, len(observation.Occurrences))
	for _, occurrence := range observation.Occurrences {
		result[occurrence.Path] = occurrence
	}
	return result
}

func assertOccurrence(t *testing.T, occurrences map[string]Occurrence, path, mode, kind string) {
	t.Helper()
	occurrence, ok := occurrences[path]
	if !ok {
		t.Fatalf("missing occurrence %q", path)
	}
	if occurrence.Mode != mode || occurrence.Kind != kind {
		t.Fatalf("occurrence %q = mode %s kind %s, want %s %s", path, occurrence.Mode, occurrence.Kind, mode, kind)
	}
}

func assertStringSetEqual(t *testing.T, name string, left, right []string) {
	t.Helper()
	leftCopy := append([]string(nil), left...)
	rightCopy := append([]string(nil), right...)
	sort.Strings(leftCopy)
	sort.Strings(rightCopy)
	if strings.Join(leftCopy, "\x00") != strings.Join(rightCopy, "\x00") {
		t.Fatalf("%s mismatch: %v != %v", name, leftCopy, rightCopy)
	}
}

func newFixtureRepository(t *testing.T) testfixture.Repository {
	t.Helper()
	root, err := os.MkdirTemp(".", "fixture-repository-")
	if err != nil {
		t.Fatalf("create fixture directory: %v", err)
	}
	t.Cleanup(func() { _ = os.RemoveAll(root) })
	repository, err := testfixture.Create(root)
	if err != nil {
		t.Fatalf("create fixture repository: %v", err)
	}
	return repository
}
