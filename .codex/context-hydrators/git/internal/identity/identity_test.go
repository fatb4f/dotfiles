package identity

import "testing"

func TestContentAndOccurrenceIdentityAreDistinct(t *testing.T) {
	t.Parallel()

	blob := ObjectID{Format: "sha1", Hex: "1111111111111111111111111111111111111111"}
	revisionA := ObjectID{Format: "sha1", Hex: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
	revisionB := ObjectID{Format: "sha1", Hex: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}

	if ContentID(blob) != ContentID(blob) {
		t.Fatal("content identity must be stable")
	}
	if OccurrenceID("repo.fixture", revisionA, "a.txt") == OccurrenceID("repo.fixture", revisionA, "b.txt") {
		t.Fatal("rename must change snapshot occurrence identity")
	}
	if OccurrenceID("repo.fixture", revisionA, "a.txt") == OccurrenceID("repo.fixture", revisionB, "a.txt") {
		t.Fatal("snapshot occurrence identity must bind the resolved revision")
	}
	if PathID("repo.fixture", "a.txt") != PathID("repo.fixture", "a.txt") {
		t.Fatal("path identity must be stable across revisions")
	}
}
