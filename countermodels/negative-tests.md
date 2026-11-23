# Negative tests

Tests designed to break v2 claims. Each names the target, the construction, and the expected result if the framework is sound. Status: specified, not yet run against a formal model (TRT-M0 does not exist yet).

## NT-1: History-reset operator (targets TO-1 via PR #2 contract)

Define Actualize so that each step discards the prior history and returns a fresh one-event history. Under the PR #2 TO-1 implication as stated, Cons holds at every step. Expected sound result: the proof contract must exclude this operator through an explicit record-preservation (extension) hypothesis. If it does not, TO-1 is vacuous. Classification if it succeeds against a future proof: framework inconsistency in the contract, not an implementation bug.

## NT-2: Vacuous admissibility (targets TO-1)

Define Adm so restrictively that no event sequence beyond the base history is reachable. The conditional then holds vacuously. Guard already present in the contract (nonempty reachable sequence required); this test re-runs against any TRT-M0 instantiation to confirm the guard is discharged with an actual sequence, not asserted.

## NT-3: Context collision (targets TO-1, TO-3)

Take one physical event recorded under two different measurement contexts with incompatible outcome records. If event identity is context-dependent and no context-compatibility relation is declared, Cons over the joint history is undefined. Expected sound result: TRT-M0 either fixes event identity independent of context or declares the compatibility relation. Classification if unresolved: implementation counterexample against the contract.

## NT-4: Constant constructions (targets any Gleason-style or bridge-style import)

Re-express the two LRT audit counterexamples (constant frame function; constant-nonActual) against any v2 axiom that plays a similar structural role. Expected sound result: the axiom either excludes the constant construction by an explicit hypothesis or is recorded as inconsistent and removed. This test is the standing regression test for governance/integrity-findings.md, finding 1.

Human-Curated, AI-Enabled (HCAE)
