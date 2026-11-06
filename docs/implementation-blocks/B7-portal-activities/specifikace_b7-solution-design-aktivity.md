# B7 · Solution design: aktivity v členském portálu (údaje o autě +100, marketingový souhlas +50)

| | |
| --- | --- |
| Projekt | Věrnostní program NAJETO (EneOil), AI Hackathon 2026, varianta 2, tým 2A |
| Verze | 0.9 · 6. 11. 2026 · návrh pro implementaci |
| Vlastník | Matěj Kováčik (Enehano, tým 2A) |
| Vstupy | `specifikace/b7-marketingove-zadani-aktivity.md` (obchodní a obsahová pravidla, texty), `EneOil-Klub-Solution-Design.docx` v1.0, `specifikace/eneoil-klub-funkcni-zadani.md` (BR-30 až BR-34, FR-E4-01 až 03, FR-E1-01, FR-E1-05, NFR-12) |
| Rozsah | Datový model, konfigurace, serverová logika, LWC v Experience Cloudu, back-office, bezpečnost, report KPI, testy, plán implementace |

> **Názvy existujících objektů a polí** (`Point_Ledger__c`, `Member_Status__c`, `Member_Number__c` …) jsou převzaté ze SD v1.0. Před implementací je ověřte proti orgu z bloku Implementace I; pokud se liší, platí org a tento dokument se upraví.

---

## 1. Shrnutí řešení

- Údaje o autě a souhlas se ukládají na **členovi (Person Account)**. Člen je mění jen přes Apex controller v portálu, nikdy přímo.
- O odměně rozhoduje **jedna serverová služba** `ActivityRewardService`, volaná z triggeru na Account a z jednorázové dávky. Kanál změny (portál, registrace, back-office, dávka) nehraje roli.
- **Jednorázovost** garantuje databáze: pohyb bodů typu Aktivita má `Unique_Key__c = ACT-{AccountId}-{ActivityCode}` jako unikátní External ID. Druhý pokus skončí `DUPLICATE_VALUE` a služba ho vyhodnotí jako „už odměněno“. Žádný příznak na členovi, který by šel ručně vynulovat.
- **Souhlas má auditní stopu** v neměnném objektu `Consent_Event__c` (udělení / odvolání, čas, verze textu, místo). Aktuální stav je na členovi a synchronizuje se do standardního `PersonHasOptedOutOfEmail`.
- Body za aktivity se připisují ve **stejné transakci** jako uložení dat. Selže-li zápis bodů z jiného důvodu než duplicity, uložení se celé vrátí a portál ukáže chybu. Potvrzení o bodech portál zobrazí až z odpovědi serveru.
- Konfigurace (body, zapnutí aktivity, verze textu souhlasu) je v Custom Metadata, bez nasazení kódu.

### 1.1 Rozhodnutí

| ID | Rozhodnutí | Důvod |
| --- | --- | --- |
| SD-B7-01 | Vozidlo = 4 pole přímo na Account (jedno auto na člena). Žádný objekt Vozidlo. | R-04, jednoduchost; přechod na více aut = nový objekt `Vehicle__c` v roadmapě |
| SD-B7-02 | Jednorázovost přes unikátní `Unique_Key__c` na `Point_Ledger__c`, ne přes příznak na členovi | Odolné proti dvojkliku, souběhu i opakované dávce; zdroj pravdy je bodový účet |
| SD-B7-03 | Vyhodnocení odměny v triggeru na Account (after insert / after update) | Pokryje portál, registraci, back-office i import; jedna logika |
| SD-B7-04 | Kompletnost profilu počítá Apex (`VehicleProfile.isComplete`), formule `Profile_Complete__c` je jen pro reporty | Formule v Trigger.new nejsou spolehlivě přepočítané |
| SD-B7-05 | Audit souhlasu ve vlastním `Consent_Event__c`, stav na Account | Rychlé pro hackathon; standardní consent model (Individual, ContactPointTypeConsent) je roadmapa při napojení rozesílacího nástroje |
| SD-B7-06 | Souhlas uděluje jen člen (portál, registrace). Back-office smí jen zaznamenat odvolání. | Souhlas za člena nelze prokázat |
| SD-B7-07 | Body za aktivity v `Loyalty_Activity__mdt`, ne v `Loyalty_Settings__mdt` | Jeden záznam = jedna aktivita (body, zapnuto, pořadí, text v historii). Nahrazuje „body za aktivity“ ze SD v1.0 kap. 5. |
| SD-B7-08 | Stávající členové: idempotentní `ActivityBackfillBatch`, spouštěná při go-live (a kdykoli znovu) | R-05; opakované spuštění nic nezdvojí |
| SD-B7-09 | SPZ se nesbírá, pole se nezakládá | R-03 (minimalizace) |

