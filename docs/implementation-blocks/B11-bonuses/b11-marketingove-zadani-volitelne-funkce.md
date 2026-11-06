# B11 — Marketingové zadání: Volitelné funkce

6. 11. 2026 · Matěj Kováčik

## Shrnutí

Ze čtyř volitelných funkcí jde do v1 a dnešního dema jen voucher jako PDF. Expirace bodů a storno transakcí jsou schválené k ostrému spuštění. Členské úrovně Okreska / Dálnice se odkládají do etapy 2, až budou data pro nastavení prahu. Formálně musí rozhodnutí ještě schválit Petra Králová, finance a legal (kap. 8).

|  |  |
| --- | --- |
| Projekt | Věrnostní program NAJETO (EneOil), AI Hackathon 2026, tým 2A |
| Dokument | Odpověď marketingu a produktu na zadání B11 (`OPTIONAL_FEATURES_MARKETING_BRIEF.md`) |
| Verze | 0.9 · návrh ke schválení · 6. 11. 2026 |
| Vlastník dokumentu | Matěj Kováčik (Enehano, tým 2A) |
| Navazuje na | `specifikace/eneoil-klub-funkcni-zadani.md` (BR-41, BR-42, BR-60 až BR-62, FR-E2-06, FR-E9-08, FR-E10), `EneOil-Klub-Solution-Design.docx` (kap. 15), B7 (`specifikace/b7-marketingove-zadani-aktivity.md`), B8 (`specifikace/b8-marketingove-zadani-odmeny.md`), Brand Kit EneOil, NAJETO brand v2 |

Značení: **\[R\]** rozhodnuto · **\[L\]** musí schválit legal · **\[F\]** musí schválit finance · **\[OD-n\]** otevřené rozhodnutí (kap. 8).

| # | Rozhodnutí | Stav |
| --- | --- | --- |
| R-01 | Voucher jako PDF je schválený pro v1 a demo. Výstupem je jen PDF ve formátu A6 na šířku, obrázek PNG ne. | \[R\] |
| R-02 | PDF se stahuje v Moje vouchery jen u Aktivního voucheru a přikládá se k e-mailu s voucherem. | \[R\] + \[OD-8\] |
| R-03 | PDF neobsahuje osobní údaje ani QR kód. Při každém stažení vypadá stejně jako při vydání. | \[R\] |
| R-04 | Expirace je schválená k ostrému spuštění. Body propadnou přesně 1 rok od připsání, při uplatnění odměny se berou nejdřív nejstarší (FIFO). | \[R\] + \[L\] |
| R-05 | Body připsané před účinností pravidla propadnou nejdřív 1 rok od účinnosti. Žádná ochranná lhůta ani výjimky, vrácení jen při chybě programu. | \[R\] + \[L\] |
| R-06 | Člen vidí propadající body v portálu trvale. E-mail chodí 1× měsíčně, když mu v příštím měsíci propadne aspoň 50 bodů. Expirace je v historii samostatný řádek. | \[R\] + \[L\] |
| R-07 | Vrácené body (zrušený voucher, uznaná reklamace) platí 1 rok ode dne vrácení. | \[R\] |
| R-08 | Storno je schválené k ostrému spuštění. Zadává ho jen loyalty manažer a vždy ruší celou transakci. Částečné vrácení = storno + opravná transakce. | \[R\] + \[F\] |
| R-09 | Storno odebere body za nákup, kampaně i úroveň. Zůstatek neklesne pod 0, body, které na účtu chybí, se odepíší a vykážou v reportu. | \[R\] + \[F\] |
| R-10 | Voucher pořízený z odebraných bodů zůstává platný. Při podezření na zneužití loyalty manažer pozastaví účet. | \[R\] |
| R-11 | O každém stornu, které sníží zůstatek, dostane člen servisní e-mail s důvodem a uvidí řádek v historii. | \[R\] + \[L\] |
| R-12 | Úrovně jsou odložené do etapy 2, nejdřív 6 měsíců po spuštění. Názvy Okreska a Dálnice jsou potvrzené, práh a benefit se nastaví podle reálných dat. | \[R\] + \[OD-6, OD-7\] |
| R-13 | Do úrovně se počítají jen základní body za nákupy, bez kampaní. Dálnice platí 12 měsíců od posledního splnění prahu, změna úrovně nikdy nemění zůstatek. | \[R\] |
| R-14 | Texty pro člena vystupují pod značkou NAJETO, v tykání a podle pravidel B7 a B8. | \[R\] |

## 1. Rozsah a priorita

Pořadí realizace je voucher PDF → expirace → storno → úrovně. Storno se oproti doporučení zadání posouvá před úrovně, protože bez něj nejde ostrý provoz s pokladnami. Úrovně naopak potřebují data, která zatím nemáme.

| Kandidát | Rozhodnutí | Priorita | Obchodní vlastník | Cílová etapa |
| --- | --- | --: | --- | --- |
| Voucher jako PDF nebo obrázek | Schváleno (jen PDF) | 1 | Petra Králová, Head of Loyalty | v1, demo 6. 11. 2026 |
| Expirace bodů | Schváleno | 2 | Petra Králová + finanční ředitel EneOil | Ostré spuštění |
| Storno transakce a bodů | Schváleno | 3 | Petra Králová + finance + provoz podpory | Ostré spuštění |
| Členské úrovně | Pozdější etapa | 4 | Petra Králová | Etapa 2, nejdřív 6 měsíců po spuštění |

| Kandidát | Přínos pro člena | Přínos pro program | Proč právě tahle etapa |
| --- | --- | --- | --- |
| Voucher PDF | Voucher je přenosný (B8 R-06), PDF z něj dělá dárek, který jde vytisknout nebo poslat. Kód má po ruce i bez přihlášení. | Značka NAJETO a EneServis i mimo portál. Nemění pravidla bodů ani proces v EneServisu. | Jediná funkce, kterou jde stihnout do 15:30 bez zásahu do výpočtu bodů. |
| Expirace | Jasné datum, dokdy body využít. Motivace vyměnit body za voucher, který nepropádá. | Omezuje závazek z nevyčerpaných bodů. Dává finančnímu řediteli metriku breakage pro rozpočet na další rok. | Pravidlo musí být v podmínkách od prvního dne, pozdější zavedení by bylo zpětnou změnou podmínek. První body propadnou až rok po spuštění. |
| Storno | Férový zůstatek a vysvětlený každý odečet. | Oprava vráceného nákupu, duplicitního importu a nákupu přiřazeného jinému členovi s vazbou na transakci a kampaně. | Vrácení nákupů přijde hned s ostrým provozem. Pro demo stačí ruční úprava bodů (BR-62). |
| Úrovně | Body navíc pro řidiče, kteří tankují nejčastěji. | Udržení nejcennějších členů. Benefit ale zvyšuje náklad programu. | Práh je bez dat jen odhad (kap. 4.1). Benefit se po spuštění těžko bere zpět, proto ho nastavíme až podle skutečného chování členů. |

