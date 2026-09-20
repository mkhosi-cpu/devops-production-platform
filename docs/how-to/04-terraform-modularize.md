# How-to 04 — Refactor flat Terraform into a reusable module (Week 6)

How to move a working flat config into a module **without destroying live infrastructure**,
using `moved` blocks.

> Why modules: define resources once with inputs/outputs, then reuse for many
> environments (dev/prod) instead of copy-pasting. See `terraform/modules/network`.

## Steps

1. **Create the module** under `terraform/modules/<name>/`:
   - `main.tf` — the resources, with varying values replaced by `var.*`.
   - `variables.tf` — the inputs (CIDRs, AZs, `name_prefix`, region, ports…).
   - `outputs.tf` — the values callers need (ids, etc.).
   - `README.md` — inputs/outputs table + example.

2. **Call it from the root** (`main.tf`):
   ```hcl
   module "network" {
     source      = "./modules/network"
     name_prefix = "devops-lab"
     vpc_cidr    = "10.0.0.0/16"
     # ...
   }
   ```
   Point root `outputs.tf` at `module.network.*`. Delete the old flat `network.tf`.

3. **Add `moved` blocks** (`moved.tf`) — one per resource, old address → new module address:
   ```hcl
   moved {
     from = aws_vpc.lab
     to   = module.network.aws_vpc.lab
   }
   # ...one per resource
   ```
   These tell Terraform the resources only changed *address*, not identity — so it updates
   state instead of destroy/recreate.

4. **Init + plan + apply:**
   ```powershell
   terraform init            # registers the new module
   terraform plan            # expect: "N moved", 0 to add/change/destroy
   terraform apply           # records the moves in state (no infra change)
   ```

5. **Clean up:** delete `moved.tf` (one-time). Optionally add provider `default_tags`
   (Project/Environment/ManagedBy) for consistent, filterable tagging, then `apply`.

## Key points
- `plan` showing **0 add/change/destroy** (only moves) is the proof the refactor is purely
  organizational — the professional way to restructure live/prod Terraform.
- Keep module interfaces small; never hard-code environment values inside a module — pass
  them as variables so the module is reusable.
