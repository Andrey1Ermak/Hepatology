# alp_isolated — Isolated ALP Elevation (card 10)

Status: built 2026-11-03 (Day 18). Lessons: 01-01 (slides 2, 8, 11, 12; chapter parts 1, 4, 5), 01-14. Plan: block 1 days 1, 14.
Sources: ACG 2017 (Kwo; full text read: statements 6, rec. 1 & 13, ALP section, Table 5, Fig. 4), BSG 2018 (Newsome; full text: ALP and GGT paragraphs), Gualco 2013 (abstract), Kraut 1985 (criteria via Gualco/secondary — wording kept general), Högler 2019 (abstract), Khan 2024 HPP criteria (full text), Munns 2016 rickets consensus (abstract only — no thresholds published), Korman 2008 / Yasmin 2022 (already in registry).
Card ages: all. acu: ref → card is "rt"-like but §4.2 says `ref`; kept `ref`.

## 1. Red flags
- Jaundice, pale stools, dark urine → not isolated: fractionated bilirubin, hepatology today.
- Night bone pain, limp, bone swelling or mass, weight loss → X-ray today; oncology if a lesion (ACG Table 5: primary bone malignancy, bone metastases).
- Seizure, tetany or stridor with suspected rickets → ED now (calcium). Expert opinion.
- Sick, jaundiced child with LOW ALP and Coombs-negative hemolysis → acute Wilson: INR now, call transplant center (Korman 2008; consistent with ast_isolated/alt_elevated).

## 2. Age
No age_switch: one decision path (range for age → GGT → bone → THI); age enters as rows (< 5 y THI; puberty). D-2026-11-03-1.

## 3. Algorithm (Pathways/alp_isolated.json)
1. High for this child? Lab's age- and sex-specific range; adult range makes every growing child look high (lesson 01-01; ACG; BSG). Within range → no workup. Low for age → step 5.
2. Liver or bone? GGT (ACG rec 13, statement 6; BSG). GGT raised → liver → ggt_isolated. ALT raised → alt_elevated. Direct bilirubin raised → hepatology today. GGT equivocal (infant GGT physiologically high) → ALP isoenzymes (ACG; BSG electrophoresis).
3. Bone: calcium, phosphate, 25-OH vitamin D, PTH, creatinine; X-ray if signs. Rickets confirmed by radiographs (Munns 2016). Low phosphate with normal vitamin D → endocrinology (hypophosphatemic rickets). Thyroid symptoms → TSH (ACG Table 5: hyperthyroidism, hyperparathyroidism, chronic renal failure).
4. Well, all normal: < 5 y → THI (Kraut criteria: < 5 y, no bone or liver disease, normal again within about 4 months). ≈ 70% ≥ 5 × ULN; 80% normal within 4 months, ≈ 20% longer; often after infection; also older children (Gualco 2013). Repeat ALP (+ GGT) in 3–4 months; no imaging. Older child/teen: growth spurt common; THI also occurs; repeat in 3–4 months; persistent or rising → endocrinology/bone (expert opinion).
5. Low ALP for age: repeat (EDTA/oxalate tube artefact — Khan 2024); zinc (ACG zinc metalloenzyme; Khan 2024); hypophosphatasia — early nontraumatic loss of primary teeth, rickets, poor growth (Högler 2019; Khan 2024 criteria); PLP raised (stop pyridoxine 1 wk); ALPL gene; endocrinology/metabolic bone. Hypothyroidism, celiac, malnutrition (Khan 2024 list).

## 4. First contact
Repeat: ALP, GGT, ALT, total + direct bilirubin. Bone: Ca, phosphate, 25-OH D, PTH, creatinine. Low ALP: zinc, PLP, repeat ALP in a non-EDTA tube.

## 5. Don't miss
Cholestatic liver disease (GGT raised); rickets; bone tumor; hypophosphatasia; zinc deficiency hiding cholestasis; acute Wilson (low ALP).

## 6. Why
Sources of ALP, growth plate, BSG commonest causes (vitamin D deficiency or growth), ACG fatty meal + blood group O/B, THI data, low ALP.

## 7. Pearls — see JSON.
## 8. Guidelines — ACG vs BSG (confirm origin aligned; children aligned; THI gap; low ALP gap).
## 9. Cases — THI toddler (lesson case 2); 7-y girl "high" against adult range; 18-mo rickets; 3-y early tooth loss low ALP.

## Not published (D-2026-11-03-2)
- Age/sex ALP numbers (CHOP 2024 from lesson) — D-2026-10-29-1 still holds; card says "lab's range for age and sex".
- 25-OH D thresholds and rickets vitamin D doses — Munns full text not read today; not needed for triage.

## Review 2026-11-03 (round 1) — applied
- Bone pain: fever / non-weight-bearing → ED (infection, leukemia); night pain/limp → same-day X-ray + CBC with smear, LDH, uric acid (expert opinion). Leukemia added to Don't miss.
- Low calcium without symptoms → same day; high Ca + high PTH → endocrinology (ACG Table 5 hyperparathyroidism).
- Step 2 order: jaundice first; isoenzymes outcome now has next steps.
- Low ALP: hemolysis lowers ALP; severe infant HPP (seizures, breathing) same day; teeth lost before age 4 with root intact (Khan 2024); wider differential (Khan 2024 Table 1).
- Attributions: puberty peak → lesson 01-01; zinc → Khan 2024; BSG "suggests, without data".
- GGT age pattern: high in young infants, lowest 1–6 y (lesson 01-01 slide 7).
- Pearl: ALP unreliable for bile duct injury in children (ESPGHAN 2025).