Ruční úprava bodů (bonus ze zadání hackathonu) není kandidátem B11. Je v rozsahu v1 jako SHOULD (BR-62) a používá se pro reklamace expirace i výjimky ze storna.

## 2. Voucher jako PDF

Každý vydaný voucher má PDF ve formátu A6 na šířku s kódem, odměnou a pokyny. Člen ho stáhne v Moje vouchery a dostane ho v příloze e-mailu. Slouží k tisku, darování a k ukázání kódu bez přihlášení. Uplatnění v EneServisu se nemění, obsluha dál zadává kód do Salesforce (B8 kap. 4).

### 2.1 Pravidla

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| PDF, obrázek, nebo obojí | Jen PDF. Má textovou vrstvu (čtečky obrazovky, kopírování kódu), tiskne se ve správné velikosti a jde přiložit k e-mailu. Obrázek by nepřidal nic, co PDF neumí. |
| Účel a použití | Ukázat kód při příjmu auta bez přihlášení do portálu, vytisknout, darovat. Voucher je přenosný (B8 R-06), kdo kód nadiktuje, voucher uplatní. |
| Kde je soubor | Portál: tlačítko Stáhnout PDF v Moje vouchery, jen u stavu Aktivní. E-mail s voucherem (B8 kap. 8): PDF v příloze \[OD-8\]. Když se PDF nepodaří vytvořit, e-mail odejde bez přílohy a voucher platí dál. |
| Opakované stažení | Obsah je vždy stejný jako při vydání: název odměny, kód, datum vydání, platnost. Změna katalogu ho nezmění (B8 kap. 2, historická hodnota). |
| Stav voucheru | PDF stav neukazuje. O platnosti rozhoduje evidence programu, obsluha ji ověří podle kódu. U Uplatněného a Zrušeného voucheru se PDF stáhnout nedá. |
| Osobní údaje | Žádné. Bez jména, čísla člena, e-mailu a zůstatku, protože PDF může putovat k jiné osobě. |
| QR nebo čárový kód | Ne. Obsluha kód zadává ručně a čtečky na provozovnách nejsou (B8 R-11). QR je roadmapa spolu se skenováním v Salesforce. |
| Tisk | A6 na šířku (148 × 105 mm), okraje aspoň 5 mm. Čitelné i černobíle, kód je `ink` na `brand-soft`. Vytisknout jde i na A4 (v měřítku 100 % nebo přizpůsobení stránce). |
| Mobil | PDF se otevře v prohlížeči telefonu. Kód je největší prvek stránky (Noto Sans Mono 28 pt), čitelný bez přibližování na displeji širokém 360 px. |
| Název souboru | `najeto-voucher-ENE-7KQ4-M2XD.pdf` |

### 2.2 Obsah a vizuál

Rozvržení vychází z Brand Kitu (kap. Voucher jako obrázek / PDF) a z voucheru v portálu (B8 kap. 9). Místo „EneOil Klub“ nese NAJETO (B7 R-01).

| Pořadí | Prvek | Obsah | Vizuál |
| --: | --- | --- | --- |
| 1 | Levý pruh | Značka EneOil | Plocha `brand`, šířka 1/4 voucheru, radius 16 px vnějších rohů |
| 2 | Perforace | – | Přerušovaná linka `line` mezi pruhem a obsahem, dekorativní |
| 3 | Záhlaví | Wordmark NAJETO · „věrnostní program EneOil“ | Wordmark s oranžovou tečkou, podtitul `ink-muted` 9 pt |
| 4 | Název odměny | např. Sleva 200 Kč na přezutí | Archivo 800, 20 pt, `ink` |
| 5 | Upřesnění | Jen u prohlídky: „Práce zdarma, materiál zvlášť“ | Noto Sans 10 pt |
| 6 | Kód | Popisek „Kód voucheru“ + `ENE-7KQ4-M2XD` | Box `brand-soft`, rámeček 2 px `brand`, Noto Sans Mono 28 pt, pomčky ponechané |
| 7 | Údaje | Uplatníš v: EneServis · Vydáno {datum} · Platnost: bez omezení | Noto Sans 9 pt, `ink-muted` |
| 8 | Pokyny | Text 2.3 | Noto Sans 9 pt, `ink` |
| 9 | Patička | Podmínky, kontakt, logo EneServis vpravo | Noto Sans 7 pt, logo EneServis 24 px vysoké |

- **Písma:** Archivo, Noto Sans a Noto Sans Mono vložené v PDF. Licence SIL Open Font License 1.1, vložení do PDF je povolené.
- **Loga:** NAJETO, značka EneOil a EneServis jsou vlastní, licence není potřeba. Logo EneServis v SVG dodá marketing (B8 OD-7), do té doby textové logo podle logiky Brand Kitu.
- **Fotky a ilustrace:** žádné (Brand Kit).
- **Přístupnost:** označkované PDF (tagged), jazyk dokumentu čeština, titulek „Voucher NAJETO: {název odměny}“. Pořadí čtení název → kód → údaje → pokyny → patička. Alt text log „NAJETO, věrnostní program EneOil“ a „EneServis“, pruh a perforace jsou dekorace. Kód je text, ne obrázek. Kontrast podle Brand Kitu ≥ 4,5 : 1.
- **Nic jen v obrázku:** všechny údaje z PDF jsou i v portálu a v e-mailu.

### 2.3 Texty

