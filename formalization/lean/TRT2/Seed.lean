/-
  Seed sample model (four-valued candidate valuations, L3 as a filter).
  This shows the v0.2 contract is satisfiable and non-vacuous. It is NOT TRT-M0:
  physical states are classical partial specifications, Step ignores q, and
  Identity is carried by metatheory equality. No physical claim follows from it.
  Lean 4 core only (no Mathlib, no imports beyond this library), no declared
  axioms, no unfinished proofs. Toolchain pinned in lean-toolchain.
  WP-TRT2-002, thinx-claude (Formal Methods Lead).
  Human-Curated, AI-Enabled (HCAE).
-/

import TRT2.Contract
import TRT2.Syntax

namespace TO1v02

/-! ## 4. Sample instance: TRT-M0 seed with a four-valued model sort

  Records are (event id, outcome bit). A candidate model is a four-valued
  valuation V : event id → outcome → Bool, where V n b says "outcome b is told
  true of event n". It may tell both (a glut) or neither (a gap), so the model
  sort represents incoherent content. The L3 filter keeps the valuations that
  tell exactly one outcome per event: Excluded Middle (at least one) and
  Non-Contradiction (not both). Identity is carried by equality in the
  metatheory and is not a separate filter here.
-/

abbrev R0 := Nat × Bool
abbrev V4 := Nat → Bool → Bool

def L3v (V : V4) : Prop :=
  ∀ n, (V n true = true ∨ V n false = true) ∧ ¬ (V n true = true ∧ V n false = true)

/-- The classical valuation that tells only `true` of every event. -/
def vTrue : V4 := fun _ b => b
/-- The everywhere-glut valuation: tells both outcomes of every event. -/
def vGlut : V4 := fun _ _ => true

theorem vTrue_L3 : L3v vTrue := by
  intro n; simp [vTrue]

theorem vGlut_not_L3 : ¬ L3v vGlut := by
  intro h
  exact (h 0).2 ⟨rfl, rfl⟩

/-- Under L3, an event cannot carry both outcomes. -/
theorem L3_nc {V : V4} (hL : L3v V) (n : Nat) (a : V n true = true) (b : V n false = true) :
    False := (hL n).2 ⟨a, b⟩

def toy : Schema where
  H := List R0
  Q := Nat → Option Bool
  E := R0
  Rec := R0
  Model := V4
  L3 := L3v
  records := fun h => h
  recOf := fun e => e
  Sat := fun M r => M r.1 r.2 = true
  Interp := fun q M => ∀ n b, q n = some b → M n b = true
  Step := fun h q e h' q' => h' = h ++ [e] ∧ q' = q

