# Week 6 — Terraform Modules

**Stage:** Month 2 · Terraform and Reusable Infrastructure
**Status:** Not started.

> Evidence rule: a task counts as done only when its evidence is committed here.
> State stays in S3; secrets/state out of Git (`terraform/.gitignore`).

Builds on Week 5: refactor the flat `network.tf` into **reusable modules** with clear
inputs/outputs, so the same code can build different environments.

---

## Evidence checklist

### 1. Create focused modules for network, compute, and load balancing
**Evidence required:** each module has inputs, outputs, and a README.
- **Modules created (e.g. `modules/network`, `modules/compute`, `modules/alb`):** `____________________`
- **Each has variables.tf / outputs.tf / README.md:** `____________________`

### 2. Keep module interfaces small; don't bake env values into modules
**Evidence required:** a module can be reused with different inputs.
- **Example of reuse with different inputs:** `____________________`
- **No hard-coded environment values inside modules:** `____________________`

### 3. Consistent naming, tags, and ownership metadata
**Evidence required:** resources filterable by project/environment/owner.
- **Tagging strategy (e.g. provider `default_tags`):** `____________________`
- **Naming convention:** `____________________`

### 4. Expose only the outputs another module/step needs
**Evidence required:** root module has no unnecessary coupling.
- **Module outputs and why each is exposed:** `____________________`

### 5. Rebuild the dev environment from an empty account/clean region
**Evidence required:** apply completes without console changes.
- **`terraform apply` from clean state result:** `____________________`
- **Any manual step still required (should be none):** `____________________`

---

## Notes / plan
- Refactor `network.tf` into a `modules/network` module (VPC, subnets, IGW, route tables,
  SGs, S3 endpoint) with variables (CIDRs, AZs, name prefix) and outputs (vpc_id, subnet
  ids, sg ids).
- Root config calls the module with environment-specific inputs — sets up Week 7's
  dev vs prod environments.
- Remember the Week 5 lesson: keep everything in the VPC under Terraform (no orphan
  resources) so destroy/recreate stays clean.

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`