| Místo | Text |
| --- | --- |
| Krátký popis funkce | Voucher máš i jako PDF. |
| Podrobný popis funkce | Každý aktivní voucher si můžeš stáhnout jako PDF a vytisknout ho nebo poslat. Kód v PDF je stejný jako v portálu a platí jednou. |
| Moje vouchery: tlačítko (Aktivní) | Stáhnout PDF |
| Moje vouchery: popisek pod tlačítkem | Na tisk nebo jako dárek. Kód platí jednou. |
| Příprava souboru | Připravuji PDF… (tlačítko neaktivní) |
| Chyba stažení | PDF se nepodařilo připravit. Kód máš výš, platí i bez PDF. Zkus to prosím znovu za chvíli. |
| E-mail s voucherem: věta pod boxem s kódem | Voucher máš i v příloze jako PDF, třeba na vytištění. (Jen když příloha opravdu odchází.) |
| Nápověda: Můžu voucher darovat? | Ano. Stáhni si PDF a vytiskni ho nebo pošli. Kdo kód nadiktuje v EneServisu, voucher uplatní. Platí jednou, na jednu zakázku. |
| PDF: pokyny | Kód nadiktuj v EneServisu při objednání nebo při příjmu auta. EneServis ti odměnu odečte na účtu za zakázku. |
| PDF: patička | Platí jednou, na jednu zakázku, nejde kombinovat s jinými slevami EneServisu. Platnost ověří obsluha podle kódu. Podmínky: {odkaz na podmínky programu} · Dotazy: {e-mail podpory} |

Vlastník obsahu: Petra Králová (marketing). Schvalovatel textu patičky: legal \[L\].

## 3. Expirace bodů

Body propadnou přesně 1 rok od připsání a při uplatnění odměny se spotřebují nejdřív ty nejstarší. Pravidlo platí od ostrého spuštění, první body tedy propadnou nejdřív rok po něm. Člen vidí v portálu vždy konkrétní počet bodů a datum, ne obecné upozornění (poučení ze Shell ClubSmart, FR BR-61).

### 3.1 Pravidla

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| Přesně jeden rok od připsání | Ano. Body připsané dne D propadnou dne D + 1 rok (29. 2. → 28. 2.). Využít je jde naposledy den předtím. Datum připsání je datum pohybu, u nákupu datum nákupu (BR-43). |
| Které body propadají | Všechny připsané: nákupy, kampaně, aktivity, kladné ruční úpravy, vrácené body a v etapě 2 bonus Dálnice. Vydané vouchery nepropádají (B8 R-05). |
| Body získané před spuštěním funkce | Propadnou nejdřív 1 rok ode dne účinnosti pravidla. Týká se pilotu, historických nákupů importovaných se starším datem a jednorázové dávky za aktivity (B7 R-05). |
| Část bodů už využitá | Uplatnění odměny bere nejdřív body, které propadnou nejdřív (FIFO). Propadne jen nevyužitý zbytek. Příklad: 100 bodů připsaných 1. 1. a 50 bodů 1. 3., 1. 2. voucher za 80 bodů. Za rok propadne 1. 1. 20 bodů a 1. 3. 50 bodů. |
| Vrácené body | Body vrácené za zrušený voucher (B8 R-10) nebo po uznané reklamaci platí 1 rok ode dne vrácení. Pro člena jednoduché, zneužití brzdí to, že storno voucheru jde jen přes podporu. |
| Ochranná lhůta, výjimky | Žádné. Pozastavení účtu expiraci nezastavuje. Když bylo pozastavení neoprávněné, body se vrátí jako reklamace. |
| Vztah k úrovním (etapa 2) | Expirace nesnižuje qualifying body. |
| Vztah ke stornu | Storno nákupu odebírá body bez ohledu na jejich platnost (kap. 5). Párování na jednotlivé přídely řeší implementace. |
| Reklamace | Přes podporu NAJETO do 3 měsíců od expirace. Rozhoduje loyalty manažer, nad 1 000 bodů Petra Králová. Body se vrací jen při chybě programu (špatné datum, chyba dávky, neoprávněné pozastavení, chybějící údaj v portálu), ruční úpravou s důvodem Oprava expirace. Nedoručený e-mail důvodem není, zdrojem pravdy je portál. |
| Podmínky a účinnost | Článek Platnost bodů (kap. 7.2), účinný dnem ostrého spuštění \[OD-9\] \[L\]. |

### 3.2 Upozornění a kanály

| Kdy | Kanál | Obsah |
| --- | --- | --- |
| Trvale | Portál, Přehled pod zůstatkem | Nejbližší propadající body v příštích 90 dnech: počet a datum. Když nic nepropadá, řádek se nezobrazí. |
| Trvale | Portál, Historie bodů | Sekce Brzy propadne (90 dní dopředu po dnech) a řádky proběhlé expirace. |
| Trvale | Portál, katalog odměn | Věta o propadajících bodech, když na některou odměnu stačí. |
| 1× měsíčně, první pracovní den | Servisní e-mail | Když členovi v následujícím kalendářním měsíci propadne aspoň 50 bodů \[OD-5\]. Upozornění tedy přijde 1 až 2 měsíce předem. |
| Po expiraci | Portál | Řádek v historii a jednorázový pruh na Přehledu při dalším přihlášení. E-mail ne. |

- **Proč souhrnně 1× měsíčně:** každý nákup je samostatný příděl. Upozornění na každý příděl zvlášť by aktivnímu členovi chodilo skoro denně.
- **Servisní e-mail:** informace o stavu účtu, odchází i bez marketingového souhlasu, bez nabídek a bez odhlašovacího odkazu, stejně jako e-mail s voucherem (B8 kap. 8). Odkaz Zobrazit odměny v něm posoudí legal \[L\].
- **SMS a push:** nepoužíváme, program je nemá.

### 3.3 Texty v portálu

Skloňování: 1 bod ti propadne · 2 až 4 body ti propadnou · 0 a 5 a víc bodů ti propadne. Po expiraci: propadl 1 bod · propadly 2 až 4 body · propadlo 5 a víc bodů. Datum v textech je vždy den, kdy body z účtu zmizí.

| Místo | Text |
| --- | --- |
| Krátký popis pravidla | Body platí 1 rok od připsání. |
| Podrobný popis (nápověda Kdy body propadají) | Body platí 1 rok ode dne, kdy ti je připíšeme. Když uplatníš odměnu, použijeme nejdřív body, které propadnou nejdřív. Propadne jen to, co do té doby nevyužiješ. U bodů vždy uvidíš datum, kdy z účtu zmizí, využít je můžeš ještě den předtím. Vouchery nepropádají. |
| Jak to funguje (onboarding, kroky odměn) | Body platí 1 rok. Kdy propadnou, uvidíš vždy u zůstatku. |
| Přehled: řádek pod zůstatkem | {počet} bodů ti propadne {datum}. · odkaz Podrobnosti |
| Historie: nadpis sekce | Brzy propadne |
| Historie: řádek sekce | {datum} · {počet} bodů |
| Historie: prázdná sekce | V příštích 90 dnech ti nic nepropadne. |
| Historie: řádek expirace | {datum} · Propadlé body připsané {datum připsání} · **−{počet}** |
| Přehled: pruh po expiraci (jednou) | {datum} ti propadlo {počet} bodů připsaných před rokem. · \[Rozumím\] · odkaz Kdy body propadají |
| Katalog: má propadající body a stačí na odměnu | {počet} bodů ti propadne {datum}. Vyměň je za voucher, ten platí bez omezení. |
| Nápověda: reklamace | Myslíš, že ti body propadly neprávem? Napiš nám do 3 měsíců na {e-mail podpory} a uveď datum z historie bodů. |
| Historie: vrácení po reklamaci | {datum} · Vrácené propadlé body · **+{počet}** |
| Podpora: odpověď na uznanou reklamaci | {počet} bodů jsme ti vrátili. Platí 1 rok, do {datum}. |
| Podpora: odpověď na zamítnutou reklamaci | Body propadly podle pravidla, platí 1 rok od připsání. Datum bylo v portálu vidět od {datum prvního zobrazení}. Vrátit je proto nemůžeme. |

