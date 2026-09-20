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
**Evidence required:** environment differences are explicit.
- **Structure chosen (e.g. `environments/dev`, `environments/prod`, or workspaces):** `____________________`
- **Same module, different inputs (CIDRs, sizes, name_prefix):** `____________________`
- _Ties to the ladder in `docs/environments.md` (Local→Dev→QA→Staging→Prod)._

### 2. Add linting, security checks, and docs generation where useful
**Evidence required:** automated checks run locally or in CI.
- **Tools (e.g. `terraform fmt -check`, `validate`, tflint, tfsec/checkov, terraform-docs):** `____________________`
- **How they run:** `____________________`

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