---

## 2. Datový model

### 2.1 Account (Person Account): nová pole

| Label | API název | Typ | Povinné / Default | Poznámka |
| --- | --- | --- | --- | --- |
| Značka vozidla | `Vehicle_Make__c` | Picklist (restricted) | ne / prázdné | Hodnoty viz 2.4; API = label |
| Model vozidla | `Vehicle_Model__c` | Text(40) | ne / prázdné | Trim na serveru |
| Rok výroby | `Vehicle_Year__c` | Number(4,0) | ne / prázdné | Validation rule `VR_Vehicle_Year_Range` |
| Palivo | `Vehicle_Fuel_Type__c` | Picklist (restricted) | ne / prázdné | Hodnoty viz 2.4 |
| Profil kompletní | `Profile_Complete__c` | Formula (Checkbox) | – | Jen reporty a list views (SD-B7-04) |
| Profil poprvé dokončen | `Profile_First_Completed__c` | DateTime | ne / prázdné | Nastaví before trigger při prvním splnění, dál se nemění |
| Marketingový souhlas | `Marketing_Consent__c` | Checkbox | – / false | Aktuální stav |
| Souhlas udělen | `Marketing_Consent_Granted__c` | DateTime | ne / prázdné | Poslední udělení |
| Souhlas odvolán | `Marketing_Consent_Revoked__c` | DateTime | ne / prázdné | Poslední odvolání |
| Verze textu souhlasu | `Marketing_Consent_Version__c` | Text(20) | ne / prázdné | Např. `MKT-EMAIL-1.0` |
| Zdroj souhlasu | `Marketing_Consent_Source__c` | Picklist | ne / prázdné | Registrace · Profil portálu · Odkaz v e-mailu · Back-office · Migrace |
| (standard) Email Opt Out | `PersonHasOptedOutOfEmail` | Checkbox | – | `= NOT(Marketing_Consent__c)`, nastavuje `ConsentService` |

Formule `Profile_Complete__c`:

```
AND(
  NOT(ISPICKVAL(Vehicle_Make__c, "")),
  NOT(ISBLANK(Vehicle_Model__c)),
  NOT(ISBLANK(Vehicle_Year__c)),
  NOT(ISPICKVAL(Vehicle_Fuel_Type__c, ""))
)
```

Validation rule `VR_Vehicle_Year_Range`:

```
AND(
  NOT(ISBLANK(Vehicle_Year__c)),
  OR(Vehicle_Year__c < 1900, Vehicle_Year__c > YEAR(TODAY()) + 1)
)
```

Chybová zpráva (back-office, věcně): „Rok výroby musí být mezi 1900 a následujícím kalendářním rokem.“

Field History Tracking: `Marketing_Consent__c`, `Vehicle_Make__c`, `Vehicle_Model__c`, `Vehicle_Year__c`, `Vehicle_Fuel_Type__c` (5 z limitu 20 na Account, ověřit obsazenost).

### 2.2 Point_Ledger__c: doplnění

| Label | API název | Typ | Poznámka |
| --- | --- | --- | --- |
| Kód aktivity | `Activity_Code__c` | Text(40) | `PROFILE`, `MARKETING_CONSENT`; vyplněno jen u typu Aktivita |
| (existující) Unikátní klíč | `Unique_Key__c` | Text(100), External ID, **Unique** | Formát `ACT-{AccountId18}-{ActivityCode}` |

Pohyb typu Aktivita: `Type__c = 'Aktivita'`, `Points__c = Loyalty_Activity__mdt.Points__c`, `Movement_Date__c = now`, `Description__c = Loyalty_Activity__mdt.Ledger_Description__c` („Údaje o autě“, „Souhlas s novinkami e-mailem“).

### 2.3 Consent_Event__c (nový, neměnný)

| Label | API název | Typ | Poznámka |
| --- | --- | --- | --- |
| Číslo | `Name` | Auto Number `CE-{0000000}` | |
| Člen | `Member__c` | Lookup(Account), povinné | Lookup, ne master-detail: záznam přežije i administrativní zásahy do člena |
| Účel | `Purpose__c` | Picklist | `MARKETING_EMAIL` (připraveno na další účely) |
| Událost | `Event_Type__c` | Picklist | Udělení · Odvolání |
| Čas | `Event_Timestamp__c` | DateTime, povinné | Serverový čas |
| Verze textu | `Text_Version__c` | Text(20) | U udělení povinné |
| Zdroj | `Source__c` | Picklist | Registrace · Profil portálu · Odkaz v e-mailu · Back-office · Migrace |
| Poznámka | `Note__c` | Text(255) | Back-office: kanál žádosti (telefon, e-mail) |

