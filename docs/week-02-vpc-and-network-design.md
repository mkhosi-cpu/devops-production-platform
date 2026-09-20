# Week 2 — VPC and Network Design

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** In progress.

> Evidence rule: a task counts as done only when its evidence is committed here.
> Keep account IDs, real public IPs, and any sensitive details out of committed files.
> Tear down every session — see `docs/runbooks/teardown.md`.

The tables below are a **proposed starting design** — adjust the CIDRs, AZs, and rules
to your region and needs, then record what you actually built.

---

## Cost-avoidance build order

Week 2 can be completed for **~$0** if built in this order. Only outbound egress and
test instances ever cost money; everything else is free. See
[`docs/architecture-decisions/0001-s3-gateway-endpoint-over-nat.md`](architecture-decisions/0001-s3-gateway-endpoint-over-nat.md).

1. **Build the free resources first (no time pressure, $0):** VPC, 4 subnets, Internet
   Gateway, route tables, security groups. Document and screenshot these — covers
   Tasks 1, 3, and most of Task 2 at zero cost.
2. **Use a free S3 Gateway Endpoint for "controlled outbound," not a NAT Gateway.**
   A Gateway Endpoint lets private instances reach S3 with no internet path and no NAT
   ($0). This satisfies Task 2's controlled-outbound intent and is a stronger
   least-privilege story. Only spin up a NAT **Gateway** in a short delete-immediately
   burst if you specifically want to practice it (~$0.045/hr); a NAT **instance**
   (`t4g.nano`) is ~10× cheaper if you want egress left up briefly.
3. **Test instances (Tasks 4–5): smallest, shortest, no public IP.** Launch
   `t3.micro`/`t4g.nano` only while testing, **disable auto-assign public IP**, and
   connect via **SSM Session Manager** (avoids the ~$0.005/hr public-IPv4 charge and is
   more secure than open SSH). Terminate right after.
4. **Tear down** per `docs/runbooks/teardown.md` — the `DevOps Bill` alert (>$0.01) is
   the safety net if anything is left running.

| Resource | Charged? | Cost-avoidance |
|---|---|---|
| VPC, subnets, route tables, IGW, security groups | No | Build and leave up freely |
| S3 **Gateway** Endpoint | **No** | Use for controlled egress instead of NAT |
| NAT **Gateway** | Yes (~$0.045/hr + data) | Avoid; or short burst; or NAT instance |
| Public IPv4 | Yes (~$0.005/hr each) | No public IPs on test instances; use SSM |
| EC2 test instances | Yes (~$0.01/hr) | Smallest size, only while testing, terminate |

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

- **Region / AZs used:** `us-east-1` — e.g. `us-east-1a` (AZ A) and `us-east-1b` (AZ B)
- **Actual CIDRs (if changed):** `____________________`

### 2. Route tables, internet access, controlled outbound access
**Evidence required:** traffic paths explained in the README (or here).

| Route table | Associated subnets | Route | Target |
|---|---|---|---|
| public-rt | public-a, public-b | `0.0.0.0/0` | Internet Gateway |
| private-rt | private-a, private-b | S3 prefix list | S3 Gateway Endpoint (free) |
| private-rt (optional) | private-a, private-b | `0.0.0.0/0` | NAT Gateway — only if general egress needed |
| (local) | all | `10.0.0.0/16` | local |

- **Traffic path (inbound):** Internet → IGW → public subnet ALB → private subnet app.
- **Controlled outbound (free default):** private app → **S3 Gateway Endpoint** → S3,
  with no internet path. A `0.0.0.0/0` → NAT route is only added if general internet
  egress is required (costs ~$0.045/hr — see cost-avoidance build order above).
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
