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

### 03-11 · Biliary atresia: nutrition and growth (synced 2026-11-02)
- **Starting doses repeated (lesson slide 15, Mouzaki 2019 Table 3):** A 5,000 IU/day < 10 kg, 10,000 IU/day > 10 kg; D cholecalciferol 2,000–5,000 IU/day ("some use weekly 50,000 IU" — lesson, TODO(verify) source before showing); E TPGS 15–25 IU/kg/day; K 2–5 mg/day orally, 1–10 mg IV if INR stays high. Same numbers as the 02-13 entry — still TODO(verify) against the Mouzaki 2019 full text before the calculator ships.
- **Marker conflict to resolve at build:** vitamin D insufficiency — lesson 03-11 uses 25-OH D **< 20 ng/mL**; the 02-13 entry uses **< 15 ng/mL** (ChiLDReN threshold). 03-11 slide 15 labels its < 20 as a ChiLDReN marker; the 02-13 entry labels < 15 as the ChiLDReN threshold — one of them misreads Shneider 2012. TODO(verify) against the Shneider 2012 Methods and Mouzaki 2019 Table 3; record the choice in DECISIONS.
- **Vitamin A toxicity (slide 15):** raised intracranial pressure and liver injury — the calculator must carry a "monitor levels" caution next to any A dose.
- **Vitamin E (slide 15):** serum E alone is falsely normal with high lipids → use E:total lipid ratio (< 0.6 mg/g under 1 year). TPGS forms its own micelles; giving it **with** A and D improves their absorption — show as a tip. (02-13 entry says A, D and K — TODO(verify) which vitamins in Mouzaki 2019.)
- **Vitamin K (slide 15):** INR also reflects synthesis — correction after IV K = deficiency; no correction = synthetic failure (→ inr_prolonged, c_vitk_inr). IV reactions reported.
- **Trigger line for the calculator (slide 14):** total bilirubin > 2 mg/dL predicts deficiency better than serum bile acids (Venkat 2014); with bilirubin > 2 (Shneider 2012), 3/24 sufficient in all four at 3 months, 0/23 at 6 months. Insufficiency despite a TPGS multivitamin + extra K (92 infants, 1/3/6 months): A 29–36%, D 21–37%, K 10–22%, E 16–18%. Lesson wording here is "> 2"; the 02-13 entry already flagged "≥ 2 vs > 2" — decide once at build.
- **Monitoring rhythm (slide 6, Mouzaki 2019 Tables 2–3):** A, D, E, K every 3–6 months, monthly if severe cholestasis (slide 18 step 2: every 1–3 months once bilirubin > 2 mg/dL at 3 months after Kasai — expert framework); essential fatty acids (triene:tetraene) every 3–6 months — risk rises on high-MCT, low-LCT feeds; zinc and iron as indicated (at most every 3 months). Bone: check calcium and phosphate with low D (rickets, fractures).
