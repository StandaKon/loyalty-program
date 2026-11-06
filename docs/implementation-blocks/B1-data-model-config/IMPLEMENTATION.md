# Nasazení datové vrstvy B1

Datum 6. 11. 2026. Uživatel schválil návrh a výslovně autorizoval vytvoření a nasazení metadat. Nasazení používá pouze lokální default org z projektu, bez změny cílového orgu.

## Prostředí a rozsah

Připojený org je Enehano, Developer Edition, ID `00Daj00001EHpFFEA1`. `IsSandbox = false` je u Developer Edition očekávané a neoznačuje v tomto případě produkční prostředí. Ověřena dostupnost Person Accounts, consent objektů a Customer Community licencí. Org obsahuje Person Account record type `PersonAccount` a vlastní komunitní profil `EneOil Member`.

Implementace používá API 63.0 podle projektu. Vytváří:

- Pět objektů `Loyalty_Transaction__c`, `Loyalty_Campaign__c`, `Point_Ledger__c`, `Reward__c` a `Voucher__c`.
- Celkem 80 polí včetně rozšíření Accountu, standardních consent objektů a Custom Metadata.
- Třicet validačních pravidel, master-detail ledgeru na Account a standardní roll-up zůstatku.
- `Loyalty_Settings__mdt` a záznam Default se sazbami 1 bod za litr, 20 Kč za bod, 100 bodů za profil a 50 bodů za marketing.
- Pět záložek a pět rozložení pro standardní práci s daty.
- Sedm permission setů, dva Custom Permissions, členský sharing set, prázdnou skupinu správců kampaní a dvě pravidla interního sdílení.
- Tři testovací Apex třídy. Neobsahuje produkční Apex, portál ani bodový engine.

Opakující se XML vytváří [deterministický generátor](../../../scripts/python/generate_b1_metadata.py). Spouští se z kořene repozitáře příkazem `python3 scripts/python/generate_b1_metadata.py`. Nemění jiné komponenty ani neodstraňuje soubory. Opakované spuštění bylo ověřeno porovnáním SHA-256 všech XML souborů.

## Oprávnění

| Sada | Účel |
| --- | --- |
| `Loyalty_Member` | Customer Community člen. Pouze Read na vlastní Account, Contact, transakce, ledger a vouchery a společné katalogové objekty. Žádný přímý zápis bodů či voucherů, žádné Delete, View All ani Modify All. Osobní e-mail a telefon se zpřístupňují přes odpovídající Contact FLS. |
| `Loyalty_Campaign_Manager` | Create, Read a Update kampaní a odměn, pouze Read partnera. Bez přístupu k osobním polím člena, ledgeru a voucherům. |
| `Loyalty_Manager` | Interní správa programu, členů, katalogu a kampaní, čtení pohybů a voucherů. Také Read standardních consent objektů a jejich nových vlastních polí, se zachováním záznamového sdílení. |
| `Loyalty_Back_Office` | Čtení programu a založení vstupního nákupu. |
| `Loyalty_Transaction_Import` | APIEnabled, vyhledání člena a založení vstupního nákupu. Bez editace vypočtených výsledků. |
| `Loyalty_Reporting` | Čtecí sada pro všechny potřebné reportové záznamy. Bez kódu voucheru a osobních profilových polí. Obsahuje schválený Read All rozsah pro reporting. |
| `Loyalty_Service_Operator` | Zatím pouze Custom Permission pro budoucí řízenou operátorskou akci. Žádné plošné čtení voucherů. |

Sharing set `EneOil_Member_Data` mapuje uživatelský Account na vlastní Account, `Loyalty_Transaction__c.Member__c` a `Voucher__c.Member__c`. Ledger dědí přístup z Accountu. Je připraven pro profily `EneOil Member`, `Customer Community User` a `Customer Community Login User`. Standardní externí profily org aktuálně neumožňuje použít pro vytváření uživatelů, proto se pro skutečné členy používá vlastní profil. Toto bezpečnostní nastavení se neměnilo.

Skupina `Loyalty_Campaign_Managers` má Edit sdílení pro všechny kampaně a odměny. Manažer, který má upravovat i cizí záznamy, potřebuje příslušný permission set a členství v této skupině. Samotný permission set nepřiděluje přístup k cizím záznamům. Skupina byla nasazena bez členů.