### 3.4 E-mail před expirací

| Prvek | Rozhodnutí |
| --- | --- |
| Odesílatel a reply-to | NAJETO od EneOil, reply-to e-mail podpory (jako B8) |
| Předmět | V {měsíc v 6. pádě} ti propadne {počet} bodů |
| Měsíce | v lednu · v únoru · v březnu · v dubnu · v květnu · v červnu · v červenci · v srpnu · v září · v říjnu · v listopadu · v prosinci |
| Preheader | Využij je včas. Voucher do EneServisu platí bez omezení. |
| Rozpis | Po dnech, nejvýš 5 řádků, zbytek jedním řádkem „a další {počet} bodů do {datum}“ |
| Věta o odměně | Když zůstatek stačí: název nejdražší dostupné odměny. Když ne: kolik chybí do nejlevnější. |
| HTML a textová verze | Jako B8 kap. 8: 600 px, karta `surface-raised`, čísla Noto Sans Mono, tlačítko `brand` / `on-brand`, patička `steel`. Číslo bodů v e-mailu `ink`, ne `minus`, zatím nic nepropadlo. |

Text e-mailu (příklad, odesláno 1. 11. 2027):

```markdown
Předmět: V prosinci ti propadne 120 bodů
Preheader: Využij je včas. Voucher do EneServisu platí bez omezení.

# V prosinci ti propadne 120 bodů

Body platí 1 rok od připsání. Tyhle ti přibyly v prosinci 2026.

Propadne 3. 12. 2027 ........ 45 bodů
Propadne 15. 12. 2027 ....... 75 bodů
Celkem ..................... 120 bodů

Využít je můžeš vždy nejpozději den před uvedeným datem.

Máš 740 bodů. Na voucher Sleva 200 Kč na přezutí ti stačí.
Voucher použije nejdřív právě body, které propadají.

[Zobrazit odměny] → {odkaz na Odměny}

Dotazy: {e-mail podpory} · {telefon podpory}
Podmínky programu: {odkaz /podminky-programu}

---
NAJETO · věrnostní program EneOil · Máš najeto na víc.
EneOil a.s., [sídlo], IČO [doplní legal]
Tenhle e-mail dostáváš, protože máš účet NAJETO a blíží se konec platnosti tvých bodů.
Zásady ochrany osobních údajů: {odkaz}
```

### 3.5 UX a vizuál

- **Přehled, mobil shora dolů:** zůstatek (Noto Sans Mono 48 px) → řádek expirace → pruh postupu k nejbližší odměně → akce. Na desktopu stejné pořadí v levém sloupci.
- **Řádek expirace:** ikona `schedule` (Material Symbols) a text `brand-text`. Upozornění není chyba, červená `minus` se používá jen pro už propadlé body v historii (Brand Kit).
- **Pruh po expiraci:** podklad `brand-soft`, text `ink`, ikona `info`, tlačítko Rozumím. Zobrazí se jednou.
- **Stav nikdy jen barvou:** u každého čísla je i slovo (propadne, propadlé).

Vlastník pravidel: Petra Králová + finance \[F\]. Vlastník textů: Petra Králová. Schvalovatel: legal \[L\].

## 4. Členské úrovně (pozdější etapa)

Úrovně Okreska a Dálnice odkládáme do etapy 2, nejdřív 6 měsíců po spuštění. Ve v1 se nic z této kapitoly neimplementuje ani nekomunikuje. Pravidla níže jsou preferovaná varianta, práh a benefit se před startem etapy potvrdí na ostrých datech \[OD-6, OD-7\].

### 4.1 Pravidla (preferovaná varianta)

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| Počet, názvy | Dvě úrovně: **Okreska** (každý nový člen) a **Dálnice** (vyšší). Názvy jsou potvrzené (Brand Kit, BR-60). Třetí úroveň ne, s jedním partnerem a jedním benefitem by neměla obsah. |
| Co se počítá (qualifying body) | Jen základní body za nákupy (palivo + ostatní) za posledních 12 měsíců. Nepočítají se kampaně, aktivity, ruční úpravy, vrácené body ani bonus Dálnice. Storno qualifying body snižuje, uplatnění odměny a expirace ne. |
| Proč bez kampaní | Práh nesmí záviset na tom, jaké kampaně zrovna běží. S kampaněmi (varianta FR) by na 2 000 bodů stačilo zhruba 21 tankování po 45 l ročně (45 + 50 = 95 bodů za tankování), tedy plnou nádrž každé 2 až 3 týdny. Dálnici by měl skoro každý pravidelný zákazník. Pro člena je pravidlo „1 litr = 1 bod do úrovně“ srozumitelnější. |
| Práh | 2 000 qualifying bodů za 12 měsíců (parametr). Odpovídá zhruba 2 000 l paliva, při spotřebě 7 l / 100 km asi 28 000 km ročně. Cíl kalibrace: Dálnici má 10 až 20 % aktivních členů \[OD-6\]. |
| Období kvalifikace | Klouzavých 12 měsíců ke dni vyhodnocení. Žádný kalendářní reset (poučení z MOL Move). |
| Postup | Hned po zpracování nákupu, kterým člen práh dosáhne. Benefit platí od dalšího nákupu. |
| Platnost a udržení | Dálnice platí do konce měsíce, ve kterém člen práh splnil naposledy, + 12 měsíců. Vyhodnocení probíhá 1. den každého měsíce, každé splnění platnost posune. Příklad: postup 14. 3. 2028 → Dálnice do 31. 3. 2029; splněno i 1. 4. 2028 → do 30. 4. 2029. |
| Pokles | Den po konci platnosti je člen zpět na Okresce. Zůstatek, vouchery, historie ani expirace bodů se nemění. Na Dálnici se vrátí kdykoli znovu splní práh. |
| Proč garance místo měsíčního sestupu (FR) | Bez garance by člen, který práh právě dosáhl, mohl za měsíc spadnout, až mu vypadne nejstarší měsíc. Datum „Dálnici máš do…“ se dá jednoduše komunikovat. |
| Benefit Okreska | Celý základní program. |
| Benefit Dálnice | Body za palivo × 1,2 (+20 %), zaokrouhleno dolů za každý nákup. Samostatný řádek v rozpisu i v historii. Nenásobí se kampaněmi a kampaně nenásobí jeho. Příklad T01: 109 + 9 = 118 bodů (floor(45 × 1,2) − 45 = 9). |
| Udržitelnost benefitu | Při hodnotě bodu 0,40 Kč (B8) stojí Dálnice člena s 2 000 l ročně asi 400 bodů, tedy 160 Kč za rok. Další benefity (např. přednostní termín v EneServisu) jen po písemném závazku EneServisu, do té doby se nekomunikují \[OD-7\] \[F\]. |
| Změna nebo ukončení výhod | Oznámení aspoň 30 dní předem v portálu a e-mailem. Dosažená Dálnice platí do svého data, připsané body zůstávají \[L\]. |
| Start etapy 2 | Zpětné vyhodnocení 12 měsíců. Kdo práh splňuje, začíná na Dálnici s platností podle pravidla výše. |
| Informování | Postup: pruh v portálu + servisní e-mail. Blížící se konec platnosti: e-mail 1. den posledního měsíce, když člen práh zrovna nesplňuje. Pokles: jen pruh v portálu, člen už byl upozorněný. |

