/-
  Syntax bridge (contract section 1, A1): an instance with an explicit Syntax
  sort, Sat over Syntax and enc : Rec -> Syntax induces the v0.2 schema with
  SatRec M r := Sat M (enc r), and TO-1 carries over.
  Lean 4 core only (no Mathlib, no imports beyond this library), no declared
  axioms, no unfinished proofs. Toolchain pinned in lean-toolchain.
  WP-TRT2-002, thinx-claude (Formal Methods Lead).
  Human-Curated, AI-Enabled (HCAE).
-/

import TRT2.Contract

namespace TO1v02

/-- The explicit syntax bridge (contract A1). A syntactic instance has a Syntax
    sort, Sat over Syntax, and enc : Rec → Syntax; it induces our schema with
    SatRec M r := Sat M (enc r). -/
structure SynSchema where
  H : Type
  Q : Type
  E : Type
  Rec : Type
  Syntax : Type
  Model : Type
  L3 : Model → Prop
  records : H → List Rec
  recOf : E → Rec
  enc : Rec → Syntax
  SatS : Model → Syntax → Prop
  Interp : Q → Model → Prop
  Step : H → Q → E → H → Q → Prop

def SynSchema.toSchema (T : SynSchema) : Schema where
  H := T.H
  Q := T.Q
  E := T.E
  Rec := T.Rec
  Model := T.Model
  L3 := T.L3
  records := T.records
  recOf := T.recOf
  Sat := fun M r => T.SatS M (T.enc r)
  Interp := T.Interp
  Step := T.Step

/-- TO-1 holds for every syntactic instance whose induced schema meets C3. -/
theorem syn_to1 (T : SynSchema) (h3 : T.toSchema.C3) : T.toSchema.TO1 :=
  to1 T.toSchema h3

end TO1v02
