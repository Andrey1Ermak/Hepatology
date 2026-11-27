# ref_biopsy — Liver Biopsy (draft)

Reference card C (task: day 22). Inbox is filled by daily lesson sync (§3.4).

## Inbox

### 03-03 · Biliary atresia: diagnosis (synced 2026-10-25)
- **Infant cholestasis — what the pathologist reads:** obstructive pattern (ductular proliferation, bile plugs, portal edema and fibrosis, preserved lobule) vs hepatitic (lobular disarray, giant cells, portal inflammation). Overlap: giant cells in 20–50% of atresia; A1AT, Alagille, PFIC3, CF and PN give ductular change.
- Accuracy: 90–95% with experienced pediatric pathologists (Fawaz 2017, 1B); obstruction calls in proven atresia 79–98% across consortium pathologists, PPV 90.7% (Russo 2016); AUC 0.84 in ChiLDReN (Pandurangi 2024). → Ask for an experienced pediatric liver pathologist.
- **Timing:** a biopsy at ~3 weeks may show only hepatitis; pale stools persist → repeat or go to cholangiogram.
- Safety: complication rate ~1.7% in a large pediatric series, higher in small infants — vitamin K and INR first. TODO(verify) source of 1.7% (lesson cites Fawaz 2017) before publishing.

### 04-03 · Alagille syndrome III: the liver (synced 2026-11-09)
- **Published 2026-11-09:** "Diagnosis known" → ALGS: no routine biopsy for prognosis or management (EASL 2024 rec., LoE 3, strong — verified in full text); with a known variant, do not biopsy to prove paucity (lesson 04-03, slide 18).
- Paucity definition: duct/portal tract ratio < 0.9 on ≥ 10 tracts; some use duct/artery < 0.5 — definitions not interchangeable; CK7/CK19 to find remnants; paucity not specific (~11% of pediatric biopsies at one centre — TODO(verify) source).

### 04-05 · Alagille syndrome V: the vessels (synced 2026-11-11)
- **ALGS bleeding with normal tests (Lykavieris 2003, 174 records reviewed):** 38 (22%) without liver failure bled, median PT and platelets normal; 1 death after needle liver biopsy, 4 after surgery. The published card already says "ALGS: bleeding tendency (ESPGHAN 2015)" — at block 4 synthesis consider adding the Lykavieris numbers and "normal INR/platelets do not clear the procedure; vitamin K, cross-match, experienced operator, longer observation". TODO(verify) Lykavieris 2003 abstract.

### 04-12 · Alagille syndrome XII: other causes of ductopenia (synced 2026-11-18)
- **Duct counting (slide 4):** normal duct:portal-tract ratio 0.9–1.8 (Kahn 1989, verified); paucity < 0.5 and "count ≥ 10 portal tracts — fewer cannot prove or exclude paucity" are lesson-only — TODO(verify) separate source; CK7/CK19 immunostain finds small ducts and shows CK7 in periportal hepatocytes (chronic cholestasis). Before 38 weeks post-conceptional age a ratio < 0.9 may be normal (Kahn 1989, Hepatology 10:21–3; ≥ 0.9 in 8 of 9 subjects after 38 weeks; biopsy for paucity only after 38 weeks — verified against the abstract, PMID 2737599). Candidate line under "Infant cholestasis": "Duct count on CK7 over ≥ 10 portal tracts; give the post-conceptional age." **Conflicts with the 04-03 entry above ("paucity < 0.9")** — 04-12 separates normal lower limit (0.9) from paucity (< 0.5); resolve before publishing any threshold; Kahn shows 0.9 is the lower limit of normal, so "paucity < 0.9" (04-03) is probably wrong. At build, make paucity an explicit exception to the published "6 portal tracts can name a disease" line (lesson trap: calling paucity on 6 tracts).
- **Three metrics in use (slides 4, 17):** ratio (pediatric pathology), share of portal tracts *without* a duct (Banff 2016, after LT), share *with* ducts (DILIN: moderate–severe < 50%, mild 50–75%). → Candidate pitfall: "Ask which metric the report uses before comparing two biopsies."
- **Biopsy is prognostic in persisting drug cholestasis (DILIN, Bonkovsky 2017):** duct loss → chronic injury 94% vs 47%; degree of loss the strongest predictor of a poor outcome (verified against the abstract, PMID 27981596). Candidate indication under "Diagnosis known": cholestatic drug injury that does not settle — biopsy rather than wait.
- **After HSCT:** NIH 2014/2015 — the liver alone does not establish chronic GVHD; biopsy earns its risk when no diagnostic sign elsewhere (see onc_hsct Inbox).

### 05-05 · PFIC V: the new genes (synced 2026-11-25)
- **→ publish (interpretation error risk):** an abnormal BSEP stain is not specific for ABCB11 disease. In FXR (NR1H4) deficiency BSEP was undetectable with normal ABCB11 and preserved MDR3 (Gomez-Ospina 2016 — abstract VERIFIED: "undetectable liver bile salt export pump"; already cited in ref_genetics). In MYO5B deficiency BSEP is **mislocalized, not absent**: "abnormal distribution of BSEP at canaliculi" (Qiu 2017, Hepatology 65:1655 — VERIFIED abstract), while Matarazzo 2022 found BSEP **normally expressed** at the canalicular membrane with coarse cytoplasmic MYO5B granules (VERIFIED abstract, Europe PMC 35129155). Candidate line next to the existing Strautnieks 2008 BSEP-stain line: "Absent BSEP with normal ABCB11 → think NR1H4 (FXR). Patchy or mislocalized BSEP → think MYO5B. A normal BSEP stain does not exclude MYO5B."
- **ZFYVE19 / KIF12:** high-GGT cholestasis with patent ducts; biopsy may show ductal plate malformation / congenital hepatic fibrosis pattern (Luan 2021 — TODO(verify)) → gene testing rather than repeat imaging.
- **TJP2:** EM — elongated tight junctions lacking the densest part; claudin-1 mislocalized (Sambrotta 2014 — TODO(verify) full text).

