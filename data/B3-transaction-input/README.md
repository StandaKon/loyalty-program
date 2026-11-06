# Testovací transakce B3

Přenosná CSV sada pro testování vstupu transakcí přes nasazený engine B2. Veškeré osobní údaje jsou fiktivní, e-maily používají neexistující doménu `example.invalid`. Salesforce ID ani přihlašovací údaje se neverzují.

## Obsah

| Soubor | Počet | Účel |
| --- | ---: | --- |
| `members.csv` | 3 | Dva aktivní členové a jeden blokovaný Person Account. |
| `campaigns.csv` | 2 | +50 bodů za alespoň 40 litrů; násobitel základu 1,1 za ostatní nákup alespoň 150 Kč. Platnost 1.–31. 10. 2026. |
| `transactions.csv` | 12 | Akceptační příklad 109 bodů, prahy, zaokrouhlení, nulový základ, hranice kampaní v Europe/Prague a blokovaný člen. |
| `transactions-bulk.csv` | 251 | Dávkový import, každý nákup za 25 bodů. |
| `transactions-invalid.csv` | 7 | Pět nevalidních nákupů, opakování shodného POS ID a konflikt jeho obsahu. Spouštět odděleně. |
| `expected.csv` | 263 | Explicitní očekávané výsledky a počty pohybů. Tento soubor se neimportuje. |

## Formát a mapování

CSV používá UTF-8, čárku jako oddělovač, desetinnou tečku bez oddělovačů tisíců a čas ISO 8601 s časovým pásmem. Částky mají nejvýše dvě desetinná místa, litry tři. Nulové hodnoty se předávají explicitně. Pevná data nákupů jsou záměrná; testy kampaní nesmějí záviset na dni spuštění.

| CSV sloupec | Cíl |
| --- | --- |
| `POS_Transaction_Id__c` | Unikátní externí ID nákupu; tato sada používá prefix `B3:`. |
| `Member_Number__c` | Vyhledání Person Account podle `Account.Member_Number__c`, následně `Loyalty_Transaction__c.Member__c`. Není to Salesforce ID. |
| `Purchased_At__c` | Datum a čas nákupu. Engine vyhodnocuje den v Europe/Prague. |
| `Total_Amount__c` | Celková částka v Kč. |
| `Fuel_Amount__c` | Částka za palivo v Kč. |
| `Liters__c` | Litry paliva. |
| `Other_Amount__c` | Ostatní částka v Kč. |

Import neposílá výsledná bodová pole, stav zpracování ani pohyby. Validace částek, zpracování a výpočet bodů zajišťují existující B1/B2 pravidla a trigger. Blokovaný člen je platně uložený vstup, jehož zpracování B2 skončí stavem `Error` bez bodového pohybu.

## Načtení

Příkazy spouštějte z kořene repozitáře. Je potřeba Python 3.9+, Salesforce CLI v2 s příkazem `sf api request rest`, přihlášený výchozí org, nasazené B1/B2 a Person Accounts. Skript používá API verzi ze `sfdx-project.json`, nezadává ani nemění cílový org a odmítne zápisy mimo sandbox nebo Developer Edition.

Přihlášený operátor potřebuje vytvoření/čtení Account, kampaní a transakcí, příslušná vstupní pole a čtení pohybů a zůstatku. Setup je administrátorský seed krok, protože členům nastavuje serverová registrační pole. Použitý uživatel je System Administrator s přiřazeným `Loyalty_Manager`. Manažerský permission set nově zpřístupňuje existující record type `PersonAccount.PersonAccount`; nemění to pravidla zápisu serverových polí pro běžné manažery.

