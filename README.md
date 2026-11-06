# Enehano Salesforce Template Repository

A starter template for Enehano Salesforce (SFDX) projects. It ships with a
recommended source layout, a pre-configured `sfdx-project.json`, common
in-house and open-source packages, and an [`AGENTS.md`](./AGENTS.md) primed for
AI-assisted development.

Use this template to bootstrap a new project, then customize it for your
client/engagement.

## Getting Started

### 1. Create your project repository

This is a **GitHub template repository** — don't fork it. Forks stay linked to
this upstream and are meant for contributing changes back; a new project needs
its own independent history.

- On GitHub, click **Use this template → Create a new repository**, then clone
  your new repo:

  ```bash
  git clone https://github.com/Enahano/<your-new-repo>.git
  ```

### 2. Customize `AGENTS.md`

[`AGENTS.md`](./AGENTS.md) is the guide agents (and developers) read to
understand this project. Out of the box it contains placeholders and `>`
blockquote prompts telling you what to fill in. Replace every placeholder and
dummy value with your project's real details:

- **Introduction** — overview of the project, client, and business cases.
- **Glossary** — project-specific abbreviations (delete if none).
- **Project Structure** — packages and source folders, so agents know where to
  place new metadata.
- **Installed Packages** — keep this in sync with `sfdx-project.json`.
- **Environments** — the SIT / UAT / Production URLs for this engagement.
- **Agents Guide** — project-specific Do/Don't rules.

Remove the `>` blockquote instructions once each section is filled in.

### 3. Install the AI skills

The AI skills, agents, and instructions used by this template are maintained
separately. Install and set them up by following the instructions in the
Enehano Claude Kit:

**https://github.com/Enehano/enehano-claude-kit**
