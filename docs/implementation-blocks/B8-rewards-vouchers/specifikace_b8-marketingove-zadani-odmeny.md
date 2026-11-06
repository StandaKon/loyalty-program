# B8 — Marketingové zadání: Odměny a vouchery

6. 11. 2026 · Matěj Kováčik

## Shrnutí

Návrh v. 0.9 uzavírá všechna rozhodnutí B8 preferovanou variantou, implementovat se dá hned. Otevřené zůstává formální schválení Petrou Královou, provozem EneServisu a legal (kap. 11).

|  |  |
| --- | --- |
| Projekt | Věrnostní program NAJETO (EneOil), AI Hackathon 2026, tým 2A |
| Dokument | Odpověď marketingu na zadání B8 (`REWARDS_VOUCHERS_MARKETING_BRIEF.md`) |
| Verze | 0.9 · návrh ke schválení · 6. 11. 2026 |
| Vlastník dokumentu | Matěj Kováčik (Enehano, tým 2A) |
| Navazuje na | `specifikace/eneoil-klub-funkcni-zadani.md` (BR-50 až BR-58, FR-E6), `EneOil-Klub-Solution-Design.docx` (kap. 7, OP-09), `specifikace/b7-marketingove-zadani-aktivity.md` (R-01 NAJETO), Brand Kit EneOil, NAJETO brand v2 |

Značení: **\[R\]** rozhodnuto · **\[L\]** musí schválit legal · **\[ES\]** musí potvrdit provoz EneServisu · **\[OD-n\]** otevřené rozhodnutí (kap. 11).

| # | Rozhodnutí | Stav |
| --- | --- | --- |
| R-01 | Katalog v1 tvoří 3 odměny EneServisu: 500, 1 200 a 5 000 bodů za hodnotu 200, 500 a 2 000 Kč. | \[R\] |
| R-02 | Servisní prohlídka zdarma = práce technika na pravidelné prohlídce podle plánu výrobce. Materiál a další opravy platí člen. Hodnota 2 000 Kč, tím se uzavírá OP-09. | \[R\] + \[ES\] |
| R-03 | Katalog řídí jen stav Aktivní a datum zveřejnění od/do. Počet kusů ani rozpočet Salesforce nehlídá. | \[R\] |
| R-04 | Rozpočet se jen reportuje a čerpá ho vydaný voucher (zrušené se odečítají). Uplatněné vouchery jsou podklad pro vyúčtování s EneServisem. | \[R\] + \[OD-1\] |
| R-05 | Voucher nemá expiraci. Při ukončení programu nebo partnerství jde uplatnit ještě nejméně 6 měsíců od oznámení. | \[R\] + \[L\] |
| R-06 | Voucher je přenosný. Obsluha EneServisu nevidí žádné osobní údaje člena. | \[R\] + \[L\] |
| R-07 | Voucher platí jednou a na jednu zakázku, bez částečného čerpání a bez vrácení rozdílu. Nekombinuje se s jinými slevami EneServisu. | \[R\] + \[ES\] |
| R-08 | Ověření a označení voucheru obsluhou v Salesforce je součástí v1 (FR-E6-06 ze SHOULD na MUST). | \[R\] |
| R-09 | Stavy: Aktivní → Uplatněný, Aktivní → Zrušený, oba konečné. Název „Aktivní“ nahrazuje „Vydaný“ z FR. | \[R\] |
| R-10 | Nepoužitý voucher zruší na žádost člena loyalty manažer a body vrátí v původní výši. Samoobslužné storno v portálu v1 nemá. | \[R\] |
| R-11 | Kód `ENE-XXXX-XXXX` bez znaků O, I, L, 0, 1, velikost písmen se nerozlišuje. V1 má jen textový kód, bez QR. | \[R\] |
| R-12 | Člen bez dostatku bodů nevidí neaktivní tlačítko, ale kolik mu chybí a odkaz na Získej body. | \[R\] |
| R-13 | Texty pro člena vystupují pod značkou NAJETO (B7 R-01). „EneOil Klub“ z Brand Kitu se v portálu a e-mailu nahrazuje. | \[R\] |

## 1. Katalog odměn

Katalog v1 má tři odměny EneServisu seřazené podle bodové ceny, všechny dostupné od spuštění bez limitu kusů. Hodnoty v Kč jsou včetně DPH a ukládají se na voucher při vydání.

|  | Sleva 200 Kč na přezutí | Sleva 500 Kč na servis | Servisní prohlídka zdarma |
| --- | --- | --- | --- |
| Bodová cena | 500 bodů | 1 200 bodů | 5 000 bodů |
| Hodnota pro reporting a rozpočet | 200 Kč | 500 Kč | 2 000 Kč |
| Hodnota bodu | 0,40 Kč | 0,42 Kč | 0,40 Kč |
| Text na kartě | 200 Kč dolů z ceny přezutí v EneServisu. | 500 Kč dolů z ceny servisu nebo opravy v EneServisu. | Práci na prohlídce máš zdarma, materiál platíš zvlášť. |
| Rozsah služby | Sleva z ceny přezutí kol na jednom autě: demontáž, montáž, vyvážení, případně uskladnění kol. | Sleva z celkové ceny jedné servisní zakázky (práce i materiál). | Práce technika na pravidelné servisní prohlídce podle servisního plánu výrobce pro dané auto. |
| Výluky | Nákup pneumatik a disků. | Nákup zboží bez servisní práce. | Materiál (olej, filtry, kapaliny) a opravy zjištěné při prohlídce platí člen podle ceníku. Jen osobní auta a dodávky do 3,5 t. |
| Ikona (Material Symbols) | `tire_repair` | `car_repair` | `fact_check` |

