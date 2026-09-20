# Week 5 — Terraform Foundations and State

**Stage:** Month 2 · Terraform and Reusable Infrastructure
**Status:** ✅ Complete — network adopted via import (0 drift) and proven to recreate from code.

> Evidence rule: a task counts as done only when its evidence is committed here.
> Keep secrets and Terraform state OUT of Git (see `terraform/.gitignore`).

**Month 2 outcome:** replace the manual Month 1 setup with reviewed, reusable, safely
managed infrastructure code.

---

## Approach decision — adopt then recreate
The Week 2 network was built manually and is still live (`vpc-036e955def8d2cce6`). Plan:
1. Write Terraform HCL that matches the existing network.
2. **`terraform import`** each existing resource into state (adopt it — no rebuild yet).
3. `terraform plan` shows **no changes** (proves the HCL matches reality).
4. Then prove recreate-from-code: `terraform destroy` → `terraform apply` rebuilds it.

## Prerequisites (before building)
- [ ] **Install Terraform** on the dev machine (`terraform -version` works).
- [ ] **Remote state backend:** an **S3 bucket** (versioned + encrypted) with native state
      locking. This is a *persistent* resource — kept between sessions (costs ~nothing),
      unlike the create/destroy lab infra.
- [ ] AWS credentials available to Terraform (same CLI creds used in Month 1).

## Evidence checklist — all tasks complete ✅

### 1. Provider, version, and variable files with clear constraints
**Evidence required:** `terraform fmt` and `terraform validate` pass. **Done.**
- **Provider/version pins:** `versions.tf` — `required_version >= 1.10`, AWS provider
  `~> 5.0` (resolved v5.100.0, pinned in `.terraform.lock.hcl`).
- **Variables:** `variables.tf` — `aws_region` (default `us-east-1`).
- **fmt/validate:** `terraform fmt` clean; `terraform validate` → "Success! The
  configuration is valid."

### 2. Import (adopt) the Month 1 network into Terraform
**Evidence required:** `terraform plan` matches the intended architecture (no drift). **Done.**
- **Resources imported:** all 16 — VPC, 4 subnets, IGW, 2 route tables + 4 associations,
  3 security groups, S3 gateway endpoint (via config-driven `import` blocks).
- **No drift:** import plan showed `16 to import, 0 to add, 0 to change, 0 to destroy`;
  post-apply `terraform plan` → **"No changes. Your infrastructure matches the configuration."**
- **Recreate proof:** `terraform destroy` (16 destroyed) then `terraform apply` (16 added)
  rebuilt the identical network from `network.tf` with new IDs — proving reproducibility.

### 3. Encrypted, versioned remote state with locking
**Evidence required:** safe concurrent access. **Done.**
- **State bucket:** `devops-lab-tfstate-23987ce5` (us-east-1) — versioning enabled,
  AES256 encryption, public access blocked. Persistent (kept between sessions).
- **Locking:** S3 native lockfile (`use_lockfile = true`, Terraform >= 1.10) — no DynamoDB.
  Each run acquires/releases the lock (seen in command output: "Releasing state lock").

### 4. Keep secrets and local state out of Git
**Evidence required:** no credentials or state files committed. **Done.**
- `terraform/.gitignore` excludes `.terraform/`, `*.tfstate`, `*.tfvars`; **commits**
  `.terraform.lock.hcl` (pins providers). State lives in S3, not the repo; AWS keys live
  in `~/.aws`, never in code.

### 5. Practice plan / apply / state inspection / targeted recovery
**Evidence required:** commands and risks explained. **Done.**
- Practised `init`, `plan`, `apply`, `state list` (16 resources tracked), `output`,
  `destroy`, and re-`apply`.
- **Real-world lesson (targeted recovery):** `terraform destroy` hung ~13 min on the VPC
  because an **unmanaged** security group (`devops-lab-vpce-sg`, from the Week 2 SSM
  interface-endpoint test) was never imported — a VPC can't be deleted while a non-default
  SG remains. Fix: deleted the orphan SG (`aws ec2 delete-security-group`), after which the
  VPC dropped immediately. **Takeaway:** resources created outside Terraform are invisible
  to it, cause drift, and can block a destroy — import (or avoid creating) everything in a
  managed VPC.

## Current live IDs (this apply — disposable, regenerate via `terraform output`)
- VPC `vpc-092e39275b04eea91`; public `subnet-0cb223fc71c45eefc`, `subnet-0b212b55843d5da05`;
  private `subnet-01930c14b3c26ff4c`, `subnet-08ef5c629d9591fa7`; SGs alb
  `sg-01d34e930e18ddd6a`, app `sg-0717a6e49f786f8b6`, admin `sg-01865493c91c48b05`.

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`
