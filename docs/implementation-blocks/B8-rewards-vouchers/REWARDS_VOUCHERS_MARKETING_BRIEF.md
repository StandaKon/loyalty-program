# B8 — Zadání pro marketing: odměny a vouchery

## Účel dokumentu

Marketingový tým má připravit obsahové, obchodní a komunikační zadání pro katalog odměn, uplatnění bodů a vouchery v portálu EneOil Klub. Výstup bude sloužit jako schválený podklad pro UX návrh, nastavení katalogu, právní kontrolu a implementaci v Salesforce.

Marketing nenavrhuje technické řešení Salesforce. Potřebujeme od něj jednoznačně určit nabídku odměn, obchodní pravidla, obsah portálu a podobu komunikace se členem.

## Pevné zadání programu

- Partnerem první verze katalogu je **EneServis**.
- Člen si v portálu vybere odměnu a vymění za ni body.
- Uplatnění je povoleno pouze při dostatečném bodovém zůstatku.
- Body se odečtou okamžitě po úspěšném potvrzení.
- Člen obdrží unikátní kód voucheru v portálu a v českém e-mailu.
- Voucher je určen k předložení nebo nadiktování obsluze EneServisu.
- Aktuální požadavek uvádí voucher bez expirace; marketing a vlastník programu musí toto pravidlo výslovně potvrdit.
- Portál a e-maily budou v češtině a budou respektovat Brand Kit EneOil / EneOil Klub / EneServis.

Výchozí katalog pro potvrzení:

| Odměna | Bodová cena | Hodnota pro člena |
| --- | ---: | ---: |
| Sleva na výměnu pneumatik | 500 bodů | 200 Kč |
| Sleva na servis | 1 200 bodů | 500 Kč |
| Servisní prohlídka zdarma | 5 000 bodů | Doplnit CZK hodnotu |

## Rozhodnutí požadovaná od marketingu

### 1. Nabídka a obsah katalogu odměn

Pro každou odměnu potvrďte nebo dodejte:

- finální název;
- partnera, který odměnu poskytuje;
- bodovou cenu;
- peněžní hodnotu odměny v Kč pro reporting a rozpočet;
- krátký text na kartě odměny;
- podrobný popis a rozsah služby;
- fotografii, ilustraci nebo ikonu včetně práva k použití;
- dobu dostupnosti a případné omezení počtu kusů;
- místa nebo pobočky, kde lze voucher uplatnit;
- podmínky uplatnění a výluky;
- zda lze voucher kombinovat s jinou slevou nebo akcí;
- zda lze jednu odměnu získat opakovaně a zda platí limit na člena;
- kontaktní místo pro dotazy nebo reklamace.

Je nutné potvrdit, zda se katalog pouze zveřejňuje podle data a aktivního stavu, nebo zda má Salesforce hlídat také dostupné množství a rozpočet.

### 2. Rozpočet partnera a hodnota voucherů

Rozhodněte otevřený bod OP-09:

- CZK hodnota každé odměny, včetně bezplatné servisní prohlídky;
- rozpočet partnera pro zvolené období;
- vlastník rozpočtu a frekvence jeho obnovy;
- zda se do rozpočtu započítá vydaný, nebo až skutečně uplatněný voucher;
- zda je rozpočet pouze reportovaný, nebo má systém po jeho vyčerpání další vydávání zablokovat;
- co má člen vidět, když je odměna dočasně nebo trvale nedostupná;
- zda se historická CZK hodnota vydaného voucheru zachová i po změně katalogové ceny. Výchozí pravidlo je, že ano.

### 3. Platnost a obchodní podmínky voucheru

Potvrďte:

- zda voucher skutečně nemá expiraci;
- okamžik, od kterého jej lze použít;
- zda je přenosný na jinou osobu;
- zda lze jeden voucher použít pouze jednou;
- zda je možné částečné čerpání;
- zda se z voucheru vrací nevyčerpaná hodnota;
- zda je nutná rezervace termínu v EneServisu;
- co se stane při zrušení odměny, reklamaci nebo chybném vydání;
- zda se při oprávněném stornu voucheru vracejí body a kdo je oprávněn takové storno provést;
- finální znění obchodních podmínek a odkaz, kde budou zveřejněny.

Pravidla musí schválit vlastník programu a podle potřeby také legal/privacy tým.

### 4. Použití voucheru u partnera

Spolu s provozním týmem EneServisu popište cílový postup:

1. Co člen předloží nebo nadiktuje obsluze?
2. Jak obsluha ověří platnost voucheru?
3. Které informace smí obsluha o voucheru a členovi vidět?
4. Kdy se voucher označí jako uplatněný?
5. Co obsluha udělá s neplatným, již použitým nebo zrušeným voucherem?
6. Kdo a jak řeší provozní výjimky a reklamace?

Potvrďte požadované obchodní stavy voucheru, například **Aktivní**, **Uplatněný** a **Zrušený**, a povolené přechody mezi nimi. Operátorské ověření v Salesforce je zatím volitelný požadavek a musí být výslovně potvrzeno pro první verzi.

### 5. Kód voucheru

Marketing a provoz potvrdí viditelnou podobu kódu. Výchozí formát je `ENE-XXXX-XXXX`.

Posuďte zejména:

- srozumitelnost při zobrazení na mobilu;
- snadné nadiktování a ruční zadání obsluhou;
- rozlišitelnost podobných znaků, například `0/O` nebo `1/I`;
- zda se má rozlišovat velikost písmen. Doporučení je nerozlišovat ji;
- zda první verze potřebuje pouze textový kód, nebo také QR/čárový kód.