### 4.2 Texty (návrh pro etapu 2)

| Místo | Text |
| --- | --- |
| Krátký popis | Tankuj často a jsi na Dálnici. Za palivo máš o 20 % bodů víc. |
| Podrobný popis | Každý člen začíná na Okresce. Když za 12 měsíců nasbíráš 2 000 bodů za nákupy (bez bonusů z akcí), posuneš se na Dálnici. Tam máš za každé tankování o 20 % bodů navíc. Dálnice platí 12 měsíců a každý měsíc, kdy práh splníš, se prodlouží. Body ani vouchery ti změna úrovně nikdy nevezme. |
| Karta Okreska | **Okreska** · Do Dálnice ti chybí {rozdíl} bodů. · {qualifying} z 2 000 bodů za posledních 12 měsíců |
| Karta Dálnice, práh splněný | **Dálnice** · Jsi na Dálnici. Za každé tankování máš body navíc. · Dálnici máš do {datum}. |
| Karta Dálnice, práh nesplněný | **Dálnice** · Dálnici máš do {datum}. Na prodloužení ti teď chybí {rozdíl} bodů. |
| Postup (pruh i e-mail, předmět „Jsi na Dálnici“) | **Jsi na Dálnici.** Od dalšího tankování máš za palivo o 20 % bodů víc. Dálnici máš do {datum}. |
| E-mail před koncem platnosti (předmět) | Dálnici máš do {datum} |
| E-mail před koncem platnosti (text) | Na prodloužení ti chybí {rozdíl} bodů za nákupy. Když je nasbíráš do {datum}, Dálnice ti zůstane dalších 12 měsíců. Body a vouchery ti zůstanou v každém případě. |
| Pokles (pruh) | Od {datum} jsi zase na Okresce. Body, vouchery i historie ti zůstaly. Na Dálnici se vrátíš s 2 000 body za nákupy za 12 měsíců. |
| Rozpis transakce | Bonus Dálnice (+20 % za palivo) ..... +9 |
| Historie | {datum} · Bonus Dálnice · **+{body}** |

### 4.3 Vizuál a umístění

| Prvek | Vizuál |
| --- | --- |
| Karta Okreska | `surface-raised`, štítek `green-soft` + `green-text`, ikona `alt_route` (Material Symbols), pruh postupu `brand` na `brand-soft` |
| Karta Dálnice | Plocha `steel` s bílým textem, vlevo pruh `brand`, ikona `speed`, název Archivo 800 |
| Umístění | Přehled pod zůstatkem a řádkem expirace, před pruhem k odměně. Detail úrovně na samostatné stránce s nápovědou. |
| Fotky a ilustrace | Žádné. Kapka a tachometr jen jako u zůstatku (Brand Kit). |

Vlastník: Petra Králová. Schvalovatelé před etapou 2: finance (benefit a rozpočet) \[F\], legal (článek Úrovně členství) \[L\].

## 5. Storno transakce a bodů

Storno zadává jen loyalty manažer v back-office a vždy ruší celou transakci. Vrácení části nákupu se řeší stornem a novou opravnou transakcí. O každém odečtu se člen dozví z historie bodů a ze servisního e-mailu s důvodem. Pravidla schvaluje vlastník programu, finance a provoz, marketing dodává texty.

### 5.1 Kdy se storno použije

| Situace | Postup | Důvod v číselníku |
| --- | --- | --- |
| Nákup zrušený na pokladně (storno účtenky) | Storno celé transakce | Zrušený nákup |
| Vrácení celého nákupu | Storno celé transakce | Vrácený nákup |
| Vrácení části nákupu | Storno + opravná transakce se správnými částkami a původním datem nákupu. Kampaně se vyhodnotí podle stavu v den nákupu. | Oprava nákupu |
| Duplicitní záznam (dvojí import) | Storno duplicitní transakce | Duplicitní záznam |
| Nákup přiřazený jinému členovi | Storno u špatného člena + nová transakce u správného | Nákup patří jinému účtu |
| Zneužití programu | Storno + pozastavení účtu | Porušení podmínek |

Příklad částečného vrácení: transakce T01 (45 l, ostatní 180 Kč, 109 bodů), člen vrátí zboží za 180 Kč. Storno odebere 109 bodů, opravná transakce (45 l, ostatní 0 Kč) připíše 95 bodů (45 + Natankuj plnou 50). Výsledná změna je −14 bodů.

Storno se nepoužívá pro reklamaci kvality paliva nebo zboží bez vrácení peněz. Body v takovém případě zůstávají.

### 5.2 Pravidla

