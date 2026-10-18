# HepReference — единая инструкция проекта

> Это **единственный** источник правил проекта. Claude Code читает его автоматически в каждой сессии.
> Ежедневная работа ведётся по [DAILY_PROMPTS.md](DAILY_PROMPTS.md): один день — один промпт — одна небольшая законченная задача.
> Если правило здесь расходится с чем-то ещё, прав этот файл. Меняя правило, сначала меняй его здесь.

---

## 0. Коротко

**HepReference** — iOS-справочник по детской гепатологии для начинающих феллоу. Ведёт от того, с чем пришёл ребёнок, к плану действий за 1–2 минуты: насколько срочно → что назначить → как рассуждать дальше → чего не пропустить → почему так.

- **Язык приложения:** английский (интерфейс, контент, код, комментарии, коммиты). Этот файл и промпты написаны по-русски для автора.
- **Автор и владелец контента:** Andrew Ermak, MD. Он же единственный клинический рецензент: статус `approved` ставит только он после личной проверки карточки.
- **Данные пациентов:** никогда. Ни в контенте, ни в коде, ни в примерах.

---

## 1. Структура репозитория

```
Hepatology/                         ← корень git-репозитория
├── CLAUDE.md                       ← этот файл: все правила
├── DAILY_PROMPTS.md                ← промпты по дням + журнал прогресса
├── tools/sync_sources.py           ← ежедневная синхронизация с репозиторием уроков
├── sources/                        ← сырьё от автора (Claude только читает)
│   ├── reading-final/              ← клон github.com/Andrey1Ermak/reading-final (не коммитится)
│   │   ├── Hepatology_Year_Plan.docx   ← годовой план (26 блоков × 14 дней) — каноническая версия
│   │   └── hepatology/             ← уроки: BB-DD_Topic.pptx (дек) + BB-DD_Topic_audio.pdf (текст главы)
│   ├── extracted/                  ← текст, извлечённый из уроков (генерируется, не коммитится)
│   ├── sync_state.json             ← последний обработанный коммит уроков
│   └── guidelines/                 ← PDF руководств (только локально, не коммитятся)
├── drafts/                         ← черновики карточек в Markdown (drafts/<card_id>.md)
└── ios/HepReference/               ← приложение
    ├── project.yml                 ← XcodeGen: единственный источник настроек проекта
    ├── HepReference/
    │   ├── App/                    ← точка входа, launch screen
    │   ├── Models/                 ← Card, Block, PathwayNode, CardLibrary, Manifest…
    │   ├── Views/                  ← экраны, блоки (Blocks/), деревья (Pathway/), калькуляторы (Calculators/)
    │   ├── Calculators/            ← логика калькуляторов (чистые функции) + NumericCalcRegistry
    │   ├── DesignSystem/           ← отступы, шрифты, цвета, общие компоненты
    │   ├── Content/                ← ВЕСЬ клинический контент (JSON)
    │   │   ├── manifest.json       ← порядок и категория каждой карточки
    │   │   ├── Cards/              ← <card_id>.json
    │   │   ├── Pathways/           ← <path_id>.json
    │   │   ├── Calculators/        ← chip_screen: <calc_id>.json
    │   │   ├── ScoreCalcs/         ← score_calc: <calc_id>.json
    │   │   └── Registry/           ← реестры (появляются в день 3): guidelines, labs, plan, cases, synonyms
    │   ├── Assets.xcassets/        ← иконка, цвета (brandAccent = #0F6E6E / тёмная тема #5CC8C2)
    │   └── Resources/Fonts/        ← Space Grotesk (только заголовки)
    └── HepReferenceTests/          ← юнит-тесты + ContentIntegrityTests (шлюз релиза)
```

`HepReference.xcodeproj` — **генерируемый файл**. Не редактировать руками: правим `project.yml` и запускаем `xcodegen generate`.

---

## 2. Сборка и тесты

```bash
cd ios/HepReference
xcodegen generate                                   # после добавления/удаления файлов или правки project.yml
xcodebuild -project HepReference.xcodeproj -scheme HepReference \
  -destination 'platform=iOS Simulator,name=iPhone 17' test 2>&1 \
  | grep -E "error:|failed|Executed|TEST (SUCCEEDED|FAILED)"
```

Запуск и снимок экрана для проверки:
```bash
xcrun simctl boot "iPhone 17" 2>/dev/null
APP=$(find ~/Library/Developer/Xcode/DerivedData -path "*HepReference*/Build/Products/Debug-iphonesimulator/HepReference.app" -maxdepth 6 | head -1)
xcrun simctl install "iPhone 17" "$APP" && xcrun simctl launch "iPhone 17" com.hepreference.app
xcrun simctl io "iPhone 17" screenshot /tmp/hep.png      # затем посмотреть снимок
```

Окружение: Xcode 26.6, iOS deployment target 17.0, Swift 5, XcodeGen в `/usr/local/bin`.

**Правило:** день не закрыт, пока `TEST SUCCEEDED`. Новые JSON-файлы в `Content/` попадают в бандл автоматически (папка подключена как folder reference), но новые `.swift` требуют `xcodegen generate`.

---

## 3. Продукт

