/-
  Proof audit for the WP-TRT2-002 Lean companion (validation/vv-plan.md).
  Run after `lake build`:  lake env lean Audit.lean
  tools/check_lean_proofs.py runs it in CI and fails on any axiom outside the
  allowlist, any missing headline theorem, or any compile error here.

  Part 1 pins the definitions to the contract text by definitional equality
  (Iff.rfl / rfl): weakening Cons, Adm, a condition, TO-1 or the seed's L3
  filter breaks this file. Part 2 pins each headline statement by type. Part 3
  prints the axioms each headline theorem depends on.
  Human-Curated, AI-Enabled (HCAE).
-/
import TRT2

namespace TO1v02.Audit
open TO1v02

/-! ## 1. Definition pins (contract section 2, as merged at b6260da) -/

example (S : Schema) (h : S.H) :
    S.Cons h ↔ ∃ M, S.L3 M ∧ ∀ r ∈ S.records h, S.Sat M r := Iff.rfl
example (S : Schema) (h : S.H) (q : S.Q) (e : S.E) :
    S.Adm h q e ↔
      ∃ M, S.L3 M ∧ S.Interp q M ∧ (∀ r ∈ S.records h, S.Sat M r) ∧ S.Sat M (S.recOf e) :=
  Iff.rfl
example (S : Schema) : S.C1 ↔
    ∀ h q e h' q', S.Step h q e h' q' → ∀ r ∈ S.records h, r ∈ S.records h' := Iff.rfl
example (S : Schema) : S.C2 ↔
    ∀ h q e h' q', S.Step h q e h' q' → S.recOf e ∈ S.records h' := Iff.rfl
example (S : Schema) : S.C3 ↔
    ∀ h q e h' q', S.Step h q e h' q' →
      ∀ r ∈ S.records h', r ∈ S.records h ∨ r = S.recOf e := Iff.rfl
example (S : Schema) : S.N1 ↔ ∃ h, ¬ S.Cons h := Iff.rfl
example (S : Schema) : S.N2 ↔
    ∃ h q e h' q', S.Cons h ∧ S.Step h q e h' q' ∧ ¬ S.Cons h' := Iff.rfl
example (S : Schema) : S.N3 ↔
    ∃ h q e h' q', S.Cons h ∧ S.Adm h q e ∧ S.Step h q e h' q' := Iff.rfl
example (S : Schema) : S.N4 ↔
    ∃ h q e h' q', S.Step h q e h' q' ∧ S.Cons h' ∧ ¬ S.Adm h q e := Iff.rfl
example (S : Schema) : S.L0 ↔ ∃ M, ¬ S.L3 M := Iff.rfl
example (S : Schema) : S.N5 ↔
    ∃ h, (∃ M, ∀ r ∈ S.records h, S.Sat M r) ∧ ¬ S.Cons h := Iff.rfl
example (S : Schema) : S.Conforms ↔
    S.C1 ∧ S.C2 ∧ S.C3 ∧ S.N1 ∧ S.N2 ∧ S.N3 ∧ S.N4 ∧ S.L0 ∧ S.N5 := Iff.rfl
example (S : Schema) : S.TO1 ↔
    ∀ (n : Nat) (h : Nat → S.H) (q : Nat → S.Q) (e : Nat → S.E),
      S.Cons (h 0) →
      (∀ k, k < n → S.Adm (h k) (q k) (e k) ∧ S.Step (h k) (q k) (e k) (h (k+1)) (q (k+1))) →
      S.Cons (h n) := Iff.rfl

/-- The syntax bridge: SatRec M r := Sat M (enc r). -/
example (T : SynSchema) (M : T.Model) (r : T.Rec) :
    T.toSchema.Sat M r ↔ T.SatS M (T.enc r) := Iff.rfl

/-- The seed's L3 filter is exactly Excluded Middle plus Non-Contradiction per event. -/
example (V : V4) : L3v V ↔
    ∀ n, (V n true = true ∨ V n false = true) ∧ ¬ (V n true = true ∧ V n false = true) :=
  Iff.rfl
example : toy.L3 = L3v := rfl
example : vGlut = fun _ _ => true := rfl
example : hBoth = [(0, true), (0, false)] := rfl
/-- The seed's step appends the event's record and leaves the state unchanged. -/
example (h : List R0) (q : Nat → Option Bool) (e : R0) (h' : List R0) (q' : Nat → Option Bool) :
    toy.Step h q e h' q' ↔ (h' = h ++ [e] ∧ q' = q) := Iff.rfl