Po výslovném souhlasu uživatele byla sada `Loyalty_Manager` přiřazena připojenému administrátorovi `barbora.dlapalova@ene.loyalty.cz`. Přiřazení bylo ověřeno dotazem na `PermissionSetAssignment`, ID `0Paaj000019pBa3CAE`. Ostatní sady nejsou přiřazeny reálným uživatelům. Testovací přiřazení a externí uživatelé vznikají pouze uvnitř testů a po nich se vracejí zpět.

## Výsledky ověření

Základní deployment `0Afaj00000qcLblCAE` úspěšně nasadil 140 komponent včetně prvních testů. Následný deployment `0Afaj00000qc857CAA` úspěšně ověřil všech 10 testů, včetně skutečného přístupu dvou Customer Community uživatelů v USER_MODE. Nezávislá revize následně doplnila interní sdílení správců kampaní a čtení evidence souhlasů.

Závěrečný deployment opravených oprávnění a sdílení `0Afaj00000qcO8DCAU` skončil `Succeeded`, 12 komponent bez chyb, všech 10 testů úspěšných. Nasazený sharing set byl následně znovu stažen přes Metadata API a porovnán s lokálním mapováním.

Testy ověřují součet 109 bodů, bulk zápis 251 pohybů, nevalidní částky, duplicitní POS ID, neměnnost pohybu, odmítnutí záporného zůstatku, voucherový snapshot a zůstatek 240 po směně, jednorázový klíč aktivity, shodu člena zdrojového nákupu, nevalidní kampaň a čistě čtecí členskou sadu. Přístupový test pro každého ze dvou členů ověřuje právě jeden vlastní Account, nákup, pohyb a voucher, bez cizích kódů a bez možnosti přímo vytvářet pohyby či vouchery.

Lokálně byla zkontrolována XML syntaxe, opakovatelnost generování a absence Delete či globálních oprávnění v sadách člena a manažerů. Obě zjištění z nezávislé revize byla opravena a znovu přečtena reviewerem.

## Rozdíly proti návrhu a návaznosti

Interní Account a Contact sdílení zůstalo podle existujícího orgu Public Read/Write. Externí přístup je Private. B1 nepřepisuje interní přístup ke stávajícím obchodním datům. Katalog a vlastní kampaně mají podle návrhu Public Read Only a neslouží pro tajné koncepty nabídek.

Self-lookup `Point_Ledger__c.Reverses_Entry__c` musí používat SetNull. Salesforce na self-lookupu nepodporuje Restrict. Ostatní relevantní lookupy na obchodní zdroje zákaz mazání používají. Běžné sady nemají Delete. Ochrana proti administrátorskému smazání a merge Accountu, kaskádovému mazání a odstranění ledgeru vyžaduje navazující serverovou implementaci. Metadata samotná ji nezajišťují.

Povinnost vyplnění většiny vlastních polí zajišťují aktivní validační pravidla. Pole nejsou univerzálně required na úrovni FLS, aby bylo možné skrýt technické klíče a zápisová pole členům. Výjimkou je vždy povinný master-detail ledgeru.

Následující funkce nejsou součástí této datové vrstvy:

- B2 vytváří kanonické klíče, vyhodnocuje a zamyká kampaně po použití, zapisuje zdroje a pohyby atomicky a řeší retry a zámky účtu. Unikátní pole samo nesestavuje klíč ani neprovádí výpočet.
- B6 generuje členské číslo `ENE-<18znakové Account ID>` při dokončení registrace a doplní odpovídající serverové služby. Bez nich se číslo automaticky nevyplní.
- B7 zapisuje neměnné consent události, verze textů, aktuální marketingový stav a jednorázové bonusy. Metadata consent objektů sama neprovádějí synchronizaci ani udělení souhlasu.
- B8 vytváří voucher a odpočet v jedné transakci, ověřuje dostatečný zůstatek a opakování požadavku, generuje kód a řeší e-mail, uplatnění a případný Refund. Přímé správcovské vložení voucheru samo body neodečte.
- Operátorská sada dostane přístup ke konkrétní akci až s její implementací. Nevzniká obecný voucherový CRUD přístup.

Žádná členská, partnerská ani nákupní seed data nebyla vytvořena. Po schválení finančních vstupů je připraví B4 přes stejné serverové služby jako běžný provoz. Do produkce se nenasazovalo a existující obchodní data se neměnila.
