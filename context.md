# EneOil Klub: funkční zadání pro rozpad do user stories

| | |
| --- | --- |
| Projekt | Věrnostní program pro síť čerpacích stanic (AI Hackathon 2026, varianta 2, tým 2A) |
| Verze | 1.0, 6. 11. 2026 |
| Účel | Vstup pro agenta, který z dokumentu vytvoří backlog (epiky → user stories → akceptační kritéria → odhad v MD) |
| Závazný zdroj | `Zadání-AI-Hackathon-6-11-2026_tym-2.pdf` (minimální rozsah) |
| Další zdroje | `specifikace funkcí mobilních aplikací loajalitního programu.pdf` (30 funkcí trhu, odkazy na GUI), `Shrnuti-z-recenzi-mobilnich-aplikaci-...md` (recenze 8 aplikací), `všechny aplikace pro řešení loajalitního programu.md` (AppExchange), `brand/eneoil-brand-kit.md` (názvosloví, texty, barvy) |

---

## 0. Pokyny pro agenta, který bude dělat user stories

1. **Neměň obchodní pravidla v kapitole 4.** Jsou normativní (část přímo ze zadání, část jako odsouhlasený předpoklad). Pokud najdeš rozpor, zapiš ho do otevřených otázek, nepřepisuj ho.
2. **Zachovej ID požadavků** (`FR-E2-03`, `BR-07`, `NFR-04`) v každé user story. Jeden požadavek může dát víc stories, story nesmí míchat dva epiky.
3. **Akceptační kritéria (AC) převezmi** a rozpracuj do formátu Given/When/Then. Tabulka v kapitole 4.9 je zároveň sada testovacích scénářů pro výpočet bodů.
4. **Priorita (MoSCoW) se dědí** z požadavku na story. Význam:
   - **MUST**: požadavek zadání hackathonu. Bez něj demo neprojde.
   - **SHOULD**: doporučená funkce, která má doložený úspěch na trhu nebo řeší častou kritiku v recenzích, a má nízkou pracnost. Dělá se hned po MUST.
   - **COULD**: bonus ze zadání nebo doporučená funkce s vyšší pracností. Jen pokud zbude čas.
   - **WON'T (teď)**: roadmapa pro reálnou implementaci u klienta (fáze 2). Do backlogu jako epik „Roadmapa“, bez rozpadu.
5. **Formát story:** „Jako ‹role z kap. 2› chci ‹funkci›, abych ‹přínos›.“ Ke každé story uveď odhad pro reálnou implementaci u klienta v MD (zadání ho vyžaduje pro SteerCo).
6. **Názvosloví** ber z kapitoly 3 (brand kit). V textech pro člena tykání, v back-office a reportu věcný jazyk.
7. **Poznámky „Realizace (nezávazně)“** jsou nápověda pro solution design, ne požadavek. Rozhodnutí patří do technické dokumentace.
---

## 1. Kontext a cíl

EneOil a.s. (fiktivní, v zadání „EnePumpa“) provozuje 120 čerpacích stanic v ČR. Na pokladně prodává palivo, kávu, občerstvení a zboží. Spouští věrnostní program **EneOil Klub**, aby se zákazníci vraceli. Velká loyalty platforma se při této velikosti nevyplatí (např. Salesforce Loyalty Management stojí podle oficiálního ceníku od 20 000 USD za org měsíčně, AppExchange enterprise platformy typicky od 50 000 USD ročně), proto se program staví na stávajícím **Salesforce Sales Cloud**.

**Cíl řešení:**

- Člen sbírá body za tankování, za nákupy na pokladně, v kampaních a za aktivity v portálu a utrácí je za vouchery partnera EneServis.
- Loyalty manažer v Salesforce spravuje členy, kampaně a katalog odměn bez zásahu vývojáře.
- Vedení (Head of Loyalty) řídí program podle reportu napojeného na Salesforce.
**Tři dodávané komponenty (zadání):**

| # | Komponenta | Platforma |
| --- | --- | --- |
| 01 | Loyalty engine a back-office | Sales Cloud (bez Loyalty Management package) |
| 02 | Členský portál pro přihlášeného člena | Experience Cloud |
| 03 | Manažerský report napojený na Salesforce | Claude artifact |

**Klíčové doporučení z trhu:** referenční aplikace (ORLEN, MOL Move, OMV MyStation, Shell, Circle K) jsou mobilní. Náš portál proto navrhujeme **mobile-first**: člen ho otevírá na telefonu u pumpy nebo u pokladny, takže nejdůležitější informace (zůstatek, členská karta, akce) musí být na jedno klepnutí.

---

## 2. Role a persony

| Role | Kdo | Co potřebuje |
| --- | --- | --- |
| **Člen Klubu** | Řidič, typicky jezdí po ČR, má minutu času (persona „Jana“ z brand kitu) | Vidět zůstatek a za co body dostal, vědět o akcích, rychle získat voucher do servisu, mít kartu po ruce |
| **Návštěvník** | Neregistrovaný zákazník | Zaregistrovat se jednoduše a bez zbytečných údajů |
| **Loyalty manažer** | Back-office uživatel v Sales Cloudu | Spravovat členy, kampaně, katalog odměn, řešit reklamace bodů |
| **Operátor EneServis** | Pracovník partnerského servisu nebo zákaznické linky | Ověřit nadiktovaný kód voucheru a označit ho jako uplatněný |
| **Petra Králová, Head of Loyalty** | Vedení programu, uživatel reportu | Vývoj programu: členové, registrace, čerpání bodů, oblíbené odměny, kampaně, rozpočet voucherů |
| **Finanční ředitel** | Ptá se Petry | Kolik % bodů se průměrně vyčerpá a jak nastavit rozpočet na příští rok |
| **Marketing** | Ptá se Petry | Které kampaně opakovat |
| **Systém (simulace POS)** | Import nebo ruční zadání transakce | Zpracovat transakci a připsat body přesně jednou |

---

## 3. Slovník a názvosloví

| Pojem | Význam | Použití |
| --- | --- | --- |
| **EneOil** | Síť stanic, společnost EneOil a.s. | Nikdy „Eneoil“, „ENEOIL“ |
| **EneOil Klub** | Věrnostní program | Nikdy „Klub EneOil“, „EneOil club“ |
| **člen Klubu** | Registrovaný účastník programu | Ke členovi ne „zákazník“, „uživatel“ |
| **body** | Měna programu (směnitelné body) | Skloňování: 1 bod, 2 až 4 body, 5+ bodů, 0 bodů |
| **transakce** | Jeden nákup na pokladně (palivo + ostatní, jedna platba) | |
| **základní body** | Body za palivo + body za ostatní | Základ pro násobitel kampaně |
| **kampaň** (interně) / **akce** (ke členovi) | Pravidlo nad základními pravidly | „Natankuj plnou“, „Zastávka na cestě“ |
| **aktivita** | Úkon v portálu, za který člen jednorázově získá body | Dokončení profilu, marketingový souhlas |
| **pohyb bodů** | Neměnný záznam o změně zůstatku | Historie bodů |
| **zůstatek** | Součet všech pohybů bodů člena | Ke členovi ne „kredit“, „konto“ |
| **odměna** | Položka katalogu (cena v bodech) | |
| **voucher** | Vydaný nárok s unikátním kódem `ENE-XXXX-XXXX` | Ke členovi ne „kupón“, „poukázka“ |
| **EneServis** | Autoservis EneServis, s.r.o., jediný partner programu | |
| **Okreska / Dálnice** | Úrovně členství Standard / VIP (bonus) | |
| **qualifying body** | Body pro výpočet úrovně (bonus), nejsou směnitelné | |
| **míra čerpání** | Uplatněné body / připsané body v % | KPI pro finančního ředitele |

---

## 4. Obchodní pravidla (normativní)

Značení zdroje: **[Z]** = zadání hackathonu, **[P]** = náš předpoklad (k potvrzení u garanta, viz kap. 11), **[T]** = doporučení z trhu.

### 4.1 Transakce

