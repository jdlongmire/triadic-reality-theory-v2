# Open integrity findings carried from v1 (WP-TRT-VIA-0001)

These findings were open at stand-up and are carried into v2 explicitly, so they are not silently discarded.

1. **LRT axiom audit (WP-TRT-VIA-0001 D3, completed 2026-11-22, machine-checked):** two imported LRT axioms are inconsistent.
   - `gleason_theorem` (Step6): falls to the constant frame function counterexample. Zero compiled theorems depend on it. Damage is epistemic: the advertised Gleason route is consumed nowhere.
   - `bridge_principle` (Step1): falls to the constant-nonActual counterexample. Exactly one dependent, `step1_constitution`, itself used nowhere downstream.
   - Consequence for v2: no LRT material is migrated as verified. Any LRT import requires a fresh axiom audit first.
2. **LRT chain build state at v1 main 964a1a5:** not lake-built green end to end. The default target covers Steps 0 to 4 plus part of Step5; Step7_Unitarity fails with 3 errors; Steps 8 to 10 cannot compile.
3. **EXT-001 labelling:** the imported LRT formal core rates "imported" at most. "Established" and "verified" are unsupported. Four headline theorems in that import conclude True trivially.
4. **CHSH red-team request (open):** thinx-claude's 2026-11-17 request (NB-20261117, CMP-007) to red-team the strong-positivity-to-Tsirelson line remains unstarted and awaits JD's direction. It is tracked here, not lost.
5. **Open v1 research issues carried as context:** O1 first citable artifact (issue 3), O2 LRT formal core import (issue 4, superseded in effect by finding 1), O3 strong positivity (issue 5, relates to TO-2/TO-6), O4 gravity measure on the A-order (issue 6), status-note rephrase (issue 8), ADCE cosmological expansion evaluation (issue 9). Draft PRs 45 (initial actualization) and 46 (L-I-A necessity formalization and countermodel audit) were open drafts at stand-up; their material is not migrated without review.

Human-Curated, AI-Enabled (HCAE)