Neměnnost: trigger `ConsentEventTrigger` (before update, before delete) → `addError` pro všechny bez custom permission `Loyalty_Bypass_Immutability`. Org-wide default: Private; čtení přes permission set Loyalty Manager.

### 2.4 Hodnoty picklistů

- `Vehicle_Make__c`: seznam z marketingového zadání 1.2 (Audi … Volvo, Jiná značka). Restricted, pořadí: abecedně, „Jiná značka“ poslední.
- `Vehicle_Fuel_Type__c` (API → label): `PETROL` Benzín · `DIESEL` Nafta · `LPG` LPG · `CNG` CNG · `HYBRID` Hybrid · `PHEV` Plug-in hybrid · `ELECTRIC` Elektro.

### 2.5 Custom Metadata

**`Loyalty_Activity__mdt`**

| Pole | Typ | `Profile_Complete` | `Marketing_Consent` |
| --- | --- | --- | --- |
| `Code__c` | Text(40) | `PROFILE` | `MARKETING_CONSENT` |
| `Points__c` | Number(6,0) | 100 | 50 |
| `Active__c` | Checkbox | true | true |
| `Sort_Order__c` | Number(3,0) | 1 | 2 |
| `Ledger_Description__c` | Text(80) | Údaje o autě | Souhlas s novinkami e-mailem |

**`Consent_Text__mdt`**

| Pole | Typ | `MKT_EMAIL_1_0` |
| --- | --- | --- |
| `Version__c` | Text(20) | `MKT-EMAIL-1.0` |
| `Purpose__c` | Text(40) | `MARKETING_EMAIL` |
| `Checkbox_Text__c` | Long Text Area | text 7.1 marketingového zadání |
| `Info_Text__c` | Long Text Area | text 7.2 |
| `Privacy_Policy_Path__c` | Text(255) | `/zasady-ochrany-osobnich-udaju` |
| `Active__c` | Checkbox | true |

Pravidlo: aktivní je právě jeden záznam na účel. Nová verze textu = nový záznam, starý `Active__c = false`. Už udělené souhlasy zůstávají se starou verzí (re-consent při podstatné změně je mimo B7).

Texty UI (karty, stavy, chyby) jsou **Custom Labels** s prefixem `NAJ_ACT_` (seznam v kap. 5.4), aby je šlo upravit v Setup bez zásahu do LWC.

---

## 3. Serverová logika (Apex)

### 3.1 Komponenty

| Třída | Sharing | Odpovědnost |
| --- | --- | --- |
| `MemberActivityController` | with sharing | `@AuraEnabled` API pro LWC. Zjistí `AccountId` přihlášeného člena z `User`, nikdy nebere Id od klienta. Mapuje výjimky na kódy chyb. |
| `MemberProfileService` | without sharing | Validace a uložení / smazání údajů o autě na vlastním Account. |
| `ConsentService` | without sharing | Udělení a odvolání souhlasu: pole na Account + `Consent_Event__c` v jedné transakci. Invocable metoda pro back-office odvolání. |
| `ActivityRewardService` | without sharing | `evaluate(Set<Id> accountIds)`: zjistí nárok, vloží pohyby, ošetří duplicity, vrátí výsledek. Statický `Map<Id, Set<String>> awardedInTransaction` pro controller. |
| `VehicleProfile` | – | Čistá logika: `isComplete(Account)`, `missingFields(Account)`, rozsah roku. |
| `AccountActivityTriggerHandler` | – | Trigger action na Account (trigger-actions-framework podle OP-07). |
| `ActivityBackfillBatch` | without sharing | Jednorázová dávka pro stávající členy, idempotentní. |
| `ConsentEventTrigger` | – | Neměnnost `Consent_Event__c`. |

### 3.2 Pravidla nároku (`ActivityRewardService`)

Pro každou aktivitu, jejíž `Loyalty_Activity__mdt.Active__c = true`:

| Aktivita | Nárok vzniká, když |
| --- | --- |
| `PROFILE` | `Member_Status__c = 'Aktivní'` **a** `VehicleProfile.isComplete(acc)` **a** neexistuje pohyb s klíčem `ACT-{Id}-PROFILE` |
| `MARKETING_CONSENT` | `Member_Status__c = 'Aktivní'` **a** `Marketing_Consent__c = true` **a** neexistuje pohyb s klíčem `ACT-{Id}-MARKETING_CONSENT` |

Postup (bulk, jeden SOQL na existující klíče, jeden DML):

