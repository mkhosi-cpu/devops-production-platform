# Week 5 — Terraform Foundations and State

**Stage:** Month 2 · Terraform and Reusable Infrastructure
**Status:** Not started (queued to begin the new month).

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

## Evidence checklist

### 1. Provider, version, and variable files with clear constraints
**Evidence required:** `terraform fmt` and `terraform validate` pass.
- **Provider/version pins:** `____________________`
- **Variables + constraints:** `____________________`
- **fmt/validate output:** `____________________`

### 2. Import (adopt) the Month 1 network into Terraform
**Evidence required:** `terraform plan` matches the intended architecture (no drift).
- **Resources imported (VPC, subnets, IGW, route tables, SGs, S3 endpoint):** `____________________`
- **`terraform plan` shows no changes after import:** `____________________`
- **Recreate proof (`destroy` then `apply`):** `____________________`

### 3. Encrypted, versioned remote state with locking
**Evidence required:** two operators/sessions cannot write state concurrently.
- **State bucket + settings (versioning, encryption):** `____________________`
- **Locking mechanism:** `____________________`
- **Concurrent-write test result:** `____________________`

### 4. Keep secrets and local state out of Git
**Evidence required:** repo scan finds no credentials or state files.
- **`terraform/.gitignore` in place:** `____________________`
- **Scan result:** `____________________`

### 5. Practice plan / apply / state inspection / targeted recovery
**Evidence required:** commands and risks explained.
- **On a disposable resource — commands used and what each does:** `____________________`
- **Targeted recovery (e.g. `terraform state`, `-target`) notes:** `____________________`

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`