**Pro všechny tři odměny platí:**

- **Partner:** EneServis, s.r.o. Na kartě logo EneServis a řádek „EneServis · autoservis“.
- **Dostupnost:** od spuštění programu, bez data konce, bez limitu kusů a bez limitu na člena. Stejnou odměnu lze získat opakovaně, pokaždé za nové body.
- **Kde:** na všech provozovnách EneServis v ČR, seznam dodá EneServis \[OD-2\].
- **Kombinace:** jeden voucher na jednu zakázku, nekombinuje se s jinými slevovými akcemi EneServisu \[ES\].
- **Kontakt:** dotazy k voucheru a bodům řeší podpora NAJETO {kontakt podpory} \[OD-4\], reklamaci služby provozovna EneServis.
- **Ikony:** Google Material Symbols, licence Apache 2.0, barva `ene-green`. Ikona je dekorativní (prázdný alt), logo má alt „EneServis“. Fotky ani ilustrace aut se nepoužívají (Brand Kit).

**Názvy:** pracovní „Sleva na výměnu pneumatik“ ze zadání nahrazuje „Sleva 200 Kč na přezutí“. Tak ji už uvádí Brand Kit, kampaň NAJETO i FR a řidiči říkají „přezutí“.

**Hodnota bodu:** s 1 bodem za litr vrací program 0,40 Kč na každý natankovaný litr, stejně u všech odměn. Prohlídka tedy šetření bodů nijak nezvýhodňuje. Pokud má marketing chtít členy motivovat k šetření, musela by mít hodnotu vyšší než 2 000 Kč; pro v1 to neměníme.

## 2. Rozpočet, dostupnost a limity (OP-09)

Rozpočet na vouchery se v1 jen reportuje, Salesforce vydávání nikdy neblokuje. Blokace by členovi s našetřenými body ukázala „vyčerpáno“ a vyžadovala by hlídání souběžných výdejů bez obchodního přínosu pro první verzi.

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| CZK hodnota odměn | 200 Kč · 500 Kč · 2 000 Kč vč. DPH (kap. 1). OP-09 je tím uzavřený. |
| Rozpočet pro období | Roční rozpočet na kalendářní rok, jedna částka za všechny odměny. Výši na rok 2027 doplní Petra Králová \[OD-1\]. Pro hackathon a testovací data platí 50 000 Kč na rok 2026. |
| Vlastník a obnova | Petra Králová, Head of Loyalty. Rozpočet se nastavuje jednou ročně, čerpání sleduje měsíčně v manažerském reportu (FR-E9-03). |
| Co čerpá rozpočet | **Vydaný** voucher v den vydání, v hodnotě uložené na voucheru. Zrušený voucher se z čerpání odečte. Důvod: závazek vůči členovi vzniká vydáním, ne až návštěvou servisu. |
| Uplatněné vouchery | Report je ukazuje zvlášť (počet, hodnota, podíl z vydaných). Slouží jako podklad pro měsíční vyúčtování s EneServisem \[OD-1\]. |
| Report, nebo blokace | Jen report. Report zvýrazní čerpání 80 % a 100 %, katalog běží dál. Při přečerpání rozhoduje Petra Králová ručně (deaktivace odměny, změna ceny v bodech). |
| Dostupnost v katalogu | Odměnu zobrazuje stav Aktivní a volitelné datum od/do. Počet kusů se v1 neeviduje. |
| Co člen vidí u nedostupné odměny | Deaktivovaná nebo ukončená odměna z katalogu zmizí, stav „vyčerpáno“ v1 neexistuje. Kdo ji otevře z odkazu nebo ji uplatňuje ve chvíli deaktivace, dostane text z kap. 7. Vydané vouchery platí dál. |
| Historická hodnota | Ano. Voucher si při vydání uloží bodovou cenu i hodnotu v Kč. Změna katalogu je nezmění a storno vrací původně zaplacené body. |

## 3. Platnost, uplatnění, storno a vracení bodů

