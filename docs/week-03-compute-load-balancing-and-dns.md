# Week 3 — Compute, Load Balancing, and DNS

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** Not started.

> Evidence rule: a task counts as done only when its evidence is committed here.
> Keep account IDs, real public IPs, and any sensitive details out of committed files.
> Tear down every session — see `docs/runbooks/teardown.md`.

Builds on the Week 2 network (`vpc-036e955def8d2cce6`): app runs in the **private**
subnets, the load balancer sits in the **public** subnets.

---

## ⚠️ Cost note — this is the first week with hourly-billed infrastructure

| Resource | Charge (us-east-1, approx.) | Notes |
|---|---|---|
| **Application Load Balancer** | ~$0.0225/hr + LCUs | Bills while it exists; delete after each session (common orphan) |
| EC2 app instances | ~$0.01/hr (t3.micro) | Keep count low; terminate after |
| Public IPv4 | ~$0.005/hr each | ALB nodes + any public instance |
| Route 53 hosted zone | ~$0.50/month if kept | Only if you use a real domain; a retained zone is a small standing cost |
| ACM certificate | Free | No charge for the cert itself |

**Create/destroy discipline:** build → test → capture evidence → **tear everything down**
in the same session. A short ~1–2 hour session is a few cents. The `DevOps Bill` alert
(>$0.01) will email you as soon as the ALB starts — expected.

---

## Evidence checklist

### 1. Deploy a small containerized web application to EC2
**Evidence required:** application responds through a controlled endpoint.
- **AMI / instance type:** `____________________`
- **Subnet (private):** `____________________`
- **Container / app used:** `____________________`
- **How it was reached for the test:** `____________________`

### 2. Place an Application Load Balancer in front of the application
**Evidence required:** target health is green; direct app access is restricted.
- **ALB name / scheme (internet-facing):** `____________________`
- **ALB subnets (public-a, public-b):** `____________________`
- **Target group health:** `____________________`
- **Confirmation app is only reachable via the ALB (sg-app allows only ALB SG):** `____________________`

### 3. Configure Auto Scaling and a repeatable instance bootstrap
**Evidence required:** a replacement instance joins without manual configuration.
- **Launch template + user-data bootstrap summary:** `____________________`
- **ASG min/desired/max:** `____________________`
- **Replacement test (terminate an instance, ASG replaces it):** `____________________`

### 4. Add Route 53 and TLS with ACM (if you own a domain)
**Evidence required:** HTTPS works, or the documented lab alternative is complete.
- **Domain (or lab alternative used):** `____________________`
- **ACM certificate status:** `____________________`
- **HTTPS test result:** `____________________`
- _If no domain: document the alternative (e.g. HTTP-only via ALB DNS name) and why._

### 5. Simulate instance failure and observe recovery
**Evidence required:** recovery time and observations recorded.
- **What was failed:** `____________________`
- **Detection (health check / target draining):** `____________________`
- **Recovery time:** `____________________`
- **Observations:** `____________________`

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`

---

## Teardown
- [ ] Deleted the ALB and target group.
- [ ] Terminated app instances; deleted the Auto Scaling group and launch template.
- [ ] Released any Elastic IPs; deleted leftover volumes.
- [ ] (If created) decided whether to keep or delete the Route 53 hosted zone.
- [ ] Verified 0 chargeable resources remain (see `docs/runbooks/teardown.md`).
