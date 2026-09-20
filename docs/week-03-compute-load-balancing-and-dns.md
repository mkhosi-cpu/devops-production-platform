# Week 3 — Compute, Load Balancing, and DNS

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** ✅ All 5 tasks complete (evidence below). Teardown of paid resources pending.

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

## Deployment approach (decision)

Manual weeks use an **EC2 user-data bootstrap** (Docker/ECR is reserved for the
automation phase). Because the Week 2 network has **no NAT**, the app instance runs in a
**public subnet** so user-data can `pip install` FastAPI/uvicorn from PyPI over the IGW.
Exposure is restricted by security group (port 8080 only from the ALB SG); admin via SSM
over the IGW (no interface endpoints needed — cheaper than the Week 2 test). See
[`architecture-decisions/0003-manual-deploy-user-data-public-subnet.md`](architecture-decisions/0003-manual-deploy-user-data-public-subnet.md).
The private-subnet deployment returns in Month 3 via ECR + endpoints.

## Evidence checklist  — all tasks complete ✅

### 1. Deploy the sample app to EC2 via user-data
**Evidence required:** application responds through a controlled endpoint. **Done.**
- **AMI / instance type:** Amazon Linux 2023, `t3.micro`.
- **Subnet:** `public-a` / `public-b` (via the ASG); instances get public IPv4 for PyPI.
- **App + bootstrap:** FastAPI app from `app/` installed by launch-template user-data
  (`dnf install python3/git` → `git clone` repo → venv → `pip install` → systemd service
  `devops-app` running `uvicorn main:app --port 8080`, `APP_VERSION=dev`).
- **Reached for the test:** via the ALB DNS name over HTTP:80 (see Task 2).

### 2. Place an Application Load Balancer in front of the application
**Evidence required:** target health is green; direct app access is restricted. **Done.**
- **ALB:** `devops-lab-alb`, internet-facing, listener HTTP:80 → target group `devops-lab-tg`.
- **ALB subnets:** `public-a` (us-east-1a) + `public-b` (us-east-1b); SG `devops-lab-alb-sg`.
- **Target group:** `devops-lab-tg`, HTTP:8080, health check `/health` → **healthy**.
- **Test through ALB** (`http://devops-lab-alb-1086108642.us-east-1.elb.amazonaws.com`):
  `/health` → `200 {"status":"ok"}`, `/version` → `{"version":"dev"}`, `/` → landing page.
- **Direct access restricted:** app instances use `devops-lab-app-sg`, which allows 8080
  **only from `devops-lab-alb-sg`** — no direct internet access to the app port.

### 3. Configure Auto Scaling and a repeatable instance bootstrap
**Evidence required:** a replacement instance joins without manual configuration. **Done.**
- **Launch template:** `devops-lab-app-lt` (AL2023, t3.micro, SG `devops-lab-app-sg`, IAM
  `devops-lab-ssm-role`, user-data bootstrap above) — bootstrap is fully repeatable.
- **ASG:** `devops-lab-asg`, subnets public-a/public-b, **desired 1 / min 1 / max 2**,
  ELB health checks, 300s grace.
- **Replacement test:** see Task 5 — a terminated instance was replaced automatically and
  the new instance bootstrapped and rejoined healthy with no manual steps.

### 4. Route 53 and TLS with ACM
**Evidence required:** HTTPS works, or the documented lab alternative is complete. **Done (lab alternative).**
- **No domain owned**, so served over **HTTP via the ALB DNS name**
  (`devops-lab-alb-1086108642.us-east-1.elb.amazonaws.com`). Browsers show "Not secure"
  (plain HTTP) — expected.
- **TLS/ACM + Route 53 deferred** until a domain is available; the ALB already has an
  HTTPS:443 SG rule ready for a future 443 listener + ACM cert.

### 5. Simulate instance failure and observe recovery
**Evidence required:** recovery time and observations recorded. **Done.**
- **What was failed:** manually terminated the running app instance (`i-0f65fd69115cad718`).
- **Detection:** ASG marked it out of service (ELB connection draining) at 13:20:23Z and
  launched a replacement (`i-0ff99be0f8a469ceb`) at 13:20:25Z — **~2s to react**.
- **Recovery:** replacement bootstrapped from scratch (install → clone → pip → service)
  and rejoined the target group healthy; app confirmed back through the ALB (`/health` 200,
  `/version` dev) within ~3–5 minutes total.
- **Observations:** brief ALB 503 during the gap (no healthy target), then full recovery
  with zero manual intervention — the ASG + repeatable user-data delivers self-healing.

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
