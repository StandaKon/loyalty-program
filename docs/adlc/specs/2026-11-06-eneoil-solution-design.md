# EneOil Klub: stručný solution design

Pracovní návrh k diskusi, 6. 11. 2026. Obsah prezentace je v [eneoil-steerco-content.md](../../../eneoil-steerco-content.md). Obchodní pravidla v `context.md` zůstávají beze změny. Doporučení níže nejsou schválená rozhodnutí.

## Problém a rozsah

Pro 120 stanic potřebujeme evidovat členy, připsat body za nákupy a aktivity, směnit je za vouchery EneServis a vyhodnocovat program. Zadání předepisuje Sales Cloud, Experience Cloud a Claude artifact. Hackathon simuluje pokladnu; reálná POS integrace patří do další fáze.

Úkol přípravy návrhu má velikost M. Samotná implementace je průřezová a vyžaduje zejména ověření licencí, přístupů a souběžného čerpání bodů. Repozitář obsahuje výchozí šablonu, nikoli implementovaný loyalty program. Konfigurace scratch orgu nedokládá připravenost Experience Cloudu; stav skutečného orgu nebyl ověřen.

## Zvažované přístupy

| Přístup | Přínos a omezení | Závěr |
| --- | --- | --- |
| Převážně deklarativní řešení | Rychlá správa formulářů a konfigurace. Souběh čerpání, opakování požadavků a verzování pravidel by však komplikovaly automatizace. | Použít pro administraci a jednoduché procesy. |
| Vlastní transakční engine + standardní administrace | Jedno místo pro výpočet, kontrolu duplicit a bezpečné čerpání. Vyžaduje vlastní vývoj a odpovědnost za údržbu. | **Doporučeno pro zadaný rozsah.** |
| Specializovaná loyalty platforma | Více hotových funkcí, další licence a implementační závislost. | Zadání Loyalty Management vylučuje; do hackathonu nezařazovat. |

## Architektura a odpovědnosti

| Část | Odpovědnost a návrh |
| --- | --- |
| Členský portál | Experience Cloud, responzivní komponenty, standardní identita a obnova hesla. Zobrazuje vlastní účet, akce, aktivity a vouchery. Výpočty potvrzuje server. |
| Loyalty engine | Sdílená serverová služba v Sales Cloudu pro CSV i ruční vstup, aktivity a čerpání. Pro transakční operace doporučujeme Apex; pro administraci standardní Lightning stránky a vhodné deklarativní akce. |
| Datová evidence | Samostatné členství, transakce, neměnné pohyby bodů, kampaně, aktivity, odměny a vouchery. Oddělit identitu člověka od členství a bodového účtu. |
| Konfigurace | Vlastní objekty pro kampaně, katalog a provozní parametry, editovatelné manažerem. Parametry výpočtu i kampaně evidovat s časovou platností; technickou konfiguraci lze držet v metadata. |
| Back-office | Lightning aplikace s kartou člena, správou pravidel a seznamem chyb. Partner zůstává Account EneServis. |
| Report | Claude artifact čte Salesforce přes ověřený konektor. Pokud nepokryje vlastní objekty a agregace, doplnit úzké autentizované API. Přístup pouze pro čtení, viditelný čas aktualizace. Ruční export nesplňuje zadání. |

### Datový model a přístupy

