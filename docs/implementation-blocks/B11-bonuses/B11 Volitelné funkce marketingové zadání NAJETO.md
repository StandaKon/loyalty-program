# B11 Volitelné funkce: marketingové zadání NAJETO

Nov 6, 2026 · @Zuzana Boudova

## Stav dokumentu

Verze 0.1, návrh ke schválení. Texty vycházejí z Brand Kitu EneOil (hlas, slovník, formáty), z dokumentu NAJETO v2 a z funkčního zadání EneOil Klub (BR-40 až BR-62, FR-E2-06, FR-E10). Navazuje na B8 Odměny a vouchery. Označení: **potvrzeno** (je ve zdroji), **návrh** (doporučená varianta), **nutno ověřit** (chybí podklad).

Body k rozhodnutí před schválením:

1. **Názvy úrovní.** Okreska a Dálnice pocházejí z Brand Kitu EneOil Klub. Dokument NAJETO v2 úrovně neuvádí. Návrh: ponechat, řidičský slovník sedí ke claimu „Máš najeto na víc.“
2. **Body před spuštěním expirace.** Funkční zadání tuto situaci neřeší. Návrh je v kapitole 2.
3. **Voucher a expirace bodů.** Voucher platí bez omezení (B8), body propadají po roce. Texty to rozlišují, aby si člen pravidla nepletl.

## Rozhodnutí o rozsahu a prioritě

Návrh: do první verze voucher jako soubor a expirace bodů, úrovně a storno v etapě 2. Finální prioritu potvrdí vlastník programu.

| Kandidát | Rozhodnutí | Priorita | Obchodní vlastník | Cílová etapa |
| --- | --- | --: | --- | --- |
| Voucher jako PDF nebo obrázek | schváleno (návrh) | 1 | Marketing | První verze |
| Expirace bodů | schváleno (návrh) | 2 | Vlastník programu, finance | První verze |
| Členské úrovně | pozdější etapa (návrh) | 3 | Vlastník programu, marketing | Etapa 2 |
| Storno transakce a bodů | pozdější etapa (návrh) | 4 | Vlastník programu, finance, provoz | Etapa 2 |

Zdůvodnění:

- **Voucher jako soubor.** Člen má voucher po ruce i bez přihlášení do portálu. Nízké riziko, pravidla už jsou v B8.
- **Expirace bodů.** Zavedení hned od startu je pro členy férovější než dodatečná změna podmínek. Programu dává předvídatelný náklad na body.
- **Členské úrovně.** Benefit Dálnice zvyšuje náklad na body o 20 % u paliva. Potřebuje schválení financí a data z prvních měsíců provozu pro nastavení prahu.
- **Storno.** Do etapy 2 pokryje opravy ruční úprava bodů s povinným důvodem (BR-62).

## 1. Voucher jako PDF nebo obrázek

Návrh: PDF ve formátu A6 na šířku pro tisk a obrázek PNG 1 200 × 600 px pro mobil. Oba soubory jsou ke stažení v Moje vouchery a přiložené k e-mailu s voucherem (FR-E10-01).

| Pravidlo | Rozhodnutí | Stav |
| --- | --- | --- |
| Formát | PDF A6 na šířku a PNG 1 200 × 600 px | návrh, formáty potvrzeny v Brand Kitu |
| Účel | Ukázat voucher v EneServisu z telefonu nebo vytištěný | návrh |
| Kde je soubor | Moje vouchery a příloha e-mailu | potvrzeno (FR-E10-01) |
| Opakované stažení | Soubor je vždy stejný, kód v souboru = kód v databázi | návrh |
| Stav na souboru | Soubor stav neukazuje. Aktuální stav je jen v portálu a v Salesforce | návrh |
| Tisk | Černobílý tisk musí zůstat čitelný, kód bez barevného podkladu | návrh |
| Dostupnost bez obrázku | Všechny údaje ze souboru jsou i v textu e-mailu a v portálu | potvrzeno (B8) |

Povinné prvky podle Brand Kitu:

- vlevo pruh `brand` se značkou EneOil, vpravo obsah, mezi nimi perforace (přerušovaná linka `line`);
- název odměny jako nadpis;
- kód `ENE-XXXX-XXXX` v Noto Sans Mono 40 px;
- Uplatníš v: EneServis, s logem EneServis;
- Platnost: bez omezení;
- Vydáno: datum vydání;
- logo najeto. a text věrnostní program EneOil.

Texty na souboru:

