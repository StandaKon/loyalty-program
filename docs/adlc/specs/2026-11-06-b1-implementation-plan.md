# Implementace B1

Uživatel 6. 11. 2026 schválil návrh a výslovně požádal o vytvoření modelu, permission setů a nasazení do připojeného orgu. Tento záznam konkretizuje autorizovaný rozsah, nezavádí další schvalovací krok.

## Omezení

API 63.0, pouze lokální default org, bez volby target-org a bez produkčního nasazení. Nasazení a ověřování společného orgu provádí pouze hlavní agent. Zachovat existující metadata a uživatelské změny. Implementace B1 nezahrnuje engine B2, registraci B6, aktivity B7 ani směnu B8. Jejich serverové operace, číslování členů a ochrana před administrátorským mazáním zůstávají výslovnými návaznostmi.

## Úkoly

| ID | Soubory | Změna | Ověření |
| --- | --- | --- | --- |
| T1 | `scripts/python/generate_b1_metadata.py`, `force-app/main/default/objects/**`, `force-app/main/default/customMetadata/**`, `force-app/main/default/labels/**`, `force-app/main/default/tabs/**`, `force-app/main/default/layouts/**` | Generátor, pět datových objektů, Account a consent pole, CMDT, validace, záložky a formuláře. | XML kontrola, dry-run deployment, schema v orgu. |
| T2 | `force-app/main/default/permissionsets/**`, `force-app/main/default/sharingSets/**` | Nejméně privilegované sady pro člena, kampaně, správu, back-office, import a reporting, mapování vlastníka členských dat. | Deployment a kontrola CRUD, FLS a sharing setu. |
| T3 | `force-app/main/default/classes/*Test.*`, `scripts/apex/**`, `docs/implementation-blocks/B1-data-model-config/IMPLEMENTATION.md` | Integrační testy omezení a roll-upu, záznam výsledku a zbývajících závislostí. | Specifikované testy a kontrola nasazených komponent. |

## Pořadí a závislosti

Independent: T1
T2 ← T1
T3 ← T1, T2

## Režim provedení

Jeden agent. Opakující se XML vytváří deterministický generátor. Bez paralelních zásahů do společného orgu. Schválení provedení a deploymentu vyplývá z přímého požadavku uživatele.
