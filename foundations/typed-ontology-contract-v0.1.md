# WP-TRT2-001: Typed ontology contract (candidate v0.1)

**Status:** proposed definitions; not a proof of TRT's ontological necessity.  
**Owner:** Research Architect / Integration Lead.  
**Scope:** formal interface contract for TRT-M0, subject to Claude's construction and Muse's independent review.

## Distinct sorts

| Symbol | Sort | Meaning |
|---|---|---|
| `Σ` | `Syntax` | Well-formed descriptions of a fixed, explicitly defined language. Unbounded expressibility does not imply semantic satisfaction. |
| `M` | `Model` | Classical structures for that language, with a declared satisfaction relation `M ⊨ s`. |
| `Ω_L3` | `Set Model` or specified class | Coherent interpretations under the chosen logic and signature. Self-reference requires a specified truth theory; no unrestricted truth predicate is assumed. |
| `Q` | `PhysicalState` | Operational physical states (e.g., density operators on a specified Hilbert space), distinct from models. |
| `E` | `Event` | Candidate actualization events carrying outcomes and measurement/instrument context. |
| `H` | `History` | Finite compatible records, including event identity, context, and causal provenance. |
| `χ` | `Actuality` | Determinate record or history; no identity with `Q` or `M` is presumed. |

`I∞` names the proposed ontological source of representability. It is not identified without argument with any one mathematical set above. `L3` names logical admissibility, not a physical force. `𝒜₀` names primitive actualization, not automatically a quantum instrument.

## Typed maps and relations

1. Satisfaction: `Sat : Model × Syntax → Prop`.
2. Admissible syntax: `Σ_adm := {s : Syntax | ∃ M : Model, Sat(M,s) ∧ Coherent(M)}`.
3. Interpretation: `ι : PhysicalState → Model` **only where a specified interpretation exists**; otherwise use a partial map or relation `Interpret ⊆ PhysicalState × Model`. Neither surjectivity nor injectivity is assumed.
4. Operational update: `Instrument : PhysicalState × MeasurementContext → Distribution(Outcome × PhysicalState)`, when the selected physical theory supplies such an instrument.
5. Ontological transition: `Actualize : History × PhysicalState × Event ⇀ History × PhysicalState`, a partial relation/function requiring independently declared compatibility and dynamical admissibility.
6. Projection: `record : History → FiniteSet(Record)` and `Cons : History → Prop`, with record identity and context fixed before consistency proofs.

The compact expression `χ ≡ 𝒜₀(I∞ | L3)` is an ontological schema, not a well-typed executable equation until a particular model supplies the interpretations of all terms.

## TO-1 proof contract

Specify `Adm(h,q,e)` without defining it merely as `Cons(Actualize(h,q,e))`. Establish a base history `h₀`, an explicit transition rule, and a nonempty reachable event sequence. Then prove conditionally:

```text
Cons(h₀) ∧
(∀ k < n, Adm(hₖ,qₖ,eₖ) ∧ Actualize(hₖ,qₖ,eₖ) = (hₖ₊₁,qₖ₊₁))
⇒ Cons(hₙ)
```

An inductive proof is only as substantive as the independently justified admissibility and transition rules. Record the assumptions, possible countermodels, and whether the theorem imports quantum postulates.

## Open design decisions for TRT-M0

- Specify a finite language/signature and satisfaction relation; do not assume unrestricted classical truth for self-referential syntax.
- Choose whether histories are ordered sequences, causal partial orders, or both; prove that extensions preserve earlier records.
- Separate record consistency from agreement between different observers' measurement contexts.
- Identify the physical-state interpretation relation and its limits, including quantum contextuality.
- Specify whether actualization is stochastic, relational, or deterministic, without presupposing the Born rule.
- Track three independent TO-3 obligations: no-signaling, Lorentz covariance, and microcausality.
- Audit whether a candidate theorem demonstrates new TRT-specific content or merely re-expresses assumptions from operational quantum mechanics.

## Review acceptance

Claude: confirm formal implementability and return exact type mismatches. Muse: construct negative tests and independently audit non-circularity. No claim status is promoted to theorem on the basis of this document.

Human-Curated, AI-Enabled (HCAE)