| Otázka ze zadání | Rozhodnutí |
| --- | --- |
| Plné, nebo částečné storno | Vždy plné. Částečné = plné storno + opravná transakce (5.1). Není potřeba druhý způsob výpočtu kampaní. |
| Kdo zadá | Loyalty manažer v back-office, s povinným důvodem z číselníku a komentářem (číslo účtenky nebo reklamace). Člen, obsluha stanice ani EneServis storno nezadávají. |
| Kdo schválí | Do 1 000 bodů loyalty manažer sám. Nad 1 000 bodů a vždy u důvodu Porušení podmínek po souhlasu Petry Králové, zapsaném v komentáři. Finance dostává měsíční přehled storen \[F\] \[OD-3\]. |
| Kolikrát | Transakci lze stornovat jednou. Stornovanou nejde obnovit, jen zadat novou. |
| Co se odebere | Všechny body z transakce: základ, bonusy kampaní a v etapě 2 bonus Dálnice. Jeden pohyb typu Storno navázaný na transakci. Body za aktivity se nemění. V etapě 2 storno sníží i qualifying body. |
| Člen už body utratil | Storno se provede vždy. Odebere se nejvýš aktuální zůstatek, zůstatek neklesne pod 0 (BR-42). Zbytek se odepíše a v reportu se vykáže jako neodebrané body ze storna \[F\]. |
| Proč ne záporný zůstatek | Záporné číslo by člena mátlo a blokovalo by mu odměny za nové nákupy. Jde o malé částky (1 bod = 0,40 Kč). Transakce ale musí být v evidenci zrušená kvůli reportu a vyúčtování, proto storno neodmítáme (změna oproti FR-E2-06). |
| Voucher z dotčených bodů | Zůstává platný, může ho mít i jiná osoba (B8 R-06). Při podezření na zneužití loyalty manažer pozastaví účet. Zrušení Aktivního voucheru (důvod Chybné vydání, B8 kap. 3) schvaluje Petra Králová. |
| Vztah k expiraci | Storno odebírá body bez ohledu na jejich datum platnosti. Párování na přídely řeší implementace. |
| Informování člena | Vždy řádek v historii a štítek Stornováno v detailu transakce. Servisní e-mail vždy, když storno sníží zůstatek. U opravné transakce jeden e-mail se souhrnem \[L\]. |
| Reklamace a náprava | Přes podporu NAJETO do 3 měsíců od e-mailu. Loyalty manažer ověří s provozem stanice. Chybné storno opraví novou transakcí s původními údaji, body se vrátí včetně kampaní. |
| Jak se loyalty manažer o vrácení dozví | Do integrace pokladen hlásí stanice zrušené a vrácené nákupy s číslem účtenky a člena na podporu NAJETO \[OD-10\]. |

### 5.3 Texty v portálu

| Místo | Text |
| --- | --- |
| Historie: řádek storna | {datum storna} · Storno: {důvod pro člena} z {datum nákupu} · **−{body}** |
| Historie: příklad | 7. 11. 2026 · Storno: vrácený nákup z 6. 11. 2026 · **−109** |
| Historie: opravná transakce | {datum nákupu} · Opravený nákup · **+{body}** |
| Historie: odebráno jen částečně | {datum storna} · Storno: {důvod} z {datum nákupu} · **−{odebráno}** · pod tím: Odebrali jsme {odebráno} z {celkem} bodů, víc na účtu nebylo. |
| Detail stornované transakce | Štítek Stornováno {datum} · Nákup jsme zrušili a body z něj odečetli. Důvod: {věta podle důvodu}. |
| Důvod pro člena (v historii) | zrušený nákup · vrácený nákup · oprava nákupu · dvakrát zapsaný nákup · nákup jiného účtu · porušení podmínek |

| Důvod | Věta v detailu a v e-mailu |
| --- | --- |
| Zrušený nákup | Nákup z {datum} na {stanice} byl na pokladně zrušený. |
| Vrácený nákup | Nákup z {datum} na {stanice} byl vrácený. |
| Oprava nákupu | Nákup z {datum} na {stanice} jsme opravili po vrácení části zboží. Původních {body} bodů jsme odečetli a připsali {nové body} bodů podle opravené částky. |
| Duplicitní záznam | Nákup z {datum} na {stanice} se ti omylem zapsal dvakrát. Druhý záznam jsme zrušili. |
| Nákup patří jinému účtu | Nákup z {datum} na {stanice} se k tvému účtu přiřadil omylem. Body za něj jsme odečetli. |
| Porušení podmínek | Nákup z {datum} jsme zrušili podle podmínek programu. Když s tím nesouhlasíš, napiš nám na {e-mail podpory}. \[L\] |

### 5.4 E-mail o stornu

| Prvek | Rozhodnutí |
| --- | --- |
| Odesílatel a reply-to | NAJETO od EneOil, reply-to e-mail podpory |
| Předmět | Upravili jsme ti body za nákup z {datum nákupu} |
| Preheader | Odečetli jsme {body} bodů. Máš teď {zůstatek} bodů. |
| Kdy | Hned po stornu, jen když se zůstatek snížil. U opravy nákupu a převodu na jiný účet jeden e-mail po dokončení obou kroků. |
| Co v něm nesmí být | Interní ID, názvy pohybů, jméno loyalty manažera, nabídky. |

```markdown
Předmět: Upravili jsme ti body za nákup z 6. 11. 2026
Preheader: Odečetli jsme 109 bodů. Máš teď 631 bodů.

# Upravili jsme ti body

Nákup z 6. 11. 2026 na EneOil D1 Humpolec byl vrácený.
Body, které ti za něj přibyly, jsme proto odečetli.

Nákup: 6. 11. 2026, EneOil D1 Humpolec, 1 890 Kč
Odečetli jsme: −109 bodů (nákup 54, akce 55)
Zůstatek teď: 631 bodů

Vouchery, které už máš, platí dál.

Nesouhlasíš? Napiš nám do 3 měsíců na {e-mail podpory}
nebo volej {telefon podpory}. Uveď datum nákupu.

[Historie bodů] → {odkaz na Historii}

---
NAJETO · věrnostní program EneOil · Máš najeto na víc.
EneOil a.s., [sídlo], IČO [doplní legal]
Tenhle e-mail dostáváš, protože se změnil zůstatek tvého účtu NAJETO.
Zásady ochrany osobních údajů: {odkaz}
```

Varianta pro částečný odečet, řádek místo „Odečetli jsme“: Odečetli jsme: −80 bodů. Víc na účtu nebylo, zbylých 29 bodů už neodečteme.

Vlastník pravidel: Petra Králová + finance \[F\] + provoz podpory. Vlastník textů: Petra Králová. Schvalovatel: legal \[L\].

## 6. Dopady do portálu, e-mailů, reportingu a provozu

