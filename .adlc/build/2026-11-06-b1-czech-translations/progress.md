# České překlady B1

Plan: docs/adlc/specs/2026-11-06-b1-czech-translations.md
Mode: single agent

- T1: complete. Deterministický generátor a kontrola pokrytí: 6 názvů objektů, 80 polí, 43 hodnot picklistů, 30 validací, 11 vztahů, 2 record typy. Základní anglická metadata a permission sety beze změny. Nezávislá revize bez nálezů.
- T2: complete. `LoyaltyCzechTranslationsTest` prošel v českém uživatelském kontextu při nasazení do skutečného Developer Edition orgu.
- T3: complete. Deployment `0Afaj00000qcka9CAA`: Succeeded, 12/12 komponent, 1/1 test. Zpětný retrieve `09Saj00000oXLC9EAO` ověřil všech 80 polí, 43 hodnot, 30 validací, 11 vztahů, 2 record typy a 72 pádových hodnot. Language settings se liší pouze povolením end-user jazyků. Změna se verzuje v existující `feature/data-model`.

Širší pokus `0Afaj00000qckALCAY` se vrátil zpět: 9 testů prošlo, 2 původní B1 testy selhaly kvůli souběžně aktivnímu bodovému enginu (109 vs 163 bodů a 1 vs 2 pohyby). Překladový test prošel. Detail je v IMPLEMENTATION.md.

Společný původní checkout během práce přešel na `feature/B3-transaction-input`. Lokalizace se proto dokončuje v izolovaném worktree na již existující `feature/data-model`; nová větev nevznikla. B3 soubory se necommitují.

Při zpětné kontrole Salesforce vynechal Vocative. Slovník i generátor proto používají šest skutečně ukládaných pádů; výsledná metadata se shodují s orgem.