theorem toy_C1 : toy.C1 := by
  intro (h : List R0) (q : Nat → Option Bool) (e : R0) (h' : List R0) q' hs r hr
  obtain ⟨h1, _⟩ := hs
  show r ∈ h'
  rw [h1]; exact List.mem_append_left _ hr

theorem toy_C2 : toy.C2 := by
  intro (h : List R0) (q : Nat → Option Bool) (e : R0) (h' : List R0) q' hs
  obtain ⟨h1, _⟩ := hs
  show e ∈ h'
  rw [h1]; simp

theorem toy_C3 : toy.C3 := by
  intro (h : List R0) (q : Nat → Option Bool) (e : R0) (h' : List R0) q' hs r hr
  obtain ⟨h1, _⟩ := hs
  have hr' : r ∈ h' := hr
  rw [h1] at hr'
  show r ∈ h ∨ r = e
  simpa using hr'

/-- The history that records event 0 with both outcomes. -/
def hBoth : List R0 := [(0, true), (0, false)]

theorem toy_hBoth_not_cons : ¬ toy.Cons hBoth := by
  intro ⟨M, hL, hM⟩
  have hL' : L3v M := hL
  have a : M 0 true = true := hM (0, true) (by simp [toy, hBoth])
  have b : M 0 false = true := hM (0, false) (by simp [toy, hBoth])
  exact L3_nc hL' 0 a b

theorem toy_N1 : toy.N1 := ⟨hBoth, toy_hBoth_not_cons⟩

theorem toy_N2 : toy.N2 := by
  refine ⟨[(0, true)], (fun _ => none), (0, false), hBoth, (fun _ => none),
    ⟨vTrue, vTrue_L3, ?_⟩, ⟨rfl, rfl⟩, toy_hBoth_not_cons⟩
  intro r hr
  have : r = (0, true) := by simpa [toy] using hr
  subst this; rfl

theorem toy_N3 : toy.N3 := by
  refine ⟨[], (fun _ => none), (0, true), [(0, true)], (fun _ => none),
    ⟨vTrue, vTrue_L3, ?_⟩, ⟨vTrue, vTrue_L3, ?_, ?_, ?_⟩, ⟨rfl, rfl⟩⟩
  · intro r hr; simp [toy] at hr
  · intro n b hq; simp at hq
  · intro r hr; simp [toy] at hr
  · rfl

theorem toy_N4 : toy.N4 := by
  let q : Nat → Option Bool := fun n => if n = 0 then some false else none
  refine ⟨[], q, (0, true), [(0, true)], q, ⟨rfl, rfl⟩, ⟨vTrue, vTrue_L3, ?_⟩, ?_⟩
  · intro r hr
    have : r = (0, true) := by simpa [toy] using hr
    subst this; rfl
  · intro ⟨M, hL, hI, _, he⟩
    have hL' : L3v M := hL
    have b : M 0 false = true := hI 0 false (by simp [q])
    have a : M 0 true = true := he
    exact L3_nc hL' 0 a b

/-- L0: the filter excludes a well-typed candidate model (the glut). -/
theorem toy_L0 : toy.L0 := ⟨vGlut, vGlut_not_L3⟩

/-- N5: the both-outcomes history is representable (the glut satisfies it)
    but not actualizable (no L3 model satisfies it). -/
theorem toy_N5 : toy.N5 :=
  ⟨hBoth, ⟨vGlut, fun _ _ => rfl⟩, toy_hBoth_not_cons⟩

/-- The revised contract is satisfiable by the sample model. -/
theorem toy_conforms : toy.Conforms :=
  ⟨toy_C1, toy_C2, toy_C3, toy_N1, toy_N2, toy_N3, toy_N4, toy_L0, toy_N5⟩

theorem toy_TO1 : toy.TO1 := to1 toy toy_C3

/-- The toy with an explicit (distinct) syntax sort: descriptions are tagged
    atoms, enc is the tagging map. -/
inductive Desc where
  | atom : Nat → Bool → Desc

def toySyn : SynSchema where
  H := List R0
  Q := Nat → Option Bool
  E := R0
  Rec := R0
  Syntax := Desc
  Model := V4
  L3 := L3v
  records := fun h => h
  recOf := fun e => e
  enc := fun r => Desc.atom r.1 r.2
  SatS := fun M s => match s with | Desc.atom n b => M n b = true
  Interp := fun q M => ∀ n b, q n = some b → M n b = true
  Step := fun h q e h' q' => h' = h ++ [e] ∧ q' = q

/-- The induced schema is definitionally the toy, so every toy result
    (conformance, L3 excluding the glut, N5, the six rejections) carries over. -/
theorem toySyn_is_toy : toySyn.toSchema = toy := rfl

theorem toySyn_conforms : toySyn.toSchema.Conforms := by
  rw [toySyn_is_toy]; exact toy_conforms

/-- L3 still excludes the both-outcomes model, at the syntax level:
    no L3 model satisfies the encoded both-outcomes descriptions, while the
    glut does. -/
theorem syn_both_excluded :
    (∀ s ∈ [Desc.atom 0 true, Desc.atom 0 false], toySyn.SatS vGlut s) ∧
    ¬ ∃ M, L3v M ∧ ∀ s ∈ [Desc.atom 0 true, Desc.atom 0 false], toySyn.SatS M s := by
  refine ⟨fun s hs => ?_, ?_⟩
  · simp at hs
    rcases hs with rfl | rfl <;> rfl
  · intro ⟨M, hL, hM⟩
    have a : M 0 true = true := hM (Desc.atom 0 true) (by simp)
    have b : M 0 false = true := hM (Desc.atom 0 false) (by simp)
    exact L3_nc hL 0 a b

/-- The per-description check Σ_adm sees no contradiction in this
    fragment: every single record is satisfied by some L3 model. The L3
    filter bites only on sets of descriptions (histories), via Mod_L3(Γ). -/
theorem every_atom_admissible : ∀ r : R0, ∃ M, L3v M ∧ M r.1 r.2 = true := by
  intro ⟨i, c⟩
  refine ⟨fun n b => if n = i then (b == c) else b, ?_, ?_⟩
  · intro n
    by_cases hn : n = i <;> cases c <;> simp [hn]
  · simp

/-- History closure in the seed: along any run, the final records are exactly
    the initial records plus the run's event records. -/
theorem toy_closure :
    ∀ (n : Nat) (h : Nat → toy.H) (q : Nat → toy.Q) (e : Nat → toy.E),
      (∀ k, k < n → toy.Step (h k) (q k) (e k) (h (k+1)) (q (k+1))) →
      ∀ r, r ∈ toy.records (h n) ↔
        (r ∈ toy.records (h 0) ∨ ∃ k, k < n ∧ r = toy.recOf (e k)) :=
  closure toy toy_C1 toy_C2 toy_C3

end TO1v02
