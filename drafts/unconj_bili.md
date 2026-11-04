# unconj_bili — Unconjugated Hyperbilirubinemia (card 6)

Status: draft → JSON 2026-11-04 (day 19). cat `jaundice`, acu `rt`, ages infant/child/teen, entry `lab`.
Lessons: 01-02 (Bilirubin, read correctly), 01-14 (block 1 synthesis). Plan: block 1, days 2 and 14.
Links (§4.5): → neo_jaundice (1), gallbladder (21) — not built yet, add on their day; c_conj_bili — not built; ref A `ref_norms` ✓; ref E — not built.

## Sources (guidelines.json)
- aap_2022_hyperbili — Kemper AR et al. Pediatrics 2022;150:e2022058859 (prolonged jaundice: breastfed 3–4 wk, formula-fed 2 wk → total + direct/conjugated; review newborn screen — hypothyroidism, galactosemia, tyrosinemia; G6PD when TSB rises despite phototherapy, rises suddenly or after a decline, or escalation of care; DAT if maternal antibody screen positive/unknown; breast-milk jaundice up to ~3 months (AAFP 2023 summary); direct > 1.0 / conjugated > 0.3 abnormal (lesson slide 7)). No newer version found (checked 2026-11-04).
- naspghan_espghan_2017_nc — direct > 1.0 mg/dL pathological at any total (1A).
- bsg_2018_lft — isolated raised bilirubin: Gilbert commonest; fasting repeat with FBC and split bilirubin; anemia → retics/LDH/haptoglobin; unconjugated > 40 µmol/L → consider Crigler–Najjar and genetics (adult text, not a graded recommendation).
- maruo_2016_ugt1a1 — GS 2.8 ± 1.1, intermediate 5.2 ± 2.2, CN-2 12.9 ± 5.1 mg/dL; continuum; 163 Japanese patients.
- bosma_1995_gilbert — A(TA)7TAA homozygous; allele frequency 40% (Amsterdam controls); activity ~30%.
- kaplan_1997_g6pd — G6PD-deficient: normal promoter 9.7%, heterozygous 31.6%, homozygous 50% vs controls.
- strauss_2020_cn1 — CN1: +4.3 ± 1.1 mg/dL/day; kernicterus 4/28 (14%) days 14–45; TSB ≥ 30 or B/A ≥ 1.0 mol/mol; phototherapy after day 13 → 3.5×; 9.2 h/day; +0.46 mg/dL/yr; 17 transplanted.
- dantiga_2023_cn_gene — AAV8-UGT1A1 phase 1–2, 5 patients, higher dose off phototherapy ≥ 78 wk.

## 1. Red flags
- Jaundice with poor feeding, lethargy, high-pitched cry, arching or abnormal tone → ED now (acute bilirubin encephalopathy) — AAP 2022.
- Infant: unconjugated bilirubin rising day by day without hemolysis → admit: phototherapy now, bilirubin:albumin, call hepatology (Crigler–Najjar I) — Strauss 2020, lesson case 4.
- Known Crigler–Najjar with fever, vomiting or fasting → same-day bilirubin + albumin; hepatology today — lesson slide 9.
- Pallor, dark (tea) urine, breathlessness, rapid heart rate → ED now (acute hemolysis; G6PD crisis).
- Coombs-negative hemolysis + jaundice in a sick child → acute Wilson: INR, call transplant center (consistent with ast_isolated).
- Direct > 1.0 / conjugated > 0.3 (infant) or above lab range (older child) → not this card.

## 2. Age
Two branches: infant 1–12 mo; child/teen 1–18 y. Newborn < 28 d → neonatal team and AAP 2022 phototherapy thresholds (card 1 later).

## 3. Algorithm
Infant: (1) conjugated? never divide; (2) sick? (3) hemolysis? (4) newborn screen, thyroid, feeding; (5) thriving breastfed → breast-milk jaundice, recheck; still jaundiced by 3 months / bilirubin high or rising → hepatology + UGT1A1 sequencing.
Child/teen: (1) conjugated? (2) sick? (3) hemolysis? (4) drugs (atazanavir); fasting/illness; (5) repeat when well and fed: ≤ ~5 mg/dL, normal CBC/retics/enzymes → Gilbert, no genetics; persistently > 5 → hepatology, UGT1A1 sequencing (CN-II/intermediate) — threshold = expert opinion from Maruo distributions (D-2026-11-04-1).

## 4. First contact
Total + direct/conjugated (know the method); ALT, AST, ALP, GGT, albumin; CBC, retics, smear, LDH, haptoglobin; DAT; G6PD (not during acute crisis — TODO(verify) → not published); infant: newborn screen, TSH/fT4.

## 5. Don't miss
Hemolysis (G6PD, spherocytosis, immune); Crigler–Najjar I/II; hypothyroidism in infant; acute Wilson; conjugated disease hidden by a large total; pigment gallstones with chronic hemolysis.

## 6. Why
Five steps (lesson slide 2); newborn load (slide 3); delta absent in unconjugated; Gilbert ~30% activity; continuum.

## 7. Pearls
Never divide (Harpavat 2011 via lesson); East Asian *6 missed by TA-repeat test; Gilbert + G6PD (Kaplan); fasting doubles; irinotecan/atazanavir; hemolyzed sample lowers direct; albumin beside bilirubin; phenobarbital > 30% fall in CN-II; phototherapy fails in adolescence.

## 8. Guidelines compare
Rows: when to fractionate in infants (AAP vs NASPGHAN); threshold for genetics (BSG > 40 µmol/L vs app > 5 mg/dL expert); confirming Gilbert (BSG fasting repeat vs lesson repeat when well); G6PD testing.

## 9. Cases
c1 lesson case 2 (teen Gilbert); c2 lesson case 4 (CN I) adapted to infant presentation; c3 G6PD + Gilbert-type infant / breast-milk jaundice vs hemolysis; c4 lesson Q4-style "ratio" trap.

## Review log (2026-11-04)
Round 1: 7 blocking (pale stools same-day; infant bilirubin ceiling; < 28 d route; child "sick?" first, dark urine/AST/ALP caveats; BSG cell; Maruo range; expert-opinion labels) + 10 non-blocking — all fixed except pyloric stenosis and G6PD false-normal caveat (backlog: need sources). "Up to 3 months" breast-milk jaundice — not found in AAP text, not published.

## Inbox
—
