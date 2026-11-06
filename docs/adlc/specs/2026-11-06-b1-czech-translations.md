# České překlady datového modelu B1

Uživatel 6. 11. 2026 požádal o české překlady, nasazení a verzování v existující větvi `feature/data-model`. Jde o lokální doplnění velikosti S s nízkým rizikem. Rozsah tvoří všechny uživatelské texty stávajících B1 metadat, které Salesforce umí překládat.

## Návrh

Použije se standardní Translation Workbench, jazyk `cs`, překlady vlastních objektů, jejich názvových polí, všech vlastních polí, hodnot picklistů, souvisejících seznamů a validačních hlášení. Česká rozhraní využijí také standardní překlady Salesforce. Základní metadata a API názvy zůstanou anglicky. Přepsání výchozích labelů do češtiny by porušilo projektovou konvenci a zhoršilo anglické rozhraní.

Zdrojový slovník překladů je JSON. Generátor kontroluje přesné pokrytí zdrojových polí, hodnot a validací a při chybě skončí, místo aby doplnil anglický fallback. Stávající generátor B1 spustí také generování překladů. Nevytvářejí se nepoužívané Custom Labels, obsah budoucích obrazovek ani překlady datových záznamů.

Názvy permission setů a další netranslatovatelné administrátorské popisky zůstávají v základním jazyce. Do Language.settings se přidá pouze povolení end-user jazyků nutné pro češtinu. Nemění se jazyk konkrétního uživatele, výchozí jazyk orgu ani oprávnění.

## Úkoly a ověření

| ID | Soubory | Změna a ověření |
| --- | --- | --- |
| T1 | `scripts/python/b1_cs.json`, `scripts/python/generate_b1_translations.py`, `scripts/python/generate_b1_metadata.py`, `force-app/main/default/objectTranslations/**`, `force-app/main/default/settings/Language.settings-meta.xml` | Slovník a generátor, úplnost pokrytí, XML syntaxe a opakovatelnost. |
| T2 | `force-app/main/default/classes/LoyaltyCzechTranslationsTest.*` | Ověření českých názvů, hodnot a validačního hlášení ve skutečném českém uživatelském kontextu. |
| T3 | `docs/implementation-blocks/B1-data-model-config/IMPLEMENTATION.md`, `.adlc/build/2026-11-06-b1-czech-translations/progress.md` | Nasazení do lokálního default orgu, ověření a záznam výsledku, commit a push do feature/data-model. |

## Pořadí a omezení

Independent: T1
T2 ← T1
T3 ← T1, T2

Nasazuje a proti společnému orgu ověřuje pouze hlavní agent. Bez target-org, bez produkčního deploymentu, bez změn existujících dat a oprávnění. API verze pochází z projektu. Načtená výchozí čeština nemá žádné vlastní překlady. Translation Workbench je zapnutý, end-user jazyky jsou dosud vypnuté.

## Režim provedení

Jeden agent a deterministický generátor. Přímý požadavek uživatele autorizuje vytvoření, nasazení a verzování této změny bez dalšího schvalování. Nezávislá revize ověří pokrytí a zachování anglických základních metadat před dokončením.
