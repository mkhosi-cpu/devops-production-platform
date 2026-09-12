# Week 2 — VPC and Network Design

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** In progress.

> Evidence rule: a task counts as done only when its evidence is committed here.
> Keep account IDs, real public IPs, and any sensitive details out of committed files.
> Tear down every session — see `docs/runbooks/teardown.md`.

The tables below are a **proposed starting design** — adjust the CIDRs, AZs, and rules
to your region and needs, then record what you actually built.

---

## Evidence checklist

### 1. VPC across at least two Availability Zones
**Evidence required:** CIDR plan shows public and private subnets.

**Proposed CIDR plan** (VPC `10.0.0.0/16`, 2 AZs):

| Subnet | AZ | CIDR | Type | Purpose |
|---|---|---|---|---|
| public-a | AZ A | `10.0.0.0/24` | Public | ALB, NAT Gateway |
| public-b | AZ B | `10.0.1.0/24` | Public | ALB |
| private-a | AZ A | `10.0.10.0/24` | Private | App instances |
| private-b | AZ B | `10.0.11.0/24` | Private | App instances |

- **Region / AZs used:** `____________________`
- **Actual CIDRs (if changed):** `____________________`

### 2. Route tables, internet access, controlled outbound access
**Evidence required:** traffic paths explained in the README (or here).

| Route table | Associated subnets | Route | Target |
|---|---|---|---|
| public-rt | public-a, public-b | `0.0.0.0/0` | Internet Gateway |
| private-rt | private-a, private-b | `0.0.0.0/0` | NAT Gateway (egress only) |
| (local) | all | `10.0.0.0/16` | local |

- **Traffic path (inbound):** Internet → IGW → public subnet ALB → private subnet app.
- **Traffic path (outbound from private):** app → NAT Gateway (public subnet) → IGW.
- **Confirmation private subnets have no direct inbound from the internet:** `____________________`

### 3. Security groups (least privilege)
**Evidence required:** rules use minimum required ports and sources.

**Proposed rules** (each SG references the previous one, not open CIDRs, where possible):

| SG | Inbound | Source | Purpose |
|---|---|---|---|
| `sg-alb` | 443 (and 80→redirect) | `0.0.0.0/0` | Public HTTPS to load balancer |
| `sg-app` | app port (e.g. 8080) | `sg-alb` only | Only the ALB can reach the app |
| `sg-admin` | 22 / SSM | your IP or SSM only | Admin access — avoid `0.0.0.0/0` |

- **Outbound:** restrict where practical; document any `0.0.0.0/0` egress and why.
- **Admin access method (SSM Session Manager preferred over open SSH):** `____________________`

### 4. Test DNS routing and connectivity
**Evidence required:** test commands and results saved.

Record actual commands + (sanitized) output, e.g.:
- From a public host: reach the ALB / internet.
- From a private host: reach the internet **via NAT**, but not be reachable from outside.
- DNS resolution works inside the VPC.

```
# commands and sanitized results here
____________________
```

### 5. Break one route or security group rule and diagnose
**Evidence required:** troubleshooting note with symptom, cause, and fix.

- **What was broken (e.g. removed private-rt NAT route, or tightened sg-app):** `____________________`
- **Symptom observed:** `____________________`
- **Diagnosis (how you found the cause):** `____________________`
- **Fix:** `____________________`
- **Prevention / lesson:** `____________________`

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`

---

## Teardown
- [ ] Ran `docs/runbooks/teardown.md` — verified NAT Gateway, EIPs, and any test
      instances removed; 0 chargeable resources remain.
