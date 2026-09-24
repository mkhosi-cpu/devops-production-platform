# How-to 05 — Terraform linting, security scanning, and docs (Week 7)

Automated checks that catch mistakes and insecure config **before** apply, plus
auto-generated module docs. These become the CI pipeline in Month 4.

## Tools

| Tool | Purpose |
|---|---|
| `terraform fmt` | Consistent formatting |
| `terraform validate` | Syntax / internal consistency (needs `init` first) |
| **tflint** | Terraform best-practice linting (deprecated syntax, bad values, missing tags) |
| **Trivy** | IaC **security** scan (open SGs, unencrypted resources, missing logging…) |
| **terraform-docs** | Generates the module inputs/outputs docs |

## Install (Windows, no admin)

Binaries drop into a user folder that's on your PATH:

```powershell
# One-off: download latest releases into C:\Users\MABASO\bin (see session history for
# the scripted version). Then add the folder to your USER PATH once:
[Environment]::SetEnvironmentVariable("Path", "C:\Users\MABASO\bin;" + `
  [Environment]::GetEnvironmentVariable("Path","User"), "User")
# Open a NEW terminal so PATH takes effect, then verify:
tflint --version; trivy --version; terraform-docs version
```
(Or `choco install tflint terraform-docs -y` in an elevated shell; Trivy via its installer.)

## Run the checks

```powershell
cd C:\devops-production-platform\terraform

# 1. Formatting (all files, recursive)
terraform fmt -check -recursive

# 2. Validate each environment (must be init'd)
cd environments\dev;  terraform init -backend=false; terraform validate; cd ..\..
cd environments\prod; terraform init -backend=false; terraform validate; cd ..\..

# 3. Lint (bundled terraform ruleset; add AWS plugin via .tflint.hcl + `tflint --init`)
tflint --recursive

# 4. Security scan (reads .trivyignore for accepted exceptions)
trivy config .
```

## Security triage workflow (the important habit)

A scan finding is not automatically a "fix" — you **triage**:

1. Run `trivy config .` → read each finding (severity, `AWS-####` id, `file:line`, the
   `avd.aquasec.com` link explaining the risk).
2. For each: **fix** genuine problems in the code, or **accept** ones that are intentional.
3. Record accepted ones in **`terraform/.trivyignore`** — one id per line, each with a
   comment explaining *why*. That file is the "documented exception explains the remaining
   risk" evidence.
4. Re-run → a clean `trivy config .` means "nothing unaddressed" (accepted items are
   suppressed). To review the raw list, temporarily move the ignore file:
   `Rename-Item .trivyignore _off; trivy config .; Rename-Item _off .trivyignore`.

**Example triage (this project):**
- AWS-0124 (SG rules lack descriptions) → **fixed** (added `description` to every rule).
- AWS-0104 (open egress `0.0.0.0/0`) → **accepted** (AWS default; scope in production).
- AWS-0164 (public subnets assign public IPs) → **accepted** (public tier is meant to be).
- AWS-0178 (no VPC flow logs) → **accepted/deferred** to the observability stage.

## Generate module docs

```powershell
terraform-docs markdown table --output-file README.md --output-mode inject modules/network
```
`--output-mode inject` updates the auto-generated section between markers in the module's
README, leaving your prose intact.

## Notes
- `trivy config .` requires the `.trivyignore` file to exist if referenced; it reads
  `.trivyignore` from the working directory by default.
- Keep these commands together (e.g. a `check.ps1`) so the same checks run locally and in CI.
