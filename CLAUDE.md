# Project: [Your Project Name]

## Why This Architecture

<!-- Write the reasoning behind your key decisions. Claude can read your code,
     but it can't read your mind. Focus on "why" not "what". -->

- [Why you chose this framework/language]
- [Why this database/service over alternatives]
- [Why monorepo vs polyrepo, or other structural decisions]

## Do NOT Touch

<!-- List code/areas that look refactorable but must stay as-is.
     Include the reason and expected resolution date. -->

- `[path/to/legacy/code]` — [reason, e.g. "3 enterprise clients depend on this API, deprecating Q3 2026"]
- `[path/to/handler]` — [reason, e.g. "idempotency is critical here, past incident cost $X"]

## Deploy & Environments

<!-- Claude can't know your deployment targets from source code alone. -->

- staging: [how to deploy to staging]
- production: [how to deploy to production, or "GitHub Actions only — manual deploy forbidden"]
- DB migrations: [any special process, e.g. "always run on staging first"]

## Team Workflow

<!-- Agreements that aren't encoded in CI/CD. -->

- [PR review policy, e.g. "1+ reviewer required"]
- [Merge strategy, e.g. "feat/ branches use squash merge, fix/ use regular merge"]
- [Deploy freeze rules, e.g. "no production deploys after Friday 3pm"]

## Business Context

<!-- Constraints Claude would never guess from code alone. -->

- [SLA requirements, e.g. "enterprise customers require <200ms response"]
- [Compliance, e.g. "GDPR — logical delete only, never physical delete"]
- [Scheduled jobs, e.g. "monthly report runs on 1st at midnight, high DB load"]
