# Sample Application

A deliberately small **FastAPI** service used as the deployment target across the whole
roadmap — containerized in Month 1, pushed to ECR and deployed to EKS in Month 3,
released/rolled back via CI/CD in Month 4, and monitored in Month 5.

## Endpoints

| Path | Purpose |
|---|---|
| `/` | Human-visible landing page showing the running version |
| `/health` | Returns `{"status":"ok"}` with HTTP 200 — used by ALB target health and Kubernetes probes |
| `/version` | Returns the running build (`APP_VERSION`) — lets release/rollback demos prove which image is live |

`APP_VERSION` is read from an environment variable (default `dev`) so CI can inject the
git SHA or release tag at deploy time.

**Port:** `8080` — matches the `devops-lab-app-sg` security-group rule.

## Run locally

```bash
cd app
python -m venv .venv && . .venv/Scripts/activate   # Windows; use .venv/bin/activate on Linux/Mac
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8080
# then open http://localhost:8080/
```

## Test

```bash
pip install -r requirements-dev.txt
pytest -q
```

## Build and run the container

```bash
docker build -t devops-lab-app:dev --build-arg APP_VERSION=dev .
docker run --rm -p 8080:8080 -e APP_VERSION=dev devops-lab-app:dev
curl -s localhost:8080/health   # {"status":"ok"}
```

## Notes / known limits

- No datastore yet — persistence is added only if a later week's workload needs it.
- TLS is terminated upstream (at the ALB / ingress), not in the app.