### 3.1. Пользователь и обещание
Феллоу 1–2 года: ночной звонок, консультация в отделении, первый амбулаторный визит. За 1–2 минуты приложение даёт:
1. **Срочность** — красные флаги и кому звонить сейчас.
2. **Первый контакт** — список назначений с кнопкой «Скопировать».
3. **Ход рассуждений** — по возрасту и по результатам.
4. **Не пропустить** — лечимые и срочные причины.
5. **Почему** — механизм, жемчужины, расхождения руководств, случаи. Этот слой по умолчанию свёрнут.

### 3.2. Принципы (проверяются на каждой карточке)
| Принцип | Проверка |
|---|---|
| Вход по проблеме, не по диагнозу | Карточка открывается с главного экрана по симптому или находке |
| Возраст — первый выбор | Если причины зависят от возраста, вверху стоит `age_switch` |
| Не больше 3 нажатий до назначений | Главная → плитка → карточка → блок `workup` |
| Красные флаги первыми | Первый блок карточки — срочность |
| Нет тупиков | Каждый исход алгоритма: действие, `link_card_id`, `link_calc_id` или «call …» |
| Свежесть видна | В шапке: источники, год, дата проверки |
| Одинаковая анатомия | Порядок блоков по §3.3 |

### 3.3. Анатомия карточки-алгоритма — обязательный порядок блоков

| # | Раздел (заголовок в приложении) | Тип блока | Слой |
|---|---|---|---|
| 1 | **Red flags** | `note` (k: `crit`) или `chip_screen` | Duty |
| 2 | **Age** | `age_switch` (если причины зависят от возраста) | Duty |
| 3 | **Algorithm** | `pathway` (или ветки внутри `age_switch`) | Duty |
| 4 | **First contact** | `workup` | Duty |
| 5 | **Don't miss** | `list` | Duty |
| 6 | **Why** | `text` | Learn |
| 7 | **Pearls & pitfalls** | `pearls` | Learn |
| 8 | **Guidelines** | `guideline_compare` | Learn |
| 9 | **Test yourself** | `case` | Learn |
| 10 | **Links** | формируется автоматически (next / refs / calcs / study / linked from) | — |

Справочные карточки (A–G) свободнее по структуре, но всегда с источниками и датой проверки. Блоки слоя *Learn* скрываются в режиме *Duty* (появится в день 46).

### 3.4. Цикл «учёба → практика»
Годовой план (`sources/reading-final/Hepatology_Year_Plan.docx`) и приложение связаны напрямую:
- ежедневная презентация → «Вопрос дня», «Механизм», «Тонкости», «Итог» → разделы Why / Pearls / шаги алгоритма соответствующей карточки;
- синтез дня 14 → `guideline_compare` и `case`;
- карточка ссылается на блок и день плана (`plan`), а вкладка Study показывает карточки по сегодняшнему дню плана.

**Уроки появляются каждую ночь** в `Andrey1Ermak/reading-final/hepatology/` (автоматическая задача автора). Поэтому **каждый рабочий день начинается с синхронизации** (§9, шаг 0): новые и изменённые уроки извлекаются и вносятся в карточки.

**Правила синхронизации:**
- Урок `BB-DD` относится к блоку BB, дню DD плана. Связанные карточки ищутся по `plan` в карточках (и `plan.json`, когда он есть), иначе — по колонке plan в §4.5.
- **Карточка уже есть** → перенести новое: механизм → Why; тонкости → `pearls`; «итог: что сделаю иначе» → шаги алгоритма или `workup`; сравнение руководств → `guideline_compare`; синтез дня 14 → `case`. Новые руководства → `guidelines.json`. Каждое изменение — в отчёт.
- **Карточки ещё нет** → дописать в `drafts/<card_id>.md` раздел `## Inbox` (урок · 3–10 тезисов, которые должны попасть в карточку). Этот inbox читается в день сборки карточки.
- Урок не меняет пороги и дозы молча: если он расходится с карточкой, это `TODO(verify)` и вопрос автору.
- Изменился годовой план → обновить `plan.json` и связи `plan` в карточках.

---

## 4. Каталог v1.0 — ID, названия, содержание

ID неизменны: на них держатся все ссылки. Названия — английские, как в приложении.

### 4.1. Главный экран: категории (`CardCategory`)
| cat | Плитка | Карточки |
|---|---|---|
| `jaundice` | Jaundice & Cholestasis | 1, 2, 3, 4, 5, 6, 29 |
| `labs` | Abnormal Liver Tests | 7, 8, 9, 10, 11, 12, 35 |
| `acute` | Acute Liver Illness | 13, 18, 22, 33 |
| `organomegaly` | Big Liver or Spleen | 14, 15 |
| `portal` | Portal Hypertension | 16, 17, 32 |
| `mass` | Mass, Ducts & Gallbladder | 19, 20, 21 |
| `disease` | Suspected Disease | 23, 24, 25, 26, 27, 28 |
| `special` | Special Populations | 30, 31, 34 |
| `ref` | Reference | A–G, about |

### 4.2. Карточки-алгоритмы