```
evaluate(accountIds):
  activities = Loyalty_Activity__mdt.getAll() filtr Active__c
  accounts   = SELECT Id, Member_Status__c, Vehicle_*, Marketing_Consent__c FROM Account WHERE Id IN :accountIds
  candidateKeys = pro každý účet a aktivitu splňující podmínku → 'ACT-' + Id + '-' + Code
  existing   = SELECT Unique_Key__c FROM Point_Ledger__c WHERE Unique_Key__c IN :candidateKeys
  toInsert   = candidateKeys − existing → Point_Ledger__c záznamy
  results    = Database.insert(toInsert, false)
  pro každý neúspěch:
     StatusCode.DUPLICATE_VALUE → ignorovat (souběh, už odměněno)
     jiná chyba → vrátit jako chybu pro daný účet (trigger z ní udělá addError → rollback)
  awardedInTransaction += úspěšně vložené
```

Pravidla, která z toho plynou: změna, smazání a opětovné doplnění nic nepřipíše (klíč existuje); odvolání nic neodebírá (služba body nikdy neodečítá); zablokovaný člen se vyhodnotí znovu při změně stavu na Aktivní (3.3).

### 3.3 Trigger na Account (`AccountActivityTriggerHandler`)

| Fáze | Co dělá |
| --- | --- |
| before insert / before update | Pokud `VehicleProfile.isComplete` a `Profile_First_Completed__c` je prázdné → nastaví `now`. |
| after insert | `evaluate` pro Person Accounty s kompletním profilem nebo souhlasem (registrace se souhlasem → +50). |
| after update | `evaluate` pro účty, kde se změnilo některé z: `Vehicle_*`, `Marketing_Consent__c`, nebo `Member_Status__c` na Aktivní. Chyba z `evaluate` → `Trigger.newMap.get(id).addError(Label.NAJ_ACT_ERR_GENERIC)`. |
| before update (SHOULD) | Externí odhlášení: `PersonHasOptedOutOfEmail` false → true, `Marketing_Consent__c = true` a změnu neprovádí `ConsentService` (statický příznak) → nastaví odvolání na Account a do statické fronty přidá `Consent_Event__c` se zdrojem „Odkaz v e-mailu“, vložený v after update. Pro napojení rozesílacího nástroje (např. Marketing Cloud Connect) – ověřit, že odhlášení propisuje Email Opt Out zpět do Salesforce. |

Filtr: zpracovávají se jen `IsPersonAccount = true`. Rekurzi brání statická sada už vyhodnocených Id.

### 3.4 Sekvence: uložení údajů o autě z portálu

```
LWC najetoVehicleForm  → MemberActivityController.saveVehicle(dto)
  1. accountId = User.AccountId přihlášeného člena (null → chyba NOT_MEMBER)
  2. MemberProfileService.validate(dto): značka a palivo z picklistu, model 1–40 znaků po trimu,
     rok 1900..rok+1; neplatné → AuraHandledException 'VALIDATION:<pole>'
  3. Savepoint; UPDATE Account (4 pole)
       → before trigger: Profile_First_Completed__c
       → after trigger: ActivityRewardService.evaluate → případně INSERT Point_Ledger__c (+100)
  4. výjimka → rollback → 'GENERIC'
  5. odpověď: outcome = REWARDED | SAVED_INCOMPLETE | SAVED, pointsAwarded, newBalance (SOQL po DML),
     missingFields
LWC: success text až z odpovědi; při REWARDED publikuje LMS zprávu NajetoBalanceChanged__c
```

Smazání (`deleteVehicle`): vynuluje 4 pole. `Profile_First_Completed__c` a pohyb bodů zůstávají. Odpověď `DELETED`.

### 3.5 Sekvence: souhlas

**Udělení** (`grantConsent(textVersion)`), portál i registrace:

```
  1. accountId z User; textVersion musí = aktivní Consent_Text__mdt.Version__c, jinak 'TEXT_VERSION_CHANGED'
  2. již Marketing_Consent__c = true → idempotentní odpověď ALREADY_GRANTED (žádný nový event)
  3. ConsentService.grant(accountId, version, source):
       UPDATE Account: Marketing_Consent__c = true, _Granted__c = now, _Version__c, _Source__c,
                       PersonHasOptedOutOfEmail = false
       INSERT Consent_Event__c (Udělení)
       → after trigger: evaluate → +50, pokud klíč ještě neexistuje
  4. odpověď: REWARDED | GRANTED_NO_REWARD (opětovné udělení), newBalance
```

Registrace (Implementace II, FR-E1-01): registrační controller po vytvoření Person Account a uživatele zavolá `ConsentService.grant(accountId, version, 'Registrace')`, pokud člen zaškrtl souhlas. Text a verzi pro guest uživatele vrací `MemberActivityController.getConsentText()` (třída dostupná i guest profilu, vrací jen obsah CMDT).

**Odvolání** (`revokeConsent()`):

