# ref_genetics — Genetic Testing (draft)

**Built 2026-11-09 (day 24) → Content/Cards/ref_genetics.json.** Inbox below stays as the reading list for future enrichment.

## Inbox

### 02-12 · Genetics in the infant (synced 2026-10-20)
- Yield is a property of the patient, not the test: 4.3% (preterm) to 71% (suspected genetic cholestasis) with similar panel or exome technology (slide 4: Togawa 2016, Wang H 2022, Karpen 2021, Hoskins 2026).
- Panel vs genome: GEMINI (Maron 2023, n = 400 infants, both tests on the same sample) — genome 49% vs targeted panel 27%; 95 diagnoses only by genome vs 9 only by panel; urgent turnaround 80 h vs 99 h. Exome and genome performed alike in NSIGHT2; trio vs singleton changed yield by about 1 point.
- Rapid ICU sequencing: ultra-rapid exome median 3 days, 51% yield (Lunke 2020); liver subset — acute liver dysfunction, rapid genome 7/18 (39%) diagnosed, median 4 days (Bonser 2023). **No trial in suspected atresia** — liver data are extrapolated.
- Order with copy-number (del/dup) analysis: whole-gene JAG1 deletions ~6.4% of Alagille probands, NOTCH2 3.6% (Vandriel 2025).
- Alpha-1 antitrypsin is not on every panel → Pi type and level separately.
- VUS is not a diagnosis; one heterozygous ABCB4/ABCB11 variant is a modifier at most (77.5% of a Taiwanese cohort carried ≥ 1 variant — Chen 2019; single variants ~25% of patients vs 26% of controls in another comparison, TODO(verify) source). Phase with parents; re-analyze.
- ACMG (Manickam 2021): exome or genome as first- or second-tier test for congenital anomalies or developmental delay — not a liver-disease recommendation.
- Reanalysis: EASL 2024 at least every 3 years; ACMG (Manickam 2021): laboratory policy, no interval.
- Secondary findings: a genome may report adult-onset actionable genes (ACMG secondary-findings list v3.3, 2025, added CYP27A1) → agree with parents in advance what will be returned. TODO(verify) ACMG v3.3 before publishing.
- Guidelines: NHS England National Genomic Test Directory R14 (rapid trio genome for acutely ill children) — candidate guidelines.json entry; AASLD silent.

### 02-14 · Block 2 synthesis (synced 2026-10-22)
- Rapid genome in parallel with the atresia workup; **never let it delay the cholangiogram**. A result may cancel a Kasai (Alagille with a patent duct), a pending result or VUS may not delay surgery. No guideline states this explicitly (gap, slide 17) → note as "Expert opinion (lesson 02-14)".
- Yield 4% (PN cholestasis) to 71% (genetic phenotype); genome beat panel 49% vs 27% (GEMINI) — consistent with 02-12 Inbox.
- Family referral: after GALD → obstetrics (antenatal IVIG); after familial idiopathic neonatal hepatitis → genetics ("the next pregnancy is also our patient").
- Suspected ARC → genetics, not biopsy.

### 03-02 · Biliary atresia: pathogenesis (synced 2026-10-24)
- Atresia is not a Mendelian disease (slide 14): ADD3/XPNPEP1 locus (GWAS, Garcia-Barceló 2010), GPC1 deletions (Cui 2013), rare biallelic PKD1L1 variants in 5/67 with splenic malformation (Berauer, Hepatology 2019). Common variants shift risk only modestly.
- Whom to test (slides 18, 20): no atresia-susceptibility gene test for the patient, siblings or co-twin (recurrence is rare; 19/19 twin pairs discordant). The cholestasis panel or rapid genome to rule out mimics still runs in parallel (02-14). Identical co-twin: low risk; screen with fractionated bilirubin and stool color. Splenic malformation + situs anomaly → consider a ciliary gene panel (PKD1L1) and echocardiogram; counsel that onset is embryonic. Expert opinion (lesson synthesis).

