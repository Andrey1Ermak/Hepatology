# alt_elevated — Elevated Transaminases (draft)

Card 7 · `cat: labs` · `acu: rt` · ages: neo, infant, child, teen · `entry: lab` · status: draft (day 15; JSON build — day 16).
Pipeline §7, stages 1–2. Lessons read: 01-01 Reading the liver panel (core), 01-14 Block 1 synthesis. Plan links (§4.5): blocks 1, 7, 8, 11, 13, 16, 25 — only block 1 has been taught; other branches are written from guidelines and marked **enrich after block N**.
Decisions: D-2026-10-31-1 … -6. Clinical review 2026-10-31: 9 blocking + 19 non-blocking addressed.

## Sources (checked 2026-10-31)
| id (guidelines.json) | Document | Status |
|---|---|---|
| `aasld_2025_masld_peds` | Xanthakos SA et al. AASLD practice statement, pediatric MASLD. Hepatology 2025;82:1352–94 | In registry. No newer version. ULN > 26 M / > 22 F from age 10; repeat a raised ALT within 3 months. Under 10 y: no validated cut-off (> 30 U/L is a research convention — secondary summaries; primary text closed) |
| `espghan_2026_masld` (new) | Mann JP et al. ESPGHAN position paper on screening, diagnosis and investigation of paediatric MASLD. JPGN 2026;83:555–76, doi 10.1002/jpn3.70490 | **Add at build.** Abstract verified: ALT ≥ 30 IU/L = screening test (> 10 y with obesity, or any age with risk factors). "ALT 30–80 repeat in 2–6 months; ≥ 80 investigate now; red flag refer at once" — lesson 01-01 slide 16; **TODO(verify)** in the full text |
| `seghnp_2022_htra` (new) | Ros Arnal I et al. Diagnostic action against hypertransaminasemia in paediatrics: SEGHNP/AEPap/SEPEAP consensus. An Pediatr (Barc) 2022;96(5):448.e1–448.e11, doi 10.1016/j.anpede.2022.04.009 | **Add at build.** Full text read 2026-10-31: confirm in 2–4 weeks (up to 8 if a transient cause is expected); tier 1 → tier 2 within 3–6 months; full evaluation within 12 months; chronic = > 6 months; biopsy at 12–18 months if still undiagnosed; exome if persistent and unexplained; macro-AST for isolated AST |
| `kwo_2017_acg_lft` | Kwo PY et al. ACG clinical guideline, abnormal liver chemistries. Am J Gastroenterol 2017;112:18–35 | In registry (adult). Bands by × ULN; repeat or clarify first |
| `bsg_2018_lft` | Newsome PN et al. BSG guidelines on abnormal liver blood tests. Gut 2018;67:6–19 | In registry. Investigate regardless of level; children — low threshold for referral; ceruloplasmin from age 3 |
| `naspghan_2017_nafld` | Vos MB et al. NASPGHAN NAFLD guideline. JPGN 2017;64:319–34 | In registry. Superseded in practice by AASLD 2025 for ULN; keep for history |
| `safety_2010` | Schwimmer JB et al. Gastroenterology 2010;138:1357–64 | In registry (Why) |
| `iorio_2005` (new) | Iorio R et al. J Gastroenterol 2005;40:820–6 — 425 children, isolated hypertransaminasemia | Add (Why, pearls) |
| `rudolph_2015` (new) | Rudolph B et al. Acta Paediatr 2015;104:e557–63 — 120 obese children, ALT ≥ 40 | Add (Why) |
| `mcmillan_2011` (new) | McMillan HJ et al. Pediatrics 2011;127:e132–6 — Duchenne presenting as raised transaminases | Add (pitfall) |
| `yasmin_2022` (new) | Yasmin A et al. Indian J Gastroenterol 2022;41:224–30 — Wilson ratios in children | Add (pearl) |
| `aap_redbook_2024` (new) | AAP Red Book 2024–2027, Herpes simplex chapter | Add — TODO(verify) chapter citation (neo branch) |
| `korman_2008` (new) | Korman JD et al. Hepatology 2008;48:1167–74 — Wilson ALF ratios | Add (pearl) |
| `pettersson_2008` (new) | Pettersson J et al. Br J Clin Pharmacol 2008;65:253–9 — weightlifting raises ALT/AST ≥ 7 days | Add (pitfall) |

Newer-version check 2026-10-31: no new ACG/BSG liver-test guideline; AASLD 2025 current; ESPGHAN 2026 MASLD paper is the newest pediatric document; no new international pediatric consensus on hypertransaminasemia found.

