# Нужные полные тексты

> Файл генерируется командой `python3 tools/library.py render` из `library/catalog.json` — руками не править.
> Как отдать документ — `library/README.md`. Коротко: положи PDF в `library/inbox/` (имя любое) и скажи Claude Code в проекте `/library`.

**Нужно:** 11 (P1: 3, P2: 5, P3: 3) · **Получено, ждёт конспекта:** 0 · **Конспект готов:** 0 · **Учтено в приложении:** 0

## Срочно (P1) — блокирует ближайшие задачи

| Документ | Где взять | Что нужно найти | Для чего |
|---|---|---|---|
| **Verna EC et al. AASLD EXPO: Liver biopsy. Hepatology 2026** <br>`aasld_2026_expo_biopsy` | [doi:10.1097/HEP.0000000000001828](https://doi.org/10.1097/HEP.0000000000001828) (Europe PMC 2026-11-09: закрыт) | Детский раздел целиком; минимум портальных трактов (в AASLD 2009 было ≥ 11); пороги МНО/тромбоцитов перед биопсией; прямо ли заменяет AASLD 2009 | `ref_biopsy`, `D-2026-11-09-4` |
| **Colantonio DA et al. Closing the gaps in pediatric laboratory reference intervals: a CALIPER database of 40 biochemical markers. Clin Chem 2012;58:854-868** <br>`colantonio_2012_caliper` | [doi:10.1373/clinchem.2011.177741](https://doi.org/10.1373/clinchem.2011.177741) (Europe PMC 2026-11-09: закрыт) | Таблицы референсных интервалов ALT, AST (с P5P и без), ALP, GGT, билирубина по возрастным полосам и полу у младенцев и детей; анализатор и метод | `labs.json`, `ref_norms`, `c_uln`, `D-2026-10-29-1` |
| **Fawaz R et al. Guideline for the Evaluation of Cholestatic Jaundice in Infants (NASPGHAN/ESPGHAN). JPGN 2017;64:154-168** <br>`naspghan_espghan_2017_nc` | [doi:10.1097/MPG.0000000000001334](https://doi.org/10.1097/MPG.0000000000001334) (Europe PMC 2026-11-09: закрыт) | Формулировки и силу рекомендаций: генетическое тестирование (панель/экзом), ускорение обследования на атрезию, Алажиль до холангиографии; срок желтухи 2 нед / 3 нед на грудном вскармливании; алгоритм (рисунок) | `ref_genetics`, `neo_jaundice`, `chol_0_3m`, `alt_elevated`, `D-2026-11-09-3` |

## Нужно (P2) — проверка уже опубликованного или карточки ближайших блоков

| Документ | Где взять | Что нужно найти | Для чего |
|---|---|---|---|
| **Xanthakos SA et al. AASLD Practice Statement on pediatric MASLD. Hepatology 2025;82:1352-1394** <br>`aasld_2025_masld_peds` | [doi:10.1097/HEP.0000000000001368](https://doi.org/10.1097/HEP.0000000000001368) (Europe PMC 2026-11-09: закрыт) | Пороги ALT для детей < 10–12 лет (есть ли «> 30 U/L до 10 лет»); правило «до 10 лет шире искать другие причины»; скрининг — возраст и кого | `alt_elevated`, `labs.json`, `masld` |
| **Martinez M et al. AASLD/AST/NASPGHAN Practice Guideline on pediatric liver transplantation: candidate evaluation. Hepatology 2026** <br>`aasld_ast_naspghan_2026_lt_eval` | [doi:10.1097/HEP.0000000000001805](https://doi.org/10.1097/HEP.0000000000001805) (Europe PMC 2026-11-09: закрыт) | Скрининг ГПС: порог SpO2 (< 96% или < 97%) и поза (лёжа/сидя/стоя); ортодеоксия ≥ 4%; ППГ — порог mPAP как противопоказание; критерии направления на трансплантацию (заменяет Squires 2014) | `hps_poph`, `chol_0_3m`, `post_lt` |
| **Baveno VIII Faculty. Baveno VIII — Advancing consensus in portal hypertension. J Hepatol 2026;85:993-1018** <br>`baveno_viii_2026` | [doi:10.1016/j.jhep.2026.07.030](https://doi.org/10.1016/j.jhep.2026.07.030) (Europe PMC 2026-11-09: закрыт) | Все педиатрические рекомендации (впервые в Baveno); профилактика и лечение варикозного кровотечения у детей; неинвазивные критерии КЗПГ и их применимость к детям | `varix_bleed`, `splenomegaly_ph`, `hps_poph`, `ref_elasto` |
| **EASL Clinical Practice Guidelines on vascular diseases of the liver. J Hepatol 2026;84:399-456** <br>`easl_2025_vascular` | [doi:10.1016/j.jhep.2025.08.001](https://doi.org/10.1016/j.jhep.2025.08.001) (Europe PMC 2026-11-09: закрыт) | Тромбоз воротной вены: первый метод визуализации (допплер?), антикоагуляция, детские оговорки; заменяет EASL 2016 — строка guideline_compare в ref_imaging | `ref_imaging`, `splenomegaly_ph`, `D-2026-11-06-2` |
| **Squires JE et al. NASPGHAN position paper on pediatric acute liver failure. JPGN 2022;74:138-158** <br>`naspghan_2022_palf` | [doi:10.1097/MPG.0000000000003268](https://doi.org/10.1097/MPG.0000000000003268) (Europe PMC 2026-11-09: закрыт) | Витамин K при ОПН: путь (IV/п/к) и доза по возрасту; позиция по плазме/ФЗП перед процедурами; определение PALF и пороги МНО; таблицы обследования | `inr_prolonged`, `palf`, `c_palf` |

## Желательно (P3) — уточнения и будущие карточки

| Документ | Где взять | Что нужно найти | Для чего |
|---|---|---|---|
| **Emerick KM et al. Features of Alagille syndrome in 92 patients: frequency and relation to prognosis. Hepatology 1999;29:822-829** <br>`emerick_1999_alagille` | [doi:10.1002/hep.510290331](https://doi.org/10.1002/hep.510290331) (Europe PMC 2026-11-09: закрыт) | Сверить цифры 60% / 95% и 22 / 36 (частота признаков, дефицит протоков в зависимости от возраста биопсии) | `ref_biopsy`, `ref_imaging`, `alagille` |
| **Grieve A, Makin E, Davenport M. APRi in infants with biliary atresia: prognostic value at presentation. J Pediatr Surg 2013;48:789-795** <br>`grieve_2013_apri` | [doi:10.1016/j.jpedsurg.2012.10.010](https://doi.org/10.1016/j.jpedsurg.2012.10.010) (Europe PMC 2026-11-09: закрыт) | Пороги APRI > 1,22 / < 0,43 при атрезии: что именно предсказывают, чувствительность/специфичность, когда измерено | `ref_elasto`, `c_apri_gpr` |
| **Iorio R et al. Hypertransaminasemia in childhood as a marker of genetic liver disorders. J Gastroenterol 2005;40:820-826** <br>`iorio_2005` | [doi:10.1007/s00535-005-1635-7](https://doi.org/10.1007/s00535-005-1635-7) (Europe PMC 2026-11-09: закрыт) | Сверить цифры: 425 детей, 166 со стойким повышением, распределение диагнозов (Вильсон 18, мышечные дистрофии 14 и др.) | `alt_elevated` |
