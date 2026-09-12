# DevOps Production Platform

This repository documents a six-month hands-on DevOps engineering project. The goal is to design, build, secure, operate, troubleshoot, and rebuild a production-style application platform on AWS.

The project focuses on practical engineering evidence rather than completing disconnected tutorials. Each stage extends the same platform and leaves behind working code, automated tests, architecture decisions, operational runbooks, and failure-recovery notes.

## Project status

**Current stage:** Month 1 — AWS Architecture and Operations (Week 2 in progress)

**Planned duration:** 26 weeks

**Recommended pace:** 6 to 8 focused hours per week

The detailed checklist is available in [`docs/Six_Month_DevOps_Engineering_Roadmap.docx`](docs/Six_Month_DevOps_Engineering_Roadmap.docx).

## Project objectives

By the end of this project, the platform should demonstrate that I can:

- Design a secure AWS network and application architecture.
- Provision repeatable cloud infrastructure with Terraform.
- Deploy and operate containerized workloads on Amazon EKS.
- Package Kubernetes applications with Helm.
- Build a secure CI/CD process with GitHub Actions.
- Authenticate GitHub Actions to AWS without long-lived AWS access keys.
- Create Python tools for health checks, reporting, and guarded recovery actions.
- Implement metrics, dashboards, logs, alerts, and basic tracing.
- Apply cloud, container, Kubernetes, secrets, and software supply-chain controls.
- Diagnose realistic failures, recover the platform, and document the lessons.
- Destroy and recreate the complete lab from code and written instructions.

## Learning roadmap

| Stage | Weeks | Main outcome | Status |
|---|---:|---|---|
| AWS architecture and operations | 1-4 | Build and test the initial AWS foundation | In progress |
| Terraform and reusable infrastructure | 5-8 | Replace manual setup with reusable infrastructure code | Not started |
| Kubernetes and Amazon EKS | 9-13 | Deploy and troubleshoot a resilient EKS workload | Not started |
| CI/CD and Python automation | 14-18 | Automate releases, verification, rollback, and operational checks | Not started |
| Observability and security | 19-23 | Detect failures and reduce platform and supply-chain risk | Not started |
| Capstone and portfolio review | 24-26 | Rebuild, test, explain, and safely publish the complete platform | Not started |

## Target platform

The planned platform will combine the following components:

- **AWS:** VPC, IAM, EC2, Application Load Balancer, Route 53, ACM, S3, ECR, EKS, CloudWatch, and Secrets Manager where appropriate.
- **Infrastructure as code:** Terraform modules, environment configurations, remote state, validation, and security checks.
- **Containers:** Docker images with immutable release references and vulnerability scanning.
- **Kubernetes:** Deployments, Services, Ingress, health probes, resource controls, autoscaling, RBAC, namespaces, disruption controls, and network restrictions.
- **Application delivery:** GitHub Actions, short-lived AWS authentication, automated testing, security gates, ECR publishing, Helm deployment, smoke testing, and rollback.
- **Automation:** Python command-line tools for health checks, reporting, diagnostics, and carefully controlled recovery actions.
- **Observability:** Prometheus, Grafana, Alertmanager, centralized logs, and request correlation or tracing.
- **Security:** Least privilege, secrets management, SAST, dependency scanning, container scanning, infrastructure scanning, SBOM generation, and threat modelling.

The final implementation may change as design decisions are tested. Significant decisions and trade-offs will be recorded in `docs/architecture-decisions/`.

## Repository structure

```text
devops-production-platform/
├── README.md
├── app/
├── terraform/
├── kubernetes/
├── helm/
├── ansible/
├── automation/
├── observability/
├── security/
├── docs/
│   ├── Six_Month_DevOps_Engineering_Roadmap.docx
│   ├── architecture-decisions/
│   ├── diagrams/
│   ├── game-days/
│   └── runbooks/
└── .github/
    └── workflows/
```

Each main folder will contain its own README with the purpose of that component, prerequisites, commands, validation steps, teardown instructions, and known limitations.

## Folder responsibilities