```
  1. accountId z User; souhlas není udělen → ALREADY_REVOKED
  2. ConsentService.revoke(accountId, 'Profil portálu'):
       UPDATE Account: Marketing_Consent__c = false, _Revoked__c = now, PersonHasOptedOutOfEmail = true
       INSERT Consent_Event__c (Odvolání)
  3. body se nemění; odpověď REVOKED
```

**Back-office odvolání:** quick action „Zaznamenat odvolání souhlasu“ na členovi → screen flow (povinná poznámka: kanál žádosti) → invocable `ConsentService.revokeFromBackOffice(accountId, note)`. Udělení z back-office neexistuje (SD-B7-06); pole souhlasu jsou pro interní profily read-only.

### 3.6 Stávající členové (`ActivityBackfillBatch`)

```
start:   SELECT Id FROM Account
         WHERE IsPersonAccount = true AND Member_Status__c = 'Aktivní'
           AND (Profile_Complete__c = true OR Marketing_Consent__c = true)
execute: ActivityRewardService.evaluate(scope Ids)   // scope 200
finish:  log (počet připsaných PROFILE / MARKETING_CONSENT) do debug logu a e-mailem spouštějícímu
```

Spuštění při go-live: `Database.executeBatch(new ActivityBackfillBatch(), 200);` (Anonymous Apex nebo `sf apex run`). Díky unikátnímu klíči je opakované spuštění bezpečné. Odvolaný souhlas (`Marketing_Consent__c = false`) do dávky nepatří, čímž je splněno pravidlo 2.5 marketingového zadání.

### 3.7 API controlleru

| Metoda | Vstup | Výstup |
| --- | --- | --- |
| `getActivities()` (cacheable=false) | – | `List<ActivityDTO>`: `code`, `points`, `sortOrder`, `status` (`NOT_STARTED` · `IN_PROGRESS` · `REWARDED`), `rewardedOn`, `missingFields`, `consentActive`, `email`, `memberBlocked` |
| `getVehicle()` | – | `VehicleDTO` (4 hodnoty) + `makeOptions`, `fuelOptions` (Schema describe), `yearMax` |
| `saveVehicle(VehicleDTO)` | 4 hodnoty | `ResultDTO` |
| `deleteVehicle()` | – | `ResultDTO` |
| `getConsentText()` | – | `version`, `checkboxText`, `infoText`, `privacyPath` |
| `grantConsent(String version)` | verze zobrazeného textu | `ResultDTO` |
| `revokeConsent()` | – | `ResultDTO` |

`ResultDTO`: `outcome`, `pointsAwarded`, `newBalance`, `missingFields`. Chyby: `AuraHandledException` se zprávou = kód (`VALIDATION:Vehicle_Year__c`, `TEXT_VERSION_CHANGED`, `NOT_MEMBER`, `GENERIC`); LWC kód přeloží na Custom Label. Žádné technické detaily ke členovi.

Stav `IN_PROGRESS` u `PROFILE` = aspoň jedno pole vyplněné a nárok nevznikl. U `MARKETING_CONSENT` se `IN_PROGRESS` nepoužívá (rozpracovaný stav je jen v UI).

---

## 4. Členský portál (Experience Cloud, LWC)

### 4.1 Komponenty

| LWC | Kde | Popis |
| --- | --- | --- |
| `najetoActivityList` | Přehled (`variant="dashboard"`), stránka Získej body (`variant="page"`) | Načte `getActivities()`. Dashboard: jen nesplněné, sekce se skryje, když nic nezbývá. Page: nesplněné nahoře, splněné dole. Poslouchá LMS `NajetoBalanceChanged__c` a obnoví se. |
| `najetoActivityCard` | uvnitř listu | Ikona, název, štítek „+N bodů jednou“, popis / stav, CTA. Stavové texty z labels. |
| `najetoVehicleForm` | Stránka Moje auto (z karty), Profil (`mode="profile"`) | 4 pole (`lightning-combobox`, `lightning-input type=text`, `lightning-input type=number`), klientská validace = kopie serverové, tlačítko „Uložit a získat 100 bodů“ / „Uložit změny“, stav „Ukládám…“, odkaz Smazat s potvrzením (`lightning-modal`). |
| `najetoMarketingConsent` | Získej body (`mode="activity"`), Profil (`mode="profile"`) | Text souhlasu z `getConsentText()`, nezaškrtnutý checkbox, tlačítko „Potvrdit souhlas“ (neaktivní bez zaškrtnutí), rozbalovací informace, odkaz na zásady; v profilu přepínání udělení / odvolání s potvrzením. |
| `najetoUtils` (modul) | sdílený | `formatPoints(n)` se skloňováním (1 bod / 2–4 body / 5+ bodů / 0 bodů), formát data `6. 11. 2026`, mapování chybových kódů. |
| Message channel `NajetoBalanceChanged__c` | | Po `REWARDED` obnoví zůstatek a historii na Přehledu. |