## I. Red flags (Duty, first block)
Three tiers (SEGHNP 2022 Rec 8, 9, 19; lesson 01-01 part 9; ESPGHAN 2026 "refer at once" list via lesson slide 16 — TODO(verify) wording):
- **`picu` · Call PICU / transplant center now:** encephalopathy (confusion, drowsiness, irritability); hypoglycemia; renal failure; hemodynamic instability; PALF — INR ≥ 1.5 with encephalopathy or ≥ 2.0 without, not corrected by IV vitamin K (CLAUDE.md §4.2 card 13; SEGHNP transfer list incl. "INR above 2.5"). → link `palf` when built (block 12).
- **`floor`/`step` · Same-day hepatology:** jaundice, pale stools or dark urine; INR > 1.5 → give IV vitamin K, recheck INR (lesson 01-01 part 8; 01-14 pearl 5); ALT > 10 × ULN (SEGHNP Rec 19: "priority"); suspected liver mass (SEGHNP Rec 8); large liver or spleen (ESPGHAN list via lesson).
- **Acetaminophen:** ALT > 15 × ULN, or any possible ingestion (incl. repeated supratherapeutic dosing, teen self-harm) → acetaminophen level now; `link_calc_id: nac` (lesson 01-01 slide 4 "Paracetamol level"; D-2026-10-31-5).
- **`step` · Priority referral:** poor growth (ESPGHAN list via lesson).
- **Infant:** jaundice beyond 2 weeks of age, or pale stools or dark urine at any age → fractionated bilirubin today; direct > 1.0 mg/dL (17 µmol/L) = cholestasis (NASPGHAN/ESPGHAN 2017; wording as ref_norms — conjugated assays: use the lab's cut-off).
Ascites: no source in hand for this card — leave to splenomegaly_ph/ascites cards.

## II. Age (`age_switch`, 4 options)
`neo` 0–28 d · `infant` 1–12 mo · `child` 1–10 y · `teen` 11–18 y. One pathway per age (`alt_elevated_neo`, `_infant`, `_child`, `_teen`); shared steps repeated briefly in each.

## III. Algorithm
### Shared steps (every branch ≥ 1 mo, in order)
1. **Is the child sick?** Red flags → tiers above.
2. **Read against the right ULN** (→ `c_uln`, ref A `ref_norms`): 11–18 y — ALT > 26 boys / > 22 girls (AASLD 2025; AASLD applies it from age 10 — the app band is 11–18, so a 10-year-old is read against the lab ULN in `c_uln`; D-2026-10-31-1). ≤ 10 y — no validated pediatric ULN: use your lab's age-specific range. Write down the ULN you used.
3. **Name the pattern** (→ `c_rratio`, child's own ALP ULN): R ≥ 5 hepatocellular · 2–5 mixed · ≤ 2 cholestatic → treat as a cholestasis question (GGT, fractionated bilirubin).
4. **Grade the rise** (ACG bands via `c_uln`): narrows causes, does not predict prognosis (BSG Rec 3).
5. **Repeat or investigate** (D-2026-10-31-2):
   - Well, ALT < 80 U/L, no red flags → repeat once in 2–4 weeks with CK (SEGHNP Rec 6; up to 8 weeks if a transient cause is expected — e.g., recent viral illness). Not during an infection or after strenuous exercise: no strenuous exercise for ≥ 7 days, ideally 2 weeks, before the repeat (Pettersson 2008; SEGHNP).
   - New drug or supplement → stop or review it now; do not wait it out.
   - ALT ≥ 80 U/L (ESPGHAN 2026 via lesson — TODO(verify); fallback "> 5 × ULN", ACG moderate band), or still raised on repeat → tier 1 now.
   - ALT > 10 × ULN → same-day panel and hepatology (SEGHNP Rec 19).
6. **Traps:** AST > ALT, or both up in a boy → CK first; isolated AST with normal ALT and CK → macro-AST (card 8 when built; SEGHNP Rec 16).

### `teen` (11–18 y)
- Obesity / metabolic risk, ALT persistently raised → **focused panel** (see First contact) → MASLD pathway; card 25 `masld` when built (enrich after block 16). Keep ceruloplasmin and autoantibodies if ALT ≥ 2 × ULN or rising (D-2026-10-31-4).
- Acute illness or ALT > 10 × ULN → acute hepatitis panel same day (card 22 later; enrich after block 11).
- Ask directly: alcohol, anabolic steroids, sports and herbal supplements, isotretinoin, minocycline, antiepileptics (enrich after block 13).
- Causes to weigh: MASLD; drugs/supplements/alcohol; AIH (block 8); Wilson (block 7); HBV/HCV (blocks 10–11); EBV; celiac; thyroid; muscle.

### `child` (1–10 y)
- Shared steps 1–6.
- Suspected MASLD under 10 y → broader search for other causes first (AASLD 2025 via secondary summary — TODO(verify) wording).
- Causes to weigh: viral (EBV, CMV, HAV, adenovirus); celiac; AIH (anti-LKM1 — type 2 is typical of young children); Wilson from age 3 (age alone does not exclude it; ceruloplasmin is physiologically low in infancy — TODO(verify) AASLD 2022 Wilson guidance); A1AT; drugs; muscle (Duchenne in boys).

### `infant` (1–12 mo)
- Always fractionated bilirubin, INR and glucose with the repeat; cholestasis → `chol_0_3m`/`chol_3_12m` when built.
- Check the newborn screen result — panels vary; check what your program covers (galactosemia, hypothyroidism, tyrosinemia).
- Infection: CMV PCR (urine or blood — serology reflects maternal IgG) and TORCH (SEGHNP tier 1 "TORCH in infants").
- Metabolic: galactosemia; hereditary fructose intolerance after fructose/sucrose; tyrosinemia; GSD; mitochondrial (enrich after block 17). Cystic fibrosis if suggestive (SEGHNP Rec 13). A1AT. Muscle (CK). Thyroid. Heart failure.
- Persistent rise in an infant → pediatric hepatology (BSG: low threshold in children; SEGHNP).

### `neo` (0–28 d)
- A raised ALT in a newborn is usually part of a bigger picture: sepsis, hypoxic-ischemic injury, congenital infection, cholestasis, metabolic crisis. Send fractionated bilirubin, INR, glucose, lactate, ammonia (→ ref F later).
- Ill newborn with hepatitis → think **HSV**: start empiric IV acyclovir now, while plasma/CSF HSV PCR and surface swabs are pending — dose per AAP Red Book / neonatal formulary; no dose on the card (D-2026-10-31-6). Source: AAP Red Book 2024–2027, HSV chapter (TODO(verify) chapter citation at build; the action is not in doubt).
- **GALD** (gestational alloimmune liver disease): ALT is often only modestly raised despite severe liver failure — ALT height does not reassure; INR and glucose decide (enrich after block 12).
- PALF criteria (above) → `picu` "Call transplant center".
- Use the lab's neonatal range for AST and ALT (no published neonatal ULN in the app — D-2026-10-29-1).

### Tiers (one model — SEGHNP 2022 tiers with the lesson's additions; D-2026-10-31-4)
- **Tier 1 — confirmed raise:** SEGHNP table 6 + lesson 01-01 synthesis: see First contact. Autoimmune markers, IgG, ceruloplasmin and A1AT are in tier 1 here (SEGHNP puts them in tier 2) — recorded in compare.
- **Tier 2 — tier 1 unrevealing, raise persists:** 24-h urine copper and slit lamp (if ceruloplasmin low or suspicion); A1AT genotype if level and phenotype disagree (enrich block 6); HBV DNA and HCV RNA (immunosuppressed or high-risk, even with negative serology — SEGHNP Rec 14); HIV; IgA, IgM; abdominal Doppler ultrasound (SEGHNP Rec 12).
- **Tier 3 — pediatric hepatology:** anti-SLA, anti-LC1, AMA, p-ANCA (anti-SLA earlier if AIH suspected — block 8); amino acids, ammonia, blood gas, lactate; carbohydrate-deficient transferrin (CDT); lysosomal acid lipase (LAL) activity; serum bile acids.
- **3–6-month rule:** finish tiers 1–2 within 3–6 months of the first abnormal result; > 6 months = chronic; full evaluation within 12 months (SEGHNP Rec 18). Still unexplained → clinical exome with genetics (Rec 21; ref E); if still undiagnosed and asymptomatic at 12–18 months, consider biopsy (Rec 22). Biopsy earlier when AIH or Wilson is suspected — it is part of their diagnosis (D-2026-10-31-3).
- Normalised on repeat → recheck in 3–6 months (SEGHNP Rec 17).

## IV. First contact (`workup`)
- **Repeat — confirm (2–4 weeks):** ALT, AST, GGT, ALP · total and direct bilirubin · CK · INR, albumin (infant: + glucose).
- **Tier 1 — persistent raise:** ALT, AST, GGT, ALP, total and direct bilirubin · INR, albumin, CBC with platelets, glucose · CK · tTG-IgA + total IgA (only if eating gluten) · TSH, free T4 · HBsAg, anti-HCV · EBV (VCA serology under 4 y), CMV (infant: PCR), HAV IgM if acute · IgG, ANA, SMA, anti-LKM1 · ceruloplasmin (≥ 3 y) · A1AT level + phenotype · fasting lipids · abdominal ultrasound.
- **Focused panel — teen with obesity, ALT < 2 × ULN (ACG "borderline" band, lesson 01-01 slide 4):** ALT, AST, GGT · CK · tTG-IgA + total IgA · TSH · HBsAg, anti-HCV · ceruloplasmin · fasting lipids, glucose/HbA1c · ultrasound (lesson 01-01 case 4: CK, celiac, thyroid; + Wilson per D-4).
- Iron studies not routine in children (lesson; BSG "may not be indicated").

## V. Don't miss (`list`)
- Acetaminophen — including repeated supratherapeutic dosing and self-harm; level now (→ `nac`).
- Wilson disease — from age 3; treatable; low ALP or Coombs-negative hemolysis in a sick child = Wilson ALF (→ 23; block 7).
- Autoimmune hepatitis — modest ALT with high IgG; autoantibodies can be negative (→ 24; block 8).
- Muscular dystrophy — boy with ALT and AST raised: CK before any liver work-up.
- Celiac disease — tTG-IgA with total IgA.
- Chronic HBV/HCV — ALT can be normal.
- Drugs and supplements — ask directly (→ 26; block 13).
- A1AT deficiency — level alone can be falsely normal (acute phase).
- Infants: congenital infection (CMV, HSV), metabolic disease, GALD.

## VI. Why (`text`, Learn)
- ALT lives in hepatocyte cytosol (t½ ≈ 47 h); AST also in muscle, heart, red cells (t½ ≈ 17 h) — AST falls first; AST > ALT → muscle, hemolysis, macro-AST, advanced disease (Dufour 2000).
- Lab ULNs are too high: median ALT ULN at US children's hospitals 53 U/L (range 30–90) vs 95th centile 25.8 boys / 22.1 girls in healthy teens; hospital cut-offs found 32–48% of NAFLD/HBV/HCV vs 72–82% with health-based ones (SAFETY 2010).
- Naples, 425 children with isolated hypertransaminasemia: 61% normalised within 6 months; of 166 persistent, one in three genetic — Wilson 18, muscular dystrophy 14, A1AT 4, Alagille 4, HFI 4, GSD IX 3 (Iorio 2005). Repeat first; the second abnormal result is where the treatable diseases hide.
- Primary care, 120 obese asymptomatic children with ALT ≥ 40: only one non-MASLD diagnosis (muscular dystrophy); PPV of any screening test 5% (Rudolph 2015). Pre-test probability decides the panel.

## VII. Pearls & pitfalls (`pearls`)
- pearl: From age 11, read ALT against 26 (boys) / 22 (girls), whatever the lab prints (AASLD applies it from 10).
- pearl: Repeat, but not twice — the second abnormal result starts the work-up.
- pitfall: Raised ALT and AST in a boy: check CK before any liver test or biopsy — Duchenne diagnosis was delayed by a liver work-up in 6 boys (McMillan 2011).
- pitfall: Weightlifting raises ALT and AST for at least 7 days (Pettersson 2008) — ask about exercise; repeat after ≥ 7 days, ideally 2 weeks, of rest.
- pearl: Falling ALT with rising INR and bilirubin = loss of liver mass, not recovery.
- pearl: In jaundice, a low ALP is a red flag: ALP:bilirubin < 4 and AST:ALT > 2.2 support Wilson ALF (Korman 2008: 94% sensitivity each, mixed adult–pediatric cohort); in children sensitivity collapses — ALP:bilirubin < 4 32.5%, AST:ALT ≥ 1.85 77.5% (Yasmin 2022, Dhaka, 40 children). A negative ratio does not exclude Wilson.
- pitfall: A normal ALT in a child with obesity is not a normal liver if the lab ULN is 40+.
- pearl: Isolated AST, normal ALT and CK → macro-AST (card 8 when built).

## VIII. Guidelines (`guideline_compare`)
| Topic | ACG 2017 | BSG 2018 | AASLD 2025 | ESPGHAN 2026 | SEGHNP 2022 | Verdict |
|---|---|---|---|---|---|---|
| Normal ALT | 29–33 M · 19–25 F (adults) | Lab range | > 26 M / > 22 F from 10 y; < 10 y no validated cut-off (> 30 used in population studies) | ≥ 30 all ages (screening) | > 40 M / > 35 F (> 18 mo); > 60 / > 55 (< 18 mo); 26/22 for teen screening | differs |
| First response | Repeat or clarify | Investigate now | Repeat within 3 months; 24–48 h if acute | 30–80: repeat 2–6 mo; ≥ 80 now (TODO(verify)) | Confirm in 2–4 weeks (up to 8) | material |
| CK | If history | "May help" in children | Not listed | Every child (TODO(verify)) | Tier 1 | material |
| Celiac serology | If history | Yes | tTG-IgA + total IgA | tTG-IgA + total IgA | Tier 1 | aligned |
| Anti-LKM | No | Yes | Yes | Not listed | Tier 2 | differs |
| Ceruloplasmin | Persistent rise, < 55 y | > 3 y | + 24-h urine copper | Yes | Tier 2 | aligned |
| Autoantibodies, ceruloplasmin timing | — | — | — | — | Tier 2 (app: tier 1) | differs |
| A1AT | Phenotype | Level | Phenotype or genotype | Level | Level tier 2, phenotype tier 3 | differs |
| Iron studies | Everyone | May not be indicated | Yes | Not listed | Not listed | differs |
| Thyroid | If history | Not listed | TSH | Thyroid function | Tier 1 | differs |
| Biopsy timing | — | — | — | — | Consider at 12–18 mo if undiagnosed | differs (note: only SEGHNP addresses it) |
Positions for ACG/BSG/AASLD/ESPGHAN from lesson 01-01 slides 6, 16–18; SEGHNP from full text. The lesson reads AASLD as "30 for younger children" — put that reading in the row `note` (§3.4). ACG and BSG are adult documents (BSG has pediatric notes). Verdict vocabulary: §5.2 only (lesson's CONTRADICT → material, PAEDS ADDS → differs/aligned as fits).

## IX. Test yourself (`case`)
1. **alt_elevated_c1** — 14-year-old boy, obesity, ALT 38 U/L (lab ULN 45), well. Q: normal? A: No — 1.5 × the health-based ULN of 26; record as abnormal, repeat once with CK; if persistent, focused screen and MASLD pathway. Teaching: lab ULN vs AASLD 2025 (lesson 01-01 case 4).
2. **alt_elevated_c2** — 4-year-old boy before tonsillectomy, ALT 180, AST 220, well; mother says he falls often and struggles with stairs. Q: first test? A: CK (in the lesson: 14,000) → neuromuscular referral, no liver work-up — Duchenne can present this way (lesson 01-01 case 1; McMillan 2011).
3. **alt_elevated_c3** — 7-year-old girl, well, ALT 60 (lab ULN 35); repeat 3 weeks later 64. Q: next? A: tier 1 now — incl. CK, celiac, thyroid, viral, IgG + ANA/SMA/anti-LKM1, ceruloplasmin, A1AT, ultrasound; refer if unrevealing. Teaching: repeat, but not twice — Iorio 2005 (one in three persistent cases genetic, many treatable).
4. **alt_elevated_c4** — 13-year-old girl, jaundice and tiredness, bilirubin 20 mg/dL, ALT 70, AST 180, ALP 40, Hb 8.5 Coombs-negative, INR 2.4. Q: pattern? A: Wilson ALF — ALP:bilirubin 2 (< 4), AST:ALT > 2.5, nonimmune hemolysis; call transplant center now; ceruloplasmin, urinary copper, slit lamp (lesson 01-01 case 3). (Red-flag case; keep for card 9/23 too.)

## Links (§4.5)
- → next (only when built): 8, 9, 22, 23, 24, 25, 26, 27, 28, 30. None exist now — no `link_card_id` on day 16.
- calc: `c_uln`, `c_rratio` (exist); `nac` from the acetaminophen red flag (outside §4.5 calc column — D-2026-10-31-5). ref: A `ref_norms` (exists), D `ref_elasto` (later).
- plan: block 1 days 1, 14 now; blocks 7, 8, 11, 13, 16, 25 when taught.
- Back-links: none of the existing cards (ref_norms, about) must link to 7 per §4.5.

## Build notes for day 16
- Red flags have three tiers with pills — build as the first block, either a short `pathway` or three `note` blocks (crit/warn/info); check the Anatomy gate (§3.3 order).
- Close the Red Book HSV chapter citation, or §6 removes the acyclovir line.
- `ages` all four; age_switch default = first option (D-2026-10-22-1) — order teen → child → infant → neo? Keep §5.1 order neo → teen for consistency with other cards; check the integrity gate.
- No published number without a source: every threshold above carries one; ESPGHAN 2026 positions stay TODO(verify) until the full text is read — if still closed on day 16, show them as "per lesson summary" only in guideline_compare `note`, not in the Duty layer (the Duty layer uses AASLD/SEGHNP).
- Synonyms: "transaminitis", "hypertransaminasemia", "raised LFTs", "elevated liver enzymes".
