# ADR 0004 — Environments as folders, not Terraform workspaces

- **Status:** Accepted
- **Date:** 2026-09-24
- **Applies from:** Month 2 · Week 7

## Context

The platform needs multiple environments (dev, prod, and later the full
Local→Dev→QA→Staging→Prod ladder) built from the same reusable `modules/network`. Terraform
offers two common ways to separate environments:

1. **Workspaces** — one root config and **one backend**, with multiple named state files;
   differences expressed via `terraform.workspace` conditionals.
2. **Folders** — a directory per environment, each a thin root with its **own backend/state
   key**, calling the shared module with its own inputs.

## Decision

Use **environment folders**: `terraform/environments/dev` and `.../prod`, each calling
`../../modules/network` with environment-specific inputs and its own S3 state key
(`env/dev/…`, `env/prod/…`).

## Consequences

**Positive**
- **Explicit differences:** each env's `main.tf` shows its CIDRs/prefix/tags plainly, rather
  than hiding them in `terraform.workspace` ternaries.
- **Strong isolation:** separate state keys (and the option of separate backends/accounts
  later) mean a dev operation cannot touch prod state.
- **Lower blast radius:** you are physically `cd`'d into an env folder, so it's hard to apply
  to the wrong environment.
- Handles large divergences (different regions/accounts/providers) cleanly.

**Negative / trade-offs**
- A little duplication in the thin per-env roots (backend + provider + module call). Accepted
  — it's small and explicit, and keeps environments independent.

## Alternatives considered
- **Workspaces:** less upfront boilerplate, but a shared backend weakens isolation and
  differences get buried in conditionals. HashiCorp itself cautions against workspaces for
  strong environment separation. Rejected for dev/prod; still fine for ephemeral per-developer
  sandboxes.
