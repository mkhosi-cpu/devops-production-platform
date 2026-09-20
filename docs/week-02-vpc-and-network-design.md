# Week 2 — VPC and Network Design

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** ✅ Complete — all 5 tasks evidenced; paid resources torn down.

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

- **Region / AZs used:** `us-east-1` — `us-east-1a` (AZ A) and `us-east-1b` (AZ B)
- **Actual CIDRs:** as planned, unchanged.

**As built (Phase 1 — all free resources):**

| Resource | Name | ID | Detail |
|---|---|---|---|
| VPC | `devops-lab-vpc` | `vpc-036e955def8d2cce6` | `10.0.0.0/16` |
| Subnet | `public-a` | `subnet-05f43f33812a1848a` | `10.0.0.0/24`, us-east-1a |
| Subnet | `public-b` | `subnet-03543dc6e4464e849` | `10.0.1.0/24`, us-east-1b |
| Subnet | `private-a` | `subnet-068a3ae15d3f14360` | `10.0.10.0/24`, us-east-1a |
| Subnet | `private-b` | `subnet-03a69092909fcbf16` | `10.0.11.0/24`, us-east-1b |
| Internet Gateway | `devops-lab-igw` | `igw-02a50d015605ef2e2` | attached to VPC |

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
- **Confirmation private subnets have no direct inbound from the internet:** confirmed —
  `private-rt` has no `0.0.0.0/0` route; only local + the S3 prefix-list route.

**As built:**

| Route table | ID | Associations | Routes |
|---|---|---|---|
| `public-rt` | `rtb-0be98be5c11857af7` | public-a, public-b | `10.0.0.0/16`→local, `0.0.0.0/0`→`igw-02a50d015605ef2e2` (Active) |
| `private-rt` | `rtb-09c6ab1877aeb7a7c` | private-a, private-b | `10.0.0.0/16`→local, S3 prefix-list→`vpce-00230d915ca9d2aec` |
| S3 Gateway Endpoint | `vpce-00230d915ca9d2aec` | assoc. to `private-rt` | `com.amazonaws.us-east-1.s3`, type Gateway, **$0**, Available |

### 3. Security groups (least privilege)
**Evidence required:** rules use minimum required ports and sources.

> Note: AWS reserves the `sg-` prefix for security-group IDs, so groups are named
> `devops-lab-*-sg` instead.

**As built:**

| SG | ID | Inbound | Source | Purpose |
|---|---|---|---|---|
| `devops-lab-alb-sg` | `sg-09d1b3fafba4eadd7` | 443 | `0.0.0.0/0` | Public HTTPS to load balancer (intended) |
| `devops-lab-app-sg` | `sg-0c2e860d40c311480` | TCP 8080 | `devops-lab-alb-sg` only | Only the ALB can reach the app |
| `devops-lab-admin-sg` | `sg-0f9f4ba19e0bf3f94` | none | — | Admin via SSM; no inbound (no open SSH) |

- **Least-privilege point:** `devops-lab-app-sg` accepts 8080 only from the ALB SG,
  never from the internet.
- **Admin access method:** SSM Session Manager (no inbound SSH rule).

### 4. Test DNS routing and connectivity
**Evidence required:** test commands and results saved. **Done.**

**Test host:** `devops-lab-test` (`i-08127ed978a9f6726`), t3.micro, Amazon Linux 2023,
in `private-a` (`10.0.10.42`), **no public IP**, SG `devops-lab-admin-sg`, role
`devops-lab-ssm-role`. Accessed via **SSM Session Manager** over the interface endpoints
(no SSH, no public IP) — which itself proves private management works.

Results:

| Test | Command | Result | Conclusion |
|---|---|---|---|
| No public IP | metadata `public-ipv4` | `404 Not Found` | ✅ genuinely private (private IP `10.0.10.42`) |
| DNS | `getent hosts s3.us-east-1.amazonaws.com` | resolved to S3 IPs | ✅ VPC DNS works without internet |
| S3 reachable | `curl https://s3.us-east-1.amazonaws.com` | HTTP **307** | ✅ reachable via S3 gateway endpoint |
| Internet blocked | `curl https://www.google.com` | **000** (timeout) | ✅ no general egress (no NAT) — controlled |

### 5. Break one route or security group rule and diagnose
**Evidence required:** troubleshooting note with symptom, cause, and fix. **Done.**

- **What was broken:** disassociated `private-rt` from the S3 gateway endpoint
  (`devops-lab-s3-endpoint`), which removed the S3 prefix-list route from the private
  subnets.
- **Symptom observed:** the S3 test that had returned `307` now returned `000` (timeout)
  — S3 suddenly unreachable from the private instance.
- **Diagnosis:** checked `private-rt` Routes — the S3 prefix-list route was gone. With no
  NAT in this design, removing the endpoint route leaves private subnets with no path to
  S3 at all.
- **Fix:** re-associated `private-rt` to the S3 gateway endpoint; the prefix-list route
  returned.
- **Recovery confirmed:** S3 test returned `307` again.
- **Prevention / lesson:** in a NAT-less design, the endpoint's route-table association
  *is* the only egress path — removing it silently breaks S3 access with no fallback.
  Treat endpoint associations as critical config; watch them in change reviews.

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`

---

## Teardown
- [x] Terminated test instance `devops-lab-test` (root volume auto-deleted).
- [x] Deleted the 3 SSM interface endpoints (`ssm`, `ssmmessages`, `ec2messages`).
- [x] Verified: no running instances, no NAT Gateways, no Elastic IPs, no leftover volumes.
- [x] Kept (all free): VPC, subnets, IGW, route tables, security groups, IAM role, and
      the S3 **Gateway** endpoint — retained for later weeks at $0.

**Result:** 0 chargeable resources remain. Session cost was a few cents (interface
endpoints for ~1 hour + a brief t3.micro).
