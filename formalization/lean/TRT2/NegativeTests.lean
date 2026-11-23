/-
  Required negative tests (countermodels/negative-tests.md): NT-1 and NT-5 to
  NT-9. Each degenerate instance is rejected by the contract condition it targets,
  and each still satisfies the bare conditional TO-1, which is why the
  conditions, not TO-1 alone, carry the acceptance gate (contract section 4).
  Lean 4 core only (no Mathlib, no imports beyond this library), no declared
  axioms, no unfinished proofs. Toolchain pinned in lean-toolchain.
  WP-TRT2-002, thinx-claude (Formal Methods Lead).
  Human-Curated, AI-Enabled (HCAE).
-/

import TRT2.Contract
import TRT2.Seed

namespace TO1v02

/-! ## 5. Degenerate witnesses, all rejected -/

/-- Witness 1, history reset: fails C1. -/
def resetS : Schema := { toy with Step := fun _ q e h' q' => h' = [e] ∧ q' = q }

theorem reset_rejected : ¬ resetS.C1 := by
  intro hC1
  have := hC1 [(0, true)] (fun _ => none) (1, true) [(1, true)] (fun _ => none)
    ⟨rfl, rfl⟩ (0, true) (by simp [resetS, toy])
  simp [resetS, toy] at this

/-- Witness 2, no-op: fails C2. -/
def noopS : Schema := { toy with Step := fun h q _ h' q' => h' = h ∧ q' = q }

theorem noop_rejected : ¬ noopS.C2 := by
  intro hC2
  have := hC2 [] (fun _ => none) (0, true) [] (fun _ => none) ⟨rfl, rfl⟩
  simp [noopS, toy] at this

/-- Witness 3, histories consistent by type: fails N1. -/
abbrev CH := { l : List R0 // ∃ M : V4, L3v M ∧ ∀ r ∈ l, M r.1 r.2 = true }

def subtypeS : Schema where
  H := CH
  Q := Nat → Option Bool
  E := R0
  Rec := R0
  Model := V4
  L3 := L3v
  records := fun h => h.val
  recOf := fun e => e
  Sat := fun M r => M r.1 r.2 = true
  Interp := fun q M => ∀ n b, q n = some b → M n b = true
  Step := fun h q e h' q' => h'.val = h.val ++ [e] ∧ q' = q

theorem subtype_rejected : ¬ subtypeS.N1 := by
  intro ⟨h, hn⟩
  exact hn h.property

/-- Witness 4, circular Adm: an Interp that constrains nothing makes Adm equal
    to Cons after the step. Fails N4. -/
def circS : Schema := { toy with Interp := fun _ _ => True }

theorem circ_rejected : ¬ circS.N4 := by
  intro ⟨(h : List R0), q, (e : R0), (h' : List R0), q', ⟨h1, _⟩, ⟨M, hL, hM⟩, hn⟩
  apply hn
  refine ⟨M, hL, trivial, fun r hr => hM r ?_, hM e ?_⟩
  · show r ∈ h'
    rw [h1]; exact List.mem_append_left _ hr
  · show e ∈ h'
    rw [h1]; simp

/-- Witness 5, empty interpretation: Adm never holds, so TO-1 is vacuous.
    Fails N3. -/
def emptyS : Schema := { toy with Interp := fun _ _ => False }

theorem empty_rejected : ¬ emptyS.N3 := by
  intro ⟨_, _, _, _, _, _, ⟨_, _, hI, _⟩, _⟩
  exact hI

/-- Witness 6, L3 built in (the option JD ruled out): a filter that excludes
    nothing. Fails L0. -/
def builtinS : Schema := { toy with L3 := fun _ => True }

theorem builtin_rejected : ¬ builtinS.L0 := by
  intro ⟨_, hn⟩
  exact hn trivial


/-! ## Each degenerate instance still satisfies the bare conditional TO-1

  So TO-1 alone cannot tell them from a conforming instance; the rejections
  above, required by the acceptance gate, are what exclude them. -/

theorem reset_TO1 : resetS.TO1 := by
  apply to1
  intro (h : List R0) q (e : R0) (h' : List R0) q' hs r hr
  obtain ⟨h1, _⟩ := hs
  have hr' : r ∈ h' := hr
  rw [h1] at hr'
  show r ∈ h ∨ r = e
  exact Or.inr (by simpa using hr')

theorem noop_TO1 : noopS.TO1 := by
  apply to1
  intro (h : List R0) q (e : R0) (h' : List R0) q' hs r hr
  obtain ⟨h1, _⟩ := hs
  have hr' : r ∈ h' := hr
  rw [h1] at hr'
  exact Or.inl hr'

theorem circ_TO1 : circS.TO1 := to1 circS toy_C3
theorem empty_TO1 : emptyS.TO1 := to1 emptyS toy_C3
theorem builtin_TO1 : builtinS.TO1 := to1 builtinS toy_C3

theorem subtype_TO1 : subtypeS.TO1 := by
  apply to1
  intro (h : CH) q (e : R0) (h' : CH) q' hs r hr
  obtain ⟨h1, _⟩ := hs
  have hr' : r ∈ h'.val := hr
  rw [h1] at hr'
  show r ∈ h.val ∨ r = e
  simpa using hr'

/-- The required rejections, bundled: NT-1 reset fails C1, NT-5 no-op fails C2,
    NT-6 unconstrained Interp fails N4, NT-7 empty Interp fails N3,
    NT-8 consistent-by-type fails N1, NT-9 trivial L3 fails L0. -/
theorem required_rejections :
    ¬ resetS.C1 ∧ ¬ noopS.C2 ∧ ¬ circS.N4 ∧ ¬ emptyS.N3 ∧ ¬ subtypeS.N1 ∧ ¬ builtinS.L0 :=
  ⟨reset_rejected, noop_rejected, circ_rejected, empty_rejected, subtype_rejected, builtin_rejected⟩

end TO1v02
