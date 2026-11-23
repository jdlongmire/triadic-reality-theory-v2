# WP-TRT2-001: Typed ontology and TO-1 contract (candidate v0.2)

**Document version:** v0.2 (retained v0.1 filename for PR continuity; rename at governed merge if desired).  
**Status:** proposed definitions and conditional proof contract, independently reviewed; governed merge pending.  
**Owner:** Research Architect / Integration Lead (thinx-gpt).  
**Inputs:** Claude's TO-1 v0.2 proposal (ai-bridge, 2026-11-22); Muse's independent audit in `validation/to1-contract-v02-vv-audit.md`.  
**Research Principal ruling:** L3 operates as an admissibility filter over a wider candidate-model sort.  
**Claim status:** no independently verified TRT theorem claimed by this document.

## 1. Typed ontology

| Symbol | Sort | Role |
|---|---|---|
| `Σ∞` | `Syntax` | Well-formed representable descriptions, including inconsistent descriptions. Syntax is distinct from semantics. |
| `Model` | candidate semantic valuations | A wider class of representable valuations, potentially failing the L3 filter. |
| `L3 : Model → Prop` | predicate | Admissibility filter; `Ω_L3 := {M : Model | L3(M)}`. |
| `Sat : Model × Syntax → Prop` | relation | Interpretation of syntactic descriptions by candidate models. For an incoherent candidate, `Sat` need not be classical satisfaction. |
| `Q` | `PhysicalState` | Operational states, distinct from syntactic and semantic sorts. |
| `E` | `Event` | Candidate actualization events, including measurement context where applicable. |
| `Rec` | `Record` | Typed record contents, encoded into syntax by `enc : Rec → Syntax`. |
| `H` | `History` | Raw histories, including inconsistent histories; consistency is a substantive predicate, not a subtype constraint. |
| `χ` | `Actuality` | For TRT-M0, an actualized **history**; a record is a projection of that history, not an alternative sort for χ. |

The model-theoretic admissibility filter for a set of descriptions `Γ ⊆ Σ∞` is `Mod_L3(Γ) := {M : Model | L3(M) ∧ ∀ s ∈ Γ, Sat(M,s)}`. The **operative admissibility test for a record theory or history** is `Mod_L3(Γ) ≠ ∅`, requiring a *single* L3 model to satisfy the whole set. The auxiliary per-description check is `Σ_adm := {s : Syntax | Mod_L3({s}) ≠ ∅}`; singleton satisfiability cannot substitute for joint satisfiability (and can be vacuous for individually satisfiable atomic records). This avoids an undefined `Coherent(M)` predicate and preserves the possibility of syntactically representable contradictions that no L3 model realizes. A language with a truth predicate or self-reference must define its semantics and restrictions explicitly.

The candidate physical interpretation is a **partial relation** `Interp : Q → Model → Prop`; neither totality, injectivity nor surjectivity is assumed. Any physical theory or instrument used to construct `Q` must be declared as an **imported operational postulate**, including probability distributions or Born-rule weights. These imports do not discharge TO-2.

The compact ontological expression `χ ≡ 𝒜₀(I∞ | L3)` remains a schema until an instance supplies its typed interpretation. `I∞` is not identified by definition with `Syntax` or `Model`.

## 2. TO-1 instance schema

An instance supplies sorts `H, Q, E, Rec, Model`, `L3 : Model → Prop`, `records : H → List Rec`, `recOf : E → Rec`, `SatRec : Model → Rec → Prop`, `Interp : Q → Model → Prop`, and `Step : H → Q → E → H → Q → Prop`. The semantic bridge is `SatRec(M,r) := Sat(M, enc(r))`. Claude's Lean v0.2 schema leaves `Syntax` and `enc` implicit; TRT-M0 **must instantiate them explicitly** to satisfy the repository-wide syntax/semantics distinction (A1).

Define:

```text
Cons(h) :=
  ∃ M, L3(M) ∧ ∀ r ∈ records(h), SatRec(M,r)

Adm(h,q,e) :=
  ∃ M, L3(M) ∧ Interp(q,M) ∧
       (∀ r ∈ records(h), SatRec(M,r)) ∧ SatRec(M,recOf(e))
```

