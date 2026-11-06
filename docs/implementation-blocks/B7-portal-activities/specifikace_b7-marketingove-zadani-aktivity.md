# B7 · Marketingové zadání: aktivity v členském portálu NAJETO

| | |
| --- | --- |
| Projekt | Věrnostní program NAJETO (EneOil), AI Hackathon 2026, varianta 2, tým 2A |
| Dokument | Odpověď marketingu na zadání B7 (`MARKETING_ASSIGNMENT.md`) |
| Verze | 0.9 · návrh ke schválení · 6. 11. 2026 |
| Vlastník dokumentu | Matěj Kováčik (Enehano, tým 2A) |
| Navazuje na | `specifikace/eneoil-klub-funkcni-zadani.md` (BR-30 až BR-34, FR-E4), `EneOil-Klub-Solution-Design.docx` v1.0, `brand/NAJETO_EneOil_brand_a_kampan.md`, `brand/originalni_brandkit/eneoil-brand-kit.md` |
| Technický protějšek | `specifikace/b7-solution-design-aktivity.md` |

Značení: **[R]** rozhodnuto marketingem / týmem · **[L]** návrh, který musí schválit privacy/legal · **[OD-n]** otevřené rozhodnutí s vlastníkem a termínem (kap. 9).

---

## 0. Shrnutí rozhodnutí

| # | Rozhodnutí | Stav |
| --- | --- | --- |
| R-01 | Portál a všechny texty pro člena vystupují pod značkou **NAJETO** (věrnostní program EneOil). Vizuální tokeny, písma a tone of voice přebírá z Brand Kitu EneOil. Interní názvy v Salesforce („EneOil Klub“) se nemění. | [R] |
| R-02 | Profil je dokončený, když člen vyplní **4 údaje o autě**: značka, model, rok výroby, palivo. Osobní údaje z registrace (jméno, příjmení, e-mail) stačí, další osobní údaje nesbíráme. | [R] |
| R-03 | **Registrační značku (SPZ) v B7 nesbíráme**, ani jako volitelné pole. VIN také ne. | [R] |
| R-04 | Portál podporuje **jedno vozidlo** na člena. Více vozidel je roadmapa. | [R] |
| R-05 | Člen, který měl údaje o autě nebo platný marketingový souhlas **už před spuštěním**, dostane body **jednorázovou dávkou při spuštění**. | [R] |
| R-06 | Změna ani smazání údajů o autě po připsání bodů **body neodebírá** a nové body nepřipíše. | [R] |
| R-07 | Marketingový souhlas pokrývá **jen e-mail**. Odvolání **body neodebírá**. Opětovné udělení **body znovu nepřipíše**. | [R] + [L] |
| R-08 | Body za aktivity se nepřipíší zablokovanému členovi a nejsou ovlivněny kampaněmi ani úrovní (BR-34). | [R] |

---

## 1. Aktivita 1: Doplnění údajů o autě (+100 bodů)

### 1.1 Seznam údajů

| Údaj (zobrazený název) | Povinný pro odměnu | Proč ho chceme a jak ho použijeme | Povolené hodnoty / příklad | Může člen později změnit | Zvláštní text |
| --- | --- | --- | --- | --- | --- |
| **Značka auta** | Ano | Výběr nabídek EneServis podle značky (servisní intervaly, přezutí), složení členské základny pro plánování odměn | Výběr ze seznamu (1.2), poslední volba „Jiná značka“ | Ano, kdykoli | Společné poučení k údajům o autě (7.3) |
| **Model** | Ano | Upřesnění nabídek EneServis (např. velikost pneumatik u přezutí), statistiky programu | Volný text, 1 až 40 znaků, příklad „Octavia“ | Ano, kdykoli | Společné poučení (7.3) |
| **Rok výroby** | Ano | Stáří auta určuje relevantní servisní nabídky (prohlídka, STK), segmentace pro akce | Celé číslo 1900 až aktuální rok + 1 (v roce 2026: 1900 až 2027) | Ano, kdykoli | Společné poučení (7.3) |
| **Palivo** | Ano | Akce na pumpě podle paliva (benzín, nafta, LPG), příprava rozšíření o dobíjení (NAJETO, kap. 4 brandu) | Benzín · Nafta · LPG · CNG · Hybrid · Plug-in hybrid · Elektro | Ano, kdykoli | Společné poučení (7.3) |
| ~~Registrační značka~~ | **Nesbírá se** | Pro body, kampaně ani párování transakcí ji nepotřebujeme (párování jde přes číslo člena). Využití (připomínka STK, objednání do EneServis) je roadmapa, sběr se otevře až s konkrétní službou a vlastním poučením. | | | |