| Místo | Text |
| --- | --- |
| Nadpis | Sleva 200 Kč na přezutí |
| Kód | ENE-7KQ4-M2XD |
| Partner | Uplatníš v: EneServis |
| Platnost | Platnost: bez omezení |
| Datum | Vydáno 6. 11. 2026 |
| Pokyn | Kód nadiktuj při objednání, nebo ho ukaž na místě. Jeden voucher na jednu zakázku. |
| Právní řádek | Podmínky programu NAJETO: ‹URL› |

Texty v portálu a e-mailu:

| Místo | Text |
| --- | --- |
| Tlačítko v Moje vouchery | Stáhnout voucher (PDF) |
| Druhé tlačítko | Uložit jako obrázek |
| Chyba stažení | Soubor se nepodařilo stáhnout. Kód ENE-7KQ4-M2XD platí dál a najdeš ho tady v portálu. |
| Řádek v e-mailu | Voucher máš v příloze, můžeš ho vytisknout nebo ukázat v telefonu. |
| Alt text obrázku | Voucher NAJETO: Sleva 200 Kč na přezutí, kód ENE-7KQ4-M2XD, uplatníš v EneServisu. |

Název souboru (návrh): `najeto-voucher-ENE-7KQ4-M2XD.pdf`.

## 2. Expirace bodů

Body platí přesně 1 rok od připsání, počítáno po dnech (BR-61, Q8). Na odměny se vždy berou nejdřív body, které propadnou nejdřív.

| Pravidlo | Rozhodnutí | Stav |
| --- | --- | --- |
| Doba platnosti | 1 rok od připsání, body z D propadnou D + 1 rok, z 29. 2. propadnou 28. 2. | potvrzeno (BR-61) |
| Body před spuštěním funkce | Platí do data účinnosti pravidla + 1 rok | návrh |
| Částečně využité body | Uplatnění odměny spotřebuje nejdřív nejstarší body | potvrzeno (BR-61) |
| Ochranná lhůta a výjimky | Bez ochranné lhůty, pravidlo platí pro všechny typy bodů | návrh |
| Upozornění | E-mail 30 dní a 7 dní předem, v portálu trvale od 30 dní předem | návrh, funkční zadání má e-mail 30 dní předem |
| Kanály | E-mail a portál (Přehled, Historie bodů) | návrh |
| Pohyb v historii | Samostatný řádek Propadlé body v barvě `minus` | potvrzeno (BR-41, Brand Kit) |
| Reklamace | Loyalty manažer může body vrátit ruční úpravou s důvodem (BR-62) | návrh |
| Kdo rozhoduje o reklamaci | Loyalty manažer, limit pro vrácení | nutno ověřit |
| Datum účinnosti podmínek |  | nutno ověřit |

Příklad z funkčního zadání: člen dostane 100 bodů 1. 1. 2026 a 50 bodů 1. 3. 2026. 1. 2. 2026 uplatní 80 bodů. 1. 1. 2027 mu propadne 20 bodů, 1. 3. 2027 propadne 50 bodů.

Body vrácené za zrušený voucher (B8, kapitola 3) dostanou novou roční platnost od data vrácení (návrh).

Texty portálu:

| Místo | Text |
| --- | --- |
| Vysvětlení pravidla | Body platí rok od připsání. Na odměny použijeme vždy nejdřív ty nejstarší. Voucher, který už máš, platí bez omezení. |
| Přehled, blíží se expirace (Brand Kit) | 120 bodů ti propadne 1. 12. 2026. |
| Přehled, dost bodů na odměnu | Na Slevu 200 Kč na přezutí máš dost bodů. · tlačítko Vybrat odměnu |
| Přehled, málo bodů na odměnu | Do Slevy 200 Kč na přezutí ti chybí 60 bodů. |
| Historie, řádek | 1. 12. 2026 · Propadlé body z 1. 12. 2025 · −120 |
| Po expiraci | 1. 12. 2026 ti propadlo 120 bodů. Teď máš 620 bodů. |
| Reklamace | Myslíš, že ti body propadly neoprávněně? Napiš nám na ‹e-mail podpory› a uveď datum. Ozveme se do ‹lhůta›. |

Doplnění textů B8, pokud bude expirace schválená:

| Místo v B8 | Nový text |
| --- | --- |
| Katalog: princip | U každé odměny vidíš cenu v bodech. Body se odečtou až ve chvíli, kdy uplatnění potvrdíš. Body platí rok od připsání, na odměny se berou nejdřív ty nejstarší. |
| Zrušený voucher | Zrušený · Voucher jsme zrušili 10. 11. 2026. 500 bodů je zpátky na tvém účtu. Platí do 10. 11. 2027. |

