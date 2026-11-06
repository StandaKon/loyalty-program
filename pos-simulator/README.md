# Pokladna NAJETO

Lokální pokladna pro hackathonové demo. Pokladník zadá pouze číslo člena, tankování a položky obchodu. Backend po zaplacení zavolá Salesforce endpoint `POST /services/apexrest/loyalty/v1/transactions`; existující bodový engine vytvoří ledger a vrátí body i nový zůstatek.

## Spuštění proti výchozímu Salesforce orgu

Před spuštěním nasaď metadata endpointu a přiřaď integračnímu uživateli permission set `Loyalty_Transaction_Import`. Server používá pouze výchozí org nakonfigurovaný v Salesforce CLI; target org nemění ani nepřijímá jako parametr.

```bash
node pos-simulator/server.mjs
```

Otevři `http://127.0.0.1:4173`.

Server si bezpečně vyžádá access token z lokálně přihlášeného Salesforce CLI. Token se neposílá do prohlížeče, nevypisuje se a neukládá do souboru.

## Connected App / External Client App

Pro lokální demo není potřeba. Pro samostatné nasazení nastav backendu krátkodobý token a URL orgu prostřednictvím runtime secrets:

```bash
SF_INSTANCE_URL=https://example.my.salesforce.com \
SF_ACCESS_TOKEN=... \
node pos-simulator/server.mjs
```

Credentials nikdy neukládej do repozitáře. Produkční nasazení má token získávat server-side OAuth flow pod samostatným integračním uživatelem.

## UI bez Salesforce

Pro rychlou kontrolu vzhledu lze spustit lokální demo režim:

```bash
POS_DEMO_MODE=1 node pos-simulator/server.mjs
```

Demo režim nic nezapisuje do Salesforce a v záhlaví je viditelně označen.

## API request

```json
{
  "memberNumber": "ENE-DEMO-B2",
  "posTransactionId": "ENE-POS01-20261106142000-8F32A1C0",
  "purchasedAt": "2026-11-06T14:20:00.000Z",
  "liters": 45,
  "fuelAmount": 1710,
  "otherAmount": 180,
  "totalAmount": 1890
}
```

Stejné `posTransactionId` lze bezpečně odeslat znovu. Endpoint vrátí původní výsledek a body znovu nepřipíše.