| № | id | Title | acu | Ages | Содержание (что обязательно покрыть) |
|---|---|---|---|---|---|
| 1 | `neo_jaundice` | Neonatal Jaundice: Conjugated or Not? | urg | neo, infant | Когда фракционировать (желтуха > 2 нед; > 3 нед на ГВ; ахолия/тёмная моча — в любом возрасте); пороги конъюгированного/прямого билирубина; «прямой» ≠ «конъюгированный»; физиологическая желтуха, желтуха грудного молока и гемолиз — когда это не к гепатологу |
| 2 | `chol_0_3m` | Cholestasis 0–3 Months | crit | neo, infant | **Флагман.** Первые 24 ч: сепсис/ИМП, галактоземия, гипотиреоз, пангипопитуитаризм, коагулопатия (витамин K). Исключить билиарную атрезию: УЗИ (triangular cord, желчный пузырь), ГГТ, MMP-7, HIDA, биопсия, интраоперационная холангиография — порядок и ценность. Окно Kasai: решение за дни |
| 3 | `chol_3_12m` | Cholestasis 3–12 Months | urg | infant | Поздняя атрезия, Алажиль, PFIC, α1-АТ, дефекты синтеза ЖК, NICCD; роль ГГТ, генетической панели, осмотра (лицо, сердце, позвонки, глаза) |
| 4 | `chol_older` | Cholestasis Beyond Infancy | urg | child, teen | Обструкция (камни, киста холедоха), ПСХ/ASC, АИГ, Вильсон, DILI, инфекции (EBV, HAV/HEV), позднее проявление PFIC/BRIC; когда MRCP, когда биопсия |
| 5 | `chol_low_ggt` | Low-GGT Cholestasis | urg | все | PFIC1/2, TJP2, MYO5B, дефекты синтеза ЖК, ARC; сывороточные ЖК как разделитель (высокие → транспорт; низкие → синтез → холевая кислота) |
| 6 | `unconj_bili` | Unconjugated Hyperbilirubinemia | rt | infant, child, teen | Гемолиз против нарушения конъюгации; Жильбер, Криглер–Найяр I/II; когда генетика UGT1A1 |
| 7 | `alt_elevated` | Elevated Transaminases | rt | все | Повторить и подтвердить; ВГН АЛТ по SAFETY (22 Ед/л у девочек / 26 у мальчиков) против лабораторной нормы. По возрасту: младенец (метаболика, CMV, α1-АТ, мышцы); 2–10 лет (вирусы, целиакия, АИГ, Вильсон с 3 лет, α1-АТ, лекарства, мышцы); подросток (MASLD, лекарства/добавки/алкоголь, АИГ, Вильсон, HBV/HCV, EBV). Обследование 1-го уровня → 2-го → биопсия; правило 3–6 месяцев |
| 8 | `ast_isolated` | Isolated AST Elevation | rt | все | Мышцы (КФК; миопатия Дюшенна/Беккера — ловушка с биопсией печени), гемолиз, макро-АСТ, гипотиреоз |
| 9 | `alt_over_1000` | Transaminases Over 1000 | crit | все | Ишемия/шок, парацетамол, острые вирусные гепатиты, АИГ, Вильсон, HSV у новорождённого, метаболический криз; сразу МНО, глюкоза, энцефалопатия → это уже ОПН? |
| 10 | `alp_isolated` | Isolated ALP Elevation | ref | все | Возрастные нормы (рост, пубертат), транзиторная гиперфосфатаземия, рахит, кость или печень (ГГТ, изоферменты) |
| 11 | `ggt_isolated` | Isolated GGT Elevation | rt | все | Лекарства (противоэпилептические), ранняя холангиопатия (ПСХ, Алажиль), MASLD, нормы новорождённых |
| 12 | `inr_prolonged` | Prolonged INR | urg | все | Пробная доза витамина K: дефицит или синтетическая недостаточность; факторы V/VII/VIII; ДВС; сбалансированный гемостаз |
| 13 | `palf` | Pediatric Acute Liver Failure | crit | все | Определение PALF (МНО ≥ 1,5 с энцефалопатией или ≥ 2,0 без неё, без коррекции витамином K). Причины по возрасту: новорождённый (GALD, HSV/энтеровирусы, HLH, митохондриальные, галактоземия, тирозинемия); младенец (метаболика, HFI, вирусы, ошибка дозы парацетамола); ребёнок/подросток (парацетамол, Вильсон, АИГ, вирусы, DILI; ~30–50% неясной этиологии). Панель первого дня; когда звонить в центр трансплантации |
| 14 | `hepatomegaly` | Hepatomegaly | rt | все | Застой, накопление, инфильтрация, воспаление; + гипогликемия → GSD; + гиперлипидемия → LAL-D; + спленомегалия → накопительные болезни / ПГ |
| 15 | `splenomegaly_ph` | Splenomegaly & Portal Hypertension | urg | все | EHPVO (нормальные пробы!) против цирроза и синусоидальных причин; допплер, эластография печени и селезёнки, ЭГДС |
| 16 | `varix_bleed` | Suspected Variceal Bleed | crit | все | Варикоз против других причин; первичная оценка и стабилизация до эндоскопии |
| 17 | `ascites` | Ascites | urg | все | Диагностический парацентез, SAAG, печёночный или нет, СБП |
| 18 | `enceph_nh3` | Encephalopathy & Hyperammonemia | crit | все | У ребёнка с болезнью печени (провокаторы) и без неё (нарушения цикла мочевины, органические ацидурии, NICCD) |
| 19 | `liver_mass` | Liver Mass | urg | все | < 1 года: гемангиома, мезенхимальная гамартома, гепатобластома, метастазы нейробластомы; 1–5 лет: гепатобластома; > 5 лет: ГЦК (вкл. фиброламеллярную), ФНГ, аденома. АФП (нормы младенцев!), визуализация, когда биопсия |
| 20 | `duct_dilation` | Bile Duct Dilation & Cysts | urg | все | Киста холедоха (Todani), болезнь Кароли, ARPKD/врождённый фиброз печени |
| 21 | `gallbladder` | Gallbladder & Gallstones | rt | все | ЖКБ (гемолиз, ПП, ожирение, цефтриаксон), сладж, холецистит |
| 22 | `acute_hepatitis` | Acute Hepatitis, Unknown Cause | urg | все | HAV/HBV/HCV/HEV/EBV/CMV/аденовирус, АИГ, Вильсон, DILI, целиакия — панель за один забор |
| 23 | `wilson` | Suspected Wilson Disease | urg | child, teen | Кого проверять; церулоплазмин, суточная медь мочи, кольца К–Ф, шкала Лейпцига, ATP7B; острая форма (Кумбс-отрицательный гемолиз, низкая ЩФ) |
| 24 | `aih` | Suspected Autoimmune Hepatitis | urg | child, teen | ANA, SMA, anti-LKM1, anti-SLA, IgG; критерии ESPGHAN против упрощённых IAIHG; ASC/перекрёст с ПСХ |
| 25 | `masld` | Suspected MASLD | rt | child, teen | Скрининг АЛТ с 9–11 лет при ожирении/факторах риска; что исключить до диагноза; УЗИ и эластография; номенклатура 2023 |
| 26 | `dili` | Suspected Drug-Induced Liver Injury | urg | все | R-ratio, RUCAM/RECAM, LiverTox, добавки и спортивное питание у подростков |
| 27 | `hbv_hcv` | Positive HBV or HCV Test | rt | все | Перинатальный HCV (РНК в 2–6 мес, CDC 2023), фазы HBV у детей, кого лечить |
| 28 | `aatd` | Alpha-1 Antitrypsin Deficiency | rt | все | Уровень + фенотип/генотип (PiZZ); почему один уровень ненадёжен |
| 29 | `chol_preterm_pn` | Cholestasis in Preterm or PN-Fed Infants | urg | neo, infant | PNAC/IFALD против атрезии у недоношенного; сепсис, NEC, хирургия |
| 30 | `systemic` | Liver in Systemic Disease | rt | все | Целиакия, ВЗК (→ ПСХ), сердечная недостаточность и Фонтен, сепсис-холестаз, HLH, муковисцидоз, щитовидная железа |
| 31 | `onc_hsct` | Liver After Chemo or HSCT | urg | все | SOS/VOD (детские критерии EBMT 2018), GVHD, DILI, инфекции, перегрузка железом |
| 32 | `hps_poph` | Hypoxemia in Liver Disease (HPS/POPH) | urg | все | Пульсоксиметрия, контрастная эхо, портопульмональная гипертензия |
| 33 | `kasai_fever` | Fever After Kasai | crit | infant, child | Холангит: критерии, посевы, эмпирическая терапия |
| 34 | `post_lt` | Abnormal Tests After Liver Transplant | crit | все | По срокам: тромбоз печёночной артерии (!), отторжение, билиарные стриктуры, CMV/EBV/PTLD, рецидив, DILI |
| 35 | `ferritin_high` | High Ferritin | rt | все | Воспаление против HLH против перегрузки (трансфузии) против гемохроматоза |