Voucher nemá expiraci, platí ihned po vydání, je přenosný a jde použít jednou. Body se vrací jen za zrušený nepoužitý voucher, vždy v původně zaplacené výši.

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| Expirace | Bez expirace. Pojistka v podmínkách: při ukončení programu nebo spolupráce s EneServisem lze vydané vouchery uplatnit nejméně 6 měsíců ode dne oznámení \[L\]. Vyřazení jedné odměny z katalogu vydané vouchery neomezuje. |
| Od kdy platí | Ihned po úspěšném vydání, tedy jakmile člen vidí kód v portálu. |
| Přenosnost | Ano. Kdo zná kód, voucher uplatní (např. partner s druhým autem). Za ochranu kódu odpovídá člen \[L\]. |
| Jednorázové použití | Ano, jeden voucher na jednu zakázku. Na jednu zakázku nelze uplatnit víc voucherů NAJETO. |
| Částečné čerpání | Ne. |
| Vrácení nevyčerpané hodnoty | Ne, ani v hotovosti. Když zakázka stojí méně než sleva, rozdíl propadá. Člen to vidí v detailu odměny před uplatněním. |
| Rezervace termínu | Termín se objednává u EneServisu jako obvykle (telefon, web). Voucher termín negarantuje. Kód člen nahlásí při objednání nebo nejpozději při příjmu auta. |
| Storno na žádost člena | Nepoužitý (Aktivní) voucher lze kdykoli zrušit přes podporu NAJETO. Body se vrátí celé. Uplatněný voucher zrušit nelze. |
| Chybné vydání | Např. dvojí vydání nebo vydání zablokovanému členovi: loyalty manažer voucher zruší, body se vrátí. |
| EneServis službu nemůže poskytnout | Provozovna zavřená nebo službu nedělá: člen použije jinou provozovnu, nebo požádá o storno s vrácením bodů. |
| Reklamace kvality služby | Řeší EneServis podle svého reklamačního řádu. Voucher zůstává Uplatněný, body se nevracejí. |
| Omylem označený jako uplatněný | Stav se nevrací. Po ověření s provozovnou připíše loyalty manažer členovi body ve výši ceny voucheru ruční úpravou (FR-E8-04, důvod Oprava chyby). |
| Kdo stornuje | Jen role Loyalty manažer v back-office. Povinný důvod z číselníku: Na žádost člena · Chybné vydání · Partner nemůže poskytnout · Ukončení programu nebo partnerství. Člen dostane informaci v portálu (kap. 7). |
| Obchodní podmínky | Článek „Odměny a vouchery“ v podmínkách programu NAJETO na `/podminky-programu` (návrh v kap. 10). |

## 4. Ověření a uplatnění v EneServisu

Obsluha kód ověří v Salesforce při příjmu auta a jako uplatněný ho označí až při vyúčtování zakázky. Kdo nepřijede, voucher nepřijde o platnost. Postup musí schválit provoz EneServisu \[ES\].

1. **Co člen předloží:** kód `ENE-XXXX-XXXX`. Nadiktuje ho při objednání nebo ukáže na mobilu při příjmu auta (portál nebo e-mail). Průkaz totožnosti ani členská karta se nevyžadují, voucher je přenosný.
2. **Jak obsluha ověří platnost:** v aplikaci EneOil Klub (Sales Cloud, role Operátor EneServis) zadá kód. Malá písmena, chybějící pomčky i chybějící prefix `ENE-` nevadí. Obsluha přečte členovi název odměny a ten ho potvrdí.
3. **Co obsluha vidí:** kód, název odměny, stav, datum vydání. U uplatněného voucheru i datum, provozovnu a číslo zakázky, u zrušeného datum zrušení. **Nevidí** jméno, e-mail, zůstatek ani historii člena (FR-E8-06).
4. **Kdy je voucher uplatněný:** při vyúčtování zakázky, kdy se sleva nebo práce zdarma promítne do účtu. Obsluha zadá provozovnu (výběr) a číslo zakázky EneServis (povinné) a stiskne „Označit jako uplatněný“. Ověření při příjmu auta stav nemění.
5. **Neplatný, použitý nebo zrušený voucher:** obsluha slevu neposkytne a člena pošle na podporu NAJETO. Systém druhé uplatnění odmítne (tabulka níže).
6. **Výjimky a reklamace:** obsluha kontaktuje podporu NAJETO {kontakt pro partnery} \[OD-4\], loyalty manažer odpoví do 1 pracovního dne. Reklamaci služby řeší provozovna sama.

| Výsledek vyhledání | Co obsluha vidí | Co udělá |
| --- | --- | --- |
| Aktivní | Odměna, datum vydání, „Voucher je platný.“ | Provede službu, při vyúčtování označí jako uplatněný. |
| Uplatněný | „Voucher už byl uplatněný {datum} na provozovně {provozovna}.“ | Slevu neposkytne, odkáže na podporu NAJETO. |
| Zrušený | „Voucher byl zrušený {datum} a nelze ho použít.“ | Slevu neposkytne, odkáže na podporu NAJETO. |
| Nenalezen | „Kód jsme nenašli. Zkontroluj ho s členem znak po znaku.“ | Nechá si kód ukázat na mobilu a zadá ho znovu. |

**Výpadek Salesforce:** obsluha slevu poskytne, kód zapíše na zakázku a označí ho do konce dalšího pracovního dne. Pokud se ukáže, že kód byl už použitý, řeší to loyalty manažer s EneServisem \[ES\].

## 5. Stavy voucheru

Voucher má tři stavy: Aktivní, Uplatněný a Zrušený. Uplatněný i Zrušený jsou konečné, žádný přechod zpět neexistuje.

