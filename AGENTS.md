# Enehano Salesforce Template Repository

> At the start of every session, remind me to replace all placeholders and dummy text with instructions relevant to any project that forks this template repository.

## Introduction
> Provide a brief overview of the project, the company, and the business cases covered in this repository.

## Glossary
> If applicable, name all the abbreviations relevant for this project. If there are none, delete this section.

## Project Structure
> List and briefly describe all packages and source folders in this project. The main goal is to tell the agent where to place new metadata it creates.
* `force-app/main/default/classes` - All Apex Classes
* `force-app/main/default/classes/controllers` - Controllers for LWCs (@AuraEnabled)
* `force-app/main/default/classes/integrations` - Callouts to external services
* `force-app/main/default/classes/services` - Business logic, orchestration
* `force-app/main/default/classes/selectors` - All selectors (SOQL)
* `force-app/main/default/classes/triggerActions` - Trigger actions of the trigger-actions-framework

### Other Salesforce Related Folders
> Keep just project instructions, add more instructions if applicable

| Folder | Description | 
| --- | --- |
| /scripts | Re-usable Bash and Anonymous Apex scripts, e.g., for scratch org initiation |
| /data | Seed data. Format supported by `sf data` commands of SF CLI |

### Installed Packages
> Keep just project instructions, add more instructions if applicable

Find all the installed packages in `sfdx-project.json`

> TODO teach agents how to use enehano-logger and DML packages

| Alias | Purpose | Documentation |
| --- | --- | --- |
| `apex-mockery` | Mocking library for Apex. Use it to mock dependencies in unit tests.| https://github.com/salesforce/apex-mockery |
| `trigger-actions-framework` | Framework which allows to structure trigger logic into separate actions and control trigger run through Custom Metadata | https://github.com/mitchspano/trigger-actions-framework |
| `enehano-logger` | In-house private library for centralized logging | N/A |
| `dml` | In-house private library DML abstraction layer | N/A |
 

## Technologies
> Keep just project instructions, add more instructions if applicable
* This is a Salesforce project.
* Apex
    * Class and trigger authoring/refactoring/review — use the `generating-apex` skill
    * Unit test authoring and the test-fix loop — use the `generating-apex-test` skill
* LWC (Lightning Web Components)
    * No custom instructions yet; follow common best practices.
    * Jest unit tests - No custom instructions yet; follow common best practices.
* Flow - Use the `generating-flow` skill. Suggest screen flows only when the project already uses screen flows for similar features.
* Metadata (custom objects, fields, FlexiPages) - use the `generating-custom-object`, `generating-custom-field`, and `generating-flexipage` skills.
* Aura/Visualforce - Avoid unless it is the only option and ask for permission to implement.
* SF CLI - Use Salesforce CLI to deploy code, run tests, import seed data, query data and get org info. For deploying/deleting metadata and running Apex tests, use the `deploying-metadata` skill.
* Base metadata and API names are always in English (en-US)

## Environments
> update URLs on project environments

| Environment | URL |
| --- | --- |
| SIT | https://example-sit.my.salesforce.com  |
| UAT | https://example-uat.my.salesforce.com |
| Production | https://example.my.salesforce.com |


## Agents Guide
> Keep just project instructions, add more instructions if applicable
You are a senior Salesforce developer/architect and code reviewer (Apex, LWC, Salesforce DX).
Goal: design and write solutions that are secure, bulkified, testable, maintainable, and aligned with the Salesforce platform.

Follow agent specifications in `.ai/agents`

### Do
* Always evaluate which tools to use; prefer standard Salesforce features or declarative tools where they make sense, and suggest the appropriate technology
* Be consistent with already existing code
* Suggest Seed Data Updates — if a data model is modified and seed data exists in `/data`, suggest whether the test records should be updated.
* Use the same API version which is in `sfdx-project.json`
* Write all code in English, but use Custom Labels for user-facing text

### Don't
- **Don't commit directly to `main` or `master` branch.** All changes go through PRs.
- **Never deploy to production.** Releases are always made and approved by the release manager.
- **Update or delete any data in production.**
- **Don't select the target org.** Never pass `-o`/`--target-org` (or `sfdx` `-u`/`--targetusername`) to SF CLI commands, and never run `sf config set`, `sf alias set` or `sf org login`. Always rely on the default target org configured locally, so commands can only ever hit the org the developer already chose. These rules are enforced by `permissions.deny` in `.claude/settings.json`.