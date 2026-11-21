# colantonio_2012_caliper — full-text note

- **Source:** Colantonio DA, Kyriakopoulou L, Chan MK, et al. Closing the gaps in pediatric laboratory reference intervals: a CALIPER database of 40 biochemical markers in a healthy and multiethnic population of children. Clin Chem 2012;58:854-868, doi:10.1373/clinchem.2011.177741
- **Read:** 2026-11-21 from the full text (15 PDF pages). Methods pp. 855–856, Table 1 pp. 857–863 (only liver-relevant rows extracted below), discussion pp. 864–866.
- **Status of document:** primary study (reference-interval study), not a guideline. 2,188 healthy children, newborn to 18 y, Toronto; multiethnic (≈ 64% Caucasian, plus East and South Asian). Children ≥ 1 y = healthy community children; < 1 y included healthy neonates going home from a maternity ward and outpatients (dental, fracture, plastic surgery). CLSI C28-A3 methods: Tukey outlier removal, Harris–Boyd partitioning, nonparametric 2.5th–97.5th percentiles when n ≥ 120 (Horn–Pesce robust method when n < 120; min–max when n < 39).
- **Analyzer:** **Abbott ARCHITECT c8000**. Intervals are **analyzer-specific**; other platforms need transference (the paper says so in the discussion).

## Answers to what was needed — upper (and lower) reference limits

Format: lower–upper. "F = M" when the paper gives one interval for both sexes. Units: U/L for enzymes, mg/dL for bilirubin.

**ALT — without pyridoxal-5'-phosphate (P5P)**
| Age | Female | Male |
|---|---|---|
| 0 to < 1 y | 5–33 | 5–33 |
| 1 to < 13 y | 9–25 | 9–25 |
| 13 to < 19 y | 8–22 | 9–24 |

**ALT — with P5P ("ALT ACT")**
| Age | Female | Male |
|---|---|---|
| 0 to < 1 y | 5–51 | 5–51 |
| 1 to < 13 y | 11–30 | 11–30 |
| 13 to < 19 y | 8–24 | 10–33 |

**AST — without P5P**
| Age | Female | Male |
|---|---|---|
| 0–14 d | 32–162 | 32–162 |
| 15 d to < 1 y | 20–67 | 20–67 |
| 1 to < 7 y | 21–44 | 21–44 |
| 7 to < 12 y | 18–36 | 18–36 |
| 12 to < 19 y | 13–26 | 14–35 |

**AST — with P5P ("AST ACT")** — 0–14 d 23–186; 15 d to < 1 y 23–83; 1 to < 7 y 26–55; 7 to < 12 y 22–41 (F = M for these bands). The 12 to < 19 y row did not extract cleanly from the PDF — re-check on the page before use.

**GGT**
| Age | F = M |
|---|---|
| 0–14 d | 23–219 |
| 15 d to < 1 y | 8–127 |
| 1 to < 11 y | 6–16 |
| 11 to < 19 y | 7–21 |

**ALP (4-nitrophenyl phosphate method)**
| Age | Female | Male |
|---|---|---|
| 0–14 d | 90–273 | 90–273 |
| 15 d to < 1 y | 134–518 | 134–518 |
| 1 to < 10 y | 156–369 | 156–369 |
| 10 to < 13 y | 141–460 | 141–460 |
| 13 to < 15 y | 62–280 | 127–517 |
| 15 to < 17 y | 54–128 | 89–365 |
| 17 to < 19 y | 48–95 | 59–164 |

**Bilirubin, direct (mg/dL)** — 0–14 d 0.33–0.71; 15 d to < 1 y 0.05–0.30; 1 to < 9 y 0.05–0.20; 9 to < 13 y 0.05–0.29; 13 to < 19 y F 0.10–0.39, M 0.11–0.42.
**Bilirubin, total (mg/dL)** — 0–14 d 0.19–16.60; 15 d to < 1 y 0.05–0.68; 1 to < 9 y 0.05–0.40; 9 to < 12 y 0.05–0.55; 12 to < 15 y 0.10–0.70; 15 to < 19 y 0.10–0.84.

**Albumin (bromcresol green, g/dL)** — 0–14 d 3.3–4.5; 15 d to < 1 y 2.8–4.7; 1 to < 8 y 3.8–4.7; 8 to < 15 y 4.1–4.8; 15 to < 19 y F 4.0–4.9, M 4.1–5.1. (Bromcresol purple gives lower values — separate rows in the paper.)

- **P5P choice:** the paper reports both versions and does not recommend one; the version must match the local assay. With-P5P upper limits for ALT are higher (e.g. 1–13 y: 30 vs 25).
- **Ethnicity:** ALT was one of the analytes with ethnic differences (online supplement), but Table 1 intervals are not split by ethnicity.

## Other facts useful for cards

- ref_norms: neonatal GGT is very high in the first 2 weeks (upper limit ~219) and falls through infancy — infant GGT must be read against age.
- ref_norms / alp_isolated: ALP peaks in infancy and puberty; boys' upper limits stay high to 17 y (13 to < 15 y up to 517).
- c_conj_bili: direct bilirubin upper limit in the first 2 weeks is ~0.7 mg/dL on this analyzer; < 0.3 after 2 weeks to 1 year.

## Conflicts with what the app says now

- **labs.json / ref_norms / c_uln (D-2026-10-29-1):** CALIPER numbers were withheld until the primary source was read — now available. If added, record **analyzer (Abbott ARCHITECT), method (with/without P5P), and that intervals are lab-specific**; keep "use your lab's range" as the main rule.
- **ALT teen:** CALIPER without P5P 13–19 y upper limit F 22 / M 24 (with P5P: 24 / 33) vs SAFETY/NASPGHAN 22 / 26 used in the app — similar; SAFETY remains the guideline-endorsed source.
- **alt_elevated (AASLD 2025 "> 30 U/L under 10 y" TODO):** CALIPER 1–13 y ALT upper limit is 25 (no P5P) / 30 (P5P) — see `aasld_2025_masld_peds` note for what AASLD actually says.
