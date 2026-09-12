# Week 1 — AWS Account Safety and IAM

**Stage:** Month 1 · AWS Architecture and Operations
**Status:** In progress — fill in the evidence below, then mark complete.

> Reminder from the roadmap: a task counts as done only when its evidence is
> committed or recorded here. Watching a lesson does not count.
> Keep account IDs, hostnames, tokens, and credentials safe — redact anything
> sensitive before committing.

---

## Evidence checklist

### 1. Dedicated lab account or clearly separated lab environment
- **Account ID (masked):** `********7672`
- **Primary region:** `us-east-1` (US East, N. Virginia)
- **How this is isolated from any employer/production use:** `____________________`
  _(Open item: confirm this is a dedicated lab account, not a shared/org account.)_

### 2. MFA enabled, root not used for daily work

**Root user**
- **Written verification (no sensitive details):** Confirmed via the AWS console
  Security recommendations panel: **"Root user has MFA"** shown with a green
  check, and **Security recommendations: 0** outstanding. Root user is not used
  for daily work.
- **Screenshot:** `docs/evidence/week01-root-mfa.png` — safe to commit as-is
  (no account ID or sensitive details visible).

**IAM users inventory** (from the IAM console)

| User | MFA | Notes |
|---|---|---|
| ITAdmin | Virtual MFA device (created 2025-01-19) | Password age ~600 days; last active ~304 days ago |
| KelezaIT | **None** | In 1 group; last active ~348 days ago |

**Working (daily-use) IAM user:** `ITAdmin`
- **MFA verification:** ITAdmin has a **Virtual MFA device** (created 2025-01-19),
  confirmed in the IAM console. This is the identity used for daily work; the root
  user is not used for daily operations.
- **Follow-up (Week 4 IAM review):** `KelezaIT` is unused (last active ~348 days,
  no MFA) — disable or remove it. Review ITAdmin's group/permissions for least
  privilege and rotate its ~600-day-old password.

- **Screenshots to save (REDACT FIRST):**
  - `docs/evidence/week01-iam-users.png` — usernames are fine to keep only if they
    are not employer/organizational identities.
  - `docs/evidence/week01-itadmin-mfa.png` — **the ARN in this image contains the
    full 12-digit account ID; mask it to the last 4 (….7672) before saving.**

### 3. AWS Budget and billing alert created before provisioning
- **Budget name:** `DevOps Bill`
- **Monthly threshold (USD):** `$1.00` (tripwire — alerts on essentially any spend)
- **Alert threshold(s):** `Actual cost > $0.01 (1%)` — one alert configured, status "Not exceeded".
- **Alert destination (email):** Two email recipients configured — a project/domain
  address (`K***@keleza.site`) and a personal backup (`m***@gmail.com`).
  _(Addresses masked on purpose: this repo is a public portfolio. Keep full emails
  out of committed files and screenshots.)_
- **Screenshots:** `docs/evidence/week01-budget.png`, `docs/evidence/week01-budget-alert.png`
  — safe to commit (no account ID visible).
- **Budget history:** `docs/evidence/week01-budget-history.csv` — committed. Confirms
  the budget has been active with negligible spend ($0.23 in 2025-09, $0.00 since).
- **Note:** a $1 budget is a good early tripwire for Week 1, but will alert almost
  immediately once EKS / NAT / load balancers start (Month 3). Raise the threshold
  when the lab reaches chargeable infrastructure.

### 4. AWS CLI access via short-lived credentials / IAM Identity Center
**Status: NOT DONE — identity mismatch to resolve.**

- The CLI currently authenticates as `user/KelezaIT` (long-lived IAM access keys,
  `AIDA…` UserId prefix, **no MFA**). This contradicts the console working-user
  decision (ITAdmin) and the task's intent (short-lived credentials).
- **To resolve (recommended):** configure the CLI to use **ITAdmin** (which has MFA),
  ideally via an MFA-backed session token (`aws sts get-session-token`), then re-run
  the check so the ARN shows `user/ITAdmin`.
- **Access method (target):** `____________________`
- **Confirmation no long-lived keys are stored in Git:** `____________________`
  (keys must live in `~/.aws/credentials`, never in the repo)
- **`aws sts get-caller-identity` output (account ID MASKED):**

```json
{
  "UserId": "AIDA…redacted…",
  "Account": "********7672",
  "Arn": "arn:aws:iam::********7672:user/KelezaIT"
}
```
_(Current, pending fix. Update to ITAdmin once the CLI identity is corrected.)_

### 5. First architecture diagram and expected monthly cost
- **Diagram file:** `docs/diagrams/month-01-architecture.md` (Mermaid, renders on GitHub) —
  committed. Covers VPC/2 AZs, ALB, Auto Scaling app, S3, CloudWatch, Route 53/ACM, IAM.
- **Estimated monthly cost (USD) and assumptions:** **~$0 effective** via a
  create/destroy-per-session model (no always-on infrastructure). Per-running-hour
  cost breakdown and caveats are in the diagram file. Teardown must be verified each
  session; `DevOps Bill` (>$0.01) is the safety net.

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`

---

## Completion
When every item above is filled in and committed:
- [ ] All five evidence items recorded
- [ ] Diagram committed under `docs/diagrams/`
- [ ] README status updated
- [ ] Roadmap `.docx` Week 1 marked done (already done ✅)