### 1.2 Seznam značek (výchozí hodnoty)

Abecedně, „Jiná značka“ vždy poslední: Audi · BMW · BYD · Citroën · Cupra · Dacia · Fiat · Ford · Honda · Hyundai · Jeep · Kia · Land Rover · Lexus · Mazda · Mercedes-Benz · MG · Mitsubishi · Nissan · Opel · Peugeot · Porsche · Renault · Seat · Suzuki · Škoda · Tesla · Toyota · Volkswagen · Volvo · Jiná značka.

Seznam spravuje loyalty manažer, doplnění značky nevyžaduje změnu textů. Finální seznam potvrdí marketing ([OD-5]).

### 1.3 Pravidla nároku

1. Nárok na 100 bodů vznikne při **prvním uložení**, kdy jsou všechny 4 povinné údaje vyplněné a platné. O splnění rozhoduje server, ne prohlížeč.
2. Člen může uložit i neúplné údaje. Body se nepřipíšou, karta aktivity ukáže, co chybí.
3. Odměnu lze získat **jednou za celé členství**. Další úpravy, opakované odeslání formuláře ani smazání a nové doplnění údajů body nepřidají.
4. **Stávající členové [R-05]:** kdo má k datu spuštění aktivit vyplněné všechny 4 údaje, dostane 100 bodů jednorázovou dávkou v den spuštění. V historii bodů uvidí běžný řádek „Údaje o autě · +100“ s datem spuštění.
5. **Změna po připsání [R-06]:** údaje lze měnit kdykoli, body zůstávají, nové nepřibudou.
6. **Smazání po připsání [R-06]:** člen může údaje o autě v profilu smazat (právo na výmaz). Body mu zůstanou. Pokud údaje doplní znovu, body už nepřibudou.
7. **Jedno vozidlo [R-04]:** člen má v profilu jedno auto. Při výměně auta údaje přepíše, body nepřibudou.
8. Zablokovaný člen údaje uložit může, body se mu nepřipíšou. Po odblokování se nárok vyhodnotí znovu.

---

## 2. Aktivita 2: Marketingový souhlas (+50 bodů)

### 2.1 Co souhlas pokrývá

| Oblast | Rozhodnutí |
| --- | --- |
| Kanál | **Jen e-mail** na přihlašovací e-mail člena. SMS, push ani telefon souhlas nepokrývá. |
| Odesílatel | EneOil a.s. (správce). Partner EneServis údaje člena nedostává, jeho nabídky posílá EneOil. |
| Typy sdělení | Akce na čerpacích stanicích EneOil · novinky ve věrnostním programu NAJETO · nabídky autoservisu EneServis. |
| Přizpůsobení obsahu | Výběr nabídek podle údajů o autě a historie bodů v programu (např. akce na naftu jen řidičům diesel). Musí být uvedeno v textu souhlasu. [L] |
| Mimo souhlas | Servisní e-maily k účtu a voucherům (voucher po uplatnění, obnova hesla, změna podmínek). Odcházejí i bez souhlasu, nejsou obchodním sdělením. |

### 2.2 Udělení

- Souhlas lze udělit **při registraci** (samostatné, nezaškrtnuté políčko pod povinným souhlasem s podmínkami) nebo **kdykoli později** v kartě aktivity nebo v profilu.
- Políčko nikdy není předem zaškrtnuté. Registrace ani žádná jiná funkce programu na souhlasu nezávisí.
- Text souhlasu je stejný ve všech místech a má verzi (např. `MKT-EMAIL-1.0`). Ke každému udělení se ukládá datum, čas, verze textu a místo udělení.
- Body (+50) se připíší po úspěšném uložení souhlasu na serveru. Platí jednou za celé členství.

