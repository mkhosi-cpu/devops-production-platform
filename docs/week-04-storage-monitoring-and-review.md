# Week 4 — Storage, Monitoring, and Architecture Review

**Stage:** Month 1 · AWS Architecture and Operations (final week of Month 1)
**Status:** Not started.

> Evidence rule: a task counts as done only when its evidence is committed here.
> Keep account IDs and sensitive details out of committed files.
> Tear down chargeable resources each session — see `docs/runbooks/teardown.md`.

Closes out Month 1. Adds storage + observability to the platform, then a review and the
monthly completion gate.

---

## Cost note
Mostly cheap/free for a short session:

| Resource | Charge | Notes |
|---|---|---|
| S3 | Storage + requests (tiny) | Reachable from private subnets via the existing S3 gateway endpoint |
| CloudWatch | Metrics/logs/alarms | Basic usage is negligible; custom metrics/alarms have small costs |
| EC2/ALB (if re-created for a test) | Hourly | Only if you rebuild Week 3 infra to exercise an alarm; tear down after |

---

## Evidence checklist

### 1. Use S3 for an application artifact, log archive, or static asset
**Evidence required:** bucket access and encryption choices documented.
- **Bucket name / purpose:** `____________________`
- **Encryption (SSE-S3 / SSE-KMS):** `____________________`
- **Access model (private + endpoint / policy):** `____________________`
- _Tie-in: could store the app artifact here (previews the build-once/promote model)._

### 2. Create useful CloudWatch metrics, logs, and one alarm
**Evidence required:** alarm fires during a controlled test.
- **Metric(s) / log group(s):** `____________________`
- **Alarm definition:** `____________________`
- **Controlled test that made it fire:** `____________________`

### 3. Review IAM permissions and remove broad/temporary access
**Evidence required:** final policy rationale documented.
- **What was reviewed/removed (e.g. unused `KelezaIT`, broad policies):** `____________________`
- **Final least-privilege rationale:** `____________________`
- _Carry-over from Week 1: clean up the unused `KelezaIT` user (no MFA)._

### 4. Run a failure exercise (compute, network, or permission)
**Evidence required:** runbook captures detection, diagnosis, recovery, prevention.
- **Scenario:** `____________________`
- **Detection / diagnosis / recovery / prevention:** `____________________`
- _Record as a runbook under `docs/runbooks/`._

### 5. Present the design in a ~10-minute walkthrough
**Evidence required:** can explain each AWS component without notes.
- **Walkthrough notes / recording reference:** `____________________`
- _Use the Month 1 diagram (`docs/diagrams/month-01-architecture.md`)._

---

## Monthly completion gate (Month 1)
- [ ] Can explain how traffic reaches the app and where it can be blocked.
- [ ] Can replace a failed instance without manually rebuilding it. *(shown in Week 3)*
- [ ] Have cost alerts and a written teardown procedure. *(DevOps Bill + teardown.md)*
- [ ] Repository contains a diagram, test evidence, and troubleshooting notes.

**Decision:** Continue to Month 2 ☐  ·  Repeat selected work ☐  ·  Reduce scope ☐

---

## Weekly reflection
- **Confidence before (1–5):** `___`
- **Confidence after (1–5):** `___`
- **Main lesson:** `____________________`
- **What still isn't clear:** `____________________`

---

## Teardown
- [ ] Removed any chargeable resources created for tests (see `docs/runbooks/teardown.md`).
- [ ] Decided what to keep (S3 bucket, alarms) vs delete.
