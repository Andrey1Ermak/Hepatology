---
name: library
description: Process full-text documents the author dropped into library/inbox — file them, write full-text notes in library/notes, update the catalog and push. Use when the author says /library, "обработай библиотеку", "я положил статьи", or mentions new PDFs in the library. Runs only on the author's Mac, where the PDFs are.
---

# /library — обработка библиотеки полных текстов

Правила библиотеки — `CLAUDE.md` §6a и `library/README.md`. Отвечать автору по-русски, конспекты писать по-английски.

## Шаги

1. **Синхронизация.** `git pull --rebase origin main` (облачный прогон мог поменять каталог). Рабочее дерево должно быть чистым; если нет — сначала разобраться.
2. **Разложить inbox.** `python3 tools/library.py ingest`.
   - Файл не распознан → открыть его текст (`pdftotext -l 2 <file> -`), определить документ. Если его нет в `catalog.json` — добавить запись (priority по полезности, `need` — что в нём ценно для карточек, `for` — карточки, `added` — сегодня, остальные даты null) и выполнить `python3 tools/library.py assign <file> <id>`. Id — как в `guidelines.json`, если документ там есть.
   - Мало текста (скан) → OCR (навык pdf), сохранить текст в `library/text/<id>.txt`.
   - Не статья / мусор / дубликат → оставить в inbox и сказать автору.
3. **Конспект для каждого `received`.** Прочитать `library/text/<id>.txt` целиком (при необходимости и сам PDF — таблицы и рисунки). Сначала найти в проекте, что от документа ждут: поле `need`, `grep -rn "<id>\|<фамилия первого автора>"` по `drafts/`, `BACKLOG.md`, `DECISIONS.md`, `ios/HepReference/HepReference/Content/`. Написать `library/notes/<id>.md` по шаблону из `library/README.md`:
   - на каждый пункт `need` — ответ с номером страницы/таблицы; чего в тексте нет — так и написать;
   - отдельный раздел «Conflicts with what the app says now» — сверить с карточками и `TODO(verify)`;
   - **авторское право:** только факты своими словами и числа; не больше одной короткой цитаты (< 15 слов) на пункт; таблицы не копировать целиком.
   - Документ без ответа на `need`, но полезный — всё равно конспект; бесполезный — `set <id> dropped` с причиной в `need`.
4. `python3 tools/library.py set <id> noted` для каждого конспекта; `python3 tools/library.py check` → `LIBRARY OK`.
5. **Коммит и push:** `git add library/ && git commit -m "Library: notes for <ids>"` (с атрибуцией Co-Authored-By как в DAILY_RUN.md), `git pull --rebase origin main`, `git push origin main`. PDF и текст в git не попадают (`.gitignore`) — проверить `git status`, что в коммите только `library/catalog.json`, `library/WANTED.md`, `library/notes/`.
6. **Карточки здесь не менять.** Внесение в контент — работа облачного прогона (конвейер §7 с ревью и тестами): он увидит статус `noted`.
7. **Отчёт автору** (коротко): что распознано, какие конспекты написаны и что в них важного (особенно конфликты с приложением), что не распознано, сколько осталось в WANTED (P1 отдельно).
