# Week 7 — Environments, Testing, and Review

**Stage:** Month 2 · Terraform and Reusable Infrastructure
**Status:** Not started.

> Evidence rule: a task counts as done only when its evidence is committed here.
> State in S3; secrets/state out of Git.

Uses the Week 6 `modules/network` module to stand up **separate dev and prod-style
environments** from the same code, plus automated checks and review discipline.

---

## Evidence checklist

### 1. Separate dev and prod-style configs without duplicating modules
**Evidence required:** environment differences are explicit. **Done.**
- **Structure:** `terraform/environments/dev` and `.../prod` — each a thin root calling the
  shared `modules/network`, with its **own S3 state key** (`env/dev/…`, `env/prod/…`).
- **Same module, different inputs:** dev `name_prefix=devops-lab`, `10.0.0.0/16`,
  `Environment=dev`; prod `name_prefix=devops-lab-prod`, `10.1.0.0/16`, `Environment=prod`.
  Differences live plainly in each folder's `main.tf` — no duplicated resource code.
- Dev adopted the existing live network (state migrated → `plan` = No changes); prod
  `plan` = 16 to add (validated, not applied → $0). Chose folders over workspaces (ADR 0004).

### 2. Add linting, security checks, and docs generation
**Evidence required:** automated checks run locally or in CI. **Done.**
- **Tools:** `terraform fmt`, `terraform validate` (per env), **tflint** (recommended
  ruleset via `.tflint.hcl`), **Trivy** (`trivy config`), **terraform-docs** (auto-generates
  the module README tables). Bundled into `terraform/check.ps1`.
- **Security triage:** Trivy's initial 24 findings → fixed AWS-0124 (added SG rule
  descriptions); accepted + documented AWS-0104/0164/0178 in `terraform/.trivyignore` with
  justifications. Result: `trivy config .` reports **0 unaddressed findings**.
- tflint flagged the module missing `required_version`/`required_providers` → fixed
  (`modules/network/versions.tf`); now clean. How-to: `docs/how-to/05-*`.

### 3. Review plans for destructive/unexpected changes before apply
**Evidence required:** PR template includes an infrastructure review checklist.
- **`.github/` PR template with an IaC review checklist:** `____________________`
- **Example plan review:** `____________________`

### 4. Test a safe module version change and rollback
**Evidence required:** state and resources remain consistent.
- **Change made + rollback:** `____________________`

### 5. Write two architecture decision records
**Evidence required:** ADRs state context, decision, consequence.
- **ADRs added (context/decision/consequence):** `____________________`
- _Note: ADRs 0001–0003 already exist; add two more for Month 2 choices._

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`
