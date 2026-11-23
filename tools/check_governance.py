import os, sys
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
bad=[]
for root,_,files in os.walk("."):
    if ".git" in root: continue
    for f in files:
        if f.endswith(".lean"):
            t=open(os.path.join(root,f),encoding="utf-8",errors="replace").read()
            if "sorry" in t or "admit" in t:
                bad.append(os.path.join(root,f))
if bad:
    print("SORRY/ADMIT in:", *bad); sys.exit(1)
print("governance check OK:", len(required), "required files present, no sorry/admit in Lean files")
