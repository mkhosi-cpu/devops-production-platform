# Month 1 — AWS Foundation Architecture

Starter architecture for the Month 1 goal: *a secure AWS foundation for a small
production-style application.* This is a design target for Weeks 1–4 — adjust it as
you build and record any deviations in an ADR under `docs/architecture-decisions/`.

## Diagram

```mermaid
flowchart TB
    user([User / Browser])
    dns[Route 53<br/>DNS]
    acm[ACM<br/>TLS certificate]

    user -->|HTTPS| dns

    subgraph AWS["AWS Account (region: TBD)"]
        subgraph VPC["VPC — 2 Availability Zones"]
            igw[Internet Gateway]

            subgraph AZ1["Availability Zone A"]
                pub1[Public subnet<br/>ALB + NAT]
                priv1[Private subnet<br/>App EC2]
            end

            subgraph AZ2["Availability Zone B"]
                pub2[Public subnet<br/>ALB]
                priv2[Private subnet<br/>App EC2]
            end

            alb{{Application<br/>Load Balancer}}
            asg[Auto Scaling Group<br/>containerized web app]
        end

        s3[(S3<br/>artifacts / logs / static)]
        cw[CloudWatch<br/>metrics · logs · 1 alarm]
        iam[IAM<br/>least-privilege roles]
    end

    dns --> igw
    igw --> alb
    acm -.TLS.-> alb
    alb --> pub1
    alb --> pub2
    alb --> asg
    asg --- priv1
    asg --- priv2
    asg -->|egress via NAT| pub1
    asg --> s3
    asg --> cw
    iam -.governs.-> asg
    iam -.governs.-> s3
```

## Component notes

| Component | Purpose | Week introduced |
|---|---|---|
| Route 53 + ACM | DNS and TLS termination (or documented lab alternative) | 3 |
| VPC / subnets / IGW / NAT | Network isolation across 2 AZs; controlled egress | 2 |
| Security groups | Least-required ports for ALB / app / admin | 2 |
| ALB | Public entry point; direct app access restricted | 3 |
| Auto Scaling Group | Self-healing, repeatable instance bootstrap | 3 |
| S3 | Artifacts, log archive, or static assets (encrypted) | 4 |
| CloudWatch | Metrics, logs, and at least one alarm | 4 |
| IAM | Short-lived / least-privilege access | 1 |

## Expected monthly cost estimate

> Fill in real figures for your region before ticking the Week 1 cost task.
> These are rough placeholders for a small always-on lab; **destroy resources when
> idle** to keep this near zero.

| Item | Assumption | Est. USD / month |
|---|---|---|
| EC2 (app instances) | e.g. 1–2 × t3.small, part-time | `____` |
| Application Load Balancer | 1 ALB, low traffic | `____` |
| NAT Gateway | 1 NAT, hourly + data | `____` |
| S3 | Small storage + requests | `____` |
| Route 53 | 1 hosted zone | `____` |
| CloudWatch | Basic metrics/logs | `____` |
| **Total (idle-managed)** | Torn down when not in use | **`____`** |

_Budget guardrail:_ `DevOps Bill` alerts at >$0.01, so any real spend triggers an
email immediately (see `docs/week-01-aws-account-safety-and-iam.md`).
