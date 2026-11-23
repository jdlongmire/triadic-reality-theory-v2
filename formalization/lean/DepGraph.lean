/-
  Dependency graph for the WP-TRT2-002 Lean companion (validation/vv-plan.md,
  item 4). Run after `lake build`:  lake env lean DepGraph.lean
  This tool imports Lean's metaprogramming library; the audited library TRT2
  itself imports nothing beyond Lean core (Init).
  For every user-level declaration in namespace TO1v02, prints the other
  user-level declarations its type or value uses (auxiliary compiler-generated
  constants are looked through), then the direct downstream dependents of each
  theorem, so the blast radius of any change is visible.
  Human-Curated, AI-Enabled (HCAE).
-/
import Lean
import TRT2
open Lean Elab Command

private def isUserDecl (n : Name) : Bool :=
  (`TO1v02).isPrefixOf n && !n.isInternal &&
    !(n.toString.splitOn ".match_").length > 1 &&
    !(n.toString.splitOn ".proof_").length > 1 &&
    !(n.toString.splitOn ".eq_").length > 1 &&
    !(n.toString.splitOn ".rec").length > 1 &&
    !(n.toString.splitOn ".casesOn").length > 1 &&
    !(n.toString.splitOn ".noConfusion").length > 1 &&
    !(n.toString.splitOn ".below").length > 1 &&
    !(n.toString.splitOn ".brecOn").length > 1 &&
    !(n.toString.splitOn ".ctorIdx").length > 1 &&
    !(n.toString.splitOn ".mk.").length > 1 &&
    !(n.toString.splitOn ".inj").length > 1 &&
    !(n.toString.splitOn ".sizeOf").length > 1 &&
    !(n.toString.splitOn "._").length > 1

private def directUses (env : Environment) (n : Name) : Array Name :=
  match env.find? n with
  | some ci =>
    let v := match ci.value? with | some e => e.getUsedConstants | none => #[]
    ci.type.getUsedConstants ++ v
  | none => #[]

/-- User-level constants reached from `n`, looking through auxiliary ones. -/
private partial def userDeps (env : Environment) (n : Name) : NameSet := Id.run do
  let mut seen : NameSet := {}
  let mut out : NameSet := {}
  let mut stack := (directUses env n).toList
  while !stack.isEmpty do
    match stack with
    | [] => pure ()
    | m :: rest =>
      stack := rest
      if seen.contains m || m == n then continue
      seen := seen.insert m
      if isUserDecl m then
        out := out.insert m
      else if (`TO1v02).isPrefixOf m then
        stack := (directUses env m).toList ++ stack
  return out

#eval show CommandElabM Unit from do
  let env ← getEnv
  let decls := (env.constants.fold (fun acc n _ => if isUserDecl n then acc.push n else acc) #[])
    |>.qsort (fun a b => a.toString < b.toString)
  let mut lines : Array String := #["## direct user-level dependencies"]
  let mut rev : Std.HashMap Name (Array Name) := {}
  for d in decls do
    let ds := (userDeps env d).toList.map toString |>.toArray.qsort (· < ·)
    lines := lines.push s!"{d} <- [{", ".intercalate ds.toList}]"
    for x in userDeps env d do
      rev := rev.insert x ((rev.getD x #[]).push d)
  lines := lines.push "## direct downstream dependents of each theorem"
  for d in decls do
    match env.find? d with
    | some (.thmInfo _) =>
      let ds := (rev.getD d #[]).map toString |>.qsort (· < ·)
      lines := lines.push s!"{d} -> [{", ".intercalate ds.toList}]"
    | _ => pure ()
  logInfo ("\n".intercalate lines.toList)