### 2.3 Odvolání

- Odvolat jde kdykoli **jedním krokem s potvrzením** v profilu (sekce „Novinky e-mailem“) a odkazem pro odhlášení v každém obchodním e-mailu.
- Odvolat lze i přes zákaznickou linku; loyalty manažer odvolání zaznamená v Salesforce. **Udělit souhlas za člena back-office nemůže.**
- Odvolání **body neodebírá** [R-07]. Tím je zajištěné, že odvolání pro člena nemá žádný negativní důsledek.
- Ukládá se datum, čas a místo odvolání. Obchodní e-maily přestanou odcházet bez zbytečného odkladu (technicky ihned v Salesforce, v rozesílacím nástroji podle synchronizace, viz SD).

### 2.4 Opětovné udělení

- Člen může souhlas po odvolání znovu udělit. **Body se znovu nepřipíší** [R-07], což mu portál řekne před potvrzením (texty 5.2).

### 2.5 Stávající členové

- Kdo má k datu spuštění **platný (neodvolaný)** souhlas, dostane 50 bodů jednorázovou dávkou v den spuštění [R-05].
- Kdo souhlas udělil i odvolal před spuštěním, body v dávce nedostane. Pokud souhlas udělí po spuštění, nárok na 50 bodů má (dosud odměněn nebyl).

### 2.6 Jak o odměně mluvit (dobrovolnost)

- Body jsou **poděkování**, ne cena za souhlas. Odměnu ukazujeme jako štítek „+50 bodů jednou“ vedle aktivity, ne v tlačítku ani v textu souhlasu.
- U souhlasu vždy stojí, že je dobrovolný, lze ho kdykoli odvolat a **body po odvolání zůstanou**.
- Nepoužíváme formulace typu „Přijdeš o body“, „Nenech si ujít 50 bodů“, odpočty ani opakované vyskakovací výzvy. Kartu souhlasu zobrazujeme jen na stránce Získej body, v profilu a jednou na Přehledu (sekce nesplněných aktivit).

---

## 3. Umístění v portálu a priorita (UX)

| Místo | Obsah | Priorita |
| --- | --- | --- |
| **Přehled** | Sekce „Získej body navíc“ pod kartami akcí: jen **nesplněné** aktivity, karta s ikonou, názvem, štítkem bodů a tlačítkem. Když jsou obě splněné, sekce zmizí. | 2. po zůstatku a akcích |
| **Získej body** (navigace) | Obě aktivity vždy. Nesplněné nahoře, splněné dole ve stavu „Hotovo“. | hlavní místo |
| **Profil** | Sekce „Moje auto“ (formulář 4 údajů, smazání) a „Novinky e-mailem“ (udělení / odvolání). | trvalá správa údajů |
| **Registrace** | Jen marketingový souhlas (nepovinný). Údaje o autě se při registraci **nepožadují** (registrace na jednu obrazovku, FR-E1-01). | |

**Pořadí aktivit:** 1. Doplň údaje o autě (+100), 2. Chci novinky a akce e-mailem (+50). Vyšší odměna první, souhlas nechceme tlačit dopředu (2.6).

**Formulář auta:** otevře se jako samostatná stránka (mobil) nebo panel (desktop). Pořadí polí: Značka → Model → Rok výroby → Palivo. Značka a palivo jako výběr, rok číselná klávesnice. Tlačítko je dole a na mobilu přichycené ke spodní hraně.

**Stav připisování:** po odeslání tlačítko ukáže „Ukládám…“ a je neaktivní. Potvrzení o bodech se ukáže až po odpovědi serveru. Zůstatek na Přehledu se aktualizuje z dat serveru, ne přičtením v prohlížeči.

---

## 4. Vizuální podklady

