package flowproof

import (
	"context"
	"encoding/json"
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
	responses, err := loadProjectionResponses(repoRoot)
	if err != nil {
		return nil, err
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
	}, root, taskFunc(ctx, repoRoot, responses))
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

type projectionResponses struct {
	Good     normalizedResponse
	Rejected normalizedResponse
}

type normalizedResponse struct {
	RequestID    string                  `json:"requestID"`
	Consumable   consumableState         `json:"consumable"`
	AgentContext *agentConsumableContext `json:"agentContext,omitempty"`
	Diagnostics  *diagnosticsOnly        `json:"diagnostics,omitempty"`
}

type consumableState struct {
	Accepted bool   `json:"accepted"`
	Status   string `json:"status"`
}

type agentConsumableContext struct {
	SelectedPatterns []string             `json:"selectedPatternIDs"`
	ExposedFiles     []loadedFileEvidence `json:"exposedFiles"`
	ProjectedPrompt  string               `json:"projectedPrompt"`
	PromptProjection string               `json:"promptProjection"`
	EvidenceSummary  evidenceSummary      `json:"evidenceSummary"`
	RelationRefs     []string             `json:"relationRefs"`
	FactRefs         []string             `json:"factRefs"`
	Rationale        string               `json:"rationale"`
}

type evidenceSummary struct {
	SelectedPatterns    []string             `json:"selectedPatternIDs"`
	ExposedFiles        []loadedFileEvidence `json:"exposedFiles"`
	AuthorizationSource string               `json:"authorizationSource"`
	RelationRefs        []string             `json:"relationRefs"`
	FactRefs            []string             `json:"factRefs"`
	Rationale           string               `json:"rationale"`
}

type loadedFileEvidence struct {
	Path            string   `json:"path"`
	AuthorizedBy    string   `json:"authorizedBy"`
	SourcePatternID string   `json:"sourcePatternID,omitempty"`
	RelationRef     string   `json:"relationRef"`
	FactRefs        []string `json:"factRefs"`
	Reason          string   `json:"reason"`
}

type diagnosticsOnly struct {
	Status              string               `json:"status"`
	Classification      string               `json:"classification,omitempty"`
	Violations          []string             `json:"violations"`
	MissingRequirements []string             `json:"missingRequirements"`
	Rationale           string               `json:"rationale"`
	DeniedLoads         []deniedLoadEvidence `json:"deniedLoads"`
	RelationRefs        []string             `json:"relationRefs"`
	FactRefs            []string             `json:"factRefs"`
}

type deniedLoadEvidence struct {
	Path                string   `json:"path"`
	DeniedBy            string   `json:"deniedBy"`
	RejectedRelationRef string   `json:"rejectedRelationRef"`
	FactRefs            []string `json:"factRefs"`
	Reason              string   `json:"reason"`
	RequestedBy         string   `json:"requestedBy"`
	Classification      string   `json:"classification"`
}

func loadProjectionResponses(repoRoot string) (projectionResponses, error) {
	insts := load.Instances([]string{"./cue/patterns/projections"}, &load.Config{Dir: repoRoot})
	if len(insts) != 1 {
		return projectionResponses{}, fmt.Errorf("expected one projections CUE instance, got %d", len(insts))
	}
	inst := insts[0]
	if err := inst.Err; err != nil {
		return projectionResponses{}, fmt.Errorf("loading promoted projection binding: %w", err)
	}
	cueCtx := cuecontext.New()
	root := cueCtx.BuildInstance(inst)
	if err := root.Err(); err != nil {
		return projectionResponses{}, fmt.Errorf("building promoted projection binding: %w", err)
	}

	var responses projectionResponses
	good := root.LookupPath(cue.ParsePath("cueFlowPromotedProjectionBindingSlice.fixtures.good.normalizedResponse"))
	if err := decodeValue(good, &responses.Good); err != nil {
		return projectionResponses{}, fmt.Errorf("decode accepted normalized response: %w", err)
	}
	rejected := root.LookupPath(cue.ParsePath("cueFlowPromotedProjectionBindingSlice.fixtures.bad.keywordRelevance.normalizedResponse"))
	if err := decodeValue(rejected, &responses.Rejected); err != nil {
		return projectionResponses{}, fmt.Errorf("decode rejected normalized response: %w", err)
	}
	if _, err := responses.Good.acceptedAgentContext(); err != nil {
		return projectionResponses{}, fmt.Errorf("accepted normalized response: %w", err)
	}
	if _, err := responses.Rejected.diagnosticsOnly(); err != nil {
		return projectionResponses{}, fmt.Errorf("rejected normalized response: %w", err)
	}
	return responses, nil
}

func (r normalizedResponse) acceptedAgentContext() (*agentConsumableContext, error) {
	if !r.Consumable.Accepted {
		return nil, fmt.Errorf("response %q is not accepted", r.RequestID)
	}
	if r.AgentContext == nil {
		return nil, fmt.Errorf("response %q has no agentContext", r.RequestID)
	}
	if r.Diagnostics != nil {
		return nil, fmt.Errorf("response %q exposes diagnostics on accepted response", r.RequestID)
	}
	return r.AgentContext, nil
}

func (r normalizedResponse) diagnosticsOnly() (*diagnosticsOnly, error) {
	if r.Consumable.Accepted {
		return nil, fmt.Errorf("response %q is accepted", r.RequestID)
	}
	if r.Diagnostics == nil {
		return nil, fmt.Errorf("response %q has no diagnostics", r.RequestID)
	}
	if r.AgentContext != nil {
		return nil, fmt.Errorf("response %q exposes agentContext on non-accepted response", r.RequestID)
	}
	return r.Diagnostics, nil
}

func decodeValue(v cue.Value, target any) error {
	if !v.Exists() {
		return fmt.Errorf("value missing")
	}
	if err := v.Err(); err != nil {
		return err
	}
	data, err := v.MarshalJSON()
	if err != nil {
		return err
	}
	return json.Unmarshal(data, target)
}
