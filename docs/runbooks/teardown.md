# Runbook — Lab Teardown Checklist

**Purpose:** After every lab session, remove all chargeable AWS resources so the
create/destroy model keeps effective cost at ~$0. Some resources (NAT Gateway,
Elastic IPs, EBS) bill the moment they exist, and orphaned resources are the usual
surprise bill — so this runs *every* session, not just at month end.

**When to run:** At the end of any session that created infrastructure, and always
before ticking a "teardown tested" evidence item.

**Safety net:** The `DevOps Bill` budget alerts at actual cost > $0.01, so any spend
that survives teardown will trigger an email.

---

## 1. Prefer Terraform destroy (from Month 2 onward)

If the environment was built with Terraform, this is the primary path:

```bash
terraform plan -destroy      # review what will be removed
terraform destroy            # confirm, then apply
```

Then still run the verification in section 3 — `destroy` can miss resources created
outside Terraform (manual console changes, auto-created ENIs, etc.).

## 2. Manual teardown order (Month 1 / console-built resources)

Delete in dependency order — dependents first, network last:

- [ ] **Auto Scaling Group** — set desired/min to 0, then delete the ASG
- [ ] **EC2 instances** — terminate any remaining instances
- [ ] **Application Load Balancer** — delete the ALB (common orphan → hourly charge)
- [ ] **Target groups** — delete once the ALB is gone
- [ ] **NAT Gateway** — delete (billed per hour + data; delete promptly)
- [ ] **Elastic IPs** — release any allocated/unassociated EIPs (idle EIPs bill)
- [ ] **EBS volumes** — delete volumes not removed with instances
- [ ] **EBS snapshots / AMIs** — deregister AMIs and delete snapshots you created
- [ ] **Network interfaces (ENIs)** — delete leftover detached ENIs
- [ ] **S3** — empty and/or delete lab buckets if not intentionally retained
- [ ] **CloudWatch** — delete log groups / alarms created for the session (optional; low cost)
- [ ] **Route 53** — only delete records/zones if intentionally temporary
      (a retained hosted zone is a small standing cost — decide deliberately)
- [ ] **VPC / subnets / IGW / route tables / security groups** — delete last,
      after all attached resources are gone

## 3. Verify nothing chargeable remains

- [ ] EC2 console: no running/stopped instances, no ASGs, no launch templates in use
- [ ] EC2 → Load Balancers: none
- [ ] VPC → NAT Gateways: none; **Elastic IPs: none allocated**
- [ ] EC2 → Volumes / Snapshots: none you created remain
- [ ] S3: lab buckets empty or removed
- [ ] Billing → Cost Explorer / current month: no unexpected spend
- [ ] No `DevOps Bill` alert email pending after the session

## 4. Record the result

Log a one-line teardown note in the relevant weekly evidence file:

```
Teardown YYYY-MM-DD: destroyed <env>. Verified 0 chargeable resources. Spend $____.
```

---

**Known gotchas**
- ALB and NAT Gateway are the two resources most often forgotten — check them explicitly.
- Deleting a VPC fails while any ENI, NAT, or endpoint still references it; work top-down.
- Elastic IPs are free *while attached to a running instance* but bill once idle — release them.