Stavový diagram: Aktivní → Uplatněný (obsluha EneServis při vyúčtování zakázky) · Aktivní → Zrušený (loyalty manažer s důvodem, body zpět). Oba konečné. Diagram je v Claude Doc „B8 — Marketingové zadání: Odměny a vouchery“.

Chybu obsluhy (omylem uplatněný voucher) řeší loyalty manažer ruční úpravou bodů, ne vrácením stavu (kap. 3).

| Stav | Obchodní význam | Kdo ho nastaví | Co vidí člen |
| --- | --- | --- | --- |
| Aktivní | Voucher je vydaný, body odečtené, lze ho uplatnit. V FR a SD se jmenuje „Vydaný“. | Systém po úspěšném uplatnění odměny členem | Štítek Aktivní, kód, pokyny |
| Uplatněný | Služba byla v EneServisu vyúčtovaná s odměnou. Podklad pro vyúčtování s EneServisem. | Obsluha EneServis (role Operátor EneServis) | Datum a provozovnu uplatnění |
| Zrušený | Voucher je neplatný, body se vrátily opravným pohybem. Odečítá se z čerpání rozpočtu. | Loyalty manažer s povinným důvodem | Datum zrušení a vrácené body |

## 6. Viditelná podoba kódu

Kód zůstává ve výchozím formátu `ENE-XXXX-XXXX` z abecedy 31 znaků bez dvojznačných znaků a v1 je jen textový. Algoritmus, unikátnost a kolize navrhne implementační tým (OP-10).

| Hledisko | Rozhodnutí |
| --- | --- |
| Formát | `ENE-` + 2 bloky po 4 znacích, např. `ENE-7KQ4-M2XD`. |
| Abeceda | A B C D E F G H J K M N P Q R S T U V W X Y Z 2 3 4 5 6 7 8 9. Bez O, I, L, 0, 1, aby se nešly zaměnit. |
| Velikost písmen | Nerozlišuje se. Zobrazuje se velkými písmeny (jediná výjimka z pravidla „žádné verzálky“ Brand Kitu), obsluha může psát malými. |
| Zadání obsluhou | Pomčky i prefix `ENE-` jsou volitelné, mezery se ignorují. |
| Mobil | Noto Sans Mono 20/28 v portálu, 24 px v e-mailu, pomčky ponechat. Kód se nezalamuje a vedle něj je tlačítko „Zkopírovat kód“. |
| Diktování | Po znacích. Česká písmena B, C, D, E, G, P, T, V zní podobně (bé, cé, dé…), proto nápověda v portálu doporučí hláskování („B jako Božena“). Překlep obvykle vede na „Kód jsme nenašli“, ne na cizí voucher: kód je náhodný z 31⁸ ≈ 8,5 × 10¹¹ možností. Obsluha navíc členovi přečte název odměny. |
| QR nebo čárový kód | Ve v1 ne. Obsluha kód stejně zadává do Salesforce ručně a čtečky na provozovnách nepředpokládáme. QR je kandidát pro B11 (voucher jako PDF) a pro roadmapu. |

## 7. Texty portálu

Všechny texty jsou finální návrh v češtině, v tykání a sentence case, pod značkou NAJETO. Pravidla jako v B7: číslo napřed, žádný vykřičník, bez „Bohužel“, skloňování 1 bod / 2 až 4 body / 5 bodů, proměnné ve složených závorkách. Žádný text netvrdí, že voucher vznikl, dřív než to potvrdí server.

### 7.1 Katalog a karta odměny

| Prvek | Text |
| --- | --- |
| Nadpis stránky | Odměny |
| Úvodní text | Body, které využiješ. Vyměň je za voucher do autoservisu EneServis. |
| Zůstatek v záhlaví | Máš {zůstatek} bodů. |
| Jak to funguje (3 kroky) | 1. Vyber odměnu a potvrď ji. Body ti odečteme hned. 2. Kód voucheru najdeš v Moje vouchery a pošleme ti ho i e-mailem. 3. V EneServisu kód nadiktuj při objednání nebo při příjmu auta. |
| Karta: partner | EneServis · autoservis (s logem) |
| Karta: název, popis, cena | {název} · {text na kartě z kap. 1} · **{cena} bodů** |
| Karta: hodnota v Kč | U slev je hodnota v názvu. U prohlídky se Kč neukazuje, cena práce se liší podle auta; místo toho řádek „Práce zdarma, materiál zvlášť“. 2 000 Kč je jen interní hodnota pro report. |
| Dostupná odměna | \[Uplatnit za {cena} bodů\] · odkaz Podrobnosti |
| Nedostatek bodů | Pruh postupu · Chybí ti {rozdíl} bodů. · odkaz Jak získat body (stránka Získej body) · odkaz Podrobnosti. Bez neaktivního tlačítka. |
| Prázdný katalog | Odměny právě chystáme. Tvoje body počkají. |

### 7.2 Detail, potvrzení a výsledek