Před prvním vytvořením členů musí být tato změna manažerského permission setu nasazena. Nové přiřazení není potřeba, pokud jej uživatel již má. Metadata název je `PersonAccount.PersonAccount`, i když SOQL ukazuje objekt `Account`; rozdíl názvů popisuje [Salesforce známá chyba W-4449208](https://help.salesforce.com/s/issue?id=a028c00000qQ2fAAAS&language=en_US). Při dalším nasazování permission setu je nutné sloučit tuto změnu s jeho aktuální verzí; při ověřování ji souběžné nasazení jiné větve přepsalo. Obnova přístupu zachovala i novější manažerská oprávnění v orgu.

```bash
python3 scripts/python/generate_b3_data.py
python3 scripts/python/load_b3_data.py setup
python3 scripts/python/load_b3_data.py load --file data/B3-transaction-input/transactions.csv --report .localdevserver/b3-scenarios.json
python3 scripts/python/load_b3_data.py load --file data/B3-transaction-input/transactions-bulk.csv --report .localdevserver/b3-bulk.json
python3 scripts/python/load_b3_data.py verify
```

Členové se vytvoří před kampaněmi a transakcemi. Vazby se řeší při importu, takže CSV lze přenést do jiného podporovaného orgu. Import používá standardní REST sObject Collections přes Salesforce CLI a rozděluje zápis na nejvýše 200 záznamů. Soubor s 251 nákupy odešle ve dvou požadavcích 200 + 51. Nejde o jednu atomickou databázovou transakci; úspěšné řádky zůstanou uloženy i při odmítnutí jiných řádků.

Opakujte stejné příkazy `setup` a `load` pro kontrolu opakovatelnosti. Existující shodné členy, kampaně a nákupy loader přeskočí. Shodné POS ID s odlišným členem, částkami, litry či časem odmítne jako konflikt a původní nákup nemění. Duplicitní ID uvnitř nového vstupního souboru odmítne na dalším řádku. Spouštějte pouze jeden loader současně.

## Odmítnuté řádky

Po načtení platných souborů spusťte:

```bash
python3 scripts/python/load_b3_data.py load --file data/B3-transaction-input/transactions-invalid.csv --report .localdevserver/b3-invalid.json
python3 scripts/python/load_b3_data.py verify
```

První příkaz očekávaně vrací exit code 1. Výsledek má být 0 vložených, 1 existující a 6 odmítnutých řádků. JSON report obsahuje číslo řádku CSV včetně hlavičky, POS ID a konkrétní chybu. Reporty jsou v ignorované pracovní složce.

| Řádek CSV | Očekávaná reakce | Náprava |
| ---: | --- | --- |
| 2 | Neznámý člen, odmítnuto loaderem. | Opravit členské číslo nebo nejprve vytvořit člena. |
| 3 | Nesouhlasí celková částka, odmítnuto B1. | Opravit součet paliva a ostatních částek. |
| 4 | Záporná částka, odmítnuto B1. | Opravit částku; tento vstup není cesta pro storna. |
| 5 | Nákup v budoucnosti, odmítnuto B1. | Opravit datum nebo časové pásmo. |
| 6 | Palivo bez litrů, odmítnuto B1. | Opravit litry a částku za palivo. |
| 7 | Shodný již vložený nákup, přeskočeno. | Není nutná změna. |
| 8 | Stejné POS ID s jinými litry, konflikt. | Prověřit původní účtenku; neopravovat zpracovaný nákup upsertem. |

Nevalidní řádky nevytvářejí neúplné nákupy ani bodové pohyby. Stav `Error` je vyhrazen pro uložené nákupy s chybou zpracování, například blokovaného člena.

## Ověření a rozsah

Verifier porovnává původní nákupní údaje a přiřazení členů proti CSV, bodová pole proti `expected.csv`, počet a součet pohybů a zůstatek každého člena proti celému jeho ledgeru. U příkladu 109 bodů vyžaduje pohyby 54, 5 a 50. Ověřuje i nulový bonus kampaně a chybu blokovaného člena bez pohybu.

Všechny zapnuté kampaně orgu mohou ovlivnit backdated nákupy. Případný rozdíl verifier oznámí; loader jiné kampaně nevypíná a existující testovací konfiguraci nepřepisuje. Úspěšné opakování neslouží jako retry nákupu se stavem `Error`; ten vyžaduje samostatný podporovaný postup B2.

Sada neobsahuje ruční obrazovku B3, test jejího vstupu, stanice, odměny, vouchery ani rozsáhlá data B4. Tyto části zůstávají navazujícími úkoly. Pro opětovné použití stačí shodný dataset znovu načíst. Hromadné mazání a rušení již připsaných bodů není součástí loaderu.

Lokální kontroly bez orgu:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts/python -p test_b3_data.py
```

## Výsledek ověření 6. 11. 2026

Na výchozím vývojovém orgu `EnePumoa` se vytvořili tři členové, dvě kampaně a 263 transakcí. Verifier potvrdil 262 zpracovaných nákupů a jednu očekávanou chybu blokovaného člena, 270 bodových pohybů a celkem 6 907 bodů. Zůstatky členů 001/002/003 jsou 3 385 / 3 522 / 0 bodů.

Příklad se 109 body má přesně pohyby 54 + 5 + 50. Negativní soubor vytvořil nula záznamů, rozpoznal jeden shodný existující nákup a odmítl šest řádků. Opakovaný setup i oba importy vytvořily nula nových záznamů; bodové pohyby a zůstatky se nezměnily. Prošlo všech 12 lokálních testů a 17 existujících Apex testů B2 (`PointsCalculatorTest`, `LoyaltyTransactionServiceTest`).
