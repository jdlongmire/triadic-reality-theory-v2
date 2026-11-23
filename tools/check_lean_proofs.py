"""Lean proof gate for formalization/lean (WP-TRT2-002).

Run from the repository root after `lake build` in formalization/lean:
    python3 tools/check_lean_proofs.py

Fails (exit 1) when any of these holds:
  * lean-toolchain is not the pinned toolchain;
  * the library source (TRT2.lean, TRT2/**) contains, outside comments, an
    unfinished-proof marker, an axiom/opaque/unsafe declaration, native_decide,
    implemented_by/extern, a kernel-check bypass, an attribute, a set_option,
    a notation/macro/elab/syntax extension, or an import from outside TRT2;
  * Audit.lean fails to compile (its definition and statement pins are part of
    the gate: weakening a definition or a headline statement breaks it);
  * any headline theorem is missing from the #print axioms output, depends on
    sorryAx, or depends on an axiom outside the allowlist.

The allowlist is the standard Lean core set this library actually uses. Any new
axiom must be named and dispositioned under validation/vv-plan.md item 2 before
it is added here.

Human-Curated, AI-Enabled (HCAE)
"""
import os, re, subprocess, sys

ROOT = os.path.join("formalization", "lean")
PINNED_TOOLCHAIN = "leanprover/lean4:v4.28.0"
ALLOWED_AXIOMS = {"propext", "Quot.sound"}
HEADLINES = [
    "to1", "step_lemma", "adm_step_iff", "closure", "syn_to1",
    "toy_conforms", "toy_TO1", "toy_closure", "toy_L0", "toy_N5",
    "toySyn_is_toy", "toySyn_conforms", "syn_both_excluded", "every_atom_admissible",
    "reset_rejected", "noop_rejected", "circ_rejected", "empty_rejected",
    "subtype_rejected", "builtin_rejected", "required_rejections",
    "reset_TO1", "noop_TO1", "circ_TO1", "empty_TO1", "subtype_TO1", "builtin_TO1",
]

def strip_lean_comments(text):
    out = []; i = 0; depth = 0; n = len(text)
    while i < n:
        if depth == 0 and text.startswith("--", i):
            j = text.find("\n", i)
            if j == -1: break
            out.append("\n"); i = j + 1; continue
        if text.startswith("/-", i):
            depth += 1; i += 2; continue
        if depth > 0 and text.startswith("-/", i):
            depth -= 1; i += 2; continue
        if depth == 0:
            out.append(text[i])
        i += 1
    return "".join(out)

FORBIDDEN = [
    (re.compile(r"\b(sorry|admit)\b|sorryAx"), "unfinished-proof marker"),
    (re.compile(r"\b(axiom|axioms|opaque|unsafe|partial)\b"), "axiom/opaque/unsafe/partial declaration"),
    (re.compile(r"\bnative_decide\b|Lean\.ofReduceBool|Lean\.trustCompiler"), "compiler-trusting proof"),
    (re.compile(r"\b(implemented_by|extern)\b"), "implemented_by/extern"),
    (re.compile(r"skipKernelTC|debug\.|\bset_option\b"), "set_option or kernel-check bypass"),
    (re.compile(r"@\[|^\s*attribute\b", re.M), "attribute"),
    (re.compile(r"^\s*(macro|macro_rules|elab|elab_rules|syntax|declare_syntax_cat|notation|infix|infixl|infixr|prefix|postfix|run_cmd|run_elab|run_meta)\b|#eval", re.M),
     "syntax extension or evaluation"),
]

def library_files():
    files = [os.path.join(ROOT, "TRT2.lean")]
    for r, _, fs in os.walk(os.path.join(ROOT, "TRT2")):
        files += [os.path.join(r, f) for f in fs if f.endswith(".lean")]
    return sorted(files)

def main():
    problems = []
    tc = open(os.path.join(ROOT, "lean-toolchain")).read().strip()
    if tc != PINNED_TOOLCHAIN:
        problems.append(f"lean-toolchain is {tc!r}, expected {PINNED_TOOLCHAIN!r}")

    for path in library_files():
        code = strip_lean_comments(open(path, encoding="utf-8").read())
        for pat, what in FORBIDDEN:
            if pat.search(code):
                problems.append(f"{path}: {what}")
        for imp in re.findall(r"^\s*import\s+(\S+)", code, re.M):
            if not (imp == "TRT2" or imp.startswith("TRT2.")):
                problems.append(f"{path}: import from outside the library: {imp}")

    audit = os.path.join(ROOT, "Audit.lean")
    acode = strip_lean_comments(open(audit, encoding="utf-8").read())
    if re.search(r"\b(sorry|admit|axiom)\b|sorryAx", acode):
        problems.append("Audit.lean: unfinished-proof marker or axiom declaration")

    res = subprocess.run(["lake", "env", "lean", "Audit.lean"], cwd=ROOT,
                         capture_output=True, text=True)
    out = res.stdout + res.stderr
    if res.returncode != 0 or re.search(r"\berror\b", out):
        problems.append("Audit.lean did not compile cleanly:\n" + out)

    seen = {}
    for m in re.finditer(r"'TO1v02\.([\w.]+)' depends on axioms: \[([^\]]*)\]", out):
        seen[m.group(1)] = {a.strip() for a in m.group(2).split(",") if a.strip()}
    for m in re.finditer(r"'TO1v02\.([\w.]+)' does not depend on any axioms", out):
        seen[m.group(1)] = set()
    if "sorryAx" in out:
        problems.append("sorryAx appears in the axiom output")
    for name in HEADLINES:
        if name not in seen:
            problems.append(f"headline theorem {name}: no #print axioms output")
        elif seen[name] - ALLOWED_AXIOMS:
            problems.append(f"headline theorem {name}: axioms outside allowlist: {sorted(seen[name] - ALLOWED_AXIOMS)}")

    print(f"Lean proof gate, toolchain {tc}")
    for name in HEADLINES:
        if name in seen:
            ax = ", ".join(sorted(seen[name])) or "none"
            print(f"  {name}: {ax}")
    if problems:
        print("FAIL")
        for p in problems: print("  -", p)
        sys.exit(1)
    print(f"OK: {len(HEADLINES)} headline theorems, axioms within {{{', '.join(sorted(ALLOWED_AXIOMS))}}}, "
          f"{len(library_files())} library files scanned, definition and statement pins compile.")

if __name__ == "__main__":
    main()