### 4.2 Chování UI

- Tlačítko po kliknutí okamžitě neaktivní (ochrana proti dvojkliku na klientu), serverový unikátní klíč je druhá pojistka.
- Potvrzení „Hotovo. 100 bodů je na tvém účtu.“ jen při `outcome = REWARDED`. Při `SAVED_INCOMPLETE` text rozpracovaného stavu se seznamem chybějících polí.
- Zablokovaný člen (`memberBlocked`): karty bez CTA, text „Tvůj účet je pozastavený…“.
- Styl: CSS proměnné z `eneoil-tokens.css` (nahrané jako static resource a vložené do Head Markup), žádné hex hodnoty v komponentách (FR-E7-04). Karta nesplněná `--brand-soft`, splněná `--green-soft`, body `--font-mono`.
- Ikony: Material Symbols jako SVG ve static resource `najeto_icons` (`directions_car`, `mark_email_read`, `check_circle`).
- Mobile-first: karty pod sebou, od 768 px vedle sebe; tlačítko formuláře přichycené dole na mobilu; dotykové prvky ≥ 44 px.

### 4.3 Stránky a navigace

| Stránka | URL | Obsah B7 |
| --- | --- | --- |
| Přehled | `/` | `najetoActivityList variant=dashboard` pod kartami akcí |
| Získej body | `/ziskej-body` | `najetoActivityList variant=page`, `najetoMarketingConsent mode=activity` (rozbalí se z karty) |
| Moje auto | `/moje-auto` | `najetoVehicleForm` |
| Profil | `/profil` | sekce „Moje auto“ (`najetoVehicleForm mode=profile`), „Novinky e-mailem“ (`najetoMarketingConsent mode=profile`) |
| Zásady ochrany osobních údajů | `/zasady-ochrany-osobnich-udaju` | statický obsah (zástupný text, OD-2) |
| Podmínky programu | `/podminky-programu` | statický obsah včetně článku „Body za aktivity“ |

---

## 5. Back-office a konfigurace

### 5.1 Karta člena

- Sekce „Auto“: 4 pole vozidla, `Profile_Complete__c`, `Profile_First_Completed__c`.
- Sekce „Souhlasy“: `Marketing_Consent__c`, udělen, odvolán, verze, zdroj, `PersonHasOptedOutOfEmail` (read-only).
- Related list „Události souhlasu“ (`Consent_Event__c`).
- Pohyby bodů typu Aktivita jsou v existujícím related listu pohybů (sloupec Kód aktivity).
- Quick action „Zaznamenat odvolání souhlasu“.
- List views: „Členové s nedokončeným profilem“, „Členové s marketingovým souhlasem“.

### 5.2 Oprávnění

| Permission set | Account – pole vozidla | Account – pole souhlasu | `Consent_Event__c` | `Loyalty_Activity__mdt` / `Consent_Text__mdt` | Apex |
| --- | --- | --- | --- | --- | --- |
| Loyalty Member (portál) | Read | Read | – | – | `MemberActivityController` |
| Guest (registrace) | – | – | – | – | `MemberActivityController.getConsentText` |
| Loyalty Manager | Read/Edit | Read | Read | správa přes Setup jen admin | quick action, flow |
| Loyalty Reporting | Read | Read | Read | – | – |
| Admin | vše | vše | vše + `Loyalty_Bypass_Immutability` | vše | spouštění dávky |

Portálový člen nemá přímou editaci Account: zápis jen přes controller, který pracuje výhradně s `AccountId` přihlášeného uživatele.

### 5.3 Konfigurační úlohy loyalty manažera / admina

| Úloha | Kde | Bez nasazení kódu |
| --- | --- | --- |
| Změna počtu bodů za aktivitu | `Loyalty_Activity__mdt.Points__c` | ano (platí pro budoucí připsání) |
| Vypnutí aktivity | `Loyalty_Activity__mdt.Active__c` | ano |
| Nová verze textu souhlasu | nový záznam `Consent_Text__mdt`, starý deaktivovat | ano |
| Doplnění značky | hodnota picklistu `Vehicle_Make__c` | ano (Setup) |
| Úprava textů UI | Custom Labels `NAJ_ACT_*` | ano (Setup) |

### 5.4 Custom Labels (výčet)

