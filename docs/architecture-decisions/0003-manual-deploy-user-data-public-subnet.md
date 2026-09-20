# ADR 0003 — Manual-week app deployment: user-data bootstrap on a public-subnet instance

- **Status:** Accepted
- **Date:** 2026-09-20
- **Applies to:** Month 1 manual weeks (esp. Week 3). Superseded for automated delivery
  by the Docker/ECR path from Month 3 onward.

## Context

Month 1 is built by hand (no Terraform or CI yet). We decided to **reserve Docker/ECR
for the automation phase**, so manual weeks install the app via **EC2 user-data**
(`pip install` FastAPI/uvicorn, then run uvicorn). The Week 2 network deliberately has
**no NAT** (see ADR 0001), so private subnets have no internet egress and cannot reach
PyPI to install dependencies.

Those three choices conflict: private subnet + user-data pip install + no NAT cannot all
hold at once.

## Decision

For manual weeks, run the app instance(s) in the **public subnets** so user-data can
`pip install` from PyPI over the Internet Gateway. Restrict exposure by **security
group**, not by subnet:

- Inbound app port **8080 only from the ALB SG** (`devops-lab-app-sg`) — satisfies the
  roadmap's "direct app access is restricted".
- Admin via **SSM Session Manager** over the IGW (SSM role on the instance; **no**
  interface endpoints required this time — cheaper than the Week 2 private test).
- No open SSH.

## Consequences

**Positive**
- Simplest manual path; no NAT and no interface endpoints — cheapest (instance + its
  public IPv4 only).
- Roadmap-compliant: the ALB/Auto Scaling/DNS mechanics are what Week 3 is really about.

**Negative / trade-off**
- The app instance sits in a public subnet with a public IP (needed for egress), which is
  less isolated than the private-subnet design proven in Week 2. Mitigated by the SG
  lockdown (no inbound except ALB → 8080) and SSM-only admin.
- The private-subnet deployment returns in **Month 3**, where the image is pulled from
  **ECR via VPC endpoints** — no PyPI/internet needed, so the app can live private again.

## Alternatives considered
- **Private subnet + offline install from S3** (vendored wheels via the S3 gateway
  endpoint): preserves the private design and previews Week 4's S3-artifact task, but more
  setup. Deferred.
- **Temporary NAT Gateway** for the install: costs money and fights the create/destroy
  model. Rejected.