E-mail 30 dní předem:

| Prvek | Text |
| --- | --- |
| Předmět | 120 bodů ti propadne 1. 12. 2026 |
| Preheader | Vyměň je za odměnu v EneServisu. Máš na to 30 dní. |
| Nadpis | Za 30 dní ti propadne 120 bodů |
| Tělo | Body platí rok od připsání. 120 bodů z 1. 12. 2025 propadne 1. 12. 2026. Teď máš 740 bodů, to stačí na Slevu 200 Kč na přezutí. |
| Tlačítko | Vybrat odměnu |
| Patička | najeto. věrnostní program EneOil · Máš najeto na víc. |

E-mail 7 dní předem má stejnou stavbu. Předmět: Za 7 dní ti propadne 120 bodů. Preheader: Poslední upozornění, 1. 12. 2026 body propadnou. Když člen na odměnu nemá, věta o odměně se nahradí textem „Do Slevy 200 Kč na přezutí ti chybí 60 bodů.“

Návrh odstavce do obchodních podmínek (vykání, schvaluje legal):

> **Platnost bodů.** Body jsou platné 12 měsíců ode dne připsání. Body, které do té doby neuplatníte, propadnou. Při uplatnění odměny se odečtou nejdříve body s nejbližším datem propadnutí. Body připsané před ‹datum účinnosti› platí do ‹datum účinnosti + 1 rok›. O blížícím se propadnutí Vás budeme informovat e-mailem 30 a 7 dní předem. Vouchery získané za body mají platnost bez omezení.

## 3. Členské úrovně

Dvě úrovně: Okreska pro každého nového člena a Dálnice od 2 000 bodů z tankování a nákupů za 12 měsíců. Benefit Dálnice jsou body za palivo × 1,2 (BR-60, Q9).

| Pravidlo | Rozhodnutí | Stav |
| --- | --- | --- |
| Počet a názvy | Okreska, Dálnice | návrh (Brand Kit) |
| Práh Dálnice | 2 000 kvalifikačních bodů | návrh (Q9) |
| Období | Klouzavých 12 měsíců | potvrzeno (BR-60) |
| Co se počítá | Body z transakcí včetně bonusů z akcí. Body za aktivity a ruční úpravy ne | potvrzeno (BR-60) |
| Bonus z úrovně v kvalifikaci |  | nutno ověřit |
| Postup | Ihned po dosažení prahu | potvrzeno (BR-60) |
| Udržení a pokles | Hodnocení 1× měsíčně, pokles jen pod práh za posledních 12 měsíců | potvrzeno (BR-60) |
| Benefit Dálnice | Body za palivo × 1,2, bez násobení akcemi | návrh (Q9), schvalují finance |
| Zůstatek při změně úrovně | Beze změny, žádný reset bodů | potvrzeno (BR-60) |
| Uplatnění odměny | Kvalifikační body nesnižuje | potvrzeno (BR-60) |
| Změna nebo ukončení benefitu | Oznámení členům 30 dní předem | návrh |
| Informování | E-mail při postupu a při poklesu, stav trvale v portálu | návrh |

Vizuální identita (návrh): karta Okreska na `surface-raised` s rámečkem `ene-green`, ikona Material `route`. Karta Dálnice na ploše `brand` s textem `on-brand`, ikona Material `speed`. Postup jako oranžový pruh `brand` na `brand-soft`, stejně jako progress k odměně.

Texty portálu:

| Místo | Text |
| --- | --- |
| Vysvětlení pravidla | Úrovně jsou dvě: Okreska a Dálnice. Na Dálnici se dostaneš s 2 000 body z tankování a nákupů za posledních 12 měsíců. Body za aktivity v profilu se nepočítají. Tvůj zůstatek úroveň nemění. |
| Karta Okreska | Jsi na Okresce. |
| Okreska, postup (funkční zadání) | Do Dálnice ti chybí 420 bodů. |
| Okreska, stav | Za 12 měsíců máš 1 580 z 2 000 bodů. |
| Karta Dálnice (Brand Kit) | Jsi na Dálnici. Za každé tankování máš body navíc. |
| Dálnice, benefit | Za palivo dostáváš o 20 % bodů víc. |
| Dálnice, udržení | Dálnici si udržíš s 2 000 body za posledních 12 měsíců. Teď máš 2 340. Další hodnocení 1. 12. 2026. |
| Dálnice, riziko poklesu | Na udržení Dálnice ti teď chybí 150 bodů. Hodnotíme 1. 12. 2026. |
| Rozpis transakce | Dálnice (palivo ×1,2) ... +9 |

