# Нужные полные тексты

> Файл генерируется командой `python3 tools/library.py render` из `library/catalog.json` — руками не править.
> Как отдать документ — `library/README.md`. Коротко: положи PDF в `library/inbox/` (имя любое) и скажи Claude Code в проекте `/library`.

**Нужно:** 9 (P1: 0, P2: 5, P3: 4) · **Получено, ждёт конспекта:** 0 · **Конспект готов:** 7 · **Учтено в приложении:** 0

## Нужно (P2) — проверка уже опубликованного или карточки ближайших блоков

| Документ | Где взять | Что нужно найти | Для чего |
|---|---|---|---|
| **EASL Clinical Practice Guidelines on vascular diseases of the liver. J Hepatol 2026;84:399-456** <br>`easl_2025_vascular` | [doi:10.1016/j.jhep.2025.08.001](https://doi.org/10.1016/j.jhep.2025.08.001) (Europe PMC 2026-11-19: закрыт) | Тромбоз воротной вены: первый метод визуализации (допплер?), антикоагуляция, детские оговорки; заменяет EASL 2016 — строка guideline_compare в ref_imaging | `ref_imaging`, `splenomegaly_ph`, `D-2026-11-06-2` |
| **Squires JE et al. NASPGHAN position paper on pediatric acute liver failure. JPGN 2022;74:138-158** <br>`naspghan_2022_palf` | [doi:10.1097/MPG.0000000000003268](https://doi.org/10.1097/MPG.0000000000003268) (Europe PMC 2026-11-19: закрыт) | Витамин K при ОПН: путь (IV/п/к) и доза по возрасту; позиция по плазме/ФЗП перед процедурами; определение PALF и пороги МНО; таблицы обследования | `inr_prolonged`, `palf`, `c_palf` |
| **Harpavat S et al. Guidance for the Primary Care Provider in Identifying Infants With Biliary Atresia by 2-4 Weeks of Life: Clinical Report (AAP). Pediatrics 2025;155:e2024070077** <br>`aap_2025_ba_primary_care` | [doi:10.1542/peds.2024-070077](https://doi.org/10.1542/peds.2024-070077) (Europe PMC 2026-11-19: закрыт) | Точная формулировка: прямой/конъюгированный «≥ 1 мг/дл» или «> 1 мг/дл» → срочно к гастроэнтерологу; правило «любое значение выше нормы лаборатории у новорождённого — повтор» (к какому сроку); исключения «< 1 и снижается»; есть ли целевой возраст Kasai «до 30 дней». Используется в калькуляторах c_conj_bili и c_kasai_clock | `c_conj_bili`, `c_kasai_clock`, `neo_jaundice`, `chol_0_3m`, `D-2026-11-11-2` |
| **Chen HL, Taylor SA, Lee WS, et al. Diagnostic approaches for infants with cholestatic liver diseases: FIGHS position paper. J Pediatr Gastroenterol Nutr 2025;81:1360-1377** <br>`fighs_2025_infant_cholestasis` | [doi:10.1002/jpn3.70207](https://doi.org/10.1002/jpn3.70207) (Europe PMC 2026-11-19: закрыт) | Позиции для guideline_compare карточки chol_0_3m: целевой возраст Kasai (есть ли число дней); порог прямого/конъюгированного билирубина и правило 20%; MMP-7 (рекомендуется ли, какой порог/платформа); HIDA (нужна ли); биопсия до холангиографии; генетика (когда, какой тест); универсальный скрининг (карты стула, прямой билирубин). Нужны формулировки и уровень доказательности со страницами. | `chol_0_3m`, `neo_jaundice`, `D-2026-11-13-3` |
| **Okubo R, Kuroda T, Abukawa D, et al. Clinical Practice Guidelines for Biliary Atresia in Japan, 2nd Edition. J Hepatobiliary Pancreat Sci 2026** <br>`japan_2026_ba` | [doi:10.1002/jhbp.70101](https://doi.org/10.1002/jhbp.70101) (Europe PMC 2026-11-19: закрыт) | Клинические вопросы о холангите после Касаи: профилактика антибиотиками (да/нет, срок, препарат), длительность лечения, стероиды; уровень рекомендаций. Это первое руководство общества по холангиту — может заменить вердикты GAP в kasai_fever | `kasai_fever`, `chol_0_3m`, `D-2026-11-19-1` |

## Желательно (P3) — уточнения и будущие карточки

| Документ | Где взять | Что нужно найти | Для чего |
|---|---|---|---|
| **Emerick KM et al. Features of Alagille syndrome in 92 patients: frequency and relation to prognosis. Hepatology 1999;29:822-829** <br>`emerick_1999_alagille` | [doi:10.1002/hep.510290331](https://doi.org/10.1002/hep.510290331) (Europe PMC 2026-11-19: закрыт) | Сверить цифры 60% / 95% и 22 / 36 (частота признаков, дефицит протоков в зависимости от возраста биопсии) | `ref_biopsy`, `ref_imaging`, `alagille` |
| **Grieve A, Makin E, Davenport M. APRi in infants with biliary atresia: prognostic value at presentation. J Pediatr Surg 2013;48:789-795** <br>`grieve_2013_apri` | [doi:10.1016/j.jpedsurg.2012.10.010](https://doi.org/10.1016/j.jpedsurg.2012.10.010) (Europe PMC 2026-11-19: закрыт) | Пороги APRI > 1,22 / < 0,43 при атрезии: что именно предсказывают, чувствительность/специфичность, когда измерено | `ref_elasto`, `c_apri_gpr` |
| **Iorio R et al. Hypertransaminasemia in childhood as a marker of genetic liver disorders. J Gastroenterol 2005;40:820-826** <br>`iorio_2005` | [doi:10.1007/s00535-005-1635-7](https://doi.org/10.1007/s00535-005-1635-7) (Europe PMC 2026-11-19: закрыт) | Сверить цифры: 425 детей, 166 со стойким повышением, распределение диагнозов (Вильсон 18, мышечные дистрофии 14 и др.) | `alt_elevated` |
| **Squires RH, Ng V, Romero R, et al. Evaluation of the pediatric patient for liver transplantation: 2014 practice guideline by AASLD, AST and NASPGHAN. Hepatology 2014;60:362-398** <br>`squires_2014_lt_eval` | [doi:10.1002/hep.27191](https://doi.org/10.1002/hep.27191) (Europe PMC 2026-11-19: закрыт) | Раздел о билиарной атрезии после Касаи: точная формулировка о профилактике холангита антибиотиками (по Ravanbakhsh 2024 — ссылаются на одну работу) и уровень доказательств. Нужно, только если в Martinez 2026 этого нет | `kasai_fever`, `D-2026-11-19-1` |

## Конспект готов — ждёт внесения в приложение

- `aap_2022_hyperbili` · Kemper AR et al. Clinical Practice Guideline Revision: Management of Hyperbilirubinemia in the Newborn Infant 35 or More Weeks of Gestation (AAP). Pediatrics 2022;150:e2022058859 — [конспект](notes/aap_2022_hyperbili.md) · 2026-11-21
- `aasld_2025_masld_peds` · Xanthakos SA et al. AASLD Practice Statement on pediatric MASLD. Hepatology 2025;82:1352-1394 — [конспект](notes/aasld_2025_masld_peds.md) · 2026-11-21
- `aasld_2026_expo_biopsy` · Verna EC et al. AASLD EXPO: Liver biopsy. Hepatology 2026 — [конспект](notes/aasld_2026_expo_biopsy.md) · 2026-11-21
- `aasld_ast_naspghan_2026_lt_eval` · Martinez M et al. AASLD/AST/NASPGHAN Practice Guideline on pediatric liver transplantation: candidate evaluation. Hepatology 2026 — [конспект](notes/aasld_ast_naspghan_2026_lt_eval.md) · 2026-11-21
- `baveno_viii_2026` · Baveno VIII Faculty. Baveno VIII — Advancing consensus in portal hypertension. J Hepatol 2026;85:993-1018 — [конспект](notes/baveno_viii_2026.md) · 2026-11-21
- `colantonio_2012_caliper` · Colantonio DA et al. Closing the gaps in pediatric laboratory reference intervals: a CALIPER database of 40 biochemical markers. Clin Chem 2012;58:854-868 — [конспект](notes/colantonio_2012_caliper.md) · 2026-11-21
- `naspghan_espghan_2017_nc` · Fawaz R et al. Guideline for the Evaluation of Cholestatic Jaundice in Infants (NASPGHAN/ESPGHAN). JPGN 2017;64:154-168 — [конспект](notes/naspghan_espghan_2017_nc.md) · 2026-11-21