`Adm` is specified without reference to `Step` or `Cons`. The semantic independence of `Interp` and `SatRec` from the desired result remains an external modeling/review obligation.

### Transition conditions

- **C1, preservation:** every record of `h` occurs in `h′` whenever `Step(h,q,e,h′,q′)`.
- **C2, progress:** `recOf(e)` occurs in `h′` whenever that step occurs.
- **C3, no junk:** each record of `h′` was already in `h` or equals `recOf(e)`.

Together C1–C3 establish set-valued record closure, `records(h′) = records(h) ∪ {recOf(e)}`. A sequence of steps yields the analogous finite union; multiplicities/order are **not** fixed by these conditions. Claude reports a machine-checked set-level closure lemma (`closure`); its evidence remains pending incorporation into the pinned Lean project and independent repository-level verification before promotion.

### Non-triviality obligations on each concrete instance

- **N1:** some raw history is inconsistent.
- **N2:** some step from a consistent history lands in an inconsistent history, demonstrating that `Adm` is load-bearing.
- **N3:** at least one admissible step exists from a consistent history.
- **N4:** some step lands in a consistent history but is inadmissible due to the current-state interpretation; this distinguishes `Adm` extensionally from consistency after the step.
- **L0:** some representable candidate model fails `L3`.
- **N5:** some raw history is satisfied by a candidate model but by no L3 model.

N4 is **necessary but insufficient** to establish meaningful semantic independence. The chosen `Interp` must have separately justified physical content.

### Conditional TO-1

```text
Cons(h₀) ∧
(∀ k < n, Adm(hₖ,qₖ,eₖ) ∧ Step(hₖ,qₖ,eₖ,hₖ₊₁,qₖ₊₁))
⇒ Cons(hₙ).
```

**A2, exact proof content:** for `n ≥ 1`, the final admissibility witness satisfies every earlier record and the new event. C3 ensures there are no additional records in the successor, hence `Cons(hₙ)`. This is the one-step lemma; the induction is presentational. Under C3 alone, admissibility plus a step implies consistency of the extension. Conversely, consistency of the extension does not imply admissibility, because `Interp(q,M)` may fail (N4). The theorem's substantive burden lies in demonstrating instance conformance and a justified interpretation, rather than in the abstract induction.

## 3. Machine-checking evidence and scope

Claude supplied a Lean 4 core companion `TO1v02` with a conforming four-valued toy valuation, the conditional theorem, and rejected degenerate witnesses (reset, no-op, consistent-by-type, unconstrained interpretation, empty interpretation, vacuous L3 filter). Muse reports independent reproduction using Lean 4.28.0 in `validation/to1-contract-v02-vv-audit.md`. The toy's physical states are classical partial specifications; it is **not** TRT-M0 and does not establish quantum physical adequacy. The Lean companion is to be added to the pinned formalization project by WP-TRT2-002 with proof dependency and axiom evidence.

**Outstanding:** F3 explicitly label operational distribution as imported; F4 give event records contextual semantics, compatibility and causal ordering before quantum implementation. TO-3 no-signaling, covariance, and microcausality remain separate obligations. Identity in the four-valued toy is inherited from the metatheory and is not independently established as a filter constraint. TO-2 Born probabilities/outcome selection and TO-6 physical admissibility remain open.

## 4. Explicit TO-1 instance acceptance gate

An instance's TO-1 claim is **not accepted** unless its pinned, machine-checked evidence proves C1–C3, N1–N5 and L0, and independently verifies the applicable negative-test rejections NT-1 and NT-5 through NT-9 (reset, no-op, unconstrained interpretation, empty interpretation, consistent-by-type histories, and vacuous L3 filter). The conditional structural theorem alone does not satisfy this gate. Record the exact toolchain, axiom dependencies, and review verdict; no claim-status promotion follows automatically.

## 5. Review acceptance

Claude: implementability and type compatibility, including explicit `Syntax` and `enc` in TRT-M0. Muse: independent audit of the revised contract, non-circularity, context semantics, and negative tests. No claim status promotion in this PR. Preserve the HCAE attribution.

Human-Curated, AI-Enabled (HCAE)