E-mail při postupu:

| Prvek | Text |
| --- | --- |
| Předmět | Jsi na Dálnici |
| Preheader | Za palivo teď dostáváš o 20 % bodů víc. |
| Tělo | Za posledních 12 měsíců máš 2 000 bodů z tankování a nákupů. Od dneška dostáváš za palivo o 20 % bodů víc. Zůstatek 1 240 bodů zůstává. |
| Tlačítko | Zobrazit můj účet |

E-mail při poklesu:

| Prvek | Text |
| --- | --- |
| Předmět | Od 1. 12. 2026 jsi na Okresce |
| Preheader | Tvých 740 bodů zůstává na účtu. |
| Tělo | Za posledních 12 měsíců máš 1 850 bodů z tankování a nákupů, na Dálnici je potřeba 2 000. Tvých 740 bodů zůstává na účtu. Na Dálnici se vrátíš hned, jak znovu dosáhneš 2 000 bodů. |
| Tlačítko | Zobrazit můj účet |

Návrh odstavce do obchodních podmínek (vykání, schvaluje legal):

> **Úrovně členství.** Program má úrovně Okreska a Dálnice. Každý nový člen začíná na úrovni Okreska. Úroveň Dálnice získáte, jakmile za posledních 12 měsíců nasbíráte 2 000 bodů za nákupy na stanicích EneOil, včetně bonusů z akcí. Body za aktivity a ruční úpravy se nezapočítávají. Úroveň vyhodnocujeme jednou měsíčně. Změna úrovně nemá vliv na Váš bodový zůstatek. O změně nebo ukončení výhod Vás budeme informovat nejméně 30 dní předem.

## 4. Storno transakce a bodů

Storno odebere přesně body připsané za stornovaný nákup a v historii vznikne nový opravný řádek (FR-E2-06, BR-40). Pravidla schvaluje vlastník programu, finance a provoz, marketing dodává texty pro člena.

| Pravidlo | Rozhodnutí | Stav |
| --- | --- | --- |
| Situace pro storno | Vrácení nákupu, chybně zaúčtovaný nákup, duplicitní nákup | návrh |
| Plné nebo částečné storno | Jen plné storno transakce. Částečné vrácení řeší ruční úprava bodů | návrh |
| Kdo zadává | Loyalty manažer | potvrzeno (FR-E2-06) |
| Kdo schvaluje |  | nutno ověřit |
| Odebrané body | Základ i bonusy z akcí, které transakce připsala | potvrzeno (FR-E2-06) |
| Bonus z úrovně Dálnice | Odebere se spolu s ostatními body transakce | návrh |
| Opakované storno | Transakci jde stornovat jen jednou | potvrzeno (FR-E2-06) |
| Nedostatečný zůstatek | Storno se neprovede, loyalty manažer odebere body ruční úpravou maximálně do výše zůstatku | potvrzeno (FR-E2-06, BR-62) |
| Voucher z dotčených bodů | Zůstává platný | návrh |
| Informování člena | E-mail po stornu a řádek v historii bodů | návrh |
| Reklamace | Přes podporu NAJETO, rozhoduje loyalty manažer | návrh |

Důvody storna viditelné členovi: Vrácení nákupu · Chybně zaúčtovaný nákup · Duplicitní nákup.

Texty portálu:

| Místo | Text |
| --- | --- |
| Historie, řádek | 6. 11. 2026 · Storno nákupu z 5. 11. 2026, EneOil D1 Humpolec · −109 |
| Historie, detail | Nákup z 5. 11. 2026 jsme stornovali. Důvod: vrácení nákupu. Odebrali jsme 109 bodů, které ti za něj přibyly. |
| Původní transakce | Stornováno 6. 11. 2026 |
| Částečné odebrání ruční úpravou | Za stornovaný nákup z 5. 11. 2026 jsme odebrali 80 bodů, tolik jsi měl na účtu. |
| Podpora | Nesouhlasíš se stornem? Napiš nám na ‹e-mail podpory› a pošli datum nákupu. Ozveme se do ‹lhůta›. |

E-mail po stornu:

| Prvek | Text |
| --- | --- |
| Předmět | Odebrali jsme 109 bodů za stornovaný nákup |
| Preheader | Nákup z 5. 11. 2026 na EneOil D1 Humpolec byl stornovaný. |
| Tělo | Nákup z 5. 11. 2026 na stanici EneOil D1 Humpolec jsme stornovali. Důvod: vrácení nákupu. Proto jsme odebrali 109 bodů, které ti za něj přibyly. Teď máš 631 bodů. Voucher, který už máš, platí dál. |
| Tlačítko | Zobrazit historii bodů |
| Podpora | Nesouhlasíš? Napiš nám na ‹e-mail podpory›. |