| Prvek | Rozhodnutí |
| --- | --- |
| Brand | NAJETO podle `brand/NAJETO_EneOil_brand_a_kampan.md` a PDF „NAJETO, finální brand a kampaň v2“. Wordmark `najeto` s oranžovou tečkou v záhlaví portálu. |
| Barvy | Tokeny Brand Kitu EneOil (`brand/originalni_brandkit/eneoil-tokens.css`): karta nesplněné aktivity `brand-soft`, štítek bodů text `brand-text` v Noto Sans Mono, hotová aktivita `green-soft` + ikona `green-text`, chyby `minus`. |
| Písma | Archivo 700/800 název aktivity · Noto Sans text · Noto Sans Mono body (+100, +50). |
| Ikony | Google Material Symbols (licence Apache 2.0): `directions_car` (auto), `mark_email_read` (novinky), `check_circle` (hotovo). Barva `ene-green` na světlém. |
| Ilustrace a fotky | Žádné. Brand Kit zakazuje fotky aut a stanic z internetu. Motiv kapky / tachometru jen na Přehledu (zůstatek), ne v kartách aktivit. |
| Design | Mobilní návrh zatím neexistuje. Platí obsahová hierarchie z kap. 3 a 5; komponenty navrhne UX/vývojový tým podle tokenů. Na šířce ≥ 768 px jsou karty aktivit vedle sebe, pod tím pod sebou. |
| B6 | Design source of truth z bloku B6 je Brand Kit EneOil + NAJETO brand v2. Při rozporu má přednost NAJETO v2 (název, claim, logo), u tokenů a textových pravidel Brand Kit. |

---

## 5. Texty pro člena (čeština, tykání, sentence case)

Pravidla: číslo napřed, žádný vykřičník, bez „Bohužel“, skloňování 1 bod / 2 až 4 body / 5 bodů. Proměnné jsou ve složených závorkách. Texty nepředpokládají připsání bodů dřív, než ho server potvrdí.

### 5.1 Aktivita 1: Doplň údaje o autě

| Prvek | Text |
| --- | --- |
| Název aktivity | **Doplň údaje o autě** |
| Štítek odměny | +100 bodů jednou |
| Krátký popis | Řekni nám, čím jezdíš, a připíšeme ti 100 bodů. Nabídky EneServis pak budou sedět k tvému autu. |
| Podmínky | Vyplň značku, model, rok výroby a palivo a ulož je. 100 bodů připíšeme jednou za celé členství, hned po uložení. Další úpravy už body nepřidají. |
| Výzva k akci (karta) | Doplnit údaje o autě |
| Výzva k akci (formulář, bez odměny) | Uložit a získat 100 bodů |
| Výzva k akci (formulář, odměněno) | Uložit změny |
| Probíhá ukládání | Ukládám… |
| Stav nerozpracováno | Zabere to asi minutu. Stačí 4 údaje, SPZ nepotřebujeme. |
| Stav rozpracováno | Ještě chybí: {seznam chybějících údajů, např. „rok výroby a palivo“}. Po doplnění ti připíšeme 100 bodů. |
| Stav rozpracováno (uloženo neúplné) | Uloženo. Ještě chybí: {seznam}. Body připíšeme, až bude vyplněno všechno. |
| Stav splněno | **Hotovo. 100 bodů je na tvém účtu.** Údaje o autě najdeš v profilu. |
| Stav již odměněno | Body za údaje o autě už máš ({datum}). Údaje můžeš kdykoli upravit, další body za ně nepřibudou. |
| Chyba (obecná) | Údaje se nepodařilo uložit a body jsme zatím nepřipsali. Zkus to prosím znovu za chvíli. |
| Chyba: značka | Vyber značku auta. |
| Chyba: model | Napiš model, třeba Octavia. |
| Chyba: rok | Zadej rok výroby od 1900 do {aktuální rok + 1}. |
| Chyba: palivo | Vyber palivo. |
| Nápověda: značka | Svou značku v seznamu nemáš? Vyber „Jiná značka“ a napiš ji do modelu. |
| Nápověda: model | Stačí název modelu, třeba Octavia nebo Golf. |
| Nápověda: rok výroby | Když rok nevíš přesně, stačí rok první registrace z technického průkazu. |
| Nápověda: palivo | U hybridu vyber hybrid, i když tankuješ benzín. |
| Nápověda: proč to chceme | Podle auta ti ukážeme akce a nabídky EneServis, které se ti hodí. SPZ ani VIN nepotřebujeme. {odkaz: Jak s údaji nakládáme} |
| Smazání (odkaz v profilu) | Smazat údaje o autě |
| Smazání (potvrzení) | Smazat údaje o autě? Body, které za ně máš, ti zůstanou. Za nové doplnění už body nepřibudou. · [Smazat] [Zpět] |
| Smazání (hotovo) | Údaje o autě jsme smazali. |
| Řádek historie bodů | {datum} · Údaje o autě · **+100** |

