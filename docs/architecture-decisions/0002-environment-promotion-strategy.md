# ADR 0002 — Environment promotion strategy (build once, promote by digest)

- **Status:** Accepted
- **Date:** 2026-09-20
- **Applies from:** Month 2 (env configs), Month 3 (Helm/EKS), Month 4 (CI/CD promotion)

## Context

A real delivery pipeline promotes software through several environments before
production, and must prove that the **exact artifact** validated in early stages is the
one that reaches prod — not a rebuild that might differ. We want the lab platform to
demonstrate this end-to-end, while staying compatible with the ~$0 create/destroy model
(see [[cost-strategy-create-destroy]] / ADR 0001).

## Decision

### Environment ladder
`Local → Dev → QA → Staging → Prod` (UAT sign-off happens on Staging).

| Stage | Purpose | Validated by | Promotion gate |
|---|---|---|---|
| Local | build + unit test on the dev machine | developer | unit tests pass |
| Dev | shared integration | developers | CI build + tests pass |
| QA | functional + automated test suite | QA | QA/automated tests pass |
| Staging | production mirror; smoke, perf, **UAT sign-off** | eng + business | smoke pass + sign-off |
| Prod | live | — | manual approval |

### Build once, promote by digest
- CI builds **one** image per commit, tagged immutably by git SHA, pushed to ECR **once**.
- Promotion = deploying that **same image digest** to the next environment. **Never
  rebuild** between stages.
- Environments differ **only by configuration** — env vars/secrets, replica count,
  instance/pod size, `APP_VERSION` — never by the artifact.
- **Proof of promotion:** the app's `/version` endpoint returns the injected build id;
  the same value must appear in Dev, QA, Staging, and Prod. Image **digest** (not just
  tag) is recorded at each step.
- **Rollback** = redeploy the previous known-good digest (no rebuild).

### Lab representation (cost)
Environments are expressed as **configuration**, not always-on infrastructure:
- Month 2: separate Terraform env roots (dev vs prod-style) over shared modules.
- Month 3+: one EKS cluster with a **namespace per environment** + Helm values per env.
- Only **one or two** environments are stood up at a time; promotion is demonstrated by
  deploying the same digest to the next env's config, capturing the `/version` proof,
  then tearing down.

## Consequences

**Positive**
- Guarantees the tested artifact is the shipped artifact (integrity of the pipeline).
- Environment parity: differences are explicit config, easy to review.
- Cheap to demonstrate — namespaces + config, not five live stacks.

**Negative / trade-offs**
- Requires disciplined config management (no baking env specifics into the image).
- Namespaces on one cluster are not as isolated as separate accounts/clusters; noted as
  a deliberate lab simplification, revisited if the roadmap calls for stronger isolation.

## Alternatives considered
- **Rebuild per environment:** simplest CI, but breaks the core guarantee — the prod
  image would differ from the tested one. Rejected.
- **Separate AWS account per environment:** strongest isolation and most production-like,
  but too costly/complex for this lab. Deferred.
