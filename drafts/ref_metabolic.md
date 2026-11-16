# ref_metabolic — Metabolic Workup in One Draw (draft)

Card not built yet (trigger reached 2026-10-22: lesson 02-14; backlog day 31). Inbox is filled by daily lesson sync (§3.4).

## Inbox

### 02-14 · Block 2 synthesis (synced 2026-10-22)
- **Before blood products:** red-cell GALT (donor cells make it falsely normal for months), succinylacetone (not tyrosine) (lesson 02-14 case 2, slides 11, 19).
- **Before the formula switch:** urine reducing substances turn negative once lactose stops — collect the urine first, but never delay stopping lactose. Fawaz 2017 treats the test as unreliable; GALT is the diagnostic test.
- **Before UDCA:** urine bile acids by mass spectrometry (bile acid synthesis defects are treatable with cholic acid).
- **At the time of hypoglycemia:** critical sample — cortisol, insulin, beta-hydroxybutyrate, free fatty acids (02-11 + 02-14 case 3). **Never delay glucose** to get it (slide 11: "glucose now").
- Free T4 with TSH any time the same day (does not depend on the hypoglycemia sample).
- Citrulline and AFP for NICCD (very high AFP and citrulline, high GGT — pearl 12).
- Ferritin (> 10,000 suggests HLH — TODO(verify) Allen 2008; in a neonate with liver failure at birth also think GALD) and HLH criteria when splenomegaly or liver failure at birth; extrahepatic iron (lip biopsy or MRI) for GALD.
- Diet on suspicion: stop lactose before results in suspected galactosemia — the diet is diagnostic and therapeutic.

## Card draft (day 31, 2026-11-16)

Built as `Content/Cards/ref_metabolic.json` (reference card, free-form). Scope per CLAUDE.md §4.3 F: what to draw before infusions, feeding changes and transfusion.

**Sections:** crit note "Treat first, sample in seconds" → table "What the next step erases" (before glucose / lactose stop / transfusion / UDCA / dextrose + protein restriction / vitamin K) → workup "One draw" (bedside, blood, urine, critical sample, big spleen) → lab_norms (ammonia, AFP) → "Read with care" (ammonia handling, reducing substances, succinylacetone, AFP, ferritin, serum bile acids, Δ4-3-oxo, oxysterols) → "Fallbacks" → "Feed and treat while results run" → pearls → guideline_compare (4 rows).

**Sources checked 2026-11-16:**
- Thornton 2015 PES (PMC11891912, full text): critical sample at presentation, before treatment that alters BOHB, FFA, insulin; PG, bicarbonate, BOHB, lactate; extra plasma held for insulin, FFA, C-peptide, carnitine/acylcarnitines; fasting test if no critical sample.
- Chinsky 2017 (PMC5729346, full text): SA primary marker; tyrosine-only misses ~28%; many HT-1 infants have normal tyrosine < 48 h.
- Geberhiwot 2018 (PMC5889539, full text): cholestane-triol spurious in neonatal cholestasis → plasma bile acids test of choice; false positives in ASMD, LAL-D.
- Welling 2017 GalNet (PMC5306419, full text): rec #4 galactose-restricted formula (soy, casein hydrolysate, elemental) on suspicion; GALT ± genotype.
- Savy 2018 (PMC6140721, full text): ammonia — no tourniquet, on ice, rapidly to lab, stable < 15 min at 4 °C; no capillary sample; repeat if high; hyperammonemia panel (amino acids, organic acids, acylcarnitines, orotic acid).
- Allen 2008 abstract: ferritin > 10,000 — 90% sensitive, 96% specific (all-age pediatric series, 10 HLH of 330).
- Henter 2007 (HLH-2004): ferritin ≥ 500 criterion; 5/8 or molecular diagnosis — via lesson 02-10 slide; citation verified on Europe PMC.
- Heubi 2007 (abstract) + lesson 02-07: stop UDCA 7–10 d before urine bile acids; Δ4-3-oxo secondary in severe liver disease.
- GeneReviews (Berry 2021): urine galactitol and genotype after transfusion — via lesson 02-06 (NCBI page blocked to automated fetch).
- Not verified, therefore worded without a number: duration of falsely normal GALT after transfusion (no number published); "pattern clearest in the crisis" (expert opinion label); Fawaz 2017 positions taken from lessons 02-06/02-10 (full text closed — library P1).

**Not published (deliberate):** ferritin "> 20,000 → think HLH" and "GALD > 800" (lesson 02-10 only, no primary checked); nitisinone and cholic acid doses (belong to disease cards); ammonia "within 30 min" (Häberle 2019 full text closed; secondary sources disagree 30 vs 60 min).