`NAJ_ACT_PROFILE_TITLE`, `_DESC`, `_TERMS`, `_CTA_CARD`, `_CTA_SAVE_REWARD`, `_CTA_SAVE`, `_STATE_NEW`, `_STATE_PROGRESS`, `_STATE_SAVED_INCOMPLETE`, `_STATE_DONE`, `_STATE_REWARDED`, `_ERR_MAKE`, `_ERR_MODEL`, `_ERR_YEAR`, `_ERR_FUEL`, `_HELP_MAKE`, `_HELP_MODEL`, `_HELP_YEAR`, `_HELP_FUEL`, `_HELP_WHY`, `_DELETE_LINK`, `_DELETE_CONFIRM`, `_DELETE_DONE` · `NAJ_ACT_CONSENT_TITLE`, `_DESC`, `_TERMS`, `_CTA_CARD`, `_CTA_CONFIRM`, `_STATE_NEW`, `_STATE_UNCHECKED`, `_STATE_DONE`, `_STATE_ACTIVE`, `_STATE_REVOKED`, `_REGRANT_CTA`, `_REGRANT_NOTE`, `_REGRANT_DONE`, `_REVOKE_LINK`, `_REVOKE_CONFIRM`, `_REVOKE_DONE`, `_ERR_GRANT`, `_ERR_REVOKE`, `_ERR_TEXT_CHANGED`, `_HELP` · `NAJ_ACT_PAGE_TITLE`, `_PAGE_SUBTITLE`, `_ALL_DONE`, `_BLOCKED`, `NAJ_ACT_SAVING`, `NAJ_ACT_ERR_GENERIC`.

Hodnoty = texty z marketingového zadání kap. 5 (1:1).

---

## 6. Manažerský report (doplnění E9, FR-E9-06)

| KPI | Definice (SOQL) |
| --- | --- |
| Podíl členů s dokončeným profilem | `COUNT(Id)` Account `WHERE IsPersonAccount = true AND Member_Status__c = 'Aktivní' AND Profile_Complete__c = true` / aktivní členové |
| Podíl členů s platným souhlasem | totéž s `Marketing_Consent__c = true` |
| Body za aktivity v období | `SUM(Points__c)` `Point_Ledger__c WHERE Type__c = 'Aktivita' AND Movement_Date__c = <období> GROUP BY Activity_Code__c` |
| Odvolání souhlasu v období | `COUNT(Id)` `Consent_Event__c WHERE Event_Type__c = 'Odvolání' AND Event_Timestamp__c = <období>` |
| Skladba vozového parku (SHOULD) | `GROUP BY Vehicle_Fuel_Type__c`, top 10 `Vehicle_Make__c` (jen agregovaně) |

---

## 7. Testování

### 7.1 Testovací scénáře (navazují na T01–T29)

| ID | Vstup | Očekávaný výsledek |
| --- | --- | --- |
| T29 | Souhlas udělen → odvolán → udělen | Celkem +50 jednou; 3 záznamy `Consent_Event__c`; zůstatek po odvolání beze změny |
| T30 | Člen uloží všechna 4 pole poprvé | +100, pohyb `ACT-{Id}-PROFILE`, `Profile_First_Completed__c` vyplněno, portál „Hotovo. 100 bodů je na tvém účtu.“ |
| T31 | Člen uloží 3 ze 4 polí | Uloženo, žádné body, `missingFields = [Palivo]`, stav rozpracováno |
| T32 | Po odměně změní model | Uloženo, žádné body, `outcome = SAVED` |
| T33 | Po odměně smaže údaje o autě | Pole prázdná, zůstatek beze změny, stav „Body za údaje o autě už máš“ |
| T34 | Po smazání znovu doplní všechna pole | Žádné body |
| T35 | Dvojí rychlé odeslání formuláře (souběžné volání) | Jeden pohyb +100, druhé volání `SAVED` bez chyby |
| T36 | Registrace se zaškrtnutým souhlasem | Člen vznikne s +50, `Consent_Event__c` se zdrojem Registrace |
| T37 | Registrace bez souhlasu, později souhlas v portálu | +50 při udělení v portálu |
| T38 | Odvolání v profilu | `Marketing_Consent__c = false`, `PersonHasOptedOutOfEmail = true`, event Odvolání, zůstatek beze změny |
| T39 | Back-office zaznamená odvolání | Event se zdrojem Back-office a poznámkou; pole souhlasu nelze v back-office ručně zapnout |
| T40 | Dávka nad 300 členy (část s kompletním profilem, část se souhlasem, část s odvolaným souhlasem) | Body jen oprávněným; odvolaní bez +50; druhé spuštění dávky nepřipíše nic |
| T41 | Zablokovaný člen doplní auto, pak je odblokován | Při blokaci bez bodů; po změně stavu na Aktivní +100 |
| T42 | Rok výroby 1899 / 2028 (v roce 2026) | Chyba `VALIDATION:Vehicle_Year__c`, nic se neuloží |
| T43 | `Loyalty_Activity__mdt.Marketing_Consent.Active__c = false`, člen udělí souhlas | Souhlas uložen, žádné body, karta skrytá |
| T44 | Udělení se starou verzí textu (CMDT mezitím změněno) | `TEXT_VERSION_CHANGED`, nic se neuloží |
| T45 | Člen s odvolaným souhlasem uplatní voucher | Transakční e-mail s voucherem přijde (ověřit, že odesílání nerespektuje Email Opt Out; doporučeno `setToAddresses`) |
| T46 | Úprava nebo smazání `Consent_Event__c` loyalty manažerem | Odmítnuto |
| T47 | Pokus o volání controlleru s cizím Id (úprava požadavku) | Nelze, API Id nepřijímá; mění se jen vlastní účet |

