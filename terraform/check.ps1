# Runs all Terraform quality + security checks. Use locally before committing;
# the same commands become the CI pipeline in Month 4.
# Requires: terraform, tflint, trivy on PATH. Run from the terraform/ folder.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Step($name, $block) {
  Write-Host "== $name ==" -ForegroundColor Cyan
  & $block
  if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $name" -ForegroundColor Red; exit 1 }
}

Step "terraform fmt"        { terraform fmt -check -recursive }
Step "tflint"               { tflint --recursive }
Step "trivy (security)"     { trivy config . }
foreach ($e in @("dev", "prod")) {
  Step "terraform validate ($e)" { terraform -chdir="environments/$e" validate }
}

Write-Host "All checks passed." -ForegroundColor Green
