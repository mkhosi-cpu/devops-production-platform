# ADR 0001 — Use an S3 Gateway Endpoint instead of a NAT Gateway for lab egress

- **Status:** Accepted
- **Date:** 2026-09-20
- **Stage:** Month 1 · Week 2 (VPC and network design)

## Context

Private-subnet instances need "controlled outbound access" (Week 2, Task 2). The
conventional pattern is a **NAT Gateway**, which gives private instances general
internet egress. However, a NAT Gateway in us-east-1 costs approximately **$0.045/hour
plus ~$0.045/GB processed** and bills the moment it exists — about **$32/month** if
left running. It is also the single most common source of surprise lab bills
(orphaned NAT Gateways).

This is a personal learning lab run on a create/destroy model where the goal is to keep
cost at ~$0 per session. Most of the Week 2 workload (VPC, subnets, route tables,
Internet Gateway, security groups) is free; the NAT Gateway is the only significant
network charge.

## Decision

Use a **free S3 Gateway VPC Endpoint** as the default "controlled outbound" mechanism
for private subnets, instead of a NAT Gateway.

- Private instances reach Amazon S3 via the Gateway Endpoint with **no internet path
  and no NAT**, at **$0** cost.
- Instance access for testing uses **SSM Session Manager** with no public IPv4,
  avoiding both the public-IPv4 charge and open SSH.
- A NAT Gateway (or a cheaper `t4g.nano` NAT instance) is created **only** for a short,
  delete-immediately burst if practising general internet egress is explicitly needed.

## Consequences

**Positive**
- Week 2 can be completed for essentially $0.
- Stronger least-privilege posture: egress is limited to the one AWS service allowed,
  rather than the whole internet.
- Removes the most common orphaned-resource billing risk.

**Negative / trade-offs**
- Does not exercise the NAT Gateway pattern by default; general internet egress from
  private subnets is not available unless NAT is temporarily added.
- Gateway Endpoints support only S3 and DynamoDB. Reaching other AWS services privately
  would need **interface endpoints**, which are *not* free (~$0.01/hr each) — evaluate
  per service before adding.

## Alternatives considered

- **NAT Gateway (always on):** conventional and simplest routing, but ~$32/month and the
  top surprise-bill risk. Rejected for a create/destroy lab.
- **NAT instance (`t4g.nano`):** ~10× cheaper than NAT Gateway and gives real egress;
  kept as the fallback when general internet egress must be demonstrated.
- **Short NAT Gateway burst:** create, test in ~10 min, delete — a few cents; acceptable
  for a one-off egress demonstration.