### 4.3. Справочные карточки (`cat: ref`)
| | id | Title | Содержание |
|---|---|---|---|
| A | `ref_norms` | Age-Based Liver Test Norms | АЛТ/АСТ/ГГТ/ЩФ/билирубин/АФП/аммиак по возрасту и полу — из `labs.json` |
| B | `ref_imaging` | Which Imaging When | УЗИ/допплер → MRCP → HIDA → КТ/МРТ; ограничения у младенцев; радиация |
| C | `ref_biopsy` | Liver Biopsy | Показания, доступы, осложнения, что просить у патолога (окраски, ИГХ, ЭМ, замороженный материал) |
| D | `ref_elasto` | Elastography & Fibrosis Scores | TE/SWE/MRE, педиатрические пороги, что искажает; APRI/GPR |
| E | `ref_genetics` | Genetic Testing | Панель или экзом/геном; трио; VUS; когда лечить, не дожидаясь результата |
| F | `ref_metabolic` | Metabolic Workup in One Draw | Что взять до инфузий, кормления и трансфузии |
| G | `ref_calcs` | Calculators & Scores | Хаб всех калькуляторов с формулами и источниками |
| — | `about` | About HepReference | Дисклеймер, как пользоваться (уже есть) |

### 4.4. Калькуляторы

| id | Название | Реализация | Используют |
|---|---|---|---|
| `c_conj_bili` | Conjugated bilirubin: cholestasis? | numeric (Swift) | 1, 2, 6, 29 |
| `c_kasai_clock` | Age in days & Kasai window (30/45/60 d) | numeric | 2, 3 |
| `c_uln` | ALT/AST/GGT × ULN for age & sex (из `labs.json`) | numeric | 7, 8, 9, 10, 11, 25 |
| `c_rratio` | R-ratio: injury pattern | numeric | 7, 9, 22, 26 |
| `c_vitamins` | Fat-soluble vitamin dosing in cholestasis | numeric | 2, 3, 4, 5, 29 |
| `c_vitk_inr` | INR response to vitamin K | chip_screen | 12, 13 |
| `c_palf` | PALF criteria & transplant-center referral | chip_screen (checklist_any) | 9, 12, 13, 18, 22, 23 |
| `c_peld_meld` | PELD-Cr / MELD 3.0 | numeric | 13, 15, 34 |
| `c_leipzig` | Leipzig score (Wilson) | score_calc | 9, 13, 22, 23 |
| `c_aih` | AIH criteria (simplified IAIHG + ESPGHAN pediatric) | score_calc | 22, 24 |
| `c_rucam` | RUCAM / RECAM | score_calc | 22, 26 |
| `c_apri_gpr` | APRI & GGT-to-platelet ratio | numeric | 15, 25, D |
| `nac` | Acetaminophen: 21-h IV NAC dosing | numeric (уже есть) | 9, 13 |

