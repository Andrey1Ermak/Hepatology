# c_vitamins — Fat-soluble vitamin dosing in cholestasis (calculator draft)

Calculator not built yet (block 1 trigger reached; backlog task). Inbox is filled by daily lesson sync (§3.4).

## Inbox

### 02-13 · Supportive care in the cholestatic infant (synced 2026-10-21)
- Primary source for doses and markers: Mouzaki M et al. JPGN 2019;69:498–511 (joint NASPGHAN/ESPGHAN nutrition paper). Escalation as used in ChiLDREN: Shneider BL et al. Pediatrics 2012;130:e607–14. TODO(verify) every dose below against the full text of both papers before the calculator ships.
- **Starting doses (lesson slide 9):**
  - A: 5,000 IU/day if < 10 kg; 10,000 IU/day if > 10 kg. Excess causes hepatic fibrosis — measure, do not push blindly.
  - D: cholecalciferol 2,000–5,000 IU/day; no agreed upper target.
  - E: TPGS 15–25 IU/kg/day (TPGS also improves absorption of A, D, K).
  - K: 2–5 mg/day orally; 1–10 mg IV when needed (small anaphylaxis risk with IV). TODO(verify) weight/age banding and maximum for IV, and IM vs IV in a coagulopathic infant (hematoma risk), against Mouzaki 2019 and Shneider 2012.
- **Markers of insufficiency:** A — retinol < 20 µg/dL → modified relative dose response; retinol:RBP molar ratio < 0.8 (RBP unreliable in advanced disease). D — 25-OH D < 15 ng/mL (ChiLDREN threshold). E — tocopherol:total lipid < 0.6 mg/g in infants (ChiLDREN threshold) and age 1–12 y, < 0.8 mg/g older; raw serum E misleads when lipids are high. K — INR > 1.2; PIVKA-II earlier if available; normal INR ≠ normal bone K status.
- **Escalation (ChiLDREN):** A up to 25,000–50,000 IU/day or 50,000 IU IM monthly; D 1,200–8,000 IU/day or calcitriol 0.05–0.20 µg/kg/day; E up to 100 IU/kg/day; K by INR — 1.2–1.5 → 2.5 mg/day; > 1.5 → IM 2–5 mg plus daily oral.
- **When to dose separately:** bilirubin ≥ 2 mg/dL → combined TPGS multivitamin fails (0/23 sufficient in all four at 6 months after Kasai; 58% had ≥ 1 insufficiency at 1 month across the cohort). Calculator should flag "bilirubin persistently ≥ 2 mg/dL: dose each vitamin separately and measure each". Lesson wording varies (slide 8 "≥ 2", slide 19 "> 2", chapter "stays above two"); use ≥ 2 as in the Shneider stratification and record the choice in DECISIONS at calculator build.
- **Rhythm:** levels every 3–6 months, monthly if severely cholestatic; red-cell fatty acid profile every 3–6 months (triene:tetraene alone not adequate); recheck 4–6 weeks after any dose change (lesson case).
- Interactions: cholestyramine binds fat-soluble vitamins and UDCA — separate by hours; IBAT inhibitors cause diarrhea → vitamins may fall further.
