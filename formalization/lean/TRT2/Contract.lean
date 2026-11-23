/-
  TO-1 proof contract v0.2 (foundations/typed-ontology-contract-v0.1.md, document v0.2):
  the schema an instance supplies, Cons and Adm, conditions C1-C3, N1-N5, L0,
  the conditional TO-1 theorem, and two general lemmas (A2 equivalence, closure).
  Lean 4 core only (no Mathlib, no imports beyond this library), no declared
  axioms, no unfinished proofs. Toolchain pinned in lean-toolchain.
  WP-TRT2-002, thinx-claude (Formal Methods Lead).
  Human-Curated, AI-Enabled (HCAE).
-/

namespace TO1v02

/-! ## 1. The schema: the sorts and maps a TRT-M0 instance must supply -/

structure Schema where
  /-- Raw histories. Not required to be consistent by type (condition N1). -/
  H : Type
  /-- Operational physical states. -/
  Q : Type
  /-- Candidate actualization events. -/
  E : Type
  /-- Records retained in a history. -/
  Rec : Type
  /-- Candidate models: the representable valuations, L3-coherent or not. -/
  Model : Type
  /-- The L3 filter. Ω_L3 is the set of models satisfying it. -/
  L3 : Model → Prop
  /-- Record projection of a history. -/
  records : H → List Rec
  /-- The record an event leaves when actualized. -/
  recOf : E → Rec
  /-- Satisfaction of a record by a model (via enc : Rec → Syntax, then Sat). -/
  Sat : Model → Rec → Prop
  /-- Partial interpretation relation from physical states to models. -/
  Interp : Q → Model → Prop
  /-- Relation form of the partial operator Actualize : H × Q × E ⇀ H × Q. -/
  Step : H → Q → E → H → Q → Prop

variable (S : Schema)

/-- Cons: some single L3 model satisfies every retained record. -/
def Schema.Cons (h : S.H) : Prop := ∃ M, S.L3 M ∧ ∀ r ∈ S.records h, S.Sat M r

/-- Adm: one L3 interpretation of the current physical state witnesses the whole
    record and the new event. Defined from L3, Interp and Sat, never from Step or Cons. -/
def Schema.Adm (h : S.H) (q : S.Q) (e : S.E) : Prop :=
  ∃ M, S.L3 M ∧ S.Interp q M ∧ (∀ r ∈ S.records h, S.Sat M r) ∧ S.Sat M (S.recOf e)

/-! ## 2. Contract conditions -/

/-- C1 record preservation: no earlier record is lost. Rejects history reset. -/
def Schema.C1 : Prop :=
  ∀ h q e h' q', S.Step h q e h' q' → ∀ r ∈ S.records h, r ∈ S.records h'
/-- C2 progress: the new event's record is retained. Rejects the no-op. -/
def Schema.C2 : Prop :=
  ∀ h q e h' q', S.Step h q e h' q' → S.recOf e ∈ S.records h'
/-- C3 no junk: a step adds nothing but the new record. The proof uses this. -/
def Schema.C3 : Prop :=
  ∀ h q e h' q', S.Step h q e h' q' → ∀ r ∈ S.records h', r ∈ S.records h ∨ r = S.recOf e
/-- N1 Cons is a real predicate: some history is inconsistent. -/
def Schema.N1 : Prop := ∃ h, ¬ S.Cons h
/-- N2 Adm is load-bearing: Step alone can break consistency. -/
def Schema.N2 : Prop :=
  ∃ h q e h' q', S.Cons h ∧ S.Step h q e h' q' ∧ ¬ S.Cons h'
/-- N3 non-vacuous run: some consistent history takes an admissible step. -/
def Schema.N3 : Prop :=
  ∃ h q e h' q', S.Cons h ∧ S.Adm h q e ∧ S.Step h q e h' q'
/-- N4 Adm is not Cons after the step, in extension. -/
def Schema.N4 : Prop :=
  ∃ h q e h' q', S.Step h q e h' q' ∧ S.Cons h' ∧ ¬ S.Adm h q e
/-- L0 the L3 filter excludes some candidate model. -/
def Schema.L0 : Prop := ∃ M, ¬ S.L3 M
/-- N5 L3 does work on histories: some history is satisfied by a candidate
    model, so it is representable, yet no L3 model satisfies it. -/
def Schema.N5 : Prop :=
  ∃ h, (∃ M, ∀ r ∈ S.records h, S.Sat M r) ∧ ¬ S.Cons h

