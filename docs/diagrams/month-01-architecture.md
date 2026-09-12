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

## Expected cost — create/destroy model

**Operating model:** resources are **created for a lab session and destroyed after**,
so there is no always-on infrastructure. Effective monthly cost is therefore **~$0**,
provided teardown is verified every session.

Cost is better expressed **per running hour** than per month, since nothing runs idle:

| Item | Billed while running? | Notes |
|---|---|---|
| EC2 (app instances) | Yes, per hour | Stop/terminate at end of session |
| Application Load Balancer | Yes, per hour + LCUs | Delete after session — common orphan |
| NAT Gateway | Yes, per hour + data | Charges immediately; delete promptly |
| Elastic IP | Yes, when allocated/idle | Release after teardown |
| EBS volumes / snapshots | Yes, while they exist | Delete with the instances |
| S3 | Storage + requests | Tiny; safe to leave or empty the bucket |
| Route 53 | Per hosted zone / month | Small standing cost if a zone is kept |
| CloudWatch | Metrics/logs | Negligible for a small lab |

> **Not truly $0:** NAT/EIP/EBS bill the moment they exist, and forgotten resources
> (orphaned ALB/NAT) are the usual surprise bill. The `DevOps Bill` budget alerts at
> **>$0.01**, so any real spend triggers an email immediately.
>
> **Teardown discipline:** after each session, verify no chargeable resources remain
> (see the teardown runbook under `docs/runbooks/`). Fill in real per-hour figures for
> your region if you want a concrete session-cost estimate.
