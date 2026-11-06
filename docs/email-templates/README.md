# Najeto registration welcome email

Subject: **Vítej v najeto. Tvoje cesta za odměnami začíná.**

Preheader: **Registrace je hotová. Otevři si účet a vyraz za prvními body.**

## Files

- `force-app/main/default/email/unfiled$public/NajetoWelcome.email`: reusable Czech HTML body for a Classic Custom email template (without letterhead).
- Matching `.email-meta.xml`: template settings, subject and equivalent plain-text body.
- `welcome-preview.html`: browser preview of the same HTML; its account links are deliberately disabled. Regenerate from the source when changing the design.

## Design and implementation

The template follows the supplied Najeto reference and the portal tokens: ink `#1d2c38`, orange `#ffa41b`, soft orange `#fff1db`, surface `#f6f7f8`. It uses a text wordmark, a large headline, a single account CTA and three numbered onboarding steps. No fabricated balance, QR code or reward value appears in the email.

Email clients do not inherit LWC styles. The body therefore uses presentation tables and inline styles, with a small mobile override and a fixed-width wrapper for Outlook. Arial is a deliberate fallback for the portal's Archivo/Noto Sans fonts: web-font support varies between mail clients. Rounded corners are decorative and can fall back to square corners.

Content is stored in a dedicated Czech email template, Salesforce's native email-content artifact, rather than Apex or LWC strings. Add separate language templates if multilingual email becomes necessary. The generic greeting avoids missing-name fields and Czech name-inflection problems.

`{!Community_Url}` is a Salesforce merge field: Salesforce replaces it with the site-specific URL when sending the Experience Cloud welcome email. Preserve the complete generated URL; do not append page paths or replace it with an environment-specific domain. See [Salesforce's Experience Cloud merge-field documentation](https://help.salesforce.com/s/articleView?id=experience.merge_fields_communities.htm&language=en_US&type=5).

## Use in Salesforce

No deployment, email sending or network-setting change was performed. The current network still selects `CommunityWelcomeEmailTemplate`.

After the template is deployed through your normal development process:

1. In Setup → Classic Email Templates, find **Najeto - Welcome (CS)** in **Unfiled Public Email Templates**. Alternatively create a **Custom (without using Classic Letterhead)** template, choose UTF-8, paste the HTML source and copy the subject and plain text from the metadata file.
2. In Digital Experiences → All Sites → the intended site's Workspaces → Administration → Emails, select it for **Welcome New Member** and keep **Send welcome email** enabled. Save only when ready to use the template.
3. If configuration is tracked in source, retrieve the intended network after selecting the template. The eventual `welcomeTemplate` value should be `unfiled$public/NajetoWelcome`.

The existing Experience Cloud mechanism handles sending. A second Apex sender or Flow would risk duplicate messages and is unnecessary for this template.

## Review before activation

No automated tests were run, per repository instructions. No Apex changed, so no Apex tests were added. HTML structure, links, merge-field usage and metadata XML were inspected locally; this does not verify Salesforce deployment or inbox rendering.

In a development environment, verify a real self-registration message, the resolved account link, login/password behavior and that only one welcome message is received. Review desktop and narrow mobile layouts in Gmail, Apple Mail and Outlook, including dark mode. Browser preview alone cannot confirm email-client compatibility.

Assumptions: Czech-only transactional registration email; `najeto.` is the customer-facing brand. Confirm that QR-card checkout is available before activating this copy; those steps follow the supplied design reference. The preview contains no real customer data. No points bonus is promised, because awarded points depend on the member's actions and consent.
