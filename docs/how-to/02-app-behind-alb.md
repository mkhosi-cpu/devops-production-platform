# How-to 02 — Deploy the app to EC2 behind an ALB (Week 3)

Reproducible, click-by-click steps to deploy the FastAPI app on Auto Scaling EC2
instances behind an Application Load Balancer. Region: **us-east-1**. Builds on the
Week 2 network (see [`01-vpc-network.md`](01-vpc-network.md)).

> Approach (ADR 0003): manual weeks use an **EC2 user-data bootstrap** (no Docker). App
> instances run in **public** subnets so user-data can `pip install` from PyPI over the
> IGW; exposure is restricted by security group (8080 only from the ALB).
>
> 💰 The ALB (~$0.0225/hr) and the instance (~$0.01/hr) bill hourly. Build → test →
> tear down in one session; see `docs/runbooks/teardown.md`.

---

## Phase A — Free setup

### A1. Enable public IPs on the public subnets
VPC → Subnets → for **`public-a`** and **`public-b`**: Actions → Edit subnet settings →
tick **Enable auto-assign public IPv4 address** → Save.

### A2. Allow HTTP 80 on the ALB security group
VPC → Security groups → `devops-lab-alb-sg` → Edit inbound rules → Add **HTTP 80** from
`0.0.0.0/0` (keep the existing 443 rule).

### A3. Launch template
EC2 → Launch templates → Create launch template:
- Name `devops-lab-app-lt`; AMI **Amazon Linux 2023**; type `t3.micro`; no key pair.
- Network → Security groups: `devops-lab-app-sg` (leave subnet unset).
- Advanced → IAM instance profile: `devops-lab-ssm-role`.
- Advanced → User data:

```bash
#!/bin/bash
set -xe
dnf install -y python3 python3-pip git
cd /opt
git clone https://github.com/mkhosi-cpu/devops-production-platform.git
python3 -m venv /opt/appenv
/opt/appenv/bin/pip install --upgrade pip
/opt/appenv/bin/pip install -r /opt/devops-production-platform/app/requirements.txt
cat >/etc/systemd/system/devops-app.service <<'UNIT'
[Unit]
Description=DevOps Lab App
After=network.target
[Service]
WorkingDirectory=/opt/devops-production-platform/app
Environment=APP_VERSION=dev
ExecStart=/opt/appenv/bin/uvicorn main:app --host 0.0.0.0 --port 8080
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now devops-app
```

### A4. Target group
EC2 → Target groups → Create target group:
- Target type **Instances**; name `devops-lab-tg`; **HTTP** / **8080**; VPC
  `devops-lab-vpc`; health check path **`/health`**. Register no targets (the ASG does).

## Phase B — Load balancer + Auto Scaling (billing starts)

### B1. Application Load Balancer
EC2 → Load Balancers → Create → **Application Load Balancer**:
- Name `devops-lab-alb`; **Internet-facing**; IPv4; VPC `devops-lab-vpc`.
- Mappings: `public-a` (us-east-1a) + `public-b` (us-east-1b).
- Security group: `devops-lab-alb-sg` (remove default).
- Listener **HTTP:80** → forward to `devops-lab-tg` → Create.

### B2. Auto Scaling group
EC2 → Auto Scaling Groups → Create:
- Name `devops-lab-asg`; launch template `devops-lab-app-lt` (Latest).
- Network: VPC `devops-lab-vpc`; subnets `public-a` + `public-b`.
- Load balancing: attach to existing target group `devops-lab-tg`.
- Health checks: enable **ELB** health checks; grace period **300s**.
- Group size: desired **1**, min **1**, max **2**. Create.

Wait ~3–5 min for user-data to finish. EC2 → Target groups → `devops-lab-tg` → Targets:
the target moves `initial` → **healthy**.

## Test  *(to be confirmed during the build)*
- Get the ALB DNS name: EC2 → Load Balancers → `devops-lab-alb` → **DNS name**.
- `http://<alb-dns>/`, `http://<alb-dns>/health`, `http://<alb-dns>/version`.
- Confirm the app is reachable **only** via the ALB (SG `devops-lab-app-sg` allows 8080
  from the ALB SG only).

## Route 53 / TLS
Lab alternative (no domain): serve **HTTP via the ALB DNS name**; document that TLS/ACM is
deferred until a domain is available.

## Failure simulation  *(to be confirmed during the build)*
- EC2 → Instances → terminate the running app instance.
- Watch the ASG launch a replacement that bootstraps and rejoins the target group healthy,
  with no manual steps. Record the recovery time.

## Teardown
1. Auto Scaling Groups → `devops-lab-asg` → Delete (terminates its instances).
2. Load Balancers → `devops-lab-alb` → Delete.
3. Target groups → `devops-lab-tg` → Delete.
4. (Launch template can stay — free.)
5. Verify: no running instances, no ALB, no Elastic IPs. See `docs/runbooks/teardown.md`.