### 5.2 Aktivita 2: Chci novinky a akce e-mailem

| Prvek | Text |
| --- | --- |
| Název aktivity | **Chci novinky a akce e-mailem** |
| Štítek odměny | +50 bodů jednou |
| Krátký popis | Pošleme ti akce na pumpách EneOil, novinky v NAJETO a nabídky EneServis. Jako poděkování ti připíšeme 50 bodů. |
| Podmínky | Zaškrtni souhlas a potvrď ho. Souhlas je dobrovolný a můžeš ho kdykoli odvolat. Body ti po odvolání zůstanou. Za opětovný souhlas už body nepřipíšeme. |
| Výzva k akci (karta) | Chci novinky e-mailem |
| Výzva k akci (potvrzení souhlasu) | Potvrdit souhlas |
| Probíhá ukládání | Ukládám… |
| Stav nerozpracováno | Odhlásit se můžeš kdykoli v profilu nebo odkazem v každém e-mailu. |
| Stav rozpracováno (políčko nezaškrtnuté) | Nejdřív zaškrtni souhlas. (tlačítko neaktivní) |
| Stav splněno | **Hotovo. 50 bodů je na tvém účtu.** Novinky ti budeme posílat na {e-mail}. |
| Stav již odměněno, souhlas platí | Novinky ti posíláme na {e-mail}. Body za souhlas už máš ({datum}). |
| Stav již odměněno, souhlas odvolán | Novinky e-mailem ti teď neposíláme. Body za souhlas už máš a zůstanou ti. |
| Opětovné udělení (výzva) | Znovu odebírat novinky |
| Opětovné udělení (upozornění před potvrzením) | Body za souhlas už máš, znovu je nepřipíšeme. |
| Opětovné udělení (hotovo) | Hotovo. Novinky ti zase budeme posílat na {e-mail}. |
| Odvolání (odkaz v profilu) | Přestat posílat novinky |
| Odvolání (potvrzení) | Přestat posílat novinky e-mailem? Body, které máš, ti zůstanou. Zprávy o tvém účtu a voucherech ti budeme posílat dál. · [Přestat posílat] [Zpět] |
| Odvolání (hotovo) | Hotovo. Novinky ti už posílat nebudeme. |
| Chyba (udělení) | Souhlas se nepodařilo uložit a body jsme zatím nepřipsali. Zkus to prosím znovu za chvíli. |
| Chyba (odvolání) | Odhlášení se nepodařilo uložit. Zkus to prosím znovu, nebo použij odkaz pro odhlášení v kterémkoli našem e-mailu. |
| Chyba (změněný text souhlasu) | Text souhlasu jsme mezitím upravili. Přečti si prosím novou verzi a potvrď ji znovu. |
| Nápověda | Posíláme jen e-mailem. Tvůj e-mail partnerovi EneServis nepředáváme, jeho nabídky ti posíláme my. |
| Registrace (vedle políčka) | text souhlasu 7.1, pod ním štítek „+50 bodů jednou“ a věta „Nepovinné. Odvolat můžeš kdykoli.“ |
| Řádek historie bodů | {datum} · Souhlas s novinkami e-mailem · **+50** |

### 5.3 Společné texty

