# ast_isolated — Isolated AST Elevation (draft)

Card 8 · cat `labs` · acu `rt` · ages all · entry `lab` · plan block 1 (days 1, 14) · → next: 7 (`alt_elevated`); 30 (`systemic`) not built yet · calc `c_uln` · ref A (`ref_norms`).
Sources: lessons 01-01 (slides 2, 9, 10, 19) and 01-14 (case 2, pearl 2, quiz); Dufour 2000; Caropreso 2009; Kulecka 2017; McMillan 2011; Pettersson 2008; Korman 2008; ACG 2017; BSG 2018; ESPGHAN 2026.
Status: built 2026-11-02 (day 17); clinical review: 4 blocking + 9 non-blocking fixed (cardiac and Wilson triage raised to ED / PICU; step-1 exit for liver disease; TSH in the CK-raised arm; case 3 ALT; McMillan "6 boys" verified in abstract and restored).

## 1. Red flags
- Dark or cola urine, muscle pain, swelling or weakness → rhabdomyolysis until proven otherwise: emergency department now (CK, creatinine, potassium, urinalysis).
- Heart failure, fainting, or chest pain with breathlessness → myocarditis: emergency department now (ECG, troponin). New murmur in a well child → ECG, troponin, cardiology today.
- Pallor, jaundice or dark urine with anemia → hemolysis: blood count, reticulocytes, LDH, haptoglobin, bilirubin, direct antiglobulin test (DAT) today. Coombs-negative hemolysis in a sick child with liver tests up → think acute Wilson disease: INR now, call hepatology / transplant center now.
- ALT also raised, or jaundice, low platelets, large spleen → not isolated: Elevated Transaminases card.

## 2. Age
No age switch: the causes do not split by age. Read AST against the lab's range for age (no citable infant AST norm found — labs.json has no AST entry). Newborn: CK is high after delivery — repeat before referral.

## 3. Algorithm (single pathway `ast_isolated`)
1. Is it isolated? AST above the lab's age range, ALT normal. ALT raised → `alt_elevated`. Hemolyzed sample → clean redraw.
2. Is the child sick? Rhabdomyolysis / cardiac / hemolysis outcomes as in red flags.
3. Well → repeat with CK, LDH, CBC + reticulocytes, TSH/free T4, after ≥ 7 days without strenuous exercise.
   - CK raised, no exertion → boy: Duchenne/Becker — neuromuscular referral, no liver workup; any child: myositis, metabolic myopathy, hypothyroid myopathy.
   - CK raised after exertion → rest ≥ 7 days and repeat.
   - Hemolysis screen positive → hemolysis workup.
   - TSH high → treat hypothyroidism, recheck.
4. All normal, AST persistently up in a well child → macro-AST: parents' AST; PEG precipitation; electrophoresis to confirm → no imaging, no biopsy, letter to family.
5. Macro-AST excluded → hepatology referral (ALT/GGT, ultrasound) — `alt_elevated`.

## 4. First contact (workup)
Repeat (clean venipuncture, ≥ 7 days without strenuous exercise): AST, ALT, CK, LDH; GGT, ALP, total and direct bilirubin; CBC with reticulocytes; TSH, free T4.
If anemia or jaundice: haptoglobin, DAT, blood film.
If CK, LDH and hemolysis screen are normal: AST in both parents; PEG precipitation of AST; electrophoresis if equivocal.

## 5. Don't miss
Duchenne/Becker; rhabdomyolysis; myocarditis; hemolysis incl. acute Wilson; hypothyroidism; advanced liver disease (AST > ALT with low platelets).

## 6. Why
AST lives in cytosol and mitochondria of liver, heart, skeletal muscle, red cells (Dufour 2000); t½ ≈ 17 h vs ALT ≈ 47 h. Macro-AST: AST bound to immunoglobulin, not cleared. Dystrophy: ALT to 1,220 and AST to 801 (McMillan 2011).

## 7. Pearls & pitfalls — see JSON.
## 8. Guidelines — ACG 2017, BSG 2018, ESPGHAN 2026 (lesson slide 18: ALIGNED).
## 9. Test yourself — 3 cases (01-14 case 2; 01-01 question 5; athlete after weight training).

## Inbox
(none yet — card built on day 17)
