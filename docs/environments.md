# Environments and Promotion

How the platform's environments are defined and how a build is promoted through them.
Decision and rationale: [`architecture-decisions/0002-environment-promotion-strategy.md`](architecture-decisions/0002-environment-promotion-strategy.md).

## Ladder

```
Local  →  Dev  →  QA  →  Staging  →  Prod
(laptop)  (int)   (test)  (mirror+UAT)  (live)
```

## Environment configuration matrix

Everything below is **configuration** — the container image (artifact) is identical
across all rows. Values are lab defaults; adjust as the platform grows.

| Env | Runs in (lab) | Replicas | Size | `APP_VERSION` | Gate to enter |
|---|---|---|---|---|---|
| Local | Docker on dev machine | 1 | — | `dev` | unit tests pass |
| Dev | EC2 (M1) / EKS ns `dev` (M3+) | 1 | t3.micro | git SHA | CI build + tests pass |
| QA | EKS ns `qa` | 1 | t3.micro | *same digest* | QA + automated tests pass |
| Staging | EKS ns `staging` | 2 | t3.small | *same digest* | smoke + perf + UAT sign-off |
| Prod | EKS ns `prod` | 2 | t3.small | *same digest* | manual approval |

## Promotion flow (build once, promote by digest)

1. **Build once** — on merge, CI builds the image, tags it by **git SHA**, pushes to
   ECR. Record the resulting **digest** (`...app@sha256:…`).
2. **Deploy to Dev** using dev config. Verify `GET /version` returns the SHA.
3. **Gate → QA** — deploy the *same digest*. Verify `/version` matches.
4. **Gate → Staging** — deploy the *same digest*. Run smoke/perf; capture **UAT
   sign-off**. Verify `/version` matches.
5. **Gate → Prod** — manual approval; deploy the *same digest*. Verify `/version`.
6. **Rollback** — redeploy the previous known-good digest. No rebuild.

**Golden rule:** never `docker build` during promotion — only the target environment and
its config change. The same `/version` string appearing in every environment is the
proof the identical artifact travelled the whole way.

## Where this gets implemented

| Concern | Implemented in | Roadmap week |
|---|---|---|
| Dev vs prod-style config over shared modules | `terraform/` env roots | Week 7 |
| Per-environment app config | `helm/` values files + namespaces | Week 10 |
| Build-once, push-by-digest, promote, rollback | `.github/workflows/` | Weeks 14–16 |

## Lab cost note

Only stand up **one or two** environments at a time. From Month 3, a single EKS cluster
with a **namespace per environment** keeps this cheap; promotion is deploying the same
digest into the next namespace/config, capturing the `/version` proof, then tearing down.