| Místo | Text |
| --- | --- |
| Nadpis stránky Získej body | Získej body navíc |
| Podnadpis | Za každý úkol body jednou. Máš najeto na víc. |
| Nadpis sekce na Přehledu | Získej body navíc |
| Všechno splněno (stránka) | Máš hotovo všechno. Další body přibudou s tankováním a nákupy. |
| Zablokovaný člen | Tvůj účet je pozastavený, body za aktivity teď nepřipíšeme. Napiš nám na {kontakt podpory}. |
| Aktivita vypnutá | (karta se nezobrazí) |

---

## 6. Rozhodnutí ke stávajícím členům a změnám dat (souhrn)

| Situace | Aktivita 1: auto | Aktivita 2: souhlas |
| --- | --- | --- |
| Splněno před spuštěním | +100 dávkou v den spuštění | +50 dávkou, jen pokud je souhlas k datu spuštění platný |
| Udělen a odvolán před spuštěním | – | Bez bodů v dávce; nárok při udělení po spuštění |
| Změna po odměně | Povoleno, bez bodů | – |
| Smazání / odvolání po odměně | Body zůstanou | Body zůstanou |
| Nové doplnění / opětovné udělení | Bez bodů | Bez bodů |
| Opakované odeslání, dvojklik | Jedna odměna | Jedna odměna |
| Zablokovaný člen | Bez bodů, vyhodnotí se po odblokování | Bez bodů, vyhodnotí se po odblokování |
| Vypnutá aktivita | Bez bodů, karta skrytá | Bez bodů, karta skrytá; souhlas jde udělit v profilu |

---

## 7. Právní texty (návrh ke schválení privacy/legal) [L]

Právní texty jsou ve vykání (Brand Kit). Údaje v hranatých závorkách doplní legal.

### 7.1 Text marketingového souhlasu (verze `MKT-EMAIL-1.0`)

> Souhlasím, aby mi společnost EneOil a.s., [sídlo], IČO [doplní legal], zasílala na můj e-mail obchodní sdělení: akce čerpacích stanic EneOil, novinky věrnostního programu NAJETO a nabídky partnera EneServis, s.r.o. Pro výběr nabídek může využít mé údaje z programu (údaje o vozidle a historii bodů). Souhlas je dobrovolný a mohu ho kdykoli odvolat v profilu nebo odkazem v každém e-mailu. Odvoláním nepřijdu o body, které už mám. Více v [Zásadách ochrany osobních údajů].

### 7.2 Informace pod souhlasem (rozbalovací „Jak s údaji nakládáme“)

> Správcem osobních údajů je EneOil a.s. Na základě vašeho souhlasu zpracováváme e-mail, jméno, údaje o vozidle a historii bodů v programu NAJETO za účelem zasílání obchodních sdělení e-mailem a jejich přizpůsobení. Souhlas platí do odvolání. Odvolání nemá vliv na zákonnost zpracování před ním ani na body, které jste získali. Vaše údaje partnerovi EneServis nepředáváme. Máte právo na přístup k údajům, jejich opravu a výmaz, omezení zpracování, přenositelnost a podat stížnost u Úřadu pro ochranu osobních údajů. Podrobnosti najdete v [Zásadách ochrany osobních údajů].

### 7.3 Poučení k údajům o autě

> Údaje o vozidle (značka, model, rok výroby, palivo) zpracovává EneOil a.s. pro správu programu NAJETO, statistiky programu a přizpůsobení nabídek zobrazených v portálu. Právní základ: [oprávněný zájem / plnění smlouvy o členství, určí legal, OD-1]. K zasílání obchodních sdělení e-mailem je použijeme jen, pokud jste k tomu dali souhlas. Údaje můžete kdykoli změnit nebo smazat v profilu. Uchováváme je po dobu členství v programu [doba po ukončení členství doplní legal].

### 7.4 Doplněk podmínek programu NAJETO (článek „Body za aktivity“)

