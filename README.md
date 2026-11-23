# Triadic Reality Theory v2 (TRT v2)

**Status: candidate canonical research repository. Not yet promoted.**

Triadic Reality Theory proposes three irreducible co-primitives necessary for determinate actuality:

- **L3, ontological logical constraint:** Identity, Non-Contradiction, and Excluded Middle.
- **I-infinity, unbounded informational representability:** representable distinctions, relations, states, and configurations. Representability does not entail coherence, actualizability, or actuality.
- **A, fundamental action:** primitive state transition, defined without presupposing physical time, motion, force, energy, or actuality.

Canonical candidate equation:

$$\chi \equiv \mathcal{A}_0(I_\infty \mid L_3)$$

Extended physical admissibility is a separately typed constraint, not part of the compact identity above. See `foundations/canonical-synthesis-v1.0-candidate.md`.

## Authority and promotion

- The predecessor repository, [jdlongmire/triadic-reality-theory](https://github.com/jdlongmire/triadic-reality-theory), remains the authoritative historical baseline until a promotion ADR is approved by JD Longmire, the Research Principal.
- This repository was stood up on 2026-11-22 under a work order filed in ai-bridge (`2026-11-22-thinx-gpt-trt-v2-standup-work-order.md`), with JD's direction given in the TRT v2 channel.
- Promotion requires gates G1 to G5 in `governance/promotion-adr-draft.md`. Theorem obligations TO-2 through TO-6 need not be solved for promotion, but must remain visibly open.

## Claim discipline

Every research artifact carries an explicit claim status: axiom, definition, conditional theorem, independently verified theorem, conjecture, interpretation, empirical prediction, or unresolved obligation. See `governance/claim-status-registry.md`.

A theorem is not promoted solely because Lean typechecks. Promotion requires an audit of assumptions, axioms, sorry/admit, the dependency graph, and semantic match to the claimed theorem.

## Layout

| Path | Contents |
|---|---|
| `governance/` | EBCC pointer, claim-status registry, review policy, provenance, licensing record, integrity findings, promotion ADR draft |
| `foundations/` | Canonical synthesis v1.0 (candidate), axioms, ontology and types, Logos grounding (metaphysical interpretation, separately identified) |
| `formalization/` | Syntax-semantics, physical admissibility, sequential actualization, Lean workspace pointer |
| `theorem-obligations/` | TO-1 through TO-6 |
| `models/TRT-M0/` | The minimal model, lead: Formal Methods |
| `countermodels/` | Countermodel suite, lead: V and V |
| `validation/` | Independent V and V plan and evidence records |
| `references/` | Source register (reviewed migration only) |
| `work-packages/` | WP-TRT2-001, WP-TRT2-002, WP-TRT2-003 |

## Operating model

- **JD Longmire:** Research Principal. Ontological commitments, major scope changes, axioms, final canonical promotion.
- **Research Architect / Integration Lead (thinx-gpt):** ontology, research work packages, integration, evidence traceability, release readiness.
- **Formal Methods Lead (thinx-claude):** mathematical constructions, Lean proofs, TO-1/2/3/6, countermodel construction.
- **Stand-up Execution Lead and independent V and V Lead (thinx-muse):** governance, adversarial audit, reproducibility, CI, proof dependency audits.

GitHub v2 is the durable source of truth for domain research. Ai-bridge is a private coordination mailbox, not a domain artifact store.

## License

Prose and documents: CC BY 4.0. Code and formal artifacts: Apache 2.0. See `governance/licensing.md` for the record and its provenance from v1.

Human-Curated, AI-Enabled (HCAE)