Text „tolik jsi měl“ je v mužském rodě. Rodově neutrální varianta: „Tolik bylo na tvém účtu.“

Návrh odstavce do obchodních podmínek (vykání, schvaluje legal):

> **Storno nákupu.** Pokud je nákup vrácen, chybně zaúčtován nebo započítán dvakrát, provozovatel programu odebere body, které za něj byly připsány, včetně bonusů. Pokud na účtu není dost bodů, odebere jen aktuální zůstatek. Vouchery získané před stornem zůstávají platné. O stornu Vás budeme informovat e-mailem.

## 5. Dopady a společné podklady

Všechny čtyři funkce používají stejný vizuální jazyk a patičku e-mailů jako B8. Kontakty podpory a reklamační lhůta jsou společné s B8 a zatím nutno ověřit.

| Funkce | Portál | E-mail | Reporting | Provoz |
| --- | --- | --- | --- | --- |
| Voucher jako soubor | Tlačítka ke stažení v Moje vouchery | Příloha e-mailu s voucherem | Beze změny | EneServis přijímá i vytištěný voucher |
| Expirace bodů | Přehled a Historie bodů | 2 upozorňovací e-maily | Propadlé body po měsících a podíl propadlých bodů (FR-E9) | Reklamace propadlých bodů |
| Členské úrovně | Karta úrovně, postup, řádek v rozpisu transakce | E-mail při postupu a poklesu | Členové podle úrovně, přechody mezi úrovněmi (FR-E9) | Dotazy k hodnocení úrovně |
| Storno | Řádek v historii, stav původní transakce | E-mail po stornu | Stornované body (návrh) | Zadání storna a ruční úpravy |

Společná pravidla pro texty:

- tykání v portálu a e-mailech, vykání jen v obchodních podmínkách;
- každé sdělení o bodech uvádí počet bodů a datum;
- slovo storno používáme jen pro nákup, u voucheru píšeme zrušení jako v B8;
- čísla v Noto Sans Mono, pohyb bodů s typografickým minus −;
- propadlé body v barvě `minus`, uplatněné v barvě `ink`, stornované také v `ink` (návrh);
- žádné fotky aut ani stanic, ikony z Google Material Icons (licence Apache 2.0).

Mobil: na Přehledu je pořadí zůstatek, upozornění na expiraci, karta úrovně, další odměna. Na desktopu stojí karta úrovně vedle zůstatku (návrh, navazuje na design B6, odkaz nutno ověřit).

## 6. Otevřená rozhodnutí a schválení

Před technickým návrhem je potřeba uzavřít těchto 10 bodů. Termíny nejsou v podkladech, doplňte je.

| # | Rozhodnutí | Preferovaná varianta | Vlastník | Termín |
| --- | --- | --- | --- | --- |
| 1 | Rozsah a pořadí čtyř funkcí | Soubor a expirace v první verzi, úrovně a storno v etapě 2 | Petra Králová |  |
| 2 | Body před spuštěním expirace | Platí do data účinnosti + 1 rok | Petra Králová, legal |  |
| 3 | Počet upozornění před expirací | 30 a 7 dní předem | Marketing |  |
| 4 | Limit pro vrácení propadlých bodů |  | Petra Králová |  |
| 5 | Práh a benefit Dálnice | 2 000 bodů, palivo × 1,2 | Petra Králová, finance |  |
| 6 | Bonus z úrovně v kvalifikačních bodech |  | Petra Králová |  |
| 7 | Názvy úrovní pod značkou NAJETO | Okreska, Dálnice | Marketing |  |
| 8 | Kdo schvaluje storno |  | Finance, provoz |  |
| 9 | Voucher po stornu | Zůstává platný | Petra Králová, finance |  |
| 10 | Datum účinnosti a URL podmínek |  | Legal |  |

| Role | Téma | Jméno | Datum schválení |
| --- | --- | --- | --- |
| Marketing | Texty, vizuály, e-maily |  |  |
| Produkt a vlastník programu | Rozsah, pravidla | Petra Králová (nutno ověřit) |  |
| Provoz | Storno, EneServis, reklamace |  |  |
| Finance | Expirace, úrovně, storno |  |  |
| Legal | Obchodní podmínky |  |  |
