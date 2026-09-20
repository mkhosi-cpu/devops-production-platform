# How-to 03 — Adopt the network into Terraform, then recreate from code (Week 5)

Reproducible steps to (a) put an existing, manually-built network under Terraform via
**import**, and (b) prove it rebuilds from code with `destroy`/`apply`. Region: us-east-1.

> Evidence lives in `docs/week-05-*.md`; decisions in the ADRs. Config is in `terraform/`.
> **Import is only needed to adopt pre-existing resources.** Starting from scratch? Skip
> the import step and just `terraform apply` — the HCL creates everything.

---

## 0. Prerequisites
- **Terraform >= 1.10** (needed for S3 native `use_lockfile`). Upgrade via elevated
  `choco upgrade terraform -y`, or download from releases.hashicorp.com.
- **AWS CLI configured with an admin identity** (`aws configure`; here: ITAdmin). Terraform
  reuses these credentials — no keys in code.

## 1. Create the remote-state S3 bucket (one-time, persistent)
State must live somewhere durable, versioned, encrypted, and lockable. Create it once
(kept between sessions):

```powershell
$suffix = -join ((48..57)+(97..102) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$bucket = "devops-lab-tfstate-$suffix"
aws s3api create-bucket --bucket $bucket --region us-east-1
aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $bucket --server-side-encryption-configuration '{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}'
aws s3api put-public-access-block --bucket $bucket --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
Write-Output $bucket   # put this name in versions.tf backend
```

## 2. Foundation files (`terraform/`)
- `versions.tf` — `terraform` block: `required_version >= 1.10`, AWS provider `~> 5.0`,
  and the `backend "s3"` (bucket from step 1, `key`, `region`, `encrypt=true`,
  `use_lockfile=true`).
- `providers.tf` — `provider "aws" { region = var.aws_region }`.
- `variables.tf` — `aws_region` (default `us-east-1`).

```powershell
terraform init      # downloads provider, connects the S3 backend
terraform validate  # config is valid
```

## 3. Write the network HCL
Author `network.tf` describing every resource (VPC, subnets, IGW, route tables +
associations, security groups, S3 gateway endpoint). See the committed `terraform/network.tf`.
Key gotcha: the private route table's S3 prefix-list route is owned by the endpoint, so put
`lifecycle { ignore_changes = [route] }` on that route table to avoid drift.

## 4. Import blocks (adopt existing resources)
Create a temporary `imports.tf` with one block per resource, mapping the Terraform address
to the real AWS ID. Association IDs use `"<subnet-id>/<route-table-id>"`. Example:

```hcl
import { to = aws_vpc.lab                         id = "vpc-036e955def8d2cce6" }
import { to = aws_subnet.public_a                 id = "subnet-05f43f33812a1848a" }
import { to = aws_subnet.public_b                 id = "subnet-03543dc6e4464e849" }
import { to = aws_subnet.private_a                id = "subnet-068a3ae15d3f14360" }
import { to = aws_subnet.private_b                id = "subnet-03a69092909fcbf16" }
import { to = aws_internet_gateway.igw            id = "igw-02a50d015605ef2e2" }
import { to = aws_route_table.public              id = "rtb-0be98be5c11857af7" }
import { to = aws_route_table.private             id = "rtb-09c6ab1877aeb7a7c" }
import { to = aws_route_table_association.public_a  id = "subnet-05f43f33812a1848a/rtb-0be98be5c11857af7" }
import { to = aws_route_table_association.public_b  id = "subnet-03543dc6e4464e849/rtb-0be98be5c11857af7" }
import { to = aws_route_table_association.private_a id = "subnet-068a3ae15d3f14360/rtb-09c6ab1877aeb7a7c" }
import { to = aws_route_table_association.private_b id = "subnet-03a69092909fcbf16/rtb-09c6ab1877aeb7a7c" }
import { to = aws_security_group.alb              id = "sg-09d1b3fafba4eadd7" }
import { to = aws_security_group.app              id = "sg-0c2e860d40c311480" }
import { to = aws_security_group.admin            id = "sg-0f9f4ba19e0bf3f94" }
import { to = aws_vpc_endpoint.s3                 id = "vpce-00230d915ca9d2aec" }
```
(Real HCL `import` blocks use newlines, not `,` — shown compact here for brevity. The IDs
above are the *original* manually-built resources; use whatever IDs exist in your account.)

## 5. Import and verify
```powershell
terraform plan     # expect: "16 to import, 0 to add, 0 to change, 0 to destroy"
terraform apply    # performs the import into state; AWS is NOT changed
terraform plan     # expect: "No changes" — code, state, reality all in sync
```
If `plan` shows drift, edit `network.tf` to match reality (or accept benign changes like
added tags and let `apply` reconcile), then re-plan until clean.

## 6. Clean up
- Delete `imports.tf` (one-time; state now remembers the resources).
- Add `outputs.tf` for useful values (`terraform output`).

## 7. Prove recreate-from-code
```powershell
terraform destroy   # deletes all 16 resources (type: yes)
terraform apply     # rebuilds the identical network from network.tf (type: yes)
terraform output    # NEW resource IDs (the config is constant; IDs are disposable)
```
This is the payoff: the whole network is reproducible from code. Resource IDs change after
recreate — that's expected in the create/destroy model.

## Notes
- **Never commit** state or `*.tfvars` secrets (see `terraform/.gitignore`). **Do commit**
  `.terraform.lock.hcl` (pins provider versions).
- The state bucket is the one resource we keep between sessions; everything else can be
  destroyed and recreated freely.