V1 mění jen Moje vouchery a e-mail s voucherem. Expirace a storno přidávají k ostrému spuštění dva servisní e-maily, nové řádky v historii a metriky v manažerském reportu.

| Oblast | Voucher PDF (v1) | Expirace (ostré spuštění) | Storno (ostré spuštění) | Úrovně (etapa 2) |
| --- | --- | --- | --- | --- |
| Portál | Tlačítko Stáhnout PDF u Aktivního voucheru, nápověda k darování | Řádek pod zůstatkem, sekce Brzy propadne, řádek expirace v historii, jednorázový pruh, věta v katalogu, nápověda | Řádek storna v historii, štítek Stornováno v detailu transakce | Karta úrovně na Přehledu, stránka úrovně, řádek bonusu v rozpisu |
| E-maily | PDF v příloze e-mailu s voucherem + jedna věta \[OD-8\] | Nový servisní e-mail 1× měsíčně | Nový servisní e-mail po stornu | Postup na Dálnici, blížící se konec platnosti |
| Back-office | Beze změny | Reklamace ruční úpravou s důvodem Oprava expirace | Akce Stornovat s číselníkem důvodů a komentářem, limit 1 000 bodů, opravná transakce | Parametry prahu a koeficientu, úroveň na kartě člena |
| Reporting (FR-E9) | Není potřeba | Propadlé body po měsících, breakage (propadlé / připsané), body propadající v příštích 3 měsících, vrácené body z reklamací | Počet a body storen podle důvodu, neodebrané body ze storna, stornované nákupy podle stanic | Členové podle úrovně, přechody, náklad bonusu Dálnice |
| Provoz | EneServis přijímá vytištěný voucher stejně jako nadiktovaný kód (B8 kap. 4), stačí informovat obsluhu | Podpora dostane FAQ a pravidla reklamací | Stanice hlásí vrácené a zrušené nákupy podpoře \[OD-10\], finance měsíční přehled storen | Podpora dostane FAQ k úrovním |
| Podmínky | Bod 9 článku Odměny a vouchery (kap. 7.1) | Článek Platnost bodů (kap. 7.2) | Článek Zrušení a oprava nákupu (kap. 7.3) | Článek Úrovně členství (před etapou 2) |

Pro report znamená expirace odpověď na otázku finančního ředitele ze zadání hackathonu: kolik procent bodů se vyčerpá, kolik propadne a jak velký závazek program nese do dalšího roku.

## 7. Obchodní a právní podmínky

Návrhy článků do podmínek programu NAJETO jsou ve vykání (Brand Kit) a ke schválení legal \[L\]. Údaje v hranatých závorkách doplní legal. Podmínky jsou na `/podminky-programu` (B7 kap. 7.5, B8 kap. 10.3).

### 7.1 Doplnění článku „Odměny a vouchery“ (B8 kap. 10.1), v1

> 9. Aktivní voucher lze stáhnout ve formátu PDF, vytisknout jej nebo předat jiné osobě. Rozhodující je stav voucheru v evidenci programu, nikoli vytištěný nebo uložený soubor. Uplatněný nebo zrušený voucher nelze použít ani s jeho PDF.

### 7.2 Článek „Platnost bodů“, ostré spuštění

> 1. Body platí 12 měsíců ode dne připsání. Body připsané v určitý den propadnou ve stejný den následujícího roku, body připsané 29. února propadnou 28. února. Dnem připsání bodů za nákup je den nákupu.
> 2. Při uplatnění odměny se nejprve použijí body s nejbližším dnem propadnutí.
> 3. Body, které člen do dne propadnutí nevyužije, se z jeho účtu odečtou. Propadlé body nelze obnovit, s výjimkou bodu 6.
> 4. Body připsané před \[datum účinnosti\] propadnou nejdříve \[datum účinnosti + 1 rok\].
> 5. Počet bodů a den jejich propadnutí člen vidí v portálu NAJETO. Program člena upozorní e-mailem, pokud mu v následujícím kalendářním měsíci propadne alespoň 50 bodů. Nedoručení upozornění nemá vliv na propadnutí bodů.
> 6. Pokud body propadly v důsledku chyby programu, může člen do 3 měsíců požádat o jejich vrácení prostřednictvím podpory programu.
> 7. Body vrácené podle bodu 6 nebo po zrušení voucheru platí 12 měsíců ode dne vrácení.
> 8. Vydané vouchery nepropádají (článek „Odměny a vouchery“, bod 3). Pozastavení účtu běh lhůty nepřerušuje.

### 7.3 Článek „Zrušení a oprava nákupu“, ostré spuštění

> 1. Pokud je nákup zrušen, vrácen, zaznamenán vícekrát nebo přiřazen k nesprávnému účtu, provozovatel odečte body připsané za tento nákup včetně bonusů z akcí a úrovně členství.
> 2. Při vrácení části nákupu provozovatel odečte body za původní nákup a připíše body podle opravené částky a akcí platných v den nákupu.
> 3. Zůstatek bodů nemůže klesnout pod nulu. Již vydané vouchery zůstávají platné, s výjimkou případů podle bodu 4.
> 4. Při porušení podmínek programu může provozovatel body odečíst, účet pozastavit a zrušit nepoužité vouchery získané z těchto bodů.
> 5. O každém odečtu bodů podle tohoto článku bude člen informován e-mailem a v historii bodů. Nesouhlas lze uplatnit do 3 měsíců prostřednictvím podpory programu \[kontakt\].

### 7.4 Článek „Úrovně členství“, před etapou 2

Znění se připraví po rozhodnutí OD-6 a OD-7. Musí obsahovat: práh a co se do něj počítá, období, platnost Dálnice, benefit, pravidlo, že změna úrovně nemění zůstatek, a lhůtu 30 dní pro změnu benefitu.

### 7.5 Pro legal k posouzení \[OD-2\]

- Expirace u spotřebitele: přiměřenost lhůty 12 měsíců a způsobu upozornění, zavedení pravidla od spuštění a ochrana bodů z doby před účinností.
- Servisní e-maily bez marketingového souhlasu: upozornění na expiraci (včetně odkazu Zobrazit odměny) a oznámení o stornu.
- Odečet bodů a zrušení voucheru při porušení podmínek (7.3 bod 4), vztah k přenosnosti voucheru (B8 R-06).
- Text patičky PDF voucheru (kap. 2.3).

## 8. Otevřená rozhodnutí

Deset bodů čeká na klienta. Implementaci v1 neblokuje žádný z nich: do rozhodnutí platí preferovaná varianta a číselné hodnoty jsou parametry, které jde změnit bez nasazení kódu.

