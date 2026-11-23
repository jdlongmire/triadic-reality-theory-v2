# Independent V and V plan (WP-TRT2-003)

## Proof audit (required for any theorem claim)

1. Statement match: the formal statement is compared line by line to the claimed theorem in the registry.
2. Axiom audit: `#print axioms` output (or equivalent) is recorded; any axiom beyond the standard Lean set is named and dispositioned.
3. Sorry/admit scan: zero tolerance in artifacts claimed as proven.
4. Dependency graph: downstream dependents of each audited result are listed, so the blast radius of a bad axiom is known before, not after, reliance. The LRT audit is the cautionary example: one inconsistent axiom had exactly one dependent, the other had none, and that was only known because the graph was walked.
5. Reproduction: a clean build from the pinned commit, by the V and V lead, not only by the author.

## Countermodel suite

Negative tests per `countermodels/README.md`, run at each gate G2 and G3.

## CI governance

The repository CI (`.github/workflows/ci.yml`) runs the governance check in `tools/check_governance.py`: required baseline files present, claim registry present, no sorry/admit in any `.lean` file. CI green is necessary, never sufficient, for a claim promotion.

## Gates

This plan serves gates G1 to G4 in `governance/promotion-adr-draft.md`. G5 is JD's.

Human-Curated, AI-Enabled (HCAE)
