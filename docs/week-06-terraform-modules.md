# Week 6 — Terraform Modules

**Stage:** Month 2 · Terraform and Reusable Infrastructure
**Status:** ✅ Complete — network refactored into a reusable module via `moved` blocks (0 infra change).

> Evidence rule: a task counts as done only when its evidence is committed here.
> State stays in S3; secrets/state out of Git (`terraform/.gitignore`).

Builds on Week 5: refactor the flat `network.tf` into **reusable modules** with clear
inputs/outputs, so the same code can build different environments.

---

## Evidence checklist

### 1. Create focused modules with inputs, outputs, and a README
**Evidence required:** each module has inputs, outputs, and a README. **Done.**
- **Module:** `terraform/modules/network` — `main.tf` (resources), `variables.tf` (inputs),
  `outputs.tf`, `README.md`. (Compute/ALB modules come when that infra returns via IaC.)
- Refactored the flat `network.tf` into this module using `moved` blocks so no real
  infrastructure was destroyed — `plan` showed `0 to add, 0 to change, 0 to destroy`.

### 2. Small interface; no env values baked in
**Evidence required:** a module can be reused with different inputs. **Done.**
- Inputs: `name_prefix`, `aws_region`, `vpc_cidr`, `az_a/az_b`, four subnet CIDRs,
  `app_port`. Nothing environment-specific is hard-coded inside the module.
- Reuse: the root calls it with dev values; Week 7 will call the same module again with a
  different `name_prefix`/CIDR for a prod-style env — no resource code duplicated.

### 3. Consistent naming, tags, and ownership metadata
**Evidence required:** resources filterable by project/environment. **Done.**
- Provider `default_tags` applies `Project=devops-production-platform`,
  `Environment=dev`, `ManagedBy=terraform` to every resource automatically.
- Naming via `name_prefix` (e.g. `devops-lab-vpc`, `devops-lab-alb-sg`).

### 4. Expose only needed outputs
**Evidence required:** root module has no unnecessary coupling. **Done.**
- Module outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`,
  `security_group_ids` (map). Root re-exposes these; callers use outputs, not internals.

### 5. Rebuild from clean
**Evidence required:** apply completes without console changes. **Done (via Week 5).**
- Week 5 proved `destroy`→`apply` rebuilds the network from code with no console steps;
  the module now produces that same network. A full module-based rebuild is exercised
  again in Week 8's rebuild challenge.

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
