# V and V audit: TO-1 contract revision v0.2 (thinx-claude draft)

**Verdict: PASS for folding into PR #2 as contract v0.2**, with the fold conditions below. Proposed definitions only; no claim status changes; nothing in this audit promotes TO-1 to a theorem about TRT. The conditional theorem `to1` is a theorem about the contract schema, as the draft itself states.
**Auditor:** V and V Lead, WP-TRT2-003. Date: 2026-11-22.
**Artifacts:** ai-bridge inbox/thinx-muse, 2026-11-22-thinx-claude-trt-v2-to1-contract-v0.2-proposal.md, the revision draft .md, and the Lean companion (sha256 60c0632808da136916fc01ab727ba50909e2a0b6662ab89e15ed701260ec2a30, verified byte-identical to the filed hash before the run).

## Reproduction (independent)

- Toolchain here: Lean 4.28.0 via elan (the author built on Lean 4.15.0; the file is core-only, no Mathlib, no imports, so cross-version risk is low and is recorded).
- `lean <file>`: exit 0 in about 11 seconds. Axiom printout reproduced exactly as reported: `to1` on [propext, Quot.sound]; `toy_conforms` on [propext]; `toy_TO1` on [propext, Quot.sound]; `toy_L0`, `subtype_rejected`, `empty_rejected`, `builtin_rejected` on no axioms; the remaining rejection results on [propext]. No sorryAx, no declared axioms (zero `axiom` declarations in the file).

## Line-by-line audit results

- **Definitions match the draft text.** Cons is joint satisfiability of the whole record by one L3 model. Adm is a single L3 interpretation of the current physical state satisfying the whole record plus the new event. C1, C2, C3, N1 to N5 and L0 are formalized exactly as the draft states them.
- **Definitional non-circularity verified syntactically.** The body of `Schema.Adm` references only L3, Interp, Sat, records and recOf. It does not reference Step or Cons. In this schema Adm is a fixed definition, not a supplied parameter, which is stronger than any extensional test.
- **C3-only claim verified.** `step_lemma` takes only the C3 hypothesis; its proof cases on C3 and closes each branch from the Adm witness's Sat components. Two sharpenings the author did not state: the Interp component of Adm is discarded unused in the proof, and in `to1` the induction hypothesis is unused in the successor case, because the last step's Adm alone yields Cons of the final history through the step lemma. The multi-step form is therefore presentational; the entire content of TO-1 under this contract is one-step preservation. This confirms the author's own assessment that the value sits in conformance, and it should be stated in the contract text so no reader over-reads the theorem.
- **Seed model (toy) verified.** C1 to C3 hold by append; N1 and N5 share the both-outcomes history, satisfied by the glut and by no L3 model; N2 is a genuine consistency-breaking step; N3's witness is non-vacuous; N4's witness is a real physical-state forbiddance (the state fixes event 0 false, the event records it true, the extended history is consistent on its own). One limitation to carry forward: in the seed, Step ignores q dynamically (the state never changes and does not constrain the transition), so q bites only through Adm and N4. TRT-M0 must give the physical state a dynamical role, or TO-6 inherits the gap.
- **Degenerate witnesses verified.** Each rejection proof negates exactly the condition it targets: reset fails C1, no-op fails C2, consistent-by-type fails N1 (every subtype history carries its own consistency witness), unconstrained Interp fails N4 (Adm collapses to Cons after the step, and the proof constructs Adm from the Cons witness), empty Interp fails N3, trivial L3 fails L0.

## The author's three questions, answered

1. **Is N4 strong enough as an extensional check on non-circularity?** The author's own judgment (necessary, not sufficient) is correct in general and mostly moot here. In general an existential, single-witness extensional test cannot certify an intensional property: an Adm could pass one N4 witness and still be Cons in disguise everywhere else, or be justified post hoc from Cons outcomes. But in this schema Adm is not a parameter, so circularity is excluded by construction, and N4's real function is different: it proves Interp is load-bearing in the instance. Verdict: keep N4 as a conformance condition, do not cite it as a non-circularity certificate. If a future contract variant makes Adm a supplied field again, N4 alone will not suffice and the definitional audit becomes the gate.
2. **Should NT-5 and the two new Interp cases join the negative test suite?** Yes. The suite now carries NT-5 (no-op, fails C2), NT-6 (unconstrained Interp, fails N4), NT-7 (empty Interp, fails N3; the concrete form of NT-2's vacuity), NT-8 (consistent-by-type, fails N1) and NT-9 (trivial L3 filter, fails L0), each mapped to the machine-checked rejection result.
3. **Does the proof use C3 only?** Yes, verified above, with the two sharpenings noted.

## Added findings

- **A1, the Syntax sort disappeared.** v0.1 had an explicit Syntax sort and a satisfaction relation over it. The v0.2 schema has no Syntax sort; Rec and Sat carry the syntactic role, and the encoding of records as syntax is mentioned in a comment but not formalized. This may be a legitimate simplification, but it touches registry claim TRT2-C03 (syntactic Sigma-infinity distinct from semantic Omega_L3) and WP-TRT2-001 owns the ontology. Fold condition: thinx-gpt reconciles this explicitly in PR #2, either restoring a Syntax sort or recording that Rec is the syntactic sort for M0 and amending the registry wording accordingly.
- **A2, an equivalence worth stating.** Under C1 to C3, Adm(h, q, e) plus a step is exactly Cons of the extension whose witness also interprets q: Adm implies Cons(h') by the step lemma, and a Cons(h') witness satisfying Interp(q, .) gives Adm, since C1 to C3 fix the extension's records as the old records plus rec(e). N4 is precisely the gap between those two. Stating this in the contract text makes the non-circularity structure transparent to a reader.
- **A3, Cons(h0) redundancy confirmed.** As the author disclosed, Adm at the first step yields Cons(h0) directly; the hypothesis is needed only for n = 0. No action.
- **A4, history closure should be machine-checked, not narrowed away.** The author's T8 offers either machine-checking closure (records of the final history equal the initial records plus the run's event records, as sets) or narrowing TO-1.md to consistency only. Closure follows from C1 and C2 (superset) and C3 (subset) by induction, so it is cheap to prove. Recommendation: keep TO-1's statement as consistency plus closure, and machine-check closure in the TRT-M0 PR. Do not narrow the obligation to fit the current draft.
- **A5, F3 and F4 remain open, correctly.** This revision has no Instrument (F3 labelling rule stands as written) and no measurement contexts (F4). The author's Kochen-Specker point stands: with quantum states, whether a noncontextual Interp witness can exist is exactly what makes N3 substantive. Neither is a defect in this draft; both stay tracked as fold-external conditions.

## Fold conditions for PR #2

1. A1 reconciled by thinx-gpt (Syntax sort / Rec wording, registry consistency).
2. A2 equivalence and the one-step-content note stated in the contract text.
3. The Lean file lands under formalization/lean/ with its axiom list in the PR, per the author's own note, reproduced on the repository's pinned toolchain when the Lean project is stood up (WP-TRT2-002).
4. No claim status changes ride along with the fold.

Human-Curated, AI-Enabled (HCAE)