- **BR-01 [Z]** Z pokladny přichází za každý nákup jedna transakce. Zákazník platí jednou, i když tankuje a nakupuje zároveň.
- **BR-02 [Z]** Transakce nese: celkovou částku, částku za palivo, počet natankovaných litrů, částku za ostatní. Platí: palivo + ostatní = celková částka. Pod transakcí se nevytvářejí položky ani produktový katalog.
- **BR-03 [P]** Transakce dále nese: unikátní ID transakce z pokladny, datum a čas nákupu, číslo člena, stanici (volitelně).
- **BR-04 [P] Validace:** všechny částky a litry ≥ 0; celková částka > 0; palivo + ostatní = celková (přesně, na haléře); pokud palivo > 0, pak litry > 0, a naopak. Částky i litry na 2 desetinná místa. Nevalidní transakce se nezpracuje a zaloguje se chyba.
- **BR-05 [P]** Transakce s neexistujícím nebo zablokovaným číslem člena se nezpracuje (chyba, žádné body). Transakce nečlenů se do Salesforce neimportují.
- **BR-06 [Z][T] Idempotence:** transakce se stejným ID z pokladny se zpracuje právě jednou. Opakovaný import nevytvoří nové pohyby bodů ani nové uplatnění kampaně.
- **BR-07 [Z]** Integrace s pokladnou se nestaví. Transakce se simulují importem (CSV) nebo zadáním přes konzoli / UI. Výpočet bodů musí proběhnout stejně bez ohledu na kanál vložení.
### 4.2 Základní body

- **BR-10 [Z] Palivo:** 1 bod za každý celý natankovaný litr → `body_palivo = floor(litry)`.
- **BR-11 [Z] Ostatní:** 1 bod za každých celých 20 Kč → `body_ostatni = floor(ostatni_Kc / 20)`.
- **BR-12 [Z]** `zakladni_body = body_palivo + body_ostatni`.
- **BR-13 [P]** Sazby (1 bod/litr, 20 Kč/bod) jsou uloženy jako parametr programu, ne natvrdo v kódu.
- **BR-14 [P]** Výpočet probíhá v celých číslech nebo v typu Decimal, nikdy v plovoucí čárce. Násobení 1,1 se počítá jako `floor(zaklad × 11 / 10)`.
### 4.3 Kampaně

- **BR-20 [Z]** Kampaně běží nad základními pravidly a platí automaticky pro všechny členy (bez přihlašování ke kampani).
- **BR-21 [Z]** Loyalty manažer nastavuje kampaň konfigurací: období platnosti, podmínka, odměna. Nic z toho nesmí být natvrdo v kódu.
- **BR-22 [P] Podmínka** = měřená veličina transakce (`litry`, `palivo Kč`, `ostatní Kč`, `celková částka Kč`) + operátor (`≥`) + prahová hodnota. V MVP jedna podmínka na kampaň.
- **BR-23 [P] Typ odměny:**
  - **Pevný bonus**: `bonus = hodnota` (body).
  - **Násobitel základních bodů**: `bonus = floor(zakladni_body × koeficient) − zakladni_body`.
- **BR-24 [Z]** Koeficient se vztahuje jen na základní body, nikdy na bonus z jiné kampaně ani na body z aktivit.
- **BR-25 [Z]** V jedné transakci se může uplatnit více kampaní. Bonusy se sčítají. Každá kampaň se na jednu transakci uplatní nejvýše jednou.
- **BR-26 [P]** Pokud by současně platilo více násobitelů, každý se počítá samostatně ze základních bodů a výsledné bonusy se sečtou (násobitele se mezi sebou nenásobí).
- **BR-27 [T]** O platnosti kampaně rozhoduje **datum a čas nákupu**, ne čas importu. Zpožděně importovaná transakce se hodnotí podle kampaní platných v okamžiku nákupu.
- **BR-28 [T]** Změna nebo ukončení kampaně se nepromítá zpětně do již zpracovaných transakcí.
- **BR-29 [Z]** Výchozí kampaně (testovací data):
| Kampaň | Podmínka | Odměna |
| --- | --- | --- |
| **Natankuj plnou** | litry ≥ 40 | pevný bonus +50 bodů |
| **Zastávka na cestě** | ostatní Kč ≥ 150 | násobitel 1,1 na základní body, zaokrouhleno dolů |

### 4.4 Body za aktivity v portálu

- **BR-30 [Z]** Dokončení profilu (doplnění údajů o vozidle): +100 bodů, jednorázově na člena.
- **BR-31 [Z]** Souhlas s marketingovou komunikací: +50 bodů, jednorázově na člena.
- **BR-32 [P]** Profil je dokončený, když má člen vyplněno: značka vozidla, model, druh paliva, rok výroby. SPZ je volitelná.
- **BR-33 [P]** Odvolání souhlasu body neodebírá. Opětovné udělení souhlasu body znovu nepřipíše. Smazání údajů o vozidle body neodebírá.
- **BR-34 [P]** Body za aktivity nejsou ovlivněny kampaněmi ani úrovní. Hodnoty bodů za aktivity jsou konfigurovatelné.
### 4.5 Bodový účet

- **BR-40 [T]** Každá změna zůstatku je **pohyb bodů**. Pohyby se nemažou ani needitují. Oprava = nový opravný pohyb.
- **BR-41 [P]** Typy pohybů: `Transakce` (základní body), `Kampaň` (bonus, s odkazem na kampaň), `Aktivita`, `Uplatnění odměny` (záporný), `Ruční úprava` (±, bonus), `Storno` (±, COULD), `Expirace` (záporný, bonus).
- **BR-42 [P]** Zůstatek = součet všech pohybů člena. Zůstatek nikdy neklesne pod 0 v důsledku uplatnění odměny nebo ruční úpravy.
- **BR-43 [Z]** Body za transakci se připisují okamžitě po zpracování transakce. Datum pohybu = datum nákupu (kvůli správným trendům v reportu).
### 4.6 Odměny a vouchery

- **BR-50 [Z]** Program má jednoho partnera: autoservis **EneServis, s.r.o.** Katalog:
| Odměna | Cena | Nominální hodnota (pro report) |
| --- | --- | --- |
| Sleva 200 Kč na přezutí | 500 bodů | 200 Kč |
| Sleva 500 Kč na servis | 1 200 bodů | 500 Kč |
| Servisní prohlídka zdarma | 5 000 bodů | k potvrzení, návrh 2 000 Kč [P] |

- **BR-51 [Z]** Bez dostatečného zůstatku nelze voucher uplatnit.
- **BR-52 [Z]** Body se odečtou okamžitě při uplatnění.
- **BR-53 [Z]** Při uplatnění se vygeneruje unikátní kód voucheru. Člen ho uvidí v portálu a zároveň mu přijde e-mailem. V servisu kód nadiktuje.
- **BR-54 [Z]** Voucher nemá omezenou platnost.
- **BR-55 [T] Atomicita:** odečtení bodů a vytvoření voucheru proběhne celé, nebo vůbec. Při chybě zůstanou body členovi. Dvojí odeslání požadavku (dvojklik, obnovení stránky) nevytvoří dva vouchery.
- **BR-56 [P] Formát kódu:** `ENE-XXXX-XXXX`, znaky A–Z a 2–9 bez O, I, L, 0, 1 (31 znaků, cca 8,5 × 10¹¹ kombinací). Kód je náhodný (ne sekvenční), unikátní v celé databázi, dá se nadiktovat po telefonu.
- **BR-57 [P] Stavy voucheru:** `Vydaný` → `Uplatněný` (v servisu). `Zrušený` jen z back-office s povinným důvodem, body se vrátí opravným pohybem.
- **BR-58 [P]** Cena v bodech, nominální hodnota, aktivní/neaktivní a pořadí odměn jsou konfigurovatelné loyalty manažerem. Změna ceny neovlivní již vydané vouchery.
### 4.7 Bonusová pravidla (COULD)