Формулы калькуляторов — **только из первоисточника**, с эталонными примерами в тестах. PELD-Cr и MELD 3.0 — сверить с актуальной политикой OPTN.

### 4.5. Карта связей
`→` — ссылки из исходов алгоритма (`link_card_id`); calc — калькуляторы (`link_calc_id`/блоки); ref — справки; plan — блоки годового плана.

| № | → next | calc | ref | plan |
|---|---|---|---|---|
| 1 | 2, 6, 29 | c_conj_bili | A | 1, 2 |
| 2 | 5, 12, 13, 29, 30 | c_conj_bili, c_kasai_clock, c_vitamins | A, B, C, E, F | 2, 3 |
| 3 | 5, 28, 14, 12 | c_kasai_clock, c_vitamins | B, C, E | 2, 4, 5, 6 |
| 4 | 20, 21, 23, 24, 26, 30 | c_vitamins | B, C | 7, 8, 9, 13, 18 |
| 5 | 3, 4 | c_vitamins | E, F | 2, 5 |
| 6 | 1, 21 | c_conj_bili | A, E | 1 |
| 7 | 8, 9, 22, 23, 24, 25, 26, 27, 28, 30 | c_uln, c_rratio | A, D | 1, 7, 8, 11, 13, 16, 25 |
| 8 | 7, 30 | c_uln | A | 1 |
| 9 | 13, 22, 23, 24, 26 | c_rratio, c_palf, c_leipzig, nac | A | 11, 12, 13 |
| 10 | 4, 11 | c_uln | A | 1 |
| 11 | 4, 20, 26 | c_uln | A | 1, 9 |
| 12 | 13, 2 | c_vitk_inr, c_palf | A | 1, 12 |
| 13 | 9, 18, 23, 24, 26, 30 | c_palf, c_peld_meld, c_leipzig, nac | A, E, F | 7, 12, 17 |
| 14 | 15, 19, 30, 35 | — | B, C, F | 14, 17, 20, 25 |
| 15 | 16, 17, 32 | c_apri_gpr, c_peld_meld | B, D | 14, 20 |
| 16 | 15, 13 | — | — | 14 |
| 17 | 15, 13 | — | B | 15 |
| 18 | 13, 30 | c_palf | F | 12, 15, 17 |
| 19 | 14 | — | B, C | 21 |
| 20 | 4, 21 | — | B | 18 |
| 21 | 4, 6, 20 | — | B | 19 |
| 22 | 9, 13, 23, 24, 26, 27 | c_rratio, c_leipzig, c_aih, c_rucam | A | 8, 10, 11, 13 |
| 23 | 13, 24 | c_leipzig | E | 7 |
| 24 | 11, 20, 23 | c_aih | C | 8, 9 |
| 25 | 7, 23 | c_uln, c_apri_gpr | B, D | 16 |
| 26 | 9, 13 | c_rratio, c_rucam | — | 13 |
| 27 | 22 | — | D | 10, 11 |
| 28 | 3, 15 | — | E | 6 |
| 29 | 2, 21 | c_conj_bili, c_vitamins | F | 2, 19 |
| 30 | 4, 7, 24, 31 | — | — | 18, 20, 25 |
| 31 | 26, 35, 14 | — | B | 20, 25 |
| 32 | 15 | — | B | 3, 14 |
| 33 | 2, 15 | — | B | 3 |
| 34 | 26, 27, 33 | c_peld_meld | B, C | 22, 23, 24 |
| 35 | 13, 18, 31 | — | C | 12, 25 |

Ссылка на карточку, которой ещё нет, **не добавляется** (тесты запрещают битые ссылки). Её вписывают в тот день, когда целевая карточка появилась: такая задача есть в каждом контентном промпте.

### 4.6. Сквозные сценарии (приёмочные тесты релизов)
1. **Ночной звонок:** «5 недель, желтуха, светлый стул» → 2 → (МНО 2,4) → 12 → назад в 2 → `workup` → `c_kasai_clock` → ветка «высокая ГГТ, triangular cord» → «Call pediatric surgery today».
2. **Амбулаторно:** «14 лет, ожирение, АЛТ 78» → 7 → возраст teen → `c_uln` → панель 1-го уровня → 25 → `c_apri_gpr`, ref D → «Don't miss: Wilson» → 23.
3. **Звонок из ED:** «2 года, сонливость, МНО 3,0, АЛТ 4000» → 13 → `c_palf` → «Call transplant center now» → ref F → `nac` → `c_peld_meld`.

Каждый сценарий — автоматический тест `ScenarioTests` (проход по ссылкам) и ручная проверка на устройстве.

---

## 5. Форматы контента