/-- A conforming TRT-M0 instance meets all nine. -/
def Schema.Conforms : Prop :=
  S.C1 ∧ S.C2 ∧ S.C3 ∧ S.N1 ∧ S.N2 ∧ S.N3 ∧ S.N4 ∧ S.L0 ∧ S.N5

/-! ## 3. TO-1 under the revised contract -/

def Schema.TO1 : Prop :=
  ∀ (n : Nat) (h : Nat → S.H) (q : Nat → S.Q) (e : Nat → S.E),
    S.Cons (h 0) →
    (∀ k, k < n → S.Adm (h k) (q k) (e k) ∧ S.Step (h k) (q k) (e k) (h (k+1)) (q (k+1))) →
    S.Cons (h n)

/-- Step lemma. Uses C3 only; Cons h is implied by Adm and not used. -/
theorem step_lemma (hC3 : S.C3) :
    ∀ h q e h' q', S.Adm h q e → S.Step h q e h' q' → S.Cons h' := by
  intro h q e h' q' ⟨M, hL, _, hM, he⟩ hs
  refine ⟨M, hL, fun r hr => ?_⟩
  rcases hC3 h q e h' q' hs r hr with h1 | h1
  · exact hM r h1
  · rw [h1]; exact he

theorem to1 (hC3 : S.C3) : S.TO1 := by
  intro n
  induction n with
  | zero => intro h q e h0 _; exact h0
  | succ n ih =>
    intro h q e h0 hrun
    obtain ⟨ha, hs⟩ := hrun n (by omega)
    exact step_lemma S hC3 _ _ _ _ _ ha hs

/-- A2 as an equivalence. Under C1 to C3, Adm plus a step is exactly a
    step whose successor is consistent with a witness that interprets q. -/
theorem adm_step_iff (S : Schema) (h1 : S.C1) (h2 : S.C2) (h3 : S.C3)
    (h : S.H) (q : S.Q) (e : S.E) (h' : S.H) (q' : S.Q) (hs : S.Step h q e h' q') :
    S.Adm h q e ↔ ∃ M, S.L3 M ∧ S.Interp q M ∧ ∀ r ∈ S.records h', S.Sat M r := by
  constructor
  · intro ⟨M, hL, hI, hM, he⟩
    refine ⟨M, hL, hI, fun r hr => ?_⟩
    rcases h3 h q e h' q' hs r hr with hx | hx
    · exact hM r hx
    · rw [hx]; exact he
  · intro ⟨M, hL, hI, hM⟩
    exact ⟨M, hL, hI, fun r hr => hM r (h1 h q e h' q' hs r hr), hM _ (h2 h q e h' q' hs)⟩

/-- History closure (TO-1's "closed history"),
    now machine-checked: along any run, the final records are exactly the
    initial records plus the run's event records, as sets. -/
theorem closure (S : Schema) (h1 : S.C1) (h2 : S.C2) (h3 : S.C3) :
    ∀ (n : Nat) (h : Nat → S.H) (q : Nat → S.Q) (e : Nat → S.E),
      (∀ k, k < n → S.Step (h k) (q k) (e k) (h (k+1)) (q (k+1))) →
      ∀ r, r ∈ S.records (h n) ↔ (r ∈ S.records (h 0) ∨ ∃ k, k < n ∧ r = S.recOf (e k)) := by
  intro n
  induction n with
  | zero =>
    intro h q e _ r
    constructor
    · intro hr; exact Or.inl hr
    · intro hr
      rcases hr with hr | ⟨k, hk, _⟩
      · exact hr
      · exact absurd hk (Nat.not_lt_zero _)
  | succ n ih =>
    intro h q e hrun r
    have hs := hrun n (by omega)
    have ih' := ih h q e (fun k hk => hrun k (by omega)) r
    constructor
    · intro hr
      rcases h3 _ _ _ _ _ hs r hr with hx | hx
      · rcases ih'.mp hx with hy | ⟨k, hk, hy⟩
        · exact Or.inl hy
        · exact Or.inr ⟨k, by omega, hy⟩
      · exact Or.inr ⟨n, by omega, hx⟩
    · intro hr
      rcases hr with hr | ⟨k, hk, hy⟩
      · exact h1 _ _ _ _ _ hs r (ih'.mpr (Or.inl hr))
      · by_cases hkn : k = n
        · subst hkn; rw [hy]; exact h2 _ _ _ _ _ hs
        · exact h1 _ _ _ _ _ hs r (ih'.mpr (Or.inr ⟨k, by omega, hy⟩))

end TO1v02