### 05-07 · PFIC VII: diagnosing PFIC — IHC, EM, genetics, NAPPED (synced 2026-11-27)
- No safety correction: the published card already splits the core (glutaraldehyde for EM), lists BSEP and MDR3 stains with EM for low-GGT cholestasis and the "visible BSEP does not exclude" caveat (checked 2026-11-27).
- **Light microscopy is nonspecific — VERIFIED (Evason 2011, Am J Surg Pathol 35:687, abstract PMID 21490445):** 12 children with ABCB11 mutations, 22 specimens; hepatocellular cholestasis in all, centrizonal/sinusoidal fibrosis in every patient; neonatal-hepatitis-like change varied; fibrosis worsened in 2 of 5 with paired samples; "light microscopy and EM … can support diagnosis, but are variable and nonspecific". Lesson percentages (giant cells 22/22, pseudorosettes 20/22, hepatocyte swelling 13/22, portal stage 3–4 9/21, necrosis 4/22) — TODO(verify) full text (PMC3416050) before publishing. → pearl: histology says "hepatocellular and canalicular, not ductal"; the name comes from stains and genes.
- **BSEP stain — VERIFIED (Evason 2011 abstract):** canalicular BSEP absent in 10, present in 2; the 2 with demonstrable BSEP carried missense and/or noncoding variants and had a more indolent course. Adds to the published Strautnieks line.
- **→ publish at the next ref_biopsy pass: ask for a panel, not one antibody (lesson slide 8; Sambrotta 2014, Qiu 2017):** BSEP; MDR3 (abnormal mainly with biallelic truncating ABCB4 — missense MDR3 disease often stains normally); MRP2 or CD10 as an internal canalicular control (all markers lost → poor tissue, not disease); TJP2 and claudin-1 for TJP2 deficiency (few laboratories validated); MYO5B (coarse granules). In Qiu 2017 BSEP looked reduced in 5 of 10 MYO5B livers (TODO(verify) number; the qualitative point is already in the 05-05 Inbox). Read the pattern across the panel beside the genotype.
- **EM — VERIFIED in part (Evason 2011 abstract: all 9 BSEP patients studied had canalicular dilatation, microvillus loss and finely granular bile):** coarse "Byler bile" suggests FIC1; finely granular bile suggests BSEP; elongated tight junctions with a thin zona occludens suggest TJP2 (lesson slide 9; Bull 2018, Sambrotta 2014 — TODO(verify)). EM earns its place when the panel is negative or a variant is uncertain (e.g. Byler bile supporting a missense ATP8B1 VUS). Few centres read it. Logistics already published (glutaraldehyde core) — add "ask before the needle goes in".


## Build notes (day 22, 2026-11-07)
- Card built from lessons 01-04, 01-05, 01-06 (slides + chapters) and the 03-03 Inbox above; JSON is the source of truth (`Content/Cards/ref_biopsy.json`).
- **Not published:** the "1.7% complication rate" from the 03-03 Inbox (attributed by the lesson to Fawaz 2017; source not confirmed) — replaced by the primary pediatric series (Matos 2012, Westheim 2012, Cohen 1992, Short 2013).
- **Not published (unverified beyond the lesson):** HCC needle-track seeding 1.6–5%; blind-percussion RCT (Mogahed 2016); EUS-guided biopsy (Schwartz 2025); Laennec/CPA cirrhosis subclasses; ductopenia ratio < 0.9 in term infants (Ayoub & Kamath 2020); IAIHPG 2022 histology criteria; C5b-9 in GALD. Candidates for a later pass or for cards 3, 24, 23.
- Hemostasis wording aligned with `inr_prolonged` ("no plasma for a number; agree the route with the proceduralist").

### Guideline watch (2026-11-09, weekly check)
- **AASLD EXPO: Liver Biopsy** — Verna EC, Adler DG, Kappus MR, Rand EB, Tapper EB, Rockey DC. Hepatology 2026, doi 10.1097/HEP.0000000000001828 (published 2026-10-15; PMID 42841770). Updates AASLD 2009; has pediatric recommendations (age/size, sedation, anatomy, coagulopathy, local expertise); adds EUS-guided biopsy. Full text not accessible on 2026-11-09 → re-check the AASLD 2009 lines (≥ 11 portal tracts etc.) before changing anything.

### 04-14 · Block 4 synthesis (synced 2026-11-20)
- **Published 2026-11-20 (D-2026-11-20-1):** "Who bleeds" — Lykavieris 2003 (38/174, 22%, normal median platelets and PT, 8 bleeding deaths, 1 after needle biopsy; abstract verified); ARC split into its own line. Still open: paucity threshold conflict (0.9 vs 0.5), duct-count metrics, DILIN prognosis indication — at card 3/26 build.