- **BR-60 [Z][P] Úrovně Okreska / Dálnice:**
  - Každý nový člen je **Okreska**.
  - Qualifying body = body z transakcí (základ + kampaně) za klouzavých 12 měsíců. Body za aktivity a ruční úpravy se nezapočítávají.
  - Postup na **Dálnici** ihned po dosažení prahu (parametr, návrh 2 000 qualifying bodů).
  - Benefit Dálnice: body za palivo × 1,2 (parametr), tj. `bonus_uroven = floor(body_palivo × 1,2) − body_palivo`. Samostatný řádek v rozpisu transakce. Nenásobí se kampaněmi.
  - Sestup: vyhodnocení 1× měsíčně. Sestup jen pokud qualifying body za posledních 12 měsíců klesnou pod práh.
  - **Žádný reset směnitelných bodů** při změně úrovně (poučení z MOL Move, kde roční reset úrovně a bodů je nejčastější kritikou v recenzích).
  - Qualifying body se uplatněním odměny nesnižují.
- **BR-61 [Z][T] Expirace bodů:**
  - Platnost bodů je přesně 1 rok od připsání. Body připsané dne D propadnou dne D + 1 rok (29. 2. → 28. 2.) [P].
  - Expirace se eviduje po jednotlivých přídělech (pohybech s kladnými body).
  - Uplatnění odměny spotřebovává nejdříve expirující body (FIFO).
  - Denní dávka odebere neuplatněný zbytek prošlých přídělů pohybem typu `Expirace`.
  - Expirace musí být vidět konkrétně: počet bodů a datum (poučení ze Shell ClubSmart, kde chybějící ukazatel expirace je častá výtka).
- **BR-62 [Z] Ruční úprava bodů:** přidání i odebrání bodů konkrétnímu členovi přes UI Salesforce. Povinný důvod a komentář, evidovaný autor. Odebrání max. do výše zůstatku.
### 4.8 Pořadí výpočtu jedné transakce

1. Validace (BR-04, BR-05) a kontrola duplicity (BR-06).
2. Body za palivo a za ostatní (BR-10, BR-11) → základní body (BR-12).
3. Načtení kampaní platných v čase nákupu (BR-27).
4. Pro každou kampaň vyhodnocení podmínky a výpočet bonusu ze základních bodů (BR-23 až BR-26).
5. (COULD) Bonus z úrovně Dálnice (BR-60).
6. Zápis pohybů: 1× `Transakce` (základ) + 1× `Kampaň` za každou uplatněnou kampaň (+ 1× úroveň). Uložení rozpisu na transakci.
7. (COULD) Aktualizace qualifying bodů a úrovně.
### 4.9 Referenční příklady výpočtu (testovací scénáře)

Předpoklad: aktivní obě výchozí kampaně, člen na úrovni Okreska. Všechny výsledky ověřeny výpočtem.

| ID | Litry | Palivo Kč | Ostatní Kč | Celkem Kč | Body palivo | Body ostatní | Zastávka na cestě | Natankuj plnou | **Celkem** | Co testuje |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| T01 | 45 | 1 710 | 180 | 1 890 | 45 | 9 | +5 (54 × 1,1 = 59,4 → 59) | +50 | **109** | Příklad ze zadání |
| T02 | 30,5 | 1 159 | 0 | 1 159 | 30 | 0 | 0 | 0 | **30** | Jen palivo, desetinné litry |
| T03 | 0 | 0 | 149 | 149 | 0 | 7 | 0 (pod prahem) | 0 | **7** | Jen pokladna, těsně pod prahem |
| T04 | 0 | 0 | 150 | 150 | 0 | 7 | +0 (7 × 1,1 = 7,7 → 7) | 0 | **7** | Podmínka splněna, bonus 0 |
| T05 | 40,00 | 1 520 | 0 | 1 520 | 40 | 0 | 0 | +50 | **90** | Hranice 40 l |
| T06 | 39,99 | 1 519,62 | 0 | 1 519,62 | 39 | 0 | 0 | 0 | **39** | Těsně pod 40 l |
| T07 | 60 | 2 280 | 300 | 2 580 | 60 | 15 | +7 (75 × 1,1 = 82,5 → 82) | +50 | **132** | Obě kampaně |
| T08 | 0 | 0 | 19,99 | 19,99 | 0 | 0 | 0 | 0 | **0** | Pod 20 Kč |
| T09 | 0 | 0 | 1 000 | 1 000 | 0 | 50 | +5 | 0 | **55** | Jen pokladna s kampaní |
| T10 | 52,8 | 2 006,40 | 155 | 2 161,40 | 52 | 7 | +5 (59 × 1,1 = 64,9 → 64) | +50 | **114** | Desetinné litry i haléře |

Negativní a hraniční scénáře:

| ID | Vstup | Očekávaný výsledek |
| --- | --- | --- |
| T20 | Palivo 1 000 + ostatní 100 ≠ celkem 1 050 | Transakce odmítnuta, chyba v logu, žádné body |
| T21 | Druhý import transakce se stejným ID | Žádné nové pohyby, zůstatek beze změny |
| T22 | Transakce T01 s datem nákupu mimo platnost obou kampaní | 54 bodů (jen základ) |
| T23 | Transakce s neexistujícím číslem člena | Odmítnuta, chyba v logu |
| T24 | Kampaň „Natankuj plnou“ deaktivována, pak import T05 | 40 bodů |
| T25 | Hromadný import 5 000 transakcí najednou | Všechny zpracovány, bez chyby limitů platformy, součty sedí |
| T26 | Člen s 740 body uplatní „Sleva 200 Kč na přezutí“ | Zůstatek 240, voucher `Vydaný`, e-mail odeslán |
| T27 | Člen s 499 body otevře odměnu za 500 bodů | Tlačítko neaktivní, text „Chybí ti 1 bod“ |
| T28 | Dvojklik na „Uplatnit za 500 bodů“ | Vznikne jeden voucher a jeden záporný pohyb |
| T29 | Člen udělí souhlas, odvolá ho a znovu udělí | Celkem +50 bodů jednou |

---

## 5. Konceptuální datový model

Model je funkční, ne technický. Konkrétní objekty, typy vazeb a pojmenování API rozhodne solution design.

| Entita | Klíčové atributy | Vazby | Poznámka k realizaci (nezávazně) |
| --- | --- | --- | --- |
| **Člen Klubu** | číslo člena (unikátní), stav (Aktivní / Blokovaný / Zrušený), datum registrace, zdroj registrace, zůstatek, celkem připsáno, celkem uplatněno, údaje o vozidle (značka, model, druh paliva, rok výroby, SPZ), datum dokončení profilu, marketingový souhlas (ano/ne, datum udělení, datum odvolání, verze textu), úroveň a qualifying body (bonus) | 1 : 1 Kontakt / uživatel portálu | Samostatný objekt Člen jako master pro pohyby bodů → zůstatek jako roll-up summary. Person Account, nebo Kontakt pod sběrným Accountem: rozhodnout v designu |
| **Transakce** | ID z pokladny (External ID, unikátní), datum a čas nákupu, stanice, celková částka, palivo Kč, litry, ostatní Kč, body za palivo, body za ostatní, základní body, bonus z kampaní, body celkem, stav zpracování (Zpracováno / Chyba / Stornováno), chybová zpráva | N : 1 Člen | Výpočet v triggeru / record-triggered flow při insertu, hromadně (bulk-safe) |
| **Pohyb bodů** | typ (BR-41), body (±), datum pohybu, popis pro člena, odkaz na transakci / kampaň / aktivitu / voucher, důvod a komentář (ruční úprava), autor, datum expirace a zbývající body přídělu (bonus) | N : 1 Člen (master-detail) | Neměnný záznam: bez editace a mazání pro všechny role kromě administrátora |
| **Kampaň** | název, popis pro člena, stav (Koncept / Aktivní / Ukončená), platnost od, platnost do, měřená veličina, operátor, práh, typ odměny, hodnota (body nebo koeficient), pořadí zobrazení | 1 : N Pohyb bodů | Vlastní objekt, nebo standardní Campaign s vlastními poli |
| **Aktivita** | kód (PROFIL, SOUHLAS, příp. REGISTRACE), název, body, jednorázová, aktivní | 1 : N Pohyb bodů | Jednorázovost hlídat unikátním klíčem člen + aktivita |
| **Odměna** | název, partner, cena v bodech, nominální hodnota Kč, popis, aktivní, pořadí, roční rozpočet Kč (SHOULD) | N : 1 Partner | |
| **Partner** | název, typ (autoservis), kontakt | 1 : N Odměna | Account s typem Partner |
| **Voucher** | kód (unikátní), stav, datum vydání, datum uplatnění, kdo uplatnil, body, nominální hodnota (kopie v okamžiku vydání), datum odeslání e-mailu | N : 1 Člen, N : 1 Odměna, 1 : 1 Pohyb bodů | |
| **Stanice** | název („EneOil Praha – Chodov“), město, kraj | 1 : N Transakce | SHOULD, umožní report podle stanic |
| **Parametry programu** | body za litr, Kč za bod (ostatní), body za aktivity, prahy a koeficienty úrovní, délka platnosti bodů | | Custom Metadata nebo Custom Settings |
| **Úroveň** (bonus) | název (Okreska / Dálnice), práh qualifying bodů, koeficient na body za palivo | | Custom Metadata |

