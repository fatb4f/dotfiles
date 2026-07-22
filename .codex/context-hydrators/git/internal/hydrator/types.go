package hydrator

import "github.com/fatb4f/dotfiles/.codex/context-hydrators/git/internal/identity"

const (
	RequestSchema     = "kernel.git-committed-snapshot-request.v0"
	ObservationSchema = "kernel.git-committed-snapshot-observation.v0"

	DefaultHydratorIdentity = "context-git-hydrator"
	DefaultHydratorDigest   = "sha256:00176927d77dd2810f9c6e598616dbf755a17e9d3e03a029ec9758e6d7f12969"
)

type Request struct {
	Schema       string `json:"schema"`
	RepositoryID string `json:"repositoryID"`
	Path         string `json:"path"`
	Revision     string `json:"revision"`
}

type Occurrence struct {
	Path     string            `json:"path"`
	Mode     string            `json:"mode"`
	Kind     string            `json:"kind"`
	ObjectID identity.ObjectID `json:"objectID"`
	Size     *int64            `json:"size,omitempty"`
}

type HydratorIdentity struct {
	Identity string `json:"identity"`
	Digest   string `json:"digest"`
}

type Observation struct {
	Schema            string            `json:"schema"`
	RepositoryID      string            `json:"repositoryID"`
	RequestedRevision string            `json:"requestedRevision"`
	ResolvedRevision  identity.ObjectID `json:"resolvedRevision"`
	RootTree          identity.ObjectID `json:"rootTree"`
	Occurrences       []Occurrence      `json:"occurrences"`
	Hydrator          HydratorIdentity  `json:"hydrator"`
}