### 04-01 · Alagille syndrome I: genetics (synced 2026-11-07)
- **Ask whether the panel calls copy-number variants:** ~13% of pathogenic JAG1 variants are whole-gene deletions (CHOP; ~6.4% of all probands in GALA — different denominator), invisible to Sanger and to some exome pipelines (Gilbert 2019; GeneReviews 2024: sequencing detects ~88%). Expert opinion (team generalization, not in the lesson): the same applies to any haploinsufficiency gene on a panel.
- **Microarray** when a deletion is found with developmental delay, hearing loss or autism → size a contiguous deletion (20p12 for JAG1).
- **Variant reinterpretation is real:** of 61 published NOTCH2 variants, 31% fell to VUS and 16% to likely benign under GALA 2025 disease-specific criteria (Vandriel 2025) → old "likely pathogenic" reports deserve reanalysis.
- **VUS tie-breakers:** segregation in parents, targeted phenotype search, functional data; tissue (biopsy) acceptable (EASL 2024 per lesson — TODO(verify)).
- **Parents negative in blood ≠ zero recurrence:** parental mosaicism in at least 8.2% of Alagille families (Giannakudis 2001); germline mosaicism is invisible in blood. Prenatal/preimplantation testing possible once the familial variant is known — a positive result says nothing about severity, and a normal fetal echo does not exclude Alagille syndrome.
- **Variable expressivity:** of 53 carrier relatives, 47% did not meet clinical criteria (Kamath 2003) — clinical criteria were written for probands; cascade-test relatives.
- **Record the exact variant** in the chart: it is needed for cascade testing and any related living-donor work-up.

### 04-02 · Alagille syndrome II: clinical criteria (synced 2026-11-08)
- **A variant lowers the clinical bar:** with a pathogenic/likely pathogenic JAG1 or NOTCH2 variant (or a family history), one feature suffices (GeneReviews 2024; Turnpenny & Ellard 2012). In relatives the variant test is the criterion; the exam measures severity (Kamath 2003: 47% of carrier relatives fail classic criteria).
- **Test early, low threshold:** molecular yield falls with fewer features but never to zero (~1/3 with only 1–2 features — TODO(verify) source, lesson: Exeter/Guegan 2012). EASL 2024: NGS early in unexplained cholestasis, not single-gene Sanger.
- Genotype does not tell which organs are affected: the full systems work-up is the same after a gene diagnosis.

## Build notes (day 24, 2026-11-09)
- Sources read: lessons 01-11, 02-12 (+ Inbox 02-14, 03-02, 04-01, 04-02); EASL 2024 full text (general recommendations: NGS early in infants/children; Sanger discouraged except ABCB4 in small-duct PSC; WGS if WES negative; reanalyse ≥ every 3 years; counselling before testing; incidental findings agreed in advance; VUS upgrade via family testing, in vitro data; ALGS biopsy useful with a VUS).
- 20 primary citations checked against Europe PMC/Crossref abstracts (13 confirmed, 5 partly, 2 not in abstract) — see D-2026-11-09-2.
- **Not published (no verified number):** JAG1 whole-gene deletion share (6.4% GALA / ~13% CHOP / 70 of ~700 catalogued, Gilbert 2019); single ABCB4/ABCB11 variant 25% vs 26% controls (Chen 2019); panel median 21 days (Karpen 2021); GEMINI hours (abstract: urgent 3.3 vs 4.0 days; routine genome slower, 6.1 vs 4.2 days); NHS R171 criteria; FDA/EMA IBAT label ages for PFIC (lesson slide 17 — labels not checked).
- Fawaz 2017 positions taken from the lessons (full text not accessible today) — D-2026-11-09-3; verify.
- Deferred: case block (reference card; no cases), BSEP genotype table (only BSEP3 vs BSEP1 line published), NBAS fever protocol (→ palf card), NPC1 case report.