> 1. Člen může jednorázově získat body za aktivity v portálu: 100 bodů za doplnění údajů o vozidle (značka, model, rok výroby, palivo) a 50 bodů za udělení souhlasu se zasíláním obchodních sdělení e-mailem.
> 2. Body za každou aktivitu lze získat nejvýše jednou za dobu členství. Změna, smazání a opětovné doplnění údajů ani odvolání a opětovné udělení souhlasu další body nezakládá.
> 3. Smazání údajů o vozidle ani odvolání souhlasu nemá vliv na body, které člen již získal.
> 4. Udělení souhlasu je dobrovolné a není podmínkou členství ani čerpání jiných výhod programu.
> 5. Členům, kteří podmínku aktivity splnili před jejím spuštěním, budou body připsány jednorázově v den spuštění.
> 6. Body za aktivity se nepřipisují po dobu pozastavení účtu.

### 7.5 Odkazy

| Dokument | Umístění v portálu | Vlastník |
| --- | --- | --- |
| Zásady ochrany osobních údajů | `/zasady-ochrany-osobnich-udaju` (stránka portálu, obsah dodá legal) [OD-2] | Privacy/legal EneOil |
| Podmínky programu NAJETO | `/podminky-programu` (stránka portálu) | Legal EneOil + Head of Loyalty |

---

## 8. Schvalovatelé

| Role | Jméno | Co schvaluje | Stav |
| --- | --- | --- | --- |
| Obsah (zpracovatel) | Matěj Kováčik, Enehano (tým 2A) | Kompletnost a konzistence dokumentu | Zpracováno 6. 11. 2026 |
| Marketing / loyalty | Petra Králová, Head of Loyalty, EneOil | Pole, pravidla, texty, UX, brand | Čeká na schválení [OD-4] |
| Privacy / legal | Pověřenec pro ochranu osobních údajů EneOil a.s. (jméno doplní klient) | Kap. 2 a 7 | Otevřené [OD-1, OD-3] |
| Scope (hackathon) | Lukáš Vavřín, garant | Rozsah B7 | Čeká na checkpoint |

Verze 1.0 vznikne po schválení všemi schvalovateli. Do té doby platí návrh v tomto dokumentu jako preferovaná varianta pro implementaci.

---

## 9. Otevřená rozhodnutí

| ID | Otázka | Preferovaná varianta (platí do rozhodnutí) | Vlastník | Termín |
| --- | --- | --- | --- | --- |
| OD-1 | Právní základ zpracování údajů o autě a doba uchování | Oprávněný zájem (správa a personalizace programu), uchování po dobu členství + 3 roky | Privacy/legal EneOil | před ostrým spuštěním; pro hackathon platí návrh |
| OD-2 | Obsah zásad ochrany osobních údajů a podmínek programu | Stránky v portálu se zástupným textem a verzí | Legal EneOil | před ostrým spuštěním |
| OD-3 | Identifikace správce (sídlo, IČO) v textu souhlasu | Zástupné hodnoty v Custom Metadata, změna bez nasazení kódu | Legal EneOil | před ostrým spuštěním |
| OD-4 | Formální schválení marketingem | Návrh v. 0.9 | Petra Králová | 6. 11. 2026, 15:30 (demo) |
| OD-5 | Finální seznam značek | Seznam 1.2 | Petra Králová | do spuštění; mění se konfigurací |

---

## 10. Kontrola proti akceptaci B7

| Kritérium B7 | Kde |
| --- | --- |
| U každého pole je jasné, zda je povinné pro odměnu | 1.1 |
| Rozhodnuto o existujících členech | 1.3 bod 4, 2.5, kap. 6 |
| Udělení, odvolání a opětovné udělení souhlasu | 2.2 až 2.4 |
| Právní znění a odkazy mají schvalovatele | 7, 8 |
| Texty pro všechny stavy obou aktivit | 5.1, 5.2 |
| Texty nevyvolávají dojem opakované odměny | „+100 bodů jednou“, „Za opětovný souhlas už body nepřipíšeme“, stav již odměněno |
| UX a vizuál v souladu s B6 a Brand Kitem | 3, 4 |
| Vlastník, verze, datum | hlavička, 8 |

**Změny oproti funkčnímu zadání v1.0:** BR-32 a Q5 (SPZ vypuštěna úplně, ne volitelná), nové pravidlo pro stávající členy (dávka při spuštění), kanál souhlasu jen e-mail, member-facing značka NAJETO.