| Prvek | Text |
| --- | --- |
| Detail: záhlaví | {název} · {cena} bodů · EneServis |
| Detail: Co dostaneš | {rozsah služby z kap. 1} |
| Detail: Jak ho použiješ | Objednej se do EneServisu jako obvykle. Kód nadiktuj při objednání nebo při příjmu auta. EneServis ti odměnu odečte na účtu za zakázku. |
| Detail: Podmínky | Platí jednou, na jednu zakázku. · Nejde kombinovat s jinými slevami EneServisu. · Když zakázka stojí méně než sleva, rozdíl nevracíme. · {výluky z kap. 1} · Voucher můžeš dát i někomu jinému. · Platnost bez omezení. |
| Detail: Kde | Na všech provozovnách EneServis. {odkaz: Seznam provozoven} |
| Detail: nedostupná odměna | Tahle odměna už není v nabídce. Vouchery, které už máš, platí dál. \[Zobrazit odměny\] |
| Potvrzení: nadpis | Uplatnit {název}? |
| Potvrzení: text | Za {cena} bodů dostaneš voucher do EneServisu. Body ti odečteme hned a zbude ti {zůstatek po} bodů. |
| Potvrzení: poznámka | Nepoužitý voucher můžeš zrušit přes podporu, body ti vrátíme. |
| Potvrzení: tlačítka | \[Uplatnit za {cena} bodů\] \[Zpět\] |
| Probíhá vydání | Vystavuji voucher… (tlačítko neaktivní) |
| Úspěch | **Voucher je tvůj.** Kód: `{kód}`. Posíláme ti ho i e-mailem. V EneServisu ho stačí nadiktovat. Zbývá ti {zůstatek} bodů. · \[Zkopírovat kód\] \[Moje vouchery\] |
| Neúspěch (obecný) | Uplatnění se nepovedlo a body ti zůstaly. Zkus to prosím znovu za chvíli. |
| Neúspěch: málo bodů | Na tuhle odměnu ti teď chybí {rozdíl} bodů. Body ti zůstaly. |
| Neúspěch: odměna skončila | Tahle odměna mezitím skončila a body ti zůstaly. Vyber si jinou. |
| Neúspěch: pozastavený účet | Tvůj účet je pozastavený, odměny teď uplatnit nejde. Napiš nám na {kontakt podpory}. |
| Nejistý výsledek (vypršel čas odpovědi) | Nevíme jistě, jestli se voucher vystavil. Než to zkusíš znovu, podívej se do Moje vouchery. \[Moje vouchery\] |

### 7.3 Moje vouchery a voucher

| Prvek | Text |
| --- | --- |
| Nadpis | Moje vouchery |
| Vysvětlení | Všechny tvoje vouchery na jednom místě. Aktivní jsou nahoře. |
| Prázdný stav | Zatím tu žádný voucher není. Vyber si odměnu a body vyměň za voucher do EneServisu. \[Zobrazit odměny\] |
| Štítek stavu | Aktivní · Uplatněný · Zrušený |
| Voucher: údaje | {název} · EneServis · `{kód}` · Vydáno {datum} · Za {cena} bodů · Platnost: bez omezení |
| Voucher: pokyny (Aktivní) | Kód nadiktuj v EneServisu při objednání nebo při příjmu auta. Platí jednou, na jednu zakázku. Diktuj po znacích, písmena můžeš hláskovat, třeba B jako Božena. |
| Zkopírovat kód | \[Zkopírovat kód\] → Kód je zkopírovaný. |
| Uplatněný voucher | Uplatněno {datum} v EneServisu {provozovna}. Znovu ho použít nejde. (kód šedě) |
| Zrušený voucher | Zrušeno {datum}. {cena} bodů jsme ti vrátili. Voucher už použít nejde. (kód šedě) |

### 7.4 Nápověda a historie bodů

| Prvek | Text |
| --- | --- |
| Nápověda: dotazy | Potřebuješ pomoct s voucherem? Napiš nám na {e-mail podpory} nebo volej {telefon podpory}, {provozní doba}. Uveď kód voucheru. |
| Nápověda: zrušení | Chceš nepoužitý voucher zrušit? Napiš nám, body ti vrátíme celé. |
| Nápověda: reklamace služby | Máš výhrady ke službě v EneServisu? Reklamaci řeší přímo provozovna EneServis. |
| Nápověda: e-mail nepřišel | Kód máš vždy v Moje vouchery. E-mail je jen kopie, zkontroluj i složku s nevyžádanou poštou. |
| Historie bodů: uplatnění | {datum} · Voucher {název} · **−{cena}** |
| Historie bodů: storno | {datum} · Zrušený voucher {název} · **+{cena}** |

## 8. E-mail s voucherem

E-mail je servisní, ne obchodní: odchází jen po úspěšném vydání voucheru, i bez marketingového souhlasu (B7 kap. 2.1), a nesmí obsahovat nabídky. Text vychází z Brand Kitu, „EneOil Klub“ nahrazuje NAJETO.