---

## 6. Funkční požadavky podle epiků

Přehled epiků:

| Epik | Název | Komponenta | Nejvyšší priorita |
| --- | --- | --- | --- |
| E1 | Členství a identita | Experience + Sales Cloud | MUST |
| E2 | Transakce a výpočet bodů | Sales Cloud | MUST |
| E3 | Kampaně | Sales Cloud + portál | MUST |
| E4 | Body za aktivity v portálu | Experience Cloud | MUST |
| E5 | Bodový účet a historie | Sales Cloud + portál | MUST |
| E6 | Katalog odměn a vouchery | Sales Cloud + portál + e-mail | MUST |
| E7 | Členský portál: rámec a přehled | Experience Cloud | MUST |
| E8 | Back-office loyalty manažera | Sales Cloud | MUST |
| E9 | Manažerský report | Claude artifact | MUST |
| E10 | Bonusy ze zadání | vše | COULD |
| E11 | Roadmapa (fáze 2) | | WON'T (teď) |

### E1 Členství a identita

#### FR-E1-01 Registrace člena v portálu [MUST]
Zdroj: zadání (přihlášený člen v portálu), trh #1, recenze (registrace a přihlášení patří k nejčastějším výtkám napříč aplikacemi: OMV, Shell, MOL, Circle K, TotalEnergies).
- Návštěvník se zaregistruje: jméno, příjmení, e-mail, heslo, souhlas s podmínkami programu (povinný), souhlas s marketingovou komunikací (volitelný, samostatné zaškrtávátko).
- Po ověření e-mailu vznikne Člen Klubu: stav Aktivní, unikátní číslo člena, datum registrace, úroveň Okreska (pokud je E10 v rozsahu).
- Pokud návštěvník udělí marketingový souhlas už při registraci, připíše se +50 bodů (BR-31).
- **AC:**
  - Registrace má maximálně jednu obrazovku s formulářem a jednu s potvrzením e-mailu.
  - E-mail, který už v Klubu existuje, nevytvoří druhého člena (srozumitelná hláška a odkaz na obnovu hesla).
  - Souhlas s podmínkami a marketingový souhlas jsou dvě různá pole s vlastním datem udělení.
  - Nepovinné údaje (telefon, adresa, datum narození) se při registraci nevyžadují.
#### FR-E1-02 Přihlášení a obnova hesla [MUST]
- Člen se přihlásí e-mailem a heslem, může si obnovit heslo.
- **AC:** Odkaz pro obnovu hesla dorazí do 2 minut. Po přihlášení se člen dostane na Přehled (FR-E7-02).
- SHOULD: relace zůstává platná (člen není odhlášen při každém otevření, poučení z recenzí Shell a MOL, kde odhlášení „těsně před pokladnou“ patří k nejčastějším výtkám).
#### FR-E1-03 Číslo člena [MUST]
- Při vzniku člena se automaticky vygeneruje unikátní číslo člena (např. 9 číslic). Číslo slouží jako identifikátor v transakcích z pokladny (BR-03).
- **AC:** Číslo je neměnné, unikátní, viditelné v portálu i v back-office. Neobsahuje osobní údaje.
#### FR-E1-04 Digitální členská karta [SHOULD]
Zdroj: trh #2 (ORLEN „Moje ID“ s QR, MOL Move a OMV čárový kód); recenze: digitální karta je chválená u MOL, OMV, Shell i Circle K („lepší než plastová“).
- V portálu je stránka Členská karta: QR kód s číslem člena, číslo člena čitelně jako text, jméno, logo EneOil Klub, úroveň (bonus), text „Ukaž před zaplacením“.
- **AC:**
  - Karta je dostupná jedním klepnutím z hlavní navigace i z Přehledu.
  - QR obsahuje pouze číslo člena.
  - Na šířce 360 px je QR alespoň 200 × 200 px.
- Realizace (nezávazně): QR generovat v LWC z knihovny ve statickém zdroji.
#### FR-E1-05 Profil člena [MUST]
- Člen vidí a upraví osobní údaje, údaje o vozidle (BR-32) a souhlasy. Úprava vozidla je zároveň aktivita z E4.
- **AC:** E-mail (přihlašovací jméno) se mění jen přes ověřený proces platformy, ne volným polem.
#### FR-E1-06 Stav člena a blokace [SHOULD]
- Loyalty manažer může člena zablokovat a odblokovat (s důvodem).
- **AC:** Zablokovanému členovi se nepřipisují body (BR-05) a nemůže uplatnit odměnu. V portálu vidí srozumitelnou informaci a kontakt na podporu.
#### FR-E1-07 Založení člena z back-office [SHOULD]
- Loyalty manažer založí člena ručně (např. pro demo nebo zákaznickou linku) a odešle mu pozvánku do portálu.
### E2 Transakce a výpočet bodů

#### FR-E2-01 Import transakcí ze souboru [MUST]
Zdroj: zadání §3.
- Loyalty manažer nebo administrátor nahraje CSV s transakcemi (atributy BR-02, BR-03).
- **AC:**
  - Po importu má každá validní transakce stav Zpracováno a vypočtené body.
  - Nevalidní transakce má stav Chyba a čitelnou chybovou zprávu.
  - Funguje hromadně (T25).
  - Vzorový CSV soubor s hlavičkou je součástí dokumentace.
#### FR-E2-02 Ruční zadání transakce (simulace pokladny) [MUST]
Zdroj: zadání §3.
- Loyalty manažer zadá jednu transakci přes UI (formulář / screen flow) nebo přes konzoli.
- **AC:** Výsledek výpočtu je stejný jako při importu (BR-07). Po uložení uživatel vidí rozpis bodů.
- SHOULD: demo tlačítko „Simulovat nákup“ na záznamu člena předvyplní číslo člena a aktuální čas.
#### FR-E2-03 Výpočet základních bodů [MUST]
- Implementuje BR-10 až BR-14.
- **AC:** Scénáře T01 až T10 dávají přesně uvedené hodnoty ve sloupcích Body palivo a Body ostatní.
#### FR-E2-04 Validace a idempotence [MUST]
- Implementuje BR-04 až BR-06.
- **AC:** Scénáře T20, T21, T23.
#### FR-E2-05 Rozpis bodů na transakci [MUST]
- Na záznamu transakce jsou uložena pole: body za palivo, body za ostatní, základní body, bonus z kampaní, body celkem a seznam uplatněných kampaní (přes pohyby typu Kampaň).
- **AC:** Součet pohybů navázaných na transakci = body celkem.
#### FR-E2-06 Storno transakce [COULD]
Zdroj: trh #3 („storno vytvoří opravný pohyb, nikoli přepis historie“).
- Loyalty manažer stornuje transakci. Vznikne opravný pohyb, který odečte přesně body připsané touto transakcí (základ i bonusy kampaní).
- **AC:**
  - Transakce má stav Stornováno a nelze ji stornovat dvakrát.
  - Pokud zůstatek nestačí, storno se neprovede a uživatel dostane hlášku s doporučením ruční úpravy.