### 5.1. Карточка (`Content/Cards/<id>.json`)
Текущие поля движка + расширения (появляются в день 2; до этого — только текущие):
```json
{
  "id": "chol_0_3m",
  "title": "Cholestasis 0–3 Months",
  "code": "NASPGHAN/ESPGHAN 2017 · AAP 2022",
  "cat": "jaundice",
  "acu": "crit",
  "tags": ["cholestasis", "biliary atresia", "kasai", "conjugated bilirubin", "acholic stool"],
  "ages": ["neo", "infant"],
  "entry": "symptom",
  "guidelines": ["naspghan_espghan_2017_nc", "aap_2022_hyperbili"],
  "plan": [{"block": 2, "days": [1, 3]}, {"block": 3, "days": [3, 4]}],
  "related": ["chol_3_12m", "chol_low_ggt"],
  "status": "draft",
  "blocks": [ ... ]
}
```
- `code` — короткая строка источников под заголовком (subtitle).
- `acu`: `crit` (действовать сейчас) / `urg` (сегодня) / `rt` (плановая) / `ref` (справка).
- `ages`: `neo` (0–28 дн) / `infant` (1–12 мес) / `child` (1–10 лет) / `teen` (11–18 лет).
- `entry`: `lab` / `symptom` / `situation` / `disease` / `reference`.
- `status`: `draft` → `reviewed` (проверено на устройстве) → `approved` (только автор, после своей проверки). Заменяет устаревшие `done`/`reviewed`.
- Каждая карточка добавляется и в `manifest.json` (`{"id","cat","section"}`) — тест сверяет их один к одному.

### 5.2. Блоки (`"t"`)
**Существующие:** `note` (`k`: crit/warn/info), `list` (строки или `{t, sub}`), `dose`, `branch` (`opts: [{if, then}]`), `kv` (`rows: [[k, v]]`), `table` (`head`, `rows`), `text`, `chip_screen` (`calc_id`), `pathway` (`path_id`), `score_calc` (`calc_id`), `numeric_calc` (`calc_id`, `label`).
Разметка в тексте: `[m]1-800-222-1222[/m]` — кликабельный телефон.

**Новые (дни 6–10), схемы фиксированы:**
```json
{"t": "age_switch", "h": "Age", "options": [
  {"age": "neo", "label": "0–28 d", "path_id": "chol_0_3m_neo"},
  {"age": "infant", "label": "1–3 mo", "path_id": "chol_0_3m_infant"}]}

{"t": "workup", "h": "First contact", "groups": [
  {"label": "Blood — today", "items": ["Fractionated bilirubin (total + conjugated)", "GGT, ALT, AST, ALP", "INR"]},
  {"label": "Imaging", "items": ["Fasting abdominal ultrasound with Doppler"]}]}

{"t": "lab_norms", "h": "Norms for age", "analytes": ["alt", "ggt", "alp"]}

{"t": "pearls", "items": [
  {"k": "pearl", "text": "A normal-appearing gallbladder does not exclude biliary atresia."},
  {"k": "pitfall", "text": "Isolated high AST: check CK before any liver biopsy."}]}

{"t": "guideline_compare", "h": "Guidelines", "rows": [
  {"topic": "Routine MMP-7", "positions": {"naspghan_espghan_2017_nc": "Not addressed", "…": "…"},
   "verdict": "differs", "note": "Why it matters clinically"}]}

{"t": "case", "case_ids": ["chol_0_3m_c1", "chol_0_3m_c2"]}
```
`verdict`: `aligned` / `differs` / `material` (меняет тактику).

### 5.3. Алгоритм (`Content/Pathways/<id>.json`)
`{"id": "...", "children": [PathwayNode]}`. Узлы (`"t"`):
- `section` (`h`, `children`) — именованный раздел;
- `box` (`style`: plain/info/warn/crit) — цветная рамка;
- `group` (`label`) — подзаголовок группы;
- `arm` (`kind`: mild/mod/sev/floor, `tag`, `rx?`) — цветная ветка решения;
- `out` (`cond?`, `pill`/`pills` `{kind: dc/step/floor/picu, text}` **или** `subtext`, `cond_bold?`, `link_calc_id?`, `link_label?`) — исход;
- `row` (`label?`, `text`, `bullet?`, `link_calc_id?`, `link_label?`) — строка;
- `nest`, `col` — вложенность и группировка; `table` (`head`, `rows`).
- **С дня 4:** `link_card_id` у `out` и `row` — переход на другую карточку.

Метки `pill.kind` в гепатологии: `dc` = Outpatient follow-up, `step` = Same-day workup, `floor` = Admit, `picu` = PICU / transplant center. Подписи задаются в `text`.

### 5.4. Калькуляторы
- **chip_screen** (`Content/Calculators/<id>.json`): `rows: [{tag?, items: [{key, label}], exclusive?, gridColumns?}]` + `rule` одного вида: `checklist_any` (`tiers[{band, keys, text}]`, `noneBand`, `noneText`), `chip_score` (`points`, `bands[{min_score, band, text}]`), `chip_count` (`thresholds[{min_count…}]`, `special_key?`), `chip_tier` (`tiers[{key, items, band, text}]`, `override?`) или `named` (`rule_id` → Swift-правило в `ChipScreen.verdictRule`). В тексте вердикта: `{n}` — число, `{s}` — окончание множественного числа. `band`: hi/mid/lo.
- **score_calc** (`Content/ScoreCalcs/<id>.json`): `max_score`, `dimensions[{key, label, scored?, default?, options[{value, label}] | conditional_options}]`, `bands[{min, band, label, tier}]` (по убыванию `min`), `show_score?`.
- **numeric** (Swift): `Calculators/<Name>Calc.swift` — чистая функция; `Views/Calculators/<Name>CalcView.swift` — экран; регистрация id в `Calculators/NumericCalcRegistry.swift`. Других мест для регистрации нет.

