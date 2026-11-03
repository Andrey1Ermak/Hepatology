# ggt_isolated — Isolated GGT Elevation (card 11)

Status: built 2026-11-03 (Day 18). Lessons: 01-01 (slides 2, 7; chapter parts 1, 4), 01-14. Plan: block 1 days 1, 14; block 9 days 1, 3 (enrich after block 9 — PSC; after block 4 — Alagille).
Scope: GGT raised for age with normal ALT and bilirubin (ALP may be raised — the hepatic-ALP exit of card 10 lands here).
Sources: ACG 2017 (full text: rec. 13, GGT paragraph — alcohol, phenytoin, barbiturates, pancreatic/renal disease, diabetes; Fig. 4 — persistent > 6 months → biopsy or MRCP), BSG 2018 (obesity, alcohol, drugs; GGT in the initial panel; best predictor of liver mortality), ESPGHAN PSC-IBD 2025 (van Rheenen; abstract: regular GGT screening in IBD; MRCP modality of choice; calprotectin), Berhane 2025 (Arch Dis Child; 469 IBD children; GGT < 2 × ULN NPV 98%), Deneau 2018 (287 children PSC; GGT < 50 at 1 y → 91% vs 67% 5-y event-free survival), Cepelak 1998 and Hadzagic-Catibusic 2017 (carbamazepine raises GGT: 34% vs 14.9% valproate at 1 y).

## 1. Red flags
- Jaundice, pale stools, dark urine or itch → not isolated: fractionated bilirubin, hepatology today.
- Fever with jaundice or right-upper-quadrant pain → ED now: blood cultures, ultrasound (cholangitis, stone). Expert opinion.
- Bloody diarrhea, weight loss or poor growth → GI referral this week, fecal calprotectin (IBD; ESPGHAN 2025).
- Large spleen, low platelets or bleeding → not isolated (advanced liver disease): hepatology.

## 2. Age — no age_switch (D-2026-11-03-1): infant physiology is step 1 row.

## 3. Algorithm (Pathways/ggt_isolated.json)
1. Raised for this child? Lab age range (newborn GGT high, falls through first year — lesson 01-01). ALT raised → alt_elevated. Direct bilirubin raised → hepatology today. Obese teen: read ALT against 22/26 (AASLD 2025) before calling GGT isolated.
2. Known cause? Enzyme-inducing drugs (carbamazepine, phenytoin, phenobarbital — ACG; Cepelak 1998; Hadzagic-Catibusic 2017) → well child: no workup; recheck with routine drug monitoring; investigate if ALT/bilirubin rise. Obesity (BSG) → MASLD route via ALT. Alcohol (teen; ACG, BSG) → ask privately. IBD → step 4.
3. Unexplained, repeat once (within 3 months — expert opinion, mirrors AASLD ALT rule) → persistent: ultrasound with Doppler (ACG), ANA, SMA, anti-LKM1, IgG; fecal calprotectin; exam for Alagille features; sweat test if CF possible. Dilated ducts/cyst → hepatology/surgery. Persistent unexplained → hepatology: MRCP, biopsy if MRCP normal (ACG Fig. 4; ESPGHAN 2025).
4. Child with IBD: GGT raised → repeat; ≥ 2 × ULN or persistent → MRCP + hepatology (ESPGHAN 2025; Berhane 2025 NPV 98% below 2 × ULN, single center). Below 2 × ULN: keep checking GGT.

## 4. First contact
Repeat: GGT, ALT, AST, ALP, total + direct bilirubin, platelets. Persistent: ultrasound + Doppler; ANA, SMA, anti-LKM1, IgG; fecal calprotectin.

## 5. Don't miss
PSC/ASC (IBD may be silent); choledochal cyst, stones; AIH; Alagille; CF liver disease; drug injury when ALT rises.

## 6–9 — see JSON. Guidelines: ACG / BSG / ESPGHAN 2025 (GGT as screen — differs; causes — aligned; IBD — aligned on MRCP).

## Not published
- Absolute GGT numbers by age (D-2026-10-29-1).
- Deneau GGT < 50 as a treatment target — PSC care belongs to card 4 (block 9).

## Review 2026-11-03 (round 1) — applied
- IBD < 2 × ULN: persisting > 1 month → cause workup, MRCP not routine, GGT every 3–6 months (ESPGHAN 2025 §4.1.2); ≥ 2 × ULN → prompt. Study ULN 50 U/L noted. guideline_compare row ESPGHAN vs Berhane.
- Bleeding → ED; spleen/platelets → hepatology within days.
- Obesity split: ALT > 26/22 → alt_elevated; GGT ≥ 60 suspected MASLD → full tier 1 + hepatology (ESPGHAN 2026, as alt_elevated_teen); normal ALT → step 3.
- Valproate (not inducer: ALT, INR, ammonia; boxed warning); DRESS/DILI same day; AED "no workup" labeled expert opinion with ceiling (GGT > 3 × ULN or rising).
- 34%/14.9% → Hadzagic-Catibusic only. Biopsy only if > 6 months with normal MRCP (ACG Fig. 4).
- Case c2: ALT normal.
