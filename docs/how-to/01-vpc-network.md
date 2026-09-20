# How-to 01 — Build the VPC network (Week 2)

Reproducible, click-by-click steps to rebuild the lab network from scratch in the AWS
console. Region: **us-east-1**. Everything here is **free** (no NAT, no instances).

> This is the "how to build it" guide. Proof it was built (resource IDs, tests) lives in
> `docs/week-02-vpc-and-network-design.md`; the design rationale is in ADR 0001.

## Result
A VPC across 2 AZs with public + private subnets, internet access for public subnets
only, least-privilege security groups, and free S3 egress for private subnets via a
Gateway endpoint.

---

## 1. VPC
VPC → **Your VPCs** → **Create VPC** → **VPC only**:
- Name `devops-lab-vpc`, IPv4 CIDR `10.0.0.0/16` → Create.

## 2. Subnets
VPC → **Subnets** → **Create subnet** → select `devops-lab-vpc`, add all four:

| Name | AZ | CIDR |
|---|---|---|
| `public-a` | us-east-1a | `10.0.0.0/24` |
| `public-b` | us-east-1b | `10.0.1.0/24` |
| `private-a` | us-east-1a | `10.0.10.0/24` |
| `private-b` | us-east-1b | `10.0.11.0/24` |

## 3. Internet Gateway
VPC → **Internet gateways** → Create (`devops-lab-igw`) → **Actions → Attach to VPC** →
`devops-lab-vpc`.

## 4. Route tables
VPC → **Route tables** → Create two (VPC = `devops-lab-vpc` for both):

**`public-rt`**
- Subnet associations → Edit → add `public-a`, `public-b`.
- Routes → Edit routes → Add `0.0.0.0/0` → target **Internet Gateway** (`devops-lab-igw`).

**`private-rt`**
- Subnet associations → Edit → add `private-a`, `private-b`.
- Leave routes as local only (no internet route — this is the controlled-egress design).

> Leave the VPC's auto-created "main" route table untouched.

## 5. Security groups
VPC → **Security groups** → Create three (VPC = `devops-lab-vpc`). Note: names can't start
with `sg-` (reserved).

| Name | Description | Inbound |
|---|---|---|
| `devops-lab-alb-sg` | HTTPS from internet to load balancer | HTTPS 443 from `0.0.0.0/0` |
| `devops-lab-app-sg` | App port from ALB SG only | Custom TCP 8080, source = `devops-lab-alb-sg` |
| `devops-lab-admin-sg` | Admin access via SSM; no inbound | (none) |

Create `devops-lab-alb-sg` first, since `devops-lab-app-sg` references it as a source.

## 6. S3 Gateway endpoint (free controlled outbound)
VPC → **Endpoints** → **Create endpoint**:
- Name `devops-lab-s3-endpoint`, Type **AWS services**.
- Service `com.amazonaws.us-east-1.s3`, **Type = Gateway**.
- VPC `devops-lab-vpc`; **Route tables:** tick `private-rt`.
- Policy: Full access → Create.

This adds an S3 prefix-list route to `private-rt` automatically, at $0.

---

## Optional: verify connectivity
To prove it works (this part costs ~$0.04/hr; tear down after):
1. Add 3 SSM **interface** endpoints (`ssm`, `ssmmessages`, `ec2messages`) on `private-a`/
   `private-b` with a SG allowing 443 from `10.0.0.0/16`, Enable DNS name on. Enable
   **DNS hostnames** on the VPC first.
2. Create IAM role `devops-lab-ssm-role` (policy `AmazonSSMManagedInstanceCore`).
3. Launch a `t3.micro` (Amazon Linux 2023) in `private-a`, no public IP, SG
   `devops-lab-admin-sg`, role `devops-lab-ssm-role`. Connect via **SSM Session Manager**.
4. In the shell:
   - `curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 https://s3.us-east-1.amazonaws.com` → an HTTP code = S3 reachable.
   - `curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 https://www.google.com` → `000` (blocked, no NAT).
5. **Tear down:** terminate the instance and delete the 3 interface endpoints.

## Teardown (of the whole network)
The network is free, so it can be left up. To remove it entirely, see
`docs/runbooks/teardown.md` and delete in reverse dependency order (endpoints → SGs →
route tables → subnets → IGW detach/delete → VPC).