| Prvek | Rozhodnutí |
| --- | --- |
| Jméno odesílatele | NAJETO od EneOil |
| Adresa odesílatele a reply-to | Doplní IT EneOil, reply-to = e-mail podpory \[OD-4\] |
| Předmět | Tvůj voucher: {název odměny} |
| Preheader | Kód {kód} platí bez omezení. V EneServisu ho stačí nadiktovat. |
| Pořadí obsahu | Logo NAJETO → nadpis → úvodní věta → box s kódem → Jak ho použiješ → údaje o voucheru → tlačítko → zůstatek → podpora a podmínky → patička |
| Úvodní věta podle odměny | Přezutí: Za 500 bodů máš slevu 200 Kč na přezutí v autoservisu EneServis. · Servis: Za 1 200 bodů máš slevu 500 Kč na servis v autoservisu EneServis. · Prohlídka: Za 5 000 bodů máš servisní prohlídku v autoservisu EneServis. Práce je zdarma, materiál platíš zvlášť. |
| HTML | Šířka 600 px, pozadí `surface`, karta `surface-raised`, logo PNG 32 px na veřejné URL. Kód v boxu `brand-soft` s rámečkem 2 px `brand`, monospace 24 px, letter-spacing 2 px. Tlačítko `brand` / `on-brand`, patička `steel` s bílým textem. |
| Textová verze | Stejný obsah jako níže, bez obrázků, odkazy vypsané. |
| Obrázky a alt texty | Logo NAJETO (alt „NAJETO, věrnostní program EneOil“), logo EneServis (alt „EneServis“). Vlastní loga, licence není potřeba. Další obrázky ne. |

Text e-mailu (příklad pro Slevu 200 Kč na přezutí, proměnné ve složených závorkách):

```markdown
Předmět: Tvůj voucher: Sleva 200 Kč na přezutí
Preheader: Kód ENE-7KQ4-M2XD platí bez omezení. V EneServisu ho stačí nadiktovat.

# Voucher je tvůj

Za 500 bodů máš slevu 200 Kč na přezutí v autoservisu EneServis.

Tvůj kód
ENE-7KQ4-M2XD

## Jak ho použiješ
1. Objednej se do EneServisu jako obvykle.
2. Kód nadiktuj při objednání nebo při příjmu auta.
3. EneServis ti odměnu odečte na účtu za zakázku.

Odměna: Sleva 200 Kč na přezutí
Partner: EneServis, autoservis
Za: 500 bodů
Vydáno: 6. 11. 2026
Platnost: bez omezení

Voucher platí jednou, na jednu zakázku. Můžeš ho dát i někomu jinému.

[Zobrazit v NAJETO] → {odkaz na Moje vouchery}

Zbývá ti 740 bodů.

Dotazy k voucheru: {e-mail podpory} · {telefon podpory}
Podmínky programu: {odkaz /podminky-programu}

---
NAJETO · věrnostní program EneOil · Máš najeto na víc.
EneOil a.s., [sídlo], IČO [doplní legal]
Tenhle e-mail dostáváš k voucheru z tvého účtu NAJETO.
Zásady ochrany osobních údajů: {odkaz}
```

Patička nemá odkaz na odhlášení, protože nejde o obchodní sdělení \[L\]. Nedoručení e-mailu nemění voucher ani body. Zdrojem pravdy je Moje vouchery a nápověda to členovi říká (kap. 7.4).

## 9. UX a vizuální podklady

Mobilní návrh odměn zatím neexistuje; platí obsahová hierarchie níže a tokeny Brand Kitu, komponenty navrhne UX a vývojový tým. Design source of truth (B6) je stejný jako v B7: Brand Kit EneOil + NAJETO brand v2, u názvu, claimu a loga má přednost NAJETO v2.

**Katalog (shora dolů):**

1. Zůstatek bodů (Noto Sans Mono) a odkaz Moje vouchery s počtem aktivních voucherů.
2. Nadpis a úvodní text, sbalitelný blok Jak to funguje.
3. Karty odměn vzestupně podle bodové ceny (500 → 1 200 → 5 000). Pořadí mění loyalty manažer konfigurací.

**Zvýraznění:** žádná odměna není „doporučená“. Karta, na kterou člen má body, má primární tlačítko. Karta, na kterou nemá, má pruh postupu `brand` na `brand-soft` a text, kolik chybí.

**Detail odměny:** záhlaví (logo EneServis, název, cena) → Co dostaneš → Jak ho použiješ → Podmínky → Kde → tlačítko. Na mobilu je tlačítko přichycené ke spodní hraně.

**Potvrzovací krok:** modal (desktop) nebo spodní panel (mobil). Velkým písmem cena v bodech a zůstatek po uplatnění. Primární tlačítko říká cenu, Zpět je stejně velké a předává fokus zpět na kartu.

**Moje vouchery:** Aktivní nahoře (nejnovější první), pod nimi Uplatněné a Zrušené ve sbalitelné sekci Použité a zrušené.

