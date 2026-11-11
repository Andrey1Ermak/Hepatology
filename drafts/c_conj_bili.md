# c_conj_bili — Conjugated bilirubin: cholestasis? (calculator draft)

Calculator **built 2026-11-11 (day 26)** → `Calculators/ConjBiliCalc.swift`, `Views/Calculators/ConjBiliCalcView.swift`; decisions D-2026-11-11-2. Inbox below stays as history.

## Build notes (2026-11-11)
- Verified: Fawaz 2017 abstract (direct > 1.0 mg/dL or > 17 µmol/L); NICE CG98 rec. 1.7.2 (conjugated > 25 µmol/L → expert advice; archived copy); Harpavat 2011 abstract (all BA newborn values above lab norms; 79% ratio ≤ 0.2).
- Not verified (full text closed to the cloud run): AAP 2025 exact wording (≥ 1 vs > 1; newborn above-range rule) → library `aap_2025_ba_primary_care`; "conjugated > 0.3 mg/dL" (AAP 2022, published in unconj_bili from lesson 01-02) → library `aap_2022_hyperbili`, not used in the calculator.
- SIGENP 2022 20% rule — not shown (TODO(verify) never closed; the calculator gives no ratio verdict).

## Inbox

### 02-14 · Block 2 synthesis (synced 2026-10-22)
- Primary rule: direct or conjugated bilirubin > 1.0 mg/dL = abnormal **at any total** (Fawaz 2017). No 20% ratio rule: 79% of atresia had direct/total ≤ 0.2 on day 2 (Harpavat 2011). Do not output a ratio-based verdict.
- Newborn period (AAP 2025 Harpavat): any direct/conjugated value above the lab's reference range is abnormal → repeat by 2 weeks and ask about stools. Calculator needs an optional "lab upper limit" input for this branch.
- Show alternatives as context, not as the verdict: NICE CG98 conjugated > 25 µmol/L (≈ 1.46 mg/dL); SIGENP 2022 keeps the 20% rule — TODO(verify).
- Direct (diazo) and conjugated (enzymatic/dry-slide) are different assays — label the input with the assay; TODO(verify) whether Fawaz 2017 and AAP 2025 thresholds apply to both.
- Unit toggle mg/dL ↔ µmol/L (× 17.1). Pale stool at any age overrides the number → test today.
