# Lean workspace

Lean 4 project for WP-TRT2-002 (Formal Methods). The v1 and LRT Lean material is not imported here: the WP-TRT-VIA-0001 D3 audit found two imported LRT axioms inconsistent (see `governance/integrity-findings.md`). Everything in this workspace is new, written against the TO-1 v0.2 contract in `foundations/typed-ontology-contract-v0.1.md` (document v0.2, merged at `b6260da`).

**Claim status: no change.** These files are candidate evidence for gate G2. They promote nothing in `governance/claim-status-registry.md`. A Lean typecheck alone does not discharge TO-1 (see `theorem-obligations/TO-1.md`); discharge needs the audit in `validation/vv-plan.md`, including independent reproduction by the V and V lead.

## Toolchain and build

- Toolchain: `leanprover/lean4:v4.28.0`, pinned in `lean-toolchain`. Lean core only: no Mathlib, no external packages.
- Build: `cd formalization/lean && lake build`
- Proof gate: `python3 tools/check_lean_proofs.py` (from the repository root, after the build). CI runs both on every pull request.
- Dependency graph: `lake env lean DepGraph.lean` (from this directory, after the build).

## Contents

| File | What it holds |
|---|---|
| `TRT2/Contract.lean` | The v0.2 schema, `Cons`, `Adm`, conditions C1 to C3, N1 to N5, L0, the conditional theorem `to1` (via `step_lemma`, which uses C3 only), `adm_step_iff` (A2 as an equivalence) and `closure` (history closure along a run, as sets). |
| `TRT2/Syntax.lean` | The explicit syntax bridge (A1): an instance with `Syntax`, `Sat` over syntax and `enc` induces the schema with `SatRec M r := Sat M (enc r)`; `syn_to1`. |
| `TRT2/Seed.lean` | A seed sample model with a four-valued candidate sort and L3 as a filter, meeting all nine conditions (`toy_conforms`), its syntax-explicit form (`toySyn`), and the both-outcomes exclusion (`syn_both_excluded`, `toy_N5`). |
| `TRT2/NegativeTests.lean` | The required rejections NT-1 and NT-5 to NT-9 (`required_rejections`), and proofs that each degenerate instance still satisfies the bare conditional TO-1. |
| `Audit.lean` | Definition pins (each contract definition restated and checked by definitional equality), headline statement pins, and `#print axioms` for every headline theorem. |
| `DepGraph.lean` | Prints the user-level dependency graph and each theorem's direct dependents. Imports Lean's metaprogramming library; the audited library `TRT2` does not. |

## What the gate enforces

`tools/check_lean_proofs.py` fails the build when the toolchain pin drifts; when the library source contains, outside comments, an unfinished-proof marker, an axiom, opaque, unsafe or partial declaration, `native_decide`, `implemented_by` or `extern`, a `set_option`, an attribute, a notation or syntax extension, or an import from outside the library; when `Audit.lean` fails to compile (so weakening a pinned definition or statement fails); or when any headline theorem is missing from the axiom output or depends on anything beyond `propext` and `Quot.sound`. It was tested against seven deliberate cheats (a `sorry`, a declared axiom, `Cons` weakened to `True`, the seed's L3 built in, `Adm` defined from `Cons`, toolchain drift, `native_decide`); each was caught, and the unmodified tree passed.

## What this does not establish

- **The seed is not TRT-M0.** Its physical states are classical partial specifications, its step ignores the physical state `q`, and Identity is carried by equality in the metatheory. It shows the contract is satisfiable and non-vacuous, not that TRT has physical content.
- **F4, measurement context, is open.** With quantum states and incompatible contexts, a noncontextual `Interp` witness is what Kochen and Specker deny, so N3 becomes substantive or `Interp` must be contextual.
- **TO-1 here is a structural theorem about the contract.** Its value for any instance sits in that instance's conformance proof (contract section 4).
- **Semantic independence of `Interp`** is checked only extensionally (N4); its physical justification is a review obligation.

Human-Curated, AI-Enabled (HCAE)