- `LoyaltyMember__c` navázat 1 : 1 na Contact, číslo člena uložit jako unikátní identifikátor. Pro demo doporučujeme Contact pod technickým Accountem. Pro produkci rozhodnout podle existujícího B2C modelu mezi Person Accounts a rozdělením kontaktů do více Accountů. Jeden sběrný Account není cílové řešení pro rostoucí bázi; Salesforce popisuje rizika při velkém počtu potomků v [dokumentaci data skew](https://developer.salesforce.com/docs/platform/draes/guide/draes-object-relationships-parent-child-data-skew.html).
- Pohyb bodů je detail členství; zůstatek navrhujeme jako součet pohybů přes roll-up. Zabránit editaci a mazání pohybů i smazání nadřazeného členství. Opravy vždy novým pohybem. Princip roll-up popisuje [Salesforce Help](https://help.salesforce.com/s/articleView?id=sf.fields_about_roll_up_summary_fields.htm&language=en_US&type=5).
- Zachovat jeden základní pohyb na transakci dle kap. 4.8; palivo a ostatní evidovat v rozpisu transakce pro reporting. Za každou splněnou kampaň evidovat samostatný pohyb, i při bonusu 0 bodů, aby T04 nezmizel ze statistik úspěšnosti kampaně.
- Portál sdílet podle konkrétního Contactu člena. Přístup přes společný Account by mohl zpřístupnit cizí data. Členství má přímý Contact lookup; pohyby dědí přístup přes člena, samostatně sdílené transakce a vouchery mají vlastní Contact lookup. Mapování ověřit podle [pravidel sharing sets](https://help.salesforce.com/s/articleView?id=sf.networks_setting_light_users.htm&language=en_US&type=0).
- Role Člen, Loyalty manažer, Operátor EneServis a Reporting oddělit objektovými, polními a záznamovými oprávněními. Operátor vidí jen údaje voucheru povolené FR-E6-06, včetně jména člena, nikoli bodový účet. Zápis pohybů a změny stavů dovolují jen řízené serverové operace.

## Datové toky

**Nákup:** CSV nebo formulář → stejná validace a kontrola unikátního ID → pravidla platná v čase nákupu → základ a samostatné bonusy → společný zápis transakce a pohybů → aktualizovaný zůstatek. Například T01 dává `45 + 9 + 5 + 50 = 109 bodů`. Transakce i použitá pravidla uchovají rozpis pro audit. Nevalidní vstup zůstane dohledatelný jako chyba bez pohybů; selhání zápisu bodů nesmí zanechat stav Zpracováno. Import 5 000 záznamů rozdělit do platformních dávek, nikoli jedné databázové transakce.

**Aktivita:** ověřená změna profilu nebo souhlasu → kontrola unikátního klíče člen + aktivita → jednorázový pohyb. Opětovné udělení souhlasu nepřidá další body.

**Odměna:** potvrzení požadavku s identifikátorem opakování → zámek bodového účtu → nová kontrola aktivního členství, zůstatku, aktivní odměny a její ceny → voucher a záporný pohyb v jedné transakci. Unikátní klíč požadavku brání dvojkliku, zámek brání přečerpání dvěma různými požadavky. Mechanismus zámku dokládá [Salesforce FOR UPDATE](https://developer.salesforce.com/docs/platform/salesforce-soql-sosl/guide/sforce-api-calls-soql-select-for-update.html). Cena, nominální hodnota a popis odměny se na voucher uloží jako kopie při vydání.

**E-mail:** po úspěšném potvrzení voucheru samostatné odeslání s evidencí stavu a možností opakovat pouze e-mail. Selhání doručení neruší již vydaný voucher; portál ukáže jeho kód a pravdivý stav odeslání. Nedojde k druhému odečtení bodů.

**Report:** čtecí konektor/API → agregace se stejnými definicemi jako kontrolní Salesforce reporty → artifact s obdobím a časem aktualizace. Rozlišit datum nákupu/pohybu od času technického zpracování a vydání voucheru od použití v servisu.

## Rozhodnutí před implementací

Vlastníci jsou navržené role, nikoli potvrzená odpovědnost konkrétních lidí.

| ID | Co rozhodnout / ověřit | Doporučení | Kdo / kdy | Vazba |
| --- | --- | --- | --- | --- |
| D1 | Rozsah první dodávky a bonusů | MUST jako základ. Po něm ruční opravy, karta a ověřování v servisu. Expiraci, úrovně, storno a PDF odložit; potvrdit, zda nějaký bonus povýšit. | SteerCo / před závazkem rozsahu | E1–E11, Q7–Q9 |
| D2 | Licence, objemy a model identity | Ověřit dostupné Experience licence, přístup k vlastním objektům, počet členů a frekvenci přihlášení; poté potvrdit Contact versus Person Account a přístup operátora. Demo může použít interního operátora dle Q3; produkční partner potřebuje odpovídající přístup. | Architekt + vlastník Salesforce, rozpočet SteerCo / před portálem | Q3, Q11, NFR-05 |
| D3 | Historická platnost kampaní a parametrů | Publikovanou verzi zachovat, změnu založit jako novou časovou verzi. Ukončená kampaň se nezobrazuje dnes, historický nákup se hodnotí podle tehdejších pravidel. Garant musí upřesnit T24, který neuvádí datum nákupu vůči deaktivaci. | Garant + architekt / před výpočtem | BR-27, BR-28, T24 |
| D4 | Způsob živého připojení artifactu | Nejdříve ověřit čtení vlastních objektů a refresh na skutečném účtu; teprve pak zvolit konektor nebo API. Standardní Salesforce report je provozní záloha, ne náhrada povinného artifactu. | Report developer + admin / na začátku | FR-E9-01 |
| D5 | Finanční vstupy a interpretace reportu | Potvrdit hodnotu prohlídky, návrh 2 000 Kč, roční rozpočet a práci s nulovým jmenovatelem. Míru čerpání počítat z úhrnných bodů, ne průměrem měsíčních procent. Nominální hodnotu voucherů odlišit od skutečného vyúčtování partnera, které zadání neurčuje. | Head of Loyalty + finance / před dokončením KPI | Q1, Q2, FR-E9-02 až 05 |
| D6 | Historické KPI a referenční datum | Členové aktivní ke konci období vyžadují historii stavů; samotný dnešní stav nestačí. Potvrdit jednotné časové pásmo Europe/Prague a způsob evidence změn stavu. | Analytik + Head of Loyalty / před reportem | BR-43, FR-E9-02 |
| D7 | Provozní konfigurace a audit | Vlastní kampaňový objekt s verzemi; obchodní parametry v editovatelných záznamech. Žádný požadavek na obecný pravidlový engine. | Architekt + loyalty manažer / před datovým modelem | BR-13, BR-21, NFR-04, NFR-06 |
| D8 | Potvrzení předpokladů a prioritních rozporů | Potvrdit Q4–Q6, Q10 a Q12 dle návrhů v context.md. Ujasnit minimální blokaci vyžadovanou BR-05, i když její UI je SHOULD; kartu požadovanou NFR/E7, ale vedenou jako SHOULD; zrušení voucheru BR-57 versus COULD FR-E6-07. | Garant / před uzavřením rozsahu | Kap. 11, FR-E1-04, FR-E1-06 |

Licence vybírat podle konkrétního použití, objektů a frekvence přístupů, jak uvádí [Salesforce přehled licencí](https://help.salesforce.com/s/articleView?id=experience.exp_cloud_plan_licenses.htm&language=en_US&type=5). Předpoklad využití konektoru v artifactu vychází z [dokumentace Anthropic](https://support.claude.com/en/articles/17153992-what-are-artifacts-and-how-do-i-use-them); podpora konkrétního Salesforce připojení v tomto prostředí zatím prokázána není.

## Rizika a hraniční případy

- **Odhad a termín:** hackathonové demo není odhad produkční dodávky. Pro rozsah v MD chybí ověření orgu, licencí, počtu uživatelů, objemů reálných transakcí a provozních požadavků. Integraci POS ocenit samostatně. Odhad předložit po těchto zjištěních a schválení návrhu.
- **Historická data:** již zpracované transakce nepřepočítávat při změně pravidla. U opakovaného ID s jinými částkami ohlásit konflikt, neměnit původní připsání.
- **Neměnnost versus expirace:** bude-li schválena expirace, spotřebu přídělů a zbývající množství vést v oddělené evidenci. Nepřepisovat původní pohyby; odloženě importované body vyžadují výslovné rozhodnutí o dni připsání pro expiraci.
- **Souhlasy:** zachovat historii udělení, odvolání a verzí textu, nikoli jen poslední hodnotu pole. Jednorázovou odměnu za souhlas oddělit od aktuálního souhlasu.
- **Vyhodnocení:** porovnání nákupů v kampani je orientační. Zadání neposkytuje kontrolní skupinu ani prodeje mimo Klub.

## Ověření výsledku

Převzít scénáře T01–T10 a T20–T29, T24 doplnit podle D3. Nad skutečným řešením ověřit souběžné čerpání z jednoho účtu, dvojklik, opakovaný import, změněný obsah stejného ID, opakování e-mailu a přístup dvou různých členů. Import 5 000 transakcí musí skončit se souhlasnými součty a dohledatelnými chybami. Report po novém nákupu a refreshi změní čísla, která souhlasí s kontrolním Salesforce dotazem. Portál ověřit na šířce 360 px; e-mail a obnovu hesla do 2 minut. Cíle načtení 3 s pro portál a 10 s pro report zůstávají SHOULD.

## Podklady a stav návrhu

Primárním podkladem je [context.md](../../../context.md), verze 1.0. Odkazované PDF zadání, průzkum aplikací a brand kit nejsou v dostupném repozitáři; jejich soulad nebyl samostatně ověřen. Nacenění licencí z context.md do prezentace nepřebíráme jako ověřený rozpočet.

Návrh prošel kontrolou konzistence, rozsahu, otevřených otázek a odpovědností komponent. Nejde o implementační plán ani schválení realizace. Další krok po odsouhlasení směru je rozpad a odhad v MD.