### 5.5. Реестры (`Content/Registry/`, с дня 3)
```json
// guidelines.json
[{"id": "naspghan_espghan_2017_nc", "title": "Guideline for the Evaluation of Cholestatic Jaundice in Infants",
  "society": "NASPGHAN/ESPGHAN", "year": 2017, "citation": "Fawaz R et al. JPGN 2017;64:154-168",
  "url": "https://…", "checked": "2026-10", "supersedes": null}]

// labs.json
[{"id": "alt", "name": "ALT", "unit": "U/L", "bands": [
  {"age": "child", "sex": "F", "high": 22, "source": "safety_2010"},
  {"age": "child", "sex": "M", "high": 26, "source": "safety_2010"}]}]

// plan.json  (из sources/reading-final/Hepatology_Year_Plan.docx)
[{"block": 2, "title": "Neonatal cholestasis: approach", "start": "2026-10-12",
  "days": [{"day": 1, "topic": "Epidemiology and definitions", "cards": ["neo_jaundice", "chol_0_3m"]}]}]

// cases.json
[{"id": "chol_0_3m_c1", "card": "chol_0_3m", "stem": "…", "question": "…", "answer": "…", "teaching": "…"}]

// synonyms.json
{"biliary atresia": ["BA", "kasai", "атрезия"], "cholestasis": ["conjugated hyperbilirubinemia", "холестаз"]}
```
Один источник истины: нормы — только в `labs.json`, руководства — только в `guidelines.json`. Карточки ссылаются на них по id и не дублируют.

---

## 6. Правила написания контента

**Язык и стиль**
- Американский английский, императив, коротко: «Check INR before biopsy», а не «It is recommended that…».
- Единицы — US conventional: билирубин mg/dL, ферменты U/L, аммиак µmol/L; дозы в mg/kg с максимумом.
- Одна строка — один факт или одно действие. Без абзацев в Duty-слое.
- Аббревиатуру раскрывать при первом употреблении на карточке; дальше можно сокращать.

**Клиническая точность**
- Каждое пороговое значение, доза и критерий — из руководства или первоисточника, записанного в `guidelines.json`.
- Перед работой с карточкой: **проверить в интернете, нет ли более новой версии руководства** (общество, год, «update», «practice guidance»). Записать дату проверки в `checked`.
- Если руководства расходятся, это блок `guideline_compare`, а не выбор молча.
- Если данных нет или они слабые, так и писать: «Expert opinion», «Limited pediatric data».
- Местные протоколы, телефоны и названия больниц не добавлять (решение автора по каждому случаю).
- Сомнительное не угадывать, а пометить `TODO(verify): …` в черновике и вынести в отчёт дня.

**Источники контента (по приоритету)**
1. Уроки автора: `sources/reading-final/hepatology/BB-DD_*` — дек (`.pptx`) и текст главы (`_audio.pdf`). Извлечь: `python3 tools/sync_sources.py --extract BB-DD` (или `--extract BB-` для всего блока), читать `sources/extracted/`.
2. `drafts/<card_id>.md` → раздел `## Inbox` (накоплено ежедневной синхронизацией).
3. PDF руководств в `sources/guidelines/`.
4. Актуальные руководства и первоисточники из интернета (сайты обществ, PubMed, журналы).
5. Опорные источники по блокам — в годовом плане (точка старта, не окончательный список).

---

## 7. Конвейер одной карточки

1. **Исследование:** перечитать §4 (содержание и связи); извлечь и прочитать **все уроки блоков из колонки plan** (§4.5) и `## Inbox` черновика; проверить актуальность руководств.
2. **Черновик** `drafts/<id>.md` по анатомии §3.3: все 9 разделов, источники, `TODO(verify)`.
3. **JSON:** карточка + алгоритм(ы) + запись в `manifest.json` + реестры (руководства, нормы, случаи, синонимы).
4. **Связи:** исходящие ссылки на уже существующие карточки и калькуляторы; **обратно** — вписать ссылки на новую карточку в уже существующие карточки, которые по §4.5 должны на неё вести.
5. **Тесты:** `TEST SUCCEEDED`.
6. **Проверка на симуляторе:** снимок, читаемость, тёмная тема → `status: reviewed`.
7. **Рецензия автора** → автор ставит `approved` (промпт «Утверждение карточек»).

---

## 8. Код

- Стиль кода — как в существующем движке: `Decodable`-модели с `CodingKeys` в snake_case, `@Observable` для состояния, токены `Spacing`/`Radius`/`.hep*`-шрифты, компоненты `SectionCard`, `CollapsibleSection`, `SelectableChip`, `Badge`.
- Новые поля в моделях — **необязательные** (`decodeIfPresent`), чтобы старый контент продолжал декодироваться.
- Каждый новый тип блока: `case` в `Block.swift` + View в `Views/Blocks/` + ветка в `BlockView` + тест декодирования.
- Каждый калькулятор: чистая функция + тесты на эталонных примерах из первоисточника + показ формулы и источника в интерфейсе.
- `ContentIntegrityTests` — шлюз релиза: его расширяют, но никогда не ослабляют.
- Без сторонних зависимостей.