### E3 Kampaně

#### FR-E3-01 Správa kampaní v back-office [MUST]
Zdroj: zadání §4.
- Loyalty manažer vytvoří, upraví, aktivuje a ukončí kampaň (atributy podle kapitoly 5, pravidla BR-21 až BR-23).
- **AC:**
  - Kampaně „Natankuj plnou“ a „Zastávka na cestě“ lze vytvořit čistě konfigurací, bez nasazení kódu.
  - Validace: platnost od < platnost do; práh > 0; pevný bonus > 0; koeficient > 1.
  - Kampaň, která už byla uplatněna, nelze smazat, jen ukončit.
#### FR-E3-02 Vyhodnocení kampaní při zpracování transakce [MUST]
- Implementuje BR-24 až BR-28 a pořadí výpočtu 4.8.
- **AC:** Scénáře T01 až T10, T22, T24. Pro každou uplatněnou kampaň vznikne samostatný pohyb typu Kampaň s odkazem na kampaň.
#### FR-E3-03 Klonování kampaně [SHOULD]
Zdroj: zadání (marketing chce vědět, které kampaně opakovat).
- Akce „Zopakovat kampaň“ vytvoří kopii ve stavu Koncept s prázdným obdobím platnosti.
- **AC:** Kopie má stejnou podmínku a odměnu, nové ID a odkaz na původní kampaň (pro srovnání v reportu).
#### FR-E3-04 Akce v portálu [MUST]
Zdroj: zadání (přehled aktivních kampaní); recenze OMV: slevy platí jen na některých stanicích a zákazník to zjistí až na místě.
- Stránka Akce a karty na Přehledu zobrazují aktivní kampaně platné dnes: název, lidsky napsaná podmínka a odměna (popis pro člena), platnost do, štítek „Platí na všech stanicích EneOil“.
- **AC:**
  - Ukončené kampaně a kampaně v konceptu se nezobrazují.
  - Texty odpovídají brand kitu, např. „Natankuj aspoň 40 l a dostaneš +50 bodů navíc.“
- COULD: sekce „Připravujeme“ pro kampaně s budoucí platností.
### E4 Body za aktivity v portálu

#### FR-E4-01 Přehled aktivit „Získej body“ [MUST]
Zdroj: zadání (aktivity, za které může člen v portálu získat body).
- Stránka (nebo sekce Přehledu) se seznamem aktivit: název, počet bodů, stav (Nesplněno / Hotovo, datum).
- **AC:** Splněná aktivita ukazuje „Hotovo. 100 bodů je na tvém účtu.“ a nenabízí se znovu.
#### FR-E4-02 Dokončení profilu (vozidlo) +100 [MUST]
- Implementuje BR-30, BR-32, BR-33.
- **AC:** Po prvním uložení všech povinných polí vozidla vznikne pohyb +100 typu Aktivita. Další úpravy vozidla body nepřidají.
#### FR-E4-03 Marketingový souhlas +50 [MUST]
- Implementuje BR-31, BR-33. Souhlas lze udělit i odvolat v profilu, evidují se data udělení a odvolání.
- **AC:** Scénář T29.
#### FR-E4-04 Uvítací bonus [COULD]
Zdroj: OMV (100 bodů po první transakci), Shell (250 bodů), v recenzích chválené.
- Konfigurovatelná aktivita „Registrace“ nebo „První tankování“ s počtem bodů (parametr, výchozí 0 = vypnuto).
### E5 Bodový účet a historie

#### FR-E5-01 Evidence pohybů a zůstatku [MUST]
- Implementuje BR-40 až BR-43.
- **AC:**
  - Zůstatek se po každé operaci rovná součtu pohybů.
  - Pohyb nelze upravit ani smazat (ani loyalty manažerem).
  - Každý pohyb má autora a čas vytvoření.
#### FR-E5-02 Zůstatek a historie bodů v portálu [MUST]
Zdroj: zadání (zůstatek a historie pohybů bodů).
- Velký zůstatek (Noto Sans Mono) a chronologická historie: datum, popis, body (+ zeleně, − tmavě, expirace červeně podle brand kitu).
- Řádek transakce je jeden (seskupený): „6. 11. 2026 · Tankování 45 l + nákup 180 Kč · +109“.
- **AC:**
  - Nejnovější nahoře, stránkování nebo „Načíst další“ po 20 řádcích.
  - Prázdný stav: „Zatím tu nic není. První body přibudou s prvním tankováním.“
- SHOULD: filtr podle typu (Získané / Uplatněné) a období.
#### FR-E5-03 Detail transakce s rozpisem bodů [SHOULD]
Zdroj: trh #3 (rozpad základ/bonus); recenze OMV: uživatelé vidí jen počet bodů a chtějí litry, cenu a rozpis.
- Po klepnutí na řádek transakce: datum a čas, stanice, litry, palivo Kč, ostatní Kč, celkem Kč a rozpis bodů ve stejném pořadí jako výpočet:
```
Palivo 45 l ............... 45
Nákup na pokladně 180 Kč ... 9
Zastávka na cestě (×1,1) .. +5
Natankuj plnou ........... +50
Celkem .................. 109 bodů
```

