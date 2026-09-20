# Module: network

Builds a VPC across two AZs with public and private subnets, an Internet Gateway,
public/private route tables, three least-privilege security groups (ALB / app / admin),
and a free S3 Gateway endpoint for private-subnet egress to S3.

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name_prefix` | Prefix for named resources (VPC, IGW, SGs, endpoint) | string | — |
| `aws_region` | Region, used to build the S3 endpoint service name | string | — |
| `vpc_cidr` | VPC CIDR block | string | — |
| `az_a`, `az_b` | The two availability zones | string | — |
| `public_subnet_a_cidr` / `_b_cidr` | Public subnet CIDRs | string | — |
| `private_subnet_a_cidr` / `_b_cidr` | Private subnet CIDRs | string | — |
| `app_port` | App port allowed from the ALB SG | number | 8080 |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | The VPC ID |
| `public_subnet_ids` | List of the two public subnet IDs |
| `private_subnet_ids` | List of the two private subnet IDs |
| `security_group_ids` | Map: `alb` / `app` / `admin` → SG ID |

## Example

```hcl
module "network" {
  source                = "./modules/network"
  name_prefix           = "devops-lab"
  aws_region            = "us-east-1"
  vpc_cidr              = "10.0.0.0/16"
  az_a                  = "us-east-1a"
  az_b                  = "us-east-1b"
  public_subnet_a_cidr  = "10.0.0.0/24"
  public_subnet_b_cidr  = "10.0.1.0/24"
  private_subnet_a_cidr = "10.0.10.0/24"
  private_subnet_b_cidr = "10.0.11.0/24"
}
```

## Notes
- The private route table's S3 route is owned by the endpoint (`route_table_ids`), so the
  route table uses `ignore_changes = [route]` to avoid drift.
- Keep everything in the VPC under Terraform — unmanaged resources cause drift and can
  block `terraform destroy`.