| Prvek | Vizuál |
| --- | --- |
| Voucher v portálu | Karta `surface-raised`, radius 16 px. Vlevo pruh `brand` se značkou EneOil, vpravo název (Archivo 700), kód v boxu `brand-soft` (Noto Sans Mono 20/28) s tlačítkem Zkopírovat kód, pod ním partner, datum vydání a platnost (`ink-muted`). Vychází z voucheru jako obrázku v Brand Kitu. |
| Štítky stavu | Aktivní: `green-soft` + `green-text` · Uplatněný: `line` + `ink-muted` · Zrušený: `line` + `ink-muted`. Zrušený není chyba, červená `minus` se nepoužívá. |
| Uplatněný a zrušený voucher | Bez pruhu `brand`, kód `ink-muted`, bez tlačítka Zkopírovat. |
| Ikony | Material Symbols (kap. 1), `ene-green`, dekorativní. Stav nikdy nenese jen barva, vždy i text štítku. |
| Fotky a ilustrace | Žádné (Brand Kit). |
| Logo EneServis | Podle logiky Brand Kitu („ene“ zeleně, „servis“ navy, pod tím „autoservis“). SVG a PNG dodá marketing \[OD-7\]. |
| Rozvržení | Mobile-first 360 px, dotykové prvky ≥ 44 px. Na šířce ≥ 768 px karty odměn ve 3 sloupcích, pod tím pod sebou. |
| PDF / obrázek voucheru | Není součástí B8 (bonus B11). Voucher je plně použitelný v portálu a e-mailu. |

## 10. Obchodní a právní podmínky

Návrh článku do podmínek programu NAJETO je ve vykání (Brand Kit) a ke schválení legal \[L\]. Údaje v hranatých závorkách doplní legal.

### 10.1 Článek „Odměny a vouchery“

> 1. Člen může body vyměnit za odměny z katalogu zveřejněného v portálu NAJETO. Poskytovatelem odměn je EneServis, s.r.o., \[sídlo, IČO\]. Bodová cena, rozsah a výluky každé odměny jsou uvedeny v katalogu.
> 2. Odměnu lze získat jen při dostatečném zůstatku bodů. Body se odečtou okamžitě po potvrzení. Člen obdrží jedinečný kód voucheru v portálu a e-mailem.
> 3. Voucher nemá omezenou platnost. Vyřazení odměny z katalogu nemá vliv na již vydané vouchery. Při ukončení programu nebo spolupráce se společností EneServis lze vydané vouchery uplatnit nejméně 6 měsíců ode dne oznámení.
> 4. Voucher lze uplatnit jednou, na jednu zakázku, na provozovnách EneServis. Nelze jej kombinovat s jinými slevami EneServis. Částečné čerpání, vrácení rozdílu ani výměna za peníze nejsou možné.
> 5. Voucher je přenosný. Za ochranu kódu odpovídá člen. Voucher uplatněný osobou, která kód předložila, se považuje za řádně uplatněný.
> 6. Odměna Servisní prohlídka zdarma zahrnuje práci na pravidelné servisní prohlídce podle plánu výrobce vozidla. Materiál a další práce hradí člen podle ceníku EneServis. Platí pro osobní vozidla a dodávky do 3,5 t.
> 7. Nepoužitý voucher může člen zrušit prostřednictvím podpory programu. Body se vrátí v původně odečtené výši. Uplatněný voucher zrušit nelze.
> 8. Reklamace služby uplatňujte u EneServis podle jeho reklamačního řádu. Dotazy a reklamace voucheru a bodů řeší podpora programu NAJETO \[kontakt\].

### 10.2 Ochrana osobních údajů

- EneServis od programu nedostává osobní údaje členů. Obsluha vidí jen kód, odměnu, stav a data voucheru (kap. 4).
- Číslo zakázky a provozovna se k voucheru ukládají kvůli vyúčtování a reklamacím. Legal potvrdí, zda stačí stávající zásady ochrany osobních údajů \[L\].

### 10.3 Odkazy

| Dokument | Umístění | Vlastník |
| --- | --- | --- |
| Podmínky programu NAJETO (článek 10.1) | `/podminky-programu` v portálu, odkaz z detailu odměny a z e-mailu | Legal EneOil + Petra Králová |
| Zásady ochrany osobních údajů | `/zasady-ochrany-osobnich-udaju` (stejná stránka jako v B7) | Privacy/legal EneOil |
| Seznam provozoven EneServis | Odkaz dodá EneServis \[OD-2\] | EneServis |

**Pro legal k posouzení \[OD-5\]:** přenosnost a odpovědnost za kód (bod 5), pojistka 6 měsíců místo expirace (bod 3), zda člen jako spotřebitel může od směny bodů odstoupit, a zda e-mail s voucherem smí být bez odhlašovacího odkazu.

## 11. Otevřená rozhodnutí

Osm bodů čeká na klienta, žádný ale implementaci neblokuje: do rozhodnutí platí preferovaná varianta a chybějící údaje jsou konfigurační hodnoty, které jde změnit bez nasazení kódu.