Algoritmus generování, unikátnost, bezpečnost a řešení kolizí navrhne implementační tým.

## Obsah portálu k dodání

Připravte finální české texty alespoň pro tyto prvky a stavy:

| Oblast | Text nebo rozhodnutí |
| --- | --- |
| Katalog | Nadpis, úvodní text a vysvětlení principu odměn |
| Karta odměny | Název, krátký popis, bodová cena, CZK hodnota a partner |
| Dostupná odměna | Výzva k detailu nebo uplatnění |
| Nedostatek bodů | Srozumitelný stav bez neaktivního slepého tlačítka |
| Nedostupná odměna | Text pro neaktivní, vyčerpanou nebo ukončenou nabídku |
| Detail odměny | Popis, podmínky, omezení a způsob použití |
| Potvrzení | Rekapitulace odměny, bodové ceny a okamžitého odečtu bodů |
| Úspěch | Potvrzení vytvoření voucheru a odečtu bodů |
| Neúspěch | Obecná chyba bez interních technických detailů |
| Moje vouchery | Nadpis, prázdný stav a vysvětlení seznamu |
| Voucher | Stav, kód, odměna, partner, datum vydání a pokyny |
| Uplatněný voucher | Informace, že voucher již nelze znovu použít |
| Zrušený voucher | Informace o zrušení a případném vrácení bodů |
| Nápověda | Kontaktní a reklamační informace |

Potvrzovací krok musí členovi předem jasně sdělit, kolik bodů bude odečteno a co získá. Text nesmí tvrdit, že voucher vznikl, dokud systém úspěšné vydání nepotvrdí.

## E-mail s voucherem

Marketing dodá nebo schválí:

- zobrazované jméno odesílatele;
- předmět a preheader;
- finální text e-mailu v češtině;
- pořadí a vizuální hierarchii informací;
- název odměny, partnera, bodovou cenu, voucherový kód a pokyny k použití;
- platnost nebo jednoznačnou informaci, že voucher nemá expiraci;
- obchodní podmínky, povinné právní texty a odkazy;
- kontaktní informace pro podporu;
- HTML a textovou podobu nebo obsah vhodný pro obě varianty;
- požadované obrázky včetně licence a alternativních textů.

E-mail má pouze potvrzovat již úspěšně vydaný voucher. Nedoručení e-mailu nesmí způsobit druhé odečtení bodů ani vytvoření dalšího voucheru; technické opakování odeslání vyřeší implementační tým.

## UX a vizuální podklady

Marketing dodá nebo schválí:

- obsahovou hierarchii katalogu, detailu odměny a sekce Moje vouchery;
- pořadí odměn a případná pravidla jejich zvýraznění;
- podobu potvrzovacího kroku před odečtem bodů;
- vizuální podobu voucheru v portálu;
- mobilní a desktopovou podobu, pokud již existuje design;
- ikony, fotografie a ilustrace včetně licencí a alternativních textů;
- návaznost na Brand Kit a design source of truth z bloku B6.

PDF nebo obrázkový voucher je volitelný bonus bloku B11 a není automaticky součástí B8. Pro B8 musí být voucher plnohodnotně použitelný přímo v portálu a e-mailu.

## Požadovaný formát výstupu

Marketing vrátí jeden schválený dokument obsahující:

1. finální katalog odměn se všemi hodnotami, popisy a podmínkami;
2. rozhodnutí o rozpočtu, dostupnosti a případných limitech;
3. pravidla platnosti, uplatnění, storna a vracení bodů;
4. popsaný proces ověření voucheru u EneServisu;
5. potvrzené stavy voucheru a jejich obchodní význam;
6. schválenou viditelnou podobu voucherového kódu;
7. kompletní české texty pro portál a všechny stavy;
8. finální obsah e-mailu s voucherem;
9. vizuální podklady nebo jednoznačný odkaz na Brand Kit;
10. odkazy na obchodní a právní podmínky;
11. jména marketingového, programového, provozního a legal schvalovatele;
12. datum a verzi schválení.

Nejasné varianty označte jako otevřené rozhodnutí s vlastníkem a termínem. Nepředávejte implementačnímu týmu více alternativ bez určení preferované varianty.

## Akceptace marketingového zadání

Zadání je připravené k implementaci, když:

- každá odměna má schválený název, bodovou cenu, CZK hodnotu, popis a podmínky;
- je rozhodnuto, zda se rozpočet a dostupnost pouze reportují, nebo také vynucují;
- je potvrzena platnost voucheru a pravidla pro použití, storno a vrácení bodů;
- EneServis schválil provozní postup ověření a uplatnění;
- jsou definovány stavy voucheru a jejich obchodní význam;
- je potvrzena uživatelsky viditelná podoba kódu;
- jsou dodány texty pro katalog, potvrzení, chyby a Moje vouchery;
- je schválen kompletní obsah e-mailu;
- obrazové a textové podklady jsou použitelné na mobilu a v souladu s B6;
- dokument má vlastníky, schvalovatele, verzi a datum schválení.

## Mimo rozsah marketingového zadání

Marketing nemusí navrhovat:

- Salesforce datový model a API názvy;
- LWC, Apex, Flow, integrační nebo bezpečnostní řešení;
- kontrolu bodového zůstatku a atomický odečet bodů;
- ochranu proti dvojímu kliknutí nebo opakovanému požadavku;
- algoritmus generování a zajištění unikátnosti kódu;
- technické odesílání e-mailu a opakování při chybě;
- oprávnění obsluhy a izolaci dat jednotlivých členů;
- automatizované testy a nasazení do prostředí.

Tyto oblasti zpracuje implementační tým podle schválených obchodních, obsahových, provozních a právních pravidel.