| Folder | Responsibility |
|---|---|
| `app/` | Sample application and application-level tests |
| `terraform/` | AWS infrastructure modules and environment roots |
| `kubernetes/` | Kubernetes resources, policies, and supporting manifests |
| `helm/` | Application chart and environment-specific values |
| `ansible/` | Optional host configuration and operational playbooks |
| `automation/` | Python package, CLI tools, and automated tests |
| `observability/` | Dashboards, alerts, recording rules, logs, and tracing configuration |
| `security/` | Scan configuration, policies, threat model, and documented exceptions |
| `docs/` | Roadmap, diagrams, architecture decisions, runbooks, and game-day reports |
| `.github/workflows/` | Continuous integration, release, deployment, and scheduled workflows |

## Engineering workflow

Work will follow a repeatable weekly cycle:

1. **Learn and design:** Review official documentation, define the change, and write acceptance criteria.
2. **Build and test:** Implement the smallest useful change and capture evidence.
3. **Break and recover:** Trigger a controlled failure, diagnose it, restore service, and update the runbook.
4. **Review:** Record the main lesson, confidence score, remaining gaps, and next action.

A task is complete only when the result is reproducible and its evidence has been committed. Watching a course or successfully running a copied command is not considered completion.

## Definition of done

A project stage is complete when:

- Code and configuration are committed without secrets.
- Automated tests and relevant security checks pass.
- The component README explains setup, validation, troubleshooting, and teardown.
- Architecture diagrams and decisions match the deployed system.
- At least one realistic failure has been tested and documented.
- The environment can be recreated without undocumented console changes.
- Chargeable lab resources can be identified and removed safely.
- I can explain the implementation and its trade-offs without following a tutorial step by step.

## Security and privacy boundaries

This is an independent personal learning project. It must not contain:

- Employer source code or configuration.
- Customer names, data, identifiers, or environments.
- Internal hostnames, network diagrams, or private operational details.
- Production credentials, tokens, private keys, kubeconfig files, or secrets.
- Screenshots or logs containing sensitive information.

Example configuration should use placeholders or safe lab values. Secrets required by the running platform should be injected from an approved secrets store and excluded from Git.

## AWS cost controls

This project may create chargeable AWS resources, particularly EKS clusters, worker nodes, load balancers, NAT gateways, public IP addresses, and persistent storage.

The following controls apply:

- Configure an AWS Budget and billing alerts before provisioning the lab.
- Tag resources with the project, environment, owner, and expiry where practical.
- Keep expensive environments running only while they are being used.
- Maintain and test a complete Terraform teardown process.
- Check for orphaned load balancers, storage, snapshots, public IP addresses, and networking resources after teardown.
- Review billing after major lab sessions and at the end of each stage.

## Planned evidence

The completed repository should include:

- Architecture and network diagrams.
- Terraform plans, validation results, and reusable modules.
- Kubernetes manifests and Helm releases.
- CI/CD workflow history and release evidence.
- Image digests, scan reports, and software bills of materials.
- Grafana dashboards and tested alert rules.
- Python unit tests and sample diagnostic reports.
- Architecture decision records.
- Failure scenarios, incident timelines, and recovery notes.
- A final platform demonstration and reproducibility test.

## Capstone acceptance criteria

The capstone is successful when a fresh clone can:

1. Provision the required AWS infrastructure from code.
2. Build, test, scan, and publish a uniquely traceable application image.
3. Deploy the image to EKS through the approved pipeline.
4. Verify application health and expose useful operational telemetry.
5. Detect a deliberately introduced bad release and recover safely.
6. Restore one backup or critical configuration item.
7. Remove the lab and confirm that no unintended chargeable resources remain.

## Documentation approach

The root README explains the complete project. Component READMEs will contain the technical instructions for their folders. Runbooks, diagrams, architecture decisions, and game-day reports will remain in `docs/` so that operational knowledge is not mixed into deployment code.

## Licence

No licence has been selected yet. Until a licence is added, the repository contents remain subject to the default copyright rules that apply to an unlicensed repository.
