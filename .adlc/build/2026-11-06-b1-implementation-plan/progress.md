# B1 build ledger

Plan: docs/adlc/specs/2026-11-06-b1-implementation-plan.md
Mode: single agent

T1: complete, 5 datových objektů, 80 polí, 30 validací, CMDT Default, 5 záložek a formulářů. Deployment 0Afaj00000qcLblCAE Succeeded.
T2: complete, 7 permission setů, 1 sharing set, prázdná skupina a 2 sharing rules. Finální deployment 0Afaj00000qcO8DCAU Succeeded. Člen nemá zápis ani globální přístup.
T3: complete, 10/10 Apex testů pass, včetně dvou Customer Community uživatelů v USER_MODE a 251 pohybů. Nezávislá revize opravena a znovu ověřena.

Org: 00Daj00001EHpFFEA1. Target pochází výhradně z lokálního default nastavení.
Instalované balíčky neobsahují trigger-actions-framework, dml ani enehano-logger. B1 neinstaluje balíčky a nevytváří produkční Apex.

Uživatel následně výslovně schválil přiřazení Loyalty_Manager připojenému administrátorovi. Provedeno pro barbora.dlapalova@ene.loyalty.cz a ověřeno dotazem na PermissionSetAssignment, ID 0Paaj000019pBa3CAE. Plošné View All pro manažera auto-review odmítl; bezpečně nahrazeno běžným Read podléhajícím sdílení a úspěšně nasazeno.

Návaznosti B2/B6–B8: číslování členů, kanonické klíče, atomické operace, delete/merge ochrany, neměnné consent události, správa voucherů a e-mail. Nejsou součástí metadatové datové vrstvy. Kompletní handoff: docs/implementation-blocks/B1-data-model-config/IMPLEMENTATION.md.
