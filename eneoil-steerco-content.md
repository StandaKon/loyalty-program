# Příprava pro SteerCo, interní, nezobrazovat jako slidy

- Publikum: vedení programu, Head of Loyalty, finance a vlastník Salesforce. Konkrétní účastníci a způsob prezentování nejsou potvrzené; pracovní varianta je ústní prezentace na 5–7 minut.
- Hlavní sdělení: doporučujeme vlastní loyalty engine v Sales Cloudu s členským portálem a společným reportingem. Před závazkem termínu a ceny potřebujeme potvrdit rozsah, licence a finanční vstupy.
- Příběh: přínos a hranice první dodávky → navržené řešení → spolehlivost bodů → rozhodnutí vedení → ověření a další rozvoj.
- Formát: pět obsahových slidů v češtině. Samostatný titulní slide, agenda, tým a obchodní nabídka jsou kvůli stručnosti vynechané. Soubor určuje obsah; neurčuje vizuální návrh.
- Zdroj: `context.md`, verze 1.0 z 6. 11. 2026. Technické doporučení a úplný seznam otevřených rozhodnutí jsou v [pracovním solution designu](docs/adlc/specs/2026-11-06-eneoil-solution-design.md).

# EneOil Klub: návrh pro SteerCo

## První dodávka propojí sbírání bodů, odměny a řízení programu

- **Goal:** Potvrdit přínos a hranice první dodávky.

- Pro 120 stanic zavádíme program s body za nákupy, kampaně a aktivity člena.
- Člen v mobilním portálu uvidí zůstatek, historii, akce a vouchery EneServis.
- Loyalty manažer spravuje kampaně a katalog; vedení sleduje čerpání bodů a hodnotu voucherů.
- První dodávka pokrývá povinný rozsah zadání. Pokladnu simulujeme importem nebo ručním zadáním; reálné napojení je další fáze.

_(Pracovní návrh k diskusi. Body platí podle pravidel context.md; žádné obchodní pravidlo tímto návrhem neměníme.)_

## Salesforce bude společným zdrojem bodů i manažerských čísel

- **Goal:** Vysvětlit navrženou architekturu a rozdělení odpovědností.

- **Sales Cloud:** členové, transakce, bodový účet, konfigurovatelné kampaně, odměny a vouchery. Vlastní engine bez Loyalty Management package.
- **Experience Cloud:** registrace, přihlášení a členská samoobsluha. Výpočet i potvrzení čerpání probíhají na serveru.
- **Back-office:** standardní Lightning aplikace pro správu programu a řešení reklamací.
- **Claude artifact:** report se živým čtením Salesforce a časem aktualizace. Konkrétní konektor ověříme na začátku.

_(Doporučujeme vlastní transakční engine a standardní administraci. Technické varianty a jejich omezení jsou v příloze solution designu.)_

## Každý bod bude dohledatelný a stejný požadavek se nezapočítá dvakrát

- **Goal:** Ukázat, jak řešení chrání důvěru členů a správnost evidence.

- Nákup 45 l a zboží za 180 Kč při obou výchozích kampaních přinese **109 bodů**: 45 + 9 základ, 5 + 50 bonusy.
- Jeden výpočet pro import i ruční zadání. Opakovaný import nepřidá další body.
- Každá změna má neměnný pohyb; oprava vytvoří nový záznam.
- Vydání voucheru a odečet bodů tvoří jednu operaci. Kontrola souběhu a dvojkliku zabrání dvojímu čerpání.
- Člen vidí vlastní data, servis jen údaje potřebné k ověření voucheru.

## Před závazkem dodávky potřebujeme potvrdit čtyři rozhodnutí

- **Goal:** Získat rozhodnutí vedení o rozsahu a vstupních podmínkách.

| Rozhodnutí | Doporučení k potvrzení |
| --- | --- |
| Rozsah a pořadí | Povinné funkce jako základ. Poté ruční opravy bodů, digitální karta a ověřování v servisu. Expiraci, úrovně a PDF odložit. |
| Licence a přístupy | Ověřit licence pro členy i servis a rozpočtový rámec podle počtu členů a frekvence přihlášení. |
| Hodnota odměn a rozpočet | Potvrdit hodnotu prohlídky, pracovní návrh 2 000 Kč, a roční rozpočty voucherů. |
| Odhad reálné implementace | Odhad v MD uzavřít po ověření orgu, licencí a rozsahu. Produkční POS integraci ocenit samostatně. |

_(Head of Loyalty a finance potvrzují obchodní vstupy, vlastník Salesforce licence, SteerCo rozsah a rozpočtový rámec. Jde o navržené rozdělení odpovědností.)_

## Úspěch prokážeme celou cestou od nákupu po report

- **Goal:** Dohodnout podmínky převzetí a směr dalšího rozvoje.

- Nejdříve ověříme portálové přístupy a živé připojení reportu; potom dokončíme bodový účet, portál a vouchery.
- Převzetí doložíme scénáři výpočtu, opakovaným importem, souběžným čerpáním a zpracováním 5 000 transakcí.
- Report rozliší vydané vouchery a použití v servisu. Čísla budou souhlasit se Salesforce evidencí; srovnání kampaní bude označené jako orientační.
- Další fáze může doplnit reálné POS napojení, expiraci, úrovně členství a Wallet kartu podle schválených priorit.

_(Tým před vývojem uzavře historickou platnost kampaní, identitu členů a definice historických KPI. Úplný rozhodovací seznam je v příloze. Toto je obsah prezentace, nikoli schválený realizační plán.)_
