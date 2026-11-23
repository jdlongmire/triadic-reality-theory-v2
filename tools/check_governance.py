import os, re, sys
required = [
 "README.md","CITATION.cff","AGENTS.md",
 "governance/claim-status-registry.md","governance/review-policy.md",
 "governance/provenance.md","governance/licensing.md",
 "governance/promotion-adr-draft.md","governance/integrity-findings.md",
 "foundations/canonical-synthesis-v1.0-candidate.md",
 "theorem-obligations/TO-1.md","theorem-obligations/TO-2.md",
 "theorem-obligations/TO-3.md","theorem-obligations/TO-4.md",
 "theorem-obligations/TO-5.md","theorem-obligations/TO-6.md",
 "models/TRT-M0/README.md","work-packages/WP-TRT2-001.md",
 "work-packages/WP-TRT2-002.md","work-packages/WP-TRT2-003.md",
]
missing=[p for p in required if not os.path.isfile(p)]
if missing:
    print("MISSING:", *missing); sys.exit(1)

def strip_lean_comments(text):
    # Remove nested block comments /- ... -/ (including /-! and /-- doc blocks)
    # and line comments -- ..., so prose mentioning a keyword is not flagged.
    out=[]; i=0; depth=0; n=len(text)
    while i < n:
        if depth == 0 and text.startswith("--", i):
            j=text.find("\n", i)
            if j == -1: break
            out.append("\n"); i=j+1; continue
        if text.startswith("/-", i):
            depth+=1; i+=2; continue
        if depth > 0 and text.startswith("-/", i):
            depth-=1; i+=2; continue
        if depth == 0:
            out.append(text[i])
        i+=1
    return "".join(out)

bad=[]
pattern=re.compile(r"\b(sorry|admit)\b|sorryAx")
for root,_,files in os.walk("."):
    if ".git" in root: continue
    for f in files:
        if f.endswith(".lean"):
            t=open(os.path.join(root,f),encoding="utf-8",errors="replace").read()
            if pattern.search(strip_lean_comments(t)):
                bad.append(os.path.join(root,f))
if bad:
    print("Unfinished proof markers in:", *bad); sys.exit(1)
print("governance check OK:", len(required), "required files present, no unfinished-proof markers in Lean code (comments stripped). NOTE: this text scan is a tripwire, not a proof gate; the proof gate is compiled #print axioms output in the Lean CI job.")
