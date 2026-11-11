# inr_prolonged — Prolonged INR (draft)

Built 2026-11-05 (Day 20) → `Content/Cards/inr_prolonged.json`, `Pathways/inr_prolonged.json`, `Calculators/c_vitk_inr.json`. The JSON is the source of truth; this file keeps the build notes and the Inbox for later lessons (block 12 — PALF — will add the `palf` / `c_palf` links).

## Build notes (2026-11-05)
- Anatomy §3.3: Red flags · Algorithm (6 steps: real? → sick? → vitamin K trial → response → factors → procedures) · First contact · Don't miss · Why · Pearls · Guidelines · Test yourself. No `age_switch`: the logic does not branch by age; infant specifics sit in red flags and steps 1, 2, 4.
- Main sources: lesson 01-03 (all slides + chapter), 01-14 (guideline table on coagulopathy before biopsy, the "INR 1.9 and a request for biopsy" case, self-test), Mouzaki 2019 Table 3 (full text read: "Vitamin K 2–5 mg/day; 1–10 mg IV may be required; anaphylaxis with IV vitamin K has been reported; may also be given IM"), NASPGHAN 2022 PALF paper (full text not accessible; route "IV or subcutaneous, not oral" per lesson 01-03 slide 21; transfusion position per Indian Pediatrics 2022 summary table), Squires 2006 (PALF definition).
- TODO(verify) closed: dose and route → Mouzaki 2019 (range 1–10 mg, no mg/kg published — D-2026-11-05-1).
- Not published (no reliable source): ChiLDReN staged regimen (INR 1.2–1.5 → 2.5 mg/day; > 1.5 → IM 2–5 mg; Shneider 2012), Japanese BA registry numbers (Pediatr Int 2025), a numeric "corrected INR" threshold (D-2026-11-05-2).


## Inbox

### 02-13 · Supportive care in the cholestatic infant (synced 2026-10-21)
- Vitamin K trial: give parenteral vitamin K for a prolonged INR; correction within hours → deficiency, not synthetic failure (lesson slide 10; Mouzaki 2019).
- IV vitamin K carries a small anaphylaxis risk. A single oral dose at birth does not protect a cholestatic infant; after diagnosis give daily oral vitamin K and check INR every visit, more often if bilirubin is rising (lesson slide 10).
- **Red flag:** breast-fed young infant, no prophylaxis or a single oral dose at birth, irritability or bleeding → treat as vitamin K deficiency bleeding: IV vitamin K, urgent head imaging, cholestasis workup (lesson case: 7-week-old, INR 6). Late VKDB can be the first sign of biliary atresia or AATD (McNinch 2007: 19 UK cases with liver disease).
- Japanese BA cohort 2015–19 (289 infants): no VKDB in the 3-month oral prophylaxis group; more VKDB with the shorter three-dose regimen (Pediatr Int 2025;67:e70075 — TODO(verify) authors and numbers).
- A normal INR does not prove adequate vitamin K stores for bone; PIVKA-II detects earlier deficiency.
- In known cholestasis: INR 1.2–1.5 → oral vitamin K 2.5 mg/day; > 1.5 → IM 2–5 mg plus daily oral (ChiLDREN regimen, Shneider 2012 — TODO(verify)). TODO(verify) before publishing: IV/IM dose for an infant with a maximum, and route in a coagulopathic infant (IM risks hematoma) — Mouzaki 2019 table.

### 02-14 · Block 2 synthesis (synced 2026-10-22)
- INR out of proportion to the bilirubin in a young infant → tyrosinemia (send succinylacetone, not tyrosine), galactosemia (stop lactose; GALT before transfusion) or GALD (lesson 02-14 slides 3, 11, 15).
- Parenteral vitamin K belongs to the day-1 list of every cholestatic infant at first presentation (slide 19); the staged oral/IM regimen above is for maintenance. TODO(verify) at card build: IV vs IM route and dose at first presentation in a coagulopathic infant (IM hematoma risk) — Mouzaki 2019.
- Neonatal liver failure: acyclovir before the HSV PCR returns (pearl 10) — belongs to palf (card 13); move there when its draft starts.

### 03-11 · Biliary atresia: nutrition and growth (synced 2026-11-02)
- Lesson case (slide 21): INR 1.6 before a liver biopsy in a cholestatic infant → IV vitamin K, recheck INR, then continue daily oral K — "distinguish deficiency from synthetic failure". Doses as in the 02-13 entry (oral 2–5 mg/day; IV 1–10 mg) — TODO(verify) against Mouzaki 2019 Table 3 before publishing; IV reactions reported.
- Before procedures, especially during a cholangitis admission: recheck INR (slide 16). Whenever feeds stop: check glucose.
- Japanese BA Registry (Pediatr Int 2025;67:e70075): **weekly** oral vitamin K to 3 months of age — no vitamin K deficiency bleeding; more bleeding with the three-dose schedule (slide 15 and chapter). Intracranial bleeding can be the first sign of biliary atresia. Same paper as the 02-13 entry — TODO(verify) authors and numbers still open.

### 03-12 · Biliary atresia: transplantation (synced 2026-11-05)
- **Synthetic failure is a late sign in biliary atresia (lesson slides 5, 19; Sundaram SS et al. Liver Transpl 2017;23:96–109):** an INR that does not correct with vitamin K, or encephalopathy, is a transplant-referral trigger, but INR and albumin often stay normal long after the child has stopped growing. Pitfall: "Waiting for synthetic failure" — refer at the first complication (AASLD/AST/NASPGHAN 2026 per lesson, doi 10.1097/HEP.0000000000001805; "Martinez 2026" authorship TODO(verify)), which lists "coagulopathy that cannot be corrected" among them.
- A near-normal INR keeps PELD low in cholestatic disease, so the score understates risk (→ c_peld_meld).

### 03-13 · Biliary atresia: the adult with BA (synced 2026-11-05)
- **"Two clocks" (slide 3):** in biliary atresia the synthetic clock (INR, albumin) runs slowly and can stay normal for decades; portal hypertension and cholangitis drive outcome. Normal INR/albumin ≠ low risk (slide 8). Synthetic failure was nonetheless the commonest indication (32%) for adult transplant at King's (Cortes-Cerisuelo M et al. J Clin Med 2021;10:4969, n = 34).

### 04-05 · Alagille syndrome V: the vessels (synced 2026-11-11)
- **ALGS (lesson 04-05; Lykavieris 2003):** bleeding in 22% of 174 children with normal median PT and platelets → a normal INR does not mean a safe procedure in ALGS; vitamin K before procedures and after head trauma. Candidate pearl for inr_prolonged at block 4 synthesis. TODO(verify).