/-! ## 2. Headline statement pins -/

/-- TO-1 holds for every instance meeting C3 (the one-step lemma suffices). -/
example : ∀ S : Schema, S.C3 → S.TO1 := to1
/-- A2: under C1 to C3, Adm before a step is consistency of the successor
    with a witness that interprets the current state. -/
example : ∀ (S : Schema), S.C1 → S.C2 → S.C3 →
    ∀ h q e h' q', S.Step h q e h' q' →
      (S.Adm h q e ↔ ∃ M, S.L3 M ∧ S.Interp q M ∧ ∀ r ∈ S.records h', S.Sat M r) :=
  adm_step_iff
/-- History closure along any run, as sets. -/
example : ∀ (S : Schema), S.C1 → S.C2 → S.C3 →
    ∀ (n : Nat) (h : Nat → S.H) (q : Nat → S.Q) (e : Nat → S.E),
      (∀ k, k < n → S.Step (h k) (q k) (e k) (h (k+1)) (q (k+1))) →
      ∀ r, r ∈ S.records (h n) ↔ (r ∈ S.records (h 0) ∨ ∃ k, k < n ∧ r = S.recOf (e k)) :=
  closure
example : ∀ T : SynSchema, T.toSchema.C3 → T.toSchema.TO1 := syn_to1
/-- Non-vacuity: the seed meets all nine conditions, plain and syntax-explicit. -/
example : toy.Conforms := toy_conforms
example : toySyn.toSchema.Conforms := toySyn_conforms
/-- L3 excludes the both-outcomes model, as a model and on the history. -/
example : ¬ L3v vGlut := vGlut_not_L3
example : (∀ r ∈ toy.records hBoth, toy.Sat vGlut r) ∧ ¬ toy.Cons hBoth :=
  ⟨fun _ _ => rfl, toy_hBoth_not_cons⟩
example :
    (∀ s ∈ [Desc.atom 0 true, Desc.atom 0 false], toySyn.SatS vGlut s) ∧
    ¬ ∃ M, L3v M ∧ ∀ s ∈ [Desc.atom 0 true, Desc.atom 0 false], toySyn.SatS M s :=
  syn_both_excluded
/-- Required rejections: NT-1, NT-5, NT-6, NT-7, NT-8, NT-9. -/
example : ¬ resetS.C1 ∧ ¬ noopS.C2 ∧ ¬ circS.N4 ∧ ¬ emptyS.N3 ∧ ¬ subtypeS.N1 ∧ ¬ builtinS.L0 :=
  required_rejections
/-- Each degenerate instance still satisfies the bare conditional TO-1. -/
example : resetS.TO1 ∧ noopS.TO1 ∧ circS.TO1 ∧ emptyS.TO1 ∧ subtypeS.TO1 ∧ builtinS.TO1 :=
  ⟨reset_TO1, noop_TO1, circ_TO1, empty_TO1, subtype_TO1, builtin_TO1⟩

end TO1v02.Audit

/-! ## 3. Axiom audit -/

#print axioms TO1v02.to1
#print axioms TO1v02.step_lemma
#print axioms TO1v02.adm_step_iff
#print axioms TO1v02.closure
#print axioms TO1v02.syn_to1
#print axioms TO1v02.toy_conforms
#print axioms TO1v02.toy_TO1
#print axioms TO1v02.toy_closure
#print axioms TO1v02.toy_L0
#print axioms TO1v02.toy_N5
#print axioms TO1v02.toySyn_is_toy
#print axioms TO1v02.toySyn_conforms
#print axioms TO1v02.syn_both_excluded
#print axioms TO1v02.every_atom_admissible
#print axioms TO1v02.reset_rejected
#print axioms TO1v02.noop_rejected
#print axioms TO1v02.circ_rejected
#print axioms TO1v02.empty_rejected
#print axioms TO1v02.subtype_rejected
#print axioms TO1v02.builtin_rejected
#print axioms TO1v02.required_rejections
#print axioms TO1v02.reset_TO1
#print axioms TO1v02.noop_TO1
#print axioms TO1v02.circ_TO1
#print axioms TO1v02.empty_TO1
#print axioms TO1v02.subtype_TO1
#print axioms TO1v02.builtin_TO1