---

## 9. Ежедневный ритуал (для Claude)

Каждый день, независимо от промпта:
0. **Синхронизация уроков (обязательно, каждый день, первым делом):**
   - `python3 tools/sync_sources.py` — подтягивает reading-final, показывает новые/изменённые уроки и извлекает их текст;
   - `NO NEW MATERIAL` → сразу к шагу 1;
   - есть новое → внести по правилам §3.4, тесты, `python3 tools/sync_sources.py --done`, коммит `Sync: BB-DD <topic>` и push. Только потом — задача дня;
   - пропущено несколько дней → обработать все накопившиеся уроки по порядку (скрипт покажет их все).
1. **Начало:** прочитать журнал внизу `DAILY_PROMPTS.md` и убедиться, что предыдущий день закрыт (`TEST SUCCEEDED`, коммит). Если нет — сначала закончить его.
   **Проверка триггера:** если у дня указан триггер (урок `BB-14`), убедиться, что он есть в `sources/reading-final/hepatology/`. Нет урока — день не начинать: сообщить автору, когда ожидается триггер, и ограничиться синхронизацией. Приложение никогда не обгоняет обучение.
2. **Работа:** только задача текущего дня. Найденное за её пределами — в отчёт как «предложение», а не в код.
3. **Конец:**
   - тесты зелёные;
   - для визуальных изменений — снимок с симулятора;
   - отметить `[x]` у дня в `DAILY_PROMPTS.md` и добавить строку в журнал: дата · день · что сделано · открытые вопросы;
   - коммит: `Day NN: <кратко>` (английский) и `git push` в `origin main`;
   - отчёт автору по-русски: что сделано, что проверить руками, вопросы.

---

## 10. Темп и релизы: приложение идёт за обучением

**Принцип:** карточка собирается только после того, как пройден её **основной блок** годового плана (пришёл урок-синтез `BB-14`). Уроки последующих блоков обогащают уже готовые карточки через ежедневную синхронизацию и «Синтез блока». Работа над движком и функциями приложения от уроков не зависит и заполняет тихие блоки.

| Основной блок (триггер) | Карточки и калькуляторы |
|---|---|
| — (сразу) | Движок: дни 1–12 |
| 1 · инструментарий (01-14, уже есть) | A, B, C, D, E; 6, 7, 8, 10, 11, 12; c_uln, c_rratio, c_vitk_inr, c_apri_gpr, c_vitamins |
| 2 · неонатальный холестаз (02-14) | 1, 2, 29, F; c_conj_bili, c_kasai_clock; вкладка Study |
| 3 · атрезия (03-14) | 33; синтез → 2 |
| 4 · Алажиль (04-14) | синтез; избранное/недавние |
| 5 · PFIC (05-14) | 3, 5 |
| 6 · α1-АТ (06-14) | 28 |
| 7 · Вильсон (07-14) | 23; c_leipzig |
| 8 · АИГ (08-14) | 24; c_aih; режим Duty/Learn |
| 9 · ПСХ (09-14) | 4; синтез → 11, 24 |
| 10 · HBV/HDV (10-14) | синтез; вкладка Calculators + G; онбординг |
| 11 · HCV/HEV (11-14) | 27, 22 |
| 12 · ОПН (12-14) | 13, 9, 35; c_palf, c_peld_meld |
| 13 · DILI (13-14) | 26; c_rucam |
| 14 · ПГ (14-14) | 15, 16, 32 |
| 15 · цирроз (15-14) | 17, 18 |
| 16 · MASLD (16-14) | 25 |
| 17 · метаболика (17-14) | 14; синтез → F, 13, 18 |
| 18 · МВ/кисты (18-14) | 20 |
| 19 · ПП/ЖП (19-14) | 21; доступность |
| 20 · сосуды (20-14) | синтез → 15 |
| 21 · опухоли (21-14) | 19 |
| 22–24 · трансплантация (24-14) | 34 |
| 25 · системные (25-14) | 30, 31 |
| 26 · итог (26-14) | аудит, TestFlight |

| Релиз | После блока | Содержание | Критерий готовности |
|---|---|---|---|
| v0.1 | 2 | Движок, блоки 1–2: A–F, 1, 2, 6, 7, 8, 10, 11, 12, 29, вкладка Study | Сценарий 1 полностью |
| v0.2 | 6 | Младенческий холестаз целиком: 3, 5, 28, 33; избранное | Аудит этапа |
| v0.3 | 9 | 23, 24, 4; c_leipzig, c_aih; Duty/Learn | Аудит этапа |
| v0.4 | 13 | 27, 22, 13, 9, 35, 26; вкладка Calculators, онбординг | Сценарий 3 |
| v0.5 | 16 | 15, 16, 32, 17, 18, 25 | Сценарий 2 |
| v0.6 | 21 | 14, 20, 21, 19; доступность | Аудит этапа |
| v0.7 | 25 | 34, 30, 31 — все 35 + A–G | Все тесты целостности зелёные |
| v1.0 | 26 | Клинический аудит, TestFlight | Все карточки approved |

На главном экране показываются только полностью готовые разделы: никаких заглушек и битых ссылок.
