# Review policy

1. Material changes land by pull request with a named reviewer from a different role than the author (architect, formal methods, or V and V).
2. Claim-status changes require evidence in the PR body: source commit, artifact path, and the audit performed.
3. Lean changes require the proof dependency audit in `validation/vv-plan.md`: assumptions, axioms used, sorry/admit scan, dependency graph, semantic match statement.
4. Failure classifications, used in reviews and in the registry: implementation counterexample, framework inconsistency, discriminating empirical failure.
5. Migration from v1 is reviewed material only, with source commit and claim-status provenance recorded in `governance/provenance.md`. No wholesale copy.
6. Promotion of this repository from candidate to canonical requires JD's approval of the promotion ADR (gate G5).

Human-Curated, AI-Enabled (HCAE)