### 7.2 Apex testy

`ActivityRewardServiceTest` (T30–T35, T40, T41, T43 včetně bulk 200 účtů), `ConsentServiceTest` (T29, T36–T39, T44), `MemberActivityControllerTest` (portálový uživatel přes `System.runAs`, T42, T47), `ActivityBackfillBatchTest`, `ConsentEventTriggerTest` (T46). Cíl pokrytí ≥ 90 % pro nové třídy.

### 7.3 Testovací data

Při generování 300 členů (SD v1.0 kap. 15) nastavit **před spuštěním dávky**: ~35 % s kompletním autem, ~10 % s neúplným, ~45 % s platným souhlasem, ~5 % s odvolaným souhlasem (s odpovídajícími `Consent_Event__c`, zdroj Migrace). Pak spustit `ActivityBackfillBatch` – report ukáže body za aktivity a podíly.

---

## 8. Plán implementace

### 8.1 Hackathon (pořadí)

| # | Krok | Odhad |
| --- | --- | --- |
| 1 | Pole na Account, validation rule, `Consent_Event__c`, `Activity_Code__c`, CMDT + záznamy, Custom Labels | 30 min |
| 2 | `VehicleProfile`, `ActivityRewardService`, trigger action, `ConsentService`, `ConsentEventTrigger` | 45 min |
| 3 | `MemberActivityController` + DTO | 20 min |
| 4 | LWC `najetoActivityList`, `najetoActivityCard`, `najetoVehicleForm`, `najetoMarketingConsent`, LMS kanál | 60 min |
| 5 | Napojení souhlasu do registrace, stránky portálu, permission sets | 20 min |
| 6 | Back-office layout, quick action + flow odvolání, list views | 15 min |
| 7 | `ActivityBackfillBatch`, testovací data, spuštění dávky | 15 min |
| 8 | Apex testy + ruční scénáře T29–T47, test log | 30 min |
| | **Celkem** | **cca 4 h** |

Pro demo: krok 7 až po nahrání testovacích dat, aby report ukázal výsledek dávky.

### 8.2 Odhad pro reálnou implementaci u klienta (SteerCo)

| Oblast | MD |
| --- | --- |
| Datový model, CMDT, oprávnění | 0,5 |
| Apex služby, trigger, dávka, unit testy | 2 |
| LWC komponenty (4) a stránky portálu | 2 |
| Back-office (layout, flow, list views) | 0,5 |
| Report KPI | 0,5 |
| Koordinace obsahu a právních textů, nasazení textů | 0,5 |
| Testování a UAT | 1 |
| **Celkem** | **7 MD** |

---

## 9. Rizika a otevřené body

| ID | Riziko / otázka | Opatření / návrh | Vlastník |
| --- | --- | --- | --- |
| RB-01 | Odvolání přes odkaz v e-mailu potřebuje rozesílací nástroj a synchronizaci zpět | V B7 jen handler pro změnu `PersonHasOptedOutOfEmail` (3.3, SHOULD); napojení nástroje je fáze 2 | Tým 2A / klient |
| RB-02 | Transakční e-mail s voucherem by mohl respektovat Email Opt Out | Test T45; posílat na adresu (`setToAddresses`) | Tým 2A |
| RB-03 | Konečné právní texty a právní základ pro údaje o autě | Zástupné texty v CMDT, výměna bez nasazení (OD-1 až OD-3 marketingového zadání) | Privacy/legal EneOil |
| RB-04 | Rozdílné názvy existujících objektů proti SD v1.0 | Ověřit proti orgu před krokem 1 | Tým 2A |
| RB-05 | Re-consent při podstatné změně textu souhlasu | Mimo B7; verze se ukládá, podklad pro budoucí kampaň re-consentu | Klient |
| RB-06 | Více vozidel na člena | Roadmapa: objekt `Vehicle__c`, aktivita zůstává jednorázová na člena | Marketing |

**Změny proti SD v1.0:** body za aktivity se přesouvají z `Loyalty_Settings__mdt` do `Loyalty_Activity__mdt`; SPZ ve vozidle vypuštěna; přibývá `Consent_Event__c`, `Consent_Text__mdt` a dávka pro stávající členy; kanál pro člena je značka NAJETO.