| ID | Otázka | Preferovaná varianta (platí do rozhodnutí) | Vlastník | Termín |
| --- | --- | --- | --- | --- |
| OD-1 | Výše ročního rozpočtu 2027 a vyúčtování s EneServisem | Rozpočet nese EneOil, EneServis fakturuje měsíčně hodnotu uplatněných voucherů. Testovací rozpočet 50 000 Kč na rok 2026. | Petra Králová | před ostrým spuštěním |
| OD-2 | Seznam provozoven EneServis a odkaz na něj | Všechny provozovny v ČR, odkaz jako konfigurační hodnota | Vedoucí provozu EneServis | před ostrým spuštěním |
| OD-3 | Kombinace s akcemi EneServisu, výluky, rozsah prohlídky a postup z kap. 4 | Podle kap. 1, 3 a 4 | Vedoucí provozu EneServis | do verze 1.0 |
| OD-4 | Kontakty podpory (e-mail, telefon, provozní doba), kontakt pro partnery, adresa odesílatele | Zástupné hodnoty v konfiguraci, stejné jako v B7 | Petra Králová + IT EneOil | před ostrým spuštěním |
| OD-5 | Právní posouzení kap. 3 a 10 | Návrh v tomto dokumentu | Legal EneOil | před ostrým spuštěním |
| OD-6 | Formální schválení marketingem a vlastníkem programu | Návrh v. 0.9 | Petra Králová | 6. 11. 2026 15:30 (demo) |
| OD-7 | Logo EneServis v SVG a PNG | V demu textové logo podle logiky Brand Kitu | Marketing EneOil | před ostrým spuštěním |
| OD-8 | Ověření obsluhou (FR-E6-06) jako MUST a storno back-office (FR-E6-07) jako SHOULD ve v1 | Ano, viz R-08 a R-10 | Lukáš Vavřín, garant | checkpoint hackathonu |

## 12. Schvalovatelé, verze a akceptace

Verze 0.9 z 6. 11. 2026 je návrh ke schválení; verze 1.0 vznikne po schválení všemi schvalovateli. Do té doby platí tento návrh jako preferovaná varianta pro implementaci.

| Role | Jméno | Co schvaluje | Stav |
| --- | --- | --- | --- |
| Zpracovatel | Matěj Kováčik, Enehano (tým 2A) | Úplnost a konzistence s FR, SD a B7 | Zpracováno 6. 11. 2026 |
| Marketing | Petra Králová, Head of Loyalty, EneOil | Katalog, texty, e-mail, UX, brand | Čeká \[OD-6\] |
| Vlastník programu | Petra Králová, Head of Loyalty, EneOil | Rozpočet, platnost, storno a vracení bodů | Čeká \[OD-1, OD-6\] |
| Provoz partnera | Vedoucí provozu EneServis (jméno doplní klient) | Kap. 1 (rozsah, výluky), kap. 4, provozovny | Otevřené \[OD-2, OD-3\] |
| Legal / privacy | Legal a pověřenec EneOil a.s. (jméno doplní klient) | Kap. 3 a 10 | Otevřené \[OD-5\] |
| Rozsah (hackathon) | Lukáš Vavřín, garant | Rozsah B8, FR-E6-06 a FR-E6-07 ve v1 | Čeká na checkpoint \[OD-8\] |

### 12.1 Kontrola proti akceptaci B8

| Kritérium | Kde |
| --- | --- |
| Každá odměna má název, bodovou cenu, CZK hodnotu, popis a podmínky | 1 |
| Rozpočet a dostupnost: report, nebo vynucení | 2 (jen report) |
| Platnost, použití, storno a vracení bodů | 3 |
| Provozní postup EneServisu | 4 (schválení EneServisem: OD-3) |
| Stavy voucheru a jejich význam | 5 |
| Viditelná podoba kódu | 6 |
| Texty pro katalog, potvrzení, chyby a Moje vouchery | 7 |
| Obsah e-mailu | 8 |
| Podklady pro mobil v souladu s B6 | 9 |
| Vlastníci, schvalovatelé, verze, datum | Shrnutí, 12 |

### 12.2 Změny oproti FR a SD (pro implementační tým)

| Místo | Změna |
| --- | --- |
| BR-50, OP-09 | Hodnota prohlídky 2 000 Kč potvrzena, rozsah definován (práce zdarma, materiál zvlášť). |
| BR-57, FR-E6-05 | Stav „Vydaný“ se jmenuje „Aktivní“. Člen vidí i stav Zrušený s informací o vrácených bodech. |
| FR-E6-01 | Místo neaktivního tlačítka pruh postupu, text „Chybí ti {rozdíl} bodů“ a odkaz Jak získat body. |
| FR-E6-02 | Úspěch říká „Posíláme ti ho i e-mailem“ místo „Poslali jsme“. Nové texty pro málo bodů, ukončenou odměnu, pozastavený účet a nejistý výsledek. |
| FR-E6-04 | NAJETO místo EneOil Klub, tlačítko „Zobrazit v NAJETO“, údaje o voucheru, pokyny a podmínky v e-mailu. |
| FR-E6-06 | SHOULD → MUST. Obsluha nevidí jméno člena. Povinná provozovna a číslo zakázky při uplatnění. |
| FR-E6-07 | COULD → SHOULD. Číselník důvodů storna (kap. 3). Bez něj stav Zrušený nevznikne a storno se řeší ruční úpravou bodů. |