- **AC:** Rozpis odpovídá pohybům v databázi. Uplatněné kampaně jsou pojmenované.
- COULD: u nesplněné kampaně vysvětlení, např. „Zastávka na cestě: nákup 120 Kč z potřebných 150 Kč“ (trh #11: „uvést, proč se nákup započítal nebo nezapočítal“).
### E6 Katalog odměn a vouchery

#### FR-E6-01 Katalog odměn v portálu [MUST]
Zdroj: zadání §5; trh #9; recenze OMV: katalog bez bodových hodnot je kritizován.
- Karty odměn: logo EneServis, název, cena v bodech, tlačítko „Uplatnit za 500 bodů“.
- Pokud zůstatek nestačí, tlačítko je neaktivní a pod ním „Chybí ti 260 bodů“ (není to chyba).
- **AC:**
  - Zobrazují se jen aktivní odměny v nastaveném pořadí.
  - Scénář T27 (včetně správného skloňování „1 bod“, „2 body“, „5 bodů“).
- SHOULD: přepínač „Mám dost bodů“.
#### FR-E6-02 Uplatnění odměny [MUST]
- Potvrzovací krok: „Uplatnit Slevu 200 Kč na přezutí za 500 bodů? Body se odečtou hned.“ a zůstatek po uplatnění (trh #9: ukázat zůstatek po směně před potvrzením).
- Po potvrzení proběhne BR-51 až BR-56 na serveru.
- Úspěch: „Voucher je tvůj. Kód: ENE-7KQ4-M2XD. Poslali jsme ti ho i e-mailem. V servisu EneServis ho stačí nadiktovat.“
- **AC:**
  - Scénáře T26, T28.
  - Při technické chybě: „Uplatnění se nepovedlo a body ti zůstaly. Zkus to prosím znovu za chvíli.“ a zůstatek se nezmění.
  - Zůstatek se kontroluje na serveru, ne jen v prohlížeči.
#### FR-E6-03 Generování kódu voucheru [MUST]
- Implementuje BR-56.
- **AC:** 10 000 vygenerovaných kódů v testu je unikátních a odpovídá formátu. Kód neobsahuje znaky O, I, L, 0, 1.
#### FR-E6-04 E-mail s voucherem [MUST]
Zdroj: zadání §5.
- Okamžitě po uplatnění odejde e-mail podle brand kitu: předmět „Tvůj voucher: ‹odměna›“, preheader, nadpis „Voucher je tvůj“, box s kódem, zbývající zůstatek, tlačítko „Zobrazit v Klubu“.
- **AC:**
  - E-mail přijde do 2 minut a obsahuje stejný kód jako portál.
  - Datum odeslání se uloží na voucher.
  - Logo je na veřejné URL.
#### FR-E6-05 Moje vouchery v portálu [MUST]
- Seznam vydaných voucherů: odměna, kód (mono písmo), stav (Vydaný / Uplatněný), datum vydání, „Platnost: bez omezení“.
- **AC:** Nově vydaný voucher je v seznamu ihned po uplatnění. SHOULD: tlačítko „Zkopírovat kód“.
#### FR-E6-06 Ověření a uplatnění voucheru v servisu [SHOULD]
Zdroj: zadání (kód se v servisu diktuje); trh #8 (stavový model kuponu, server musí odmítnout dvojí použití); recenze MOL a Circle K: obsluha nedokáže kupon uplatnit.
- Operátor EneServis zadá nadiktovaný kód a vidí: odměnu, stav, jméno člena, datum vydání. Tlačítkem „Označit jako uplatněný“ změní stav.
- **AC:**
  - Kód ve stavu Uplatněný nebo Zrušený nelze uplatnit znovu (srozumitelná hláška s datem uplatnění).
  - Vyhledání toleruje malá písmena a chybějící pomlčky.
- Realizace (nezávazně): screen flow v Lightning App pro roli Operátor.
#### FR-E6-07 Zrušení voucheru [COULD]
- Loyalty manažer zruší voucher ve stavu Vydaný s povinným důvodem. Body se vrátí opravným pohybem (BR-57).
### E7 Členský portál: rámec a přehled

#### FR-E7-01 Struktura a navigace portálu [MUST]
- Stránky: Přehled, Historie bodů, Akce, Získej body, Odměny, Moje vouchery, Členská karta (SHOULD), Profil.
- **AC:**
  - Na mobilu (šířka 360 px) je navigace dostupná bez horizontálního posunu.
  - Členská karta a zůstatek jsou na jedno klepnutí.
  - Nepřihlášený návštěvník vidí jen úvodní stránku s registrací a přihlášením.
#### FR-E7-02 Přehled (dashboard) [MUST]
Zdroj: zadání; brand kit (hotové texty); trh #4 a #9.
- Obsah:
  - pozdrav a zůstatek („Ahoj, Jano. Máš 1 240 bodů.“),
  - SHOULD: progress k nejbližší dosud nedosažené odměně („Do servisní prohlídky zdarma ti chybí 3 760 bodů“), motiv plnění nádrže,
  - poslední 3 pohyby s odkazem do historie,
  - karty aktivních akcí,
  - nesplněné aktivity s počtem bodů,
  - (COULD) úroveň a nejbližší expirace.
- **AC:** Údaje odpovídají databázi v okamžiku načtení. Při otevření se nezobrazuje žádné vyskakovací okno ani reklama (NFR-07).
#### FR-E7-03 Přehled úspor [COULD]
Zdroj: trh #24 (Exxon „sledování úspor“, ORLEN měsíční přehled).
- „Díky Klubu jsi ušetřil 700 Kč“: součet nominálních hodnot uplatněných voucherů.
#### FR-E7-04 Brand a texty [MUST]
- Portál používá tokeny, písma a texty z `brand/eneoil-brand-kit.md` (tykání, sentence case, formát čísel `1 240 bodů`, `+109`, `−500`).
- **AC:** Žádný natvrdo zadaný hex kód v komponentách mimo definici tokenů.
### E8 Back-office loyalty manažera

#### FR-E8-01 Lightning App „EneOil Klub“ [MUST]
- Aplikace s navigací: Členové, Transakce, Pohyby bodů, Kampaně, Odměny, Vouchery, Stanice (SHOULD), Reporty.
- **AC:** Loyalty manažer najde všechny objekty programu v jedné aplikaci. Back-office texty jsou věcné, bez tykání.
#### FR-E8-02 Karta člena (360°) [MUST]
- Na záznamu člena: zůstatek, celkem připsáno a uplatněno, transakce, pohyby bodů, vouchery, splněné aktivity, souhlasy, údaje o vozidle, (COULD) úroveň a expirace.
- **AC:** Loyalty manažer odpoví na reklamaci „proč nemám body za tankování“ bez opuštění záznamu člena.
#### FR-E8-03 Správa katalogu odměn [MUST]
- CRUD odměn podle BR-58 včetně nominální hodnoty. SHOULD: roční rozpočet na odměnu.
- **AC:** Deaktivovaná odměna zmizí z portálu, vydané vouchery zůstávají platné.
#### FR-E8-04 Ruční úprava bodů [SHOULD, bonus ze zadání]
Zdroj: zadání (bonus); recenze Shell a Circle K: „body se nenačítají“, „nákupy se nepočítají“. Podpora potřebuje nástroj na nápravu.
- Akce na členovi: typ (Přidat / Odebrat), počet bodů, důvod (Reklamace chybějících bodů / Goodwill / Oprava chyby / Jiné), komentář.
- **AC:**
  - Vznikne pohyb typu Ruční úprava s autorem a důvodem (BR-62).
  - Odebrání nad zůstatek je odmítnuto.
  - Akci smí provést jen role Loyalty manažer.
#### FR-E8-05 Seznamy a přehledy pro každodenní práci [SHOULD]
- List views: Nové registrace tento týden, Transakce s chybou, Vydané vouchery k uplatnění, Aktivní kampaně.
- Standardní Salesforce reporty a dashboard jako záloha k artifactu (stejné KPI definice jako E9).
#### FR-E8-06 Role a oprávnění [MUST]
- Permission sets: Loyalty manažer (plný přístup k programu), Operátor EneServis (jen vyhledání a uplatnění voucheru), Reporting (jen čtení pro report), Člen (portál, jen vlastní data).
- **AC:** Operátor nevidí zůstatek ani historii člena, jen voucher.
### E9 Manažerský report (Claude artifact)

Zdroj: zadání §6 (persona Petra Králová) a brand kit („Manažerský report“).

#### FR-E9-01 Napojení na Salesforce [MUST]
- Report čte data ze Salesforce (dotazem přes API nebo konektor při otevření nebo obnovení), ne z ručně vloženého exportu.
- **AC:**
  - Report ukazuje čas poslední aktualizace dat.
  - Po importu nových transakcí a obnovení reportu se čísla změní.
  - Přístup k datům má jen čtecí oprávnění (role Reporting).
#### FR-E9-02 Přehled programu (KPI) [MUST]
Jednotné názvy KPI (brand kit). Filtr období (měsíc, kvartál, rok, vlastní) a srovnání s předchozím obdobím.

| KPI | Definice |
| --- | --- |
| Členové celkem | Počet členů ve stavu Aktivní k poslednímu dni období |
| Nové registrace | Počet členů s datem registrace v období, trend po týdnech nebo měsících |
| Aktivní členové (SHOULD) | Členové s alespoň 1 transakcí za posledních 90 dní, podíl z celku |
| Připsané body | Součet kladných pohybů v období, rozpad podle zdroje: palivo, pokladna, kampaně (po kampaních), aktivity, ruční úpravy |
| Uplatněné body | Součet pohybů typu Uplatnění odměny v období (absolutní hodnota) |
| **Míra čerpání (%)** | Uplatněné body / připsané body. Za období a kumulativně od startu programu |
| Nevyčerpaný zůstatek | Součet zůstatků všech členů v bodech a odhad v Kč (× průměrná hodnota bodu z katalogu) |
| Vydané vouchery podle odměny | Počet, body, nominální hodnota v Kč, podíl uplatněných v servisu |
| Body z kampaní | Viz FR-E9-04 |

- **AC:** Každé číslo v reportu lze dohledat standardním Salesforce reportem nebo SOQL dotazem se stejnou definicí (uvést v dokumentaci).
#### FR-E9-03 Rozpočet partnerských voucherů [MUST]
Zdroj: zadání („Petra hlídá rozpočet na partnerské vouchery“).
- Nominální hodnota vydaných voucherů v Kč za období podle odměny, kumulativně za rok, a SHOULD srovnání s ročním rozpočtem (čerpání v %, trend, odhad na konec roku).
- **AC:** Pro „Sleva 200 Kč na přezutí“ platí: počet vydaných × 200 Kč = zobrazená hodnota.
#### FR-E9-04 Účinnost kampaní [MUST]
Zdroj: zadání („Marketing chce vědět, které kampaně opakovat“).
- Pro každou kampaň: období, počet transakcí se splněnou podmínkou, podíl ze všech transakcí členů v období, počet unikátních členů, bonusové body celkem, odhad nákladu v Kč (body × průměrná hodnota bodu), průměrná hodnota transakce se splněnou podmínkou vs. ostatní transakce.
- Srovnání opakovaných kampaní (přes vazbu z FR-E3-03).
- **AC:** Report výslovně uvádí, že srovnání hodnoty transakcí je orientační (bez kontrolní skupiny a bez dat o prodejích mimo Klub).
#### FR-E9-05 Odpověď pro finančního ředitele [MUST]
Zdroj: zadání („kolik % bodů se průměrně vyčerpá a jak nastavit budgety na příští rok“).
- Panel: průměrná míra čerpání, průměrná hodnota bodu v Kč (vážená podle skutečně uplatněných odměn), projekce nákladu na vouchery na příští rok:
  `průměrné měsíční připsané body × 12 × míra čerpání × hodnota bodu`.
- SHOULD: tři scénáře (nízká, očekávaná a vysoká míra čerpání) nebo posuvník pro míru čerpání a růst členské základny.
- **AC:** Vzorec a vstupní předpoklady jsou v reportu vidět, ne jen výsledek.
#### FR-E9-06 Aktivity a zapojení [SHOULD]
- Podíl členů s dokončeným profilem a s marketingovým souhlasem, body za aktivity.
#### FR-E9-07 Vzhled a jazyk [MUST]
- Brand kit, kapitola „Manažerský report“: logo EneOil Klub, věcný jazyk bez tykání, řada 1 `ene-green`, řada 2 `brand`, řada 3 `steel`, připsané body `plus`, expirované `minus`, čísla Noto Sans Mono a `tabular-nums`.
- **AC:** Report je čitelný na notebooku i na tabletu, bez horizontálního posunu.
#### FR-E9-08 Bonusové metriky [COULD]
- Pokud je v rozsahu E10: expirované body po měsících, breakage (expirované / připsané), členové podle úrovně, přechody mezi úrovněmi.
### E10 Bonusy ze zadání [COULD]

Pořadí doporučené podle poměru hodnoty a pracnosti: **ruční úprava bodů** (už v E8 jako SHOULD) → **voucher jako PDF/obrázek** → **expirace** → **úrovně**.

#### FR-E10-01 Voucher jako obrázek nebo PDF [COULD]
- Při vydání voucheru se vygeneruje PDF nebo obrázek s kódem podle brand kitu (1 200 × 600 px nebo A6, pruh `brand` se značkou, kód mono 40 px, „Uplatníš v: EneServis“, „Platnost: bez omezení“, datum vystavení, perforace).
- **AC:** Soubor je ke stažení v Moje vouchery a přiložen k e-mailu. Kód v souboru = kód v databázi.
#### FR-E10-02 Expirace bodů [COULD]
- Implementuje BR-61.
- Portál: „120 bodů ti propadne 1. 12. 2026.“ na Přehledu a v Historii. SHOULD v rámci epiku: e-mail 30 dní před expirací.
- Report: FR-E9-08.
- **AC:**
  - Člen s přídělem 100 bodů (1. 1. 2026) a 50 bodů (1. 3. 2026), který 1. 2. 2026 uplatní 80 bodů, přijde 1. 1. 2027 o 20 bodů a 1. 3. 2027 o 50 bodů.
  - Dávka spuštěná dvakrát v jeden den neodebere body dvakrát.
#### FR-E10-03 Úrovně členství Okreska / Dálnice [COULD]
- Implementuje BR-60.
- Portál: barevná karta úrovně, progress bar „Do Dálnice ti chybí 420 bodů“, datum hodnocení, oddělené „postup výš“ a „udržení úrovně“ (trh #5). Text: „Jsi na Dálnici. Za každé tankování máš body navíc.“
- **AC:**
  - Člen na Dálnici s transakcí T01 dostane 109 + 9 bodů (floor(45 × 1,2) − 45 = 9), celkem 118.
  - Změna úrovně nezmění zůstatek směnitelných bodů.
### E11 Roadmapa (WON'T teď, do SteerCo jako fáze 2)

Funkce s doloženým úspěchem na trhu, které nejsou v rozsahu hackathonu, protože vyžadují data nebo integrace, které nemáme (položky nákupu, ceny paliv, platební brána), nebo mají vysokou pracnost.

| Funkce | Důkaz z trhu a recenzí | Proč ne teď |
| --- | --- | --- |
| Odměna „Káva za body“ a razítková karta na kávu | Káva je nejčastěji chválená odměna (MOL Move, Shell Café, Circle K); trh #10 | Vyžaduje položky transakce (zadání je zakazuje) a druhý typ odměny mimo EneServis |
| Ceny paliv a vyhledávač stanic s filtry | Nejčastější přání uživatelů MOL, OMV, Shell; trh #16 až #19 | Mimo věrnostní program, potřebuje zdroj cen |
| Výzvy a mise (např. 3 návštěvy za měsíc → bonus) | Circle K Inner Circle, trh #11 | Rozšíření kampaňového enginu o čítače návštěv |
| Doporučení přátel | MOL Move, Shell Box, trh #13 | Kvalifikační nákup a ochrana proti zneužití |
| Wallet karta (Apple / Google) a karta offline | OMV recenze (karta se bez signálu nezobrazí); AppExchange Kemicard | Vyžaduje doplněk nebo vlastní generování passu |
| Notifikace a centrum zpráv (push) | Trh #29, MOL | Portál není nativní aplikace |
| Platba u stojanu a QR platba | Nejchválenější funkce (Shell SmartPay, Exxon, Waylet, Shell Box); trh #21, #22 | Vyžaduje integraci pokladen a platební bránu |
| Mytí, nabíjení EV, plánování trasy | Waylet; trh #25 až #28 | Mimo rozsah sítě v zadání |
| Personalizované nabídky | Shell, Exxon „My Offers“, trh #7 | Vyžaduje nákupní data a souhlasy k profilaci |
| Výmaz účtu z portálu (GDPR self-service) | MOL, Shell Box, trh #30 | V MVP řeší loyalty manažer ručně |
| Integrace s pokladnami v reálném čase | Zadání ji pro hackathon vylučuje | Fáze 2 reálné implementace |

---

## 7. Nefunkční požadavky

| ID | Požadavek | Priorita | Zdroj |
| --- | --- | --- | --- |
| NFR-01 | **Mobile-first portál:** všechny stránky použitelné na šířce 360 px bez horizontálního posunu, dotykové prvky alespoň 44 × 44 px | MUST | Trh (referenční aplikace jsou mobilní) |
| NFR-02 | **Výpočty na serveru:** body, nárok na kampaň, zůstatek a uplatnění odměny počítá a potvrzuje výhradně Salesforce, ne prohlížeč | MUST | Trh (společný požadavek všech algoritmů) |
| NFR-03 | **Idempotence a atomicita:** transakce nepřipíše body dvakrát, uplatnění nevytvoří dva vouchery, chyba nezanechá polovičatý stav | MUST | Zadání, trh |
| NFR-04 | **Konfigurovatelnost:** kampaně, odměny, body za aktivity, sazby, prahy úrovní a délka platnosti bodů bez nasazení kódu | MUST | Zadání §4 |
| NFR-05 | **Bezpečnost dat:** člen vidí jen svá data (sharing sets / sharing rules), návštěvník nevidí žádná data členů, back-office dle FR-E8-06 | MUST | |
| NFR-06 | **Auditovatelnost:** neměnné pohyby bodů s autorem a časem, historie změn polí u kampaní a odměn | MUST | Trh #4 |
| NFR-07 | **Bez vyskakovacích oken a reklamy** při otevření portálu a během uplatnění | SHOULD | Recenze Waylet, Shell Box, ORLEN |
| NFR-08 | **Hromadné zpracování:** import 5 000 transakcí v jedné dávce bez překročení limitů platformy | MUST | Testovací data |
| NFR-09 | **Výkon:** Přehled v portálu se načte do 3 s, report do 10 s na testovacích datech | SHOULD | |
| NFR-10 | **Jazyk a brand:** čeština, názvosloví kap. 3, brand kit EneOil (tokeny, písma, texty) | MUST | Zadání (Brand Kit) |
| NFR-11 | **Přístupnost:** kontrast textu ≥ 4,5 : 1 (barvy brand kitu), číslo člena vedle QR i jako text, tlačítka popisují akci | SHOULD | Brand kit |
| NFR-12 | **Souhlasy (GDPR):** souhlas s podmínkami a marketingový souhlas oddělené, s datem udělení a odvolání a verzí textu | MUST | Trh #1, #30 |
| NFR-13 | **Přihlášení bez zbytečných překážek:** registrace na jedné obrazovce, žádné povinné údaje navíc, funkční obnova hesla, relace neprošlá při běžném používání | SHOULD | Recenze (nejčastější kritika napříč aplikacemi: OMV, Shell, MOL, Circle K, TotalEnergies) |
| NFR-14 | **Srozumitelné chyby:** každá chybová hláška říká, co se stalo a co dělat; u uplatnění vždy uvádí, zda body zůstaly | SHOULD | Brand kit, recenze |

---

## 8. Doporučené funkce: zdůvodnění a dohledatelnost

Souhrn, proč jsou SHOULD a COULD funkce v backlogu. Čísla „trh #“ odkazují na 30 funkcí v `specifikace funkcí mobilních aplikací loajalitního programu.pdf`.

| Doporučená funkce | Na trhu | V recenzích | Priorita | Požadavek |
| --- | --- | --- | --- | --- |
| Digitální členská karta s QR | ORLEN, MOL Move, OMV (trh #2) | Chválená u MOL, OMV, Shell, Circle K | SHOULD | FR-E1-04 |
| Rozpis bodů u transakce | Trh #3 (rozpad základ/bonus) | OMV: vidět jen počet bodů | SHOULD | FR-E5-03 |
| Progress k další odměně | Circle K, trh #9, #11 | Circle K chválí sledování postupu | SHOULD | FR-E7-02 |
| Cena v bodech, „Chybí ti N bodů“, zůstatek po směně | Shell, OMV, ORLEN (trh #9) | OMV: katalog bez bodových hodnot | MUST/SHOULD | FR-E6-01, FR-E6-02 |
| Akce s jasnou podmínkou a místem platnosti | Trh #6, #7 (štítky „Platí automaticky“) | OMV: platnost jen na některých stanicích | MUST | FR-E3-04 |
| Ruční úprava bodů pro reklamace | Trh #4 | Shell, Circle K: body se nepřipsaly | SHOULD | FR-E8-04 |
| Ověření voucheru v servisu | Trh #8 (stavový model) | MOL, Circle K: kupon nejde uplatnit | SHOULD | FR-E6-06 |
| Klonování kampaně | — | Zadání: marketing opakuje kampaně | SHOULD | FR-E3-03 |
| Jednoduchá registrace a trvalé přihlášení | Trh #1 | Nejčastější kritika (OMV ~160 zmínek) | SHOULD | FR-E1-01, NFR-13 |
| Oddělené souhlasy | Trh #1, #30 | OMV: příliš mnoho údajů | MUST | FR-E4-03, NFR-12 |
| Bez reklam při otevření | — | Waylet, Shell Box, ORLEN | SHOULD | NFR-07 |
| Uvítací bonus | OMV 100 bodů, Shell 250 bodů | Chválený | COULD | FR-E4-04 |
| Úrovně bez tvrdého resetu | MOL Move (trh #5) | MOL: roční reset je nejčastější kritika | COULD | FR-E10-03 |
| Viditelná expirace (počet + datum) | Trh #4 | Shell: expirace není vidět; Shell Box: ztráta bodů | COULD | FR-E10-02 |
| Přehled úspor | Exxon, ORLEN (trh #24) | | COULD | FR-E7-03 |

---

## 9. Mimo rozsah (ze zadání)

- Integrace s pokladními systémy (transakce se simulují importem nebo ručně).
- Položky transakce a produktový katalog.
- Salesforce Loyalty Management package (prostředí je čistý Salesforce).
- Nativní mobilní aplikace (portál je responzivní web v Experience Cloudu).
- Data o prodejích mimo Klub (Petra nemůže měřit dopad na prodeje, report to neslibuje).
- Platby, další partneři kromě EneServis.
---

## 10. Doporučené pořadí implementace (hackathon)

| Blok | Čas | Obsah |
| --- | --- | --- |
| Implementace I | 11:15–12:30 | Datový model (kap. 5), FR-E2-01 až 05, FR-E3-01 a 02, FR-E5-01, parametry, testovací data, scénáře T01 až T25 |
| Implementace II | 13:00–15:30 | Portál FR-E1-01 až 05, FR-E7, FR-E5-02, FR-E3-04, E4, E6 včetně e-mailu; report E9; pak SHOULD (FR-E1-04, FR-E5-03, FR-E8-04, FR-E6-06) |
| Pokud zbude čas | | COULD v pořadí: FR-E10-01, FR-E10-02, FR-E10-03, FR-E2-06 |
| Testování | 15:30–15:45 | Test log podle kapitoly 4.9 a AC jednotlivých požadavků |

**Testovací data (doporučení):** 120 stanic („EneOil Praha – Chodov“, „EneOil D1 Humpolec“), 300 členů s e-maily `@example.com` a registracemi rozloženými do 12 měsíců, 5 000 transakcí za 12 měsíců (mix: jen palivo, jen pokladna, obojí; část nad 40 l a nad 150 Kč), 2 až 3 historické běhy kampaní (aby report ukázal srovnání), 60 až 80 vydaných voucherů. Historické transakce musí mít historické datum pohybu (BR-43), jinak report neukáže trend.

---

## 11. Předpoklady a otevřené otázky (pro checkpoint s garantem v 10:45)

| # | Otázka | Náš návrh (platí, dokud garant neřekne jinak) | Dotčené |
| --- | --- | --- | --- |
| Q1 | Nominální hodnota „Servisní prohlídka zdarma“ v Kč | 2 000 Kč | BR-50, E9 |
| Q2 | Výše a období rozpočtu na partnerské vouchery | Roční rozpočet na odměnu, hodnota v testovacích datech | FR-E9-03 |
| Q3 | Kdo v servisu ověřuje kód voucheru | Interní uživatel s rolí Operátor EneServis | FR-E6-06 |
| Q4 | Odebírat body při odvolání souhlasu | Ne | BR-33 |
| Q5 | Povinná pole pro dokončený profil | Značka, model, druh paliva, rok výroby | BR-32 |
| Q6 | Zpracování transakcí nečlenů | Neimportovat | BR-05 |
| Q7 | Storno transakcí v MVP | COULD | FR-E2-06 |
| Q8 | Expirace: hodnotit po dnech, nebo přesně na čas připsání | Po dnech | BR-61 |
| Q9 | Práh a benefit úrovně Dálnice | 2 000 qualifying bodů za 12 měsíců, body za palivo × 1,2 | BR-60 |
| Q10 | Více násobitelů současně | Každý ze základu zvlášť, bonusy se sčítají | BR-26 |
| Q11 | Člen jako Person Account, nebo Kontakt pod sběrným Accountem | Rozhodne solution design (při Kontaktech hlídat data skew nad 10 000 záznamů) | Kap. 5 |
| Q12 | Zadání používá název EnePumpa, tým EneOil | EneOil podle brand kitu | Kap. 3 |