| ID | Otázka | Preferovaná varianta (platí do rozhodnutí) | Vlastník | Termín |
| --- | --- | --- | --- | --- |
| OD-1 | Formální schválení rozsahu, pořadí a pravidel B11 | Návrh v. 0.9 | Petra Králová | 6. 11. 2026, 15:30 (demo) |
| OD-2 | Právní posouzení kap. 7 a servisních e-mailů | Návrh v kap. 7 | Legal EneOil | Před ostrým spuštěním |
| OD-3 | Odpis neodebraných bodů ze storna, limit 1 000 bodů, závazek z bodů s expirací v účetnictví | Podle kap. 3 a 5, měsíční přehled storen pro finance | Finanční ředitel EneOil | Před ostrým spuštěním |
| OD-4 | Kontakty podpory (e-mail, telefon, provozní doba) | Zástupné hodnoty v konfiguraci, stejné jako B7 a B8 | Petra Králová + IT EneOil | Před ostrým spuštěním |
| OD-5 | Práh pro e-mail o expiraci | 50 bodů, parametr | Petra Králová | Do spuštění, mění se konfigurací |
| OD-6 | Práh Dálnice a co se do něj počítá | 2 000 základních bodů za 12 měsíců, bez kampaní, cíl 10 až 20 % aktivních členů | Petra Králová | Před startem etapy 2, po 6 měsících dat |
| OD-7 | Benefit Dálnice a jeho rozpočet, případný benefit EneServisu | +20 % bodů za palivo, nic dalšího | Petra Králová + finance + EneServis | Před startem etapy 2 |
| OD-8 | PDF v příloze e-mailu už ve v1 | Ano, pokud se stihne do 15:30. Jinak v demu jen stažení v portálu a příloha k ostrému spuštění. | Matěj Kováčik + Lukáš Vavřín | 6. 11. 2026, 15:30 |
| OD-9 | Datum ostrého spuštění = účinnost expirace a článku 7.2 | Doplnit | Petra Králová | Před ostrým spuštěním |
| OD-10 | Jak se loyalty manažer dozví o zrušeném nebo vráceném nákupu do integrace pokladen | Stanice pošle hlášení s číslem účtenky a člena na podporu NAJETO | Provoz sítě stanic EneOil | Před ostrým spuštěním |

## 9. Schvalovatelé, verze a akceptace

Verze 0.9 z 6. 11. 2026 je návrh ke schválení, verze 1.0 vznikne po schválení všemi schvalovateli. Do té doby platí tento návrh jako preferovaná varianta pro implementaci.

| Role | Jméno | Co schvaluje | Stav |
| --- | --- | --- | --- |
| Zpracovatel | Matěj Kováčik, Enehano (tým 2A) | Úplnost a konzistence s FR, SD, B7 a B8 | Zpracováno 6. 11. 2026 |
| Marketing | Petra Králová, Head of Loyalty, EneOil | Texty, e-maily, PDF, vizuál, názvy úrovní | Čeká \[OD-1\] |
| Produkt / vlastník programu | Petra Králová, Head of Loyalty, EneOil | Rozsah a pořadí, pravidla expirace, storna a úrovní | Čeká \[OD-1\] |
| Provoz | Vedoucí podpory NAJETO a provozu sítě stanic (jméno doplní klient) | Reklamace expirace, postup storna, hlášení vrácení ze stanic | Otevřené \[OD-10\] |
| Finance | Finanční ředitel EneOil (jméno doplní klient) | Odpisy ze storna, limit 1 000 bodů, závazek z bodů, benefit Dálnice | Otevřené \[OD-3, OD-7\] |
| Legal / privacy | Legal a pověřenec EneOil a.s. (jméno doplní klient) | Kap. 7, servisní e-maily, patička PDF | Otevřené \[OD-2\] |
| Rozsah (hackathon) | Lukáš Vavřín, garant | PDF ve v1, ostatní funkce mimo demo | Čeká \[OD-8\] |

### 9.1 Kontrola proti akceptaci B11

| Kritérium | Kde |
| --- | --- |
| Schválený rozsah a pořadí volitelných funkcí | 1 (schválení OD-1) |
| Každá vybraná funkce má jednoznačná pravidla a vlastníka | 2.1, 3.1, 5.2, vlastníci na konci kapitol |
| Pravidla pro stávající body, členy, vouchery a transakce | 2.1 (vydané vouchery), 3.1 (body před účinností, vrácené body), 4.1 (start etapy 2), 5.2 (vouchery a utracené body) |
| Texty pro všechny stavy a kanály | 2.3, 3.3, 3.4, 4.2, 5.3, 5.4 |
| Obchodní, provozní, finanční a právní dopady se schválením | 6, 7, 8 (OD-2, OD-3, OD-10) |
| Vizuál a obsah navazují na B6 a B8 | 2.2, 3.5, 4.3 (Brand Kit EneOil + NAJETO v2, voucher z B8 kap. 9) |
| Nevybrané funkce označené | 1 a 4: Úrovně = pozdější etapa |
| Verze, datum, schvalovatelé | Shrnutí, 9 |

### 9.2 Změny oproti FR a SD (pro implementační tým)

| Místo | Změna |
| --- | --- |
| FR-E10-01 | Jen PDF, ne obrázek. Bez osobních údajů a QR. Stažení jen u Aktivního voucheru. NAJETO místo EneOil Klub. Příloha e-mailu podle OD-8. |
| BR-61, FR-E10-02 | Body před účinností propadnou nejdřív rok po ní. E-mail 1× měsíčně souhrnně od 50 bodů místo 30 dní před každým přídělem. Vrácené body mají novou platnost 1 rok. Jednorázový pruh po expiraci. COULD → k ostrému spuštění. |
| FR-E2-06 | Storno se provede i při nedostatečném zůstatku: odečte do nuly, zbytek odepíše (FR storno odmítal). Částečné storno přes opravnou transakci. Číselník důvodů, servisní e-mail. COULD → k ostrému spuštění. |
| BR-60, FR-E10-03 | Qualifying body jen základní, bez kampaní. Dálnice platí 12 měsíců od posledního splnění místo měsíčního sestupu. Bonus od dalšího nákupu po postupu. Etapa 2. |
| FR-E9-08 | Doplněno: body propadající v příštích 3 měsících, storna podle důvodu, neodebrané body ze storna. |
| SD kap. 15 | Pořadí COULD: voucher PDF → expirace → storno → úrovně. Dnes jen PDF. |
