"""DevOps Lab sample application.

A deliberately small FastAPI service used as the deployment target across the
whole roadmap. It exposes the hooks the platform needs:

- ``/``        a human-visible landing page
- ``/health``  liveness/readiness probe for the ALB and later Kubernetes
- ``/version`` reports the running build, injected via the APP_VERSION env var
              (lets release/rollback demos prove which image is live)
"""
import os

from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse

# Injected at deploy time (CI sets this to the git SHA or release tag).
APP_VERSION = os.getenv("APP_VERSION", "dev")

app = FastAPI(title="DevOps Lab App", version=APP_VERSION)


@app.get("/", response_class=HTMLResponse)
def root() -> str:
    return f"""<!doctype html>
<html lang="en">
  <head><meta charset="utf-8"><title>DevOps Lab App</title></head>
  <body style="font-family: system-ui; margin: 3rem;">
    <h1>DevOps Lab App</h1>
    <p>Running version: <strong>{APP_VERSION}</strong></p>
    <p>Endpoints: <code>/health</code>, <code>/version</code></p>
  </body>
</html>"""


@app.get("/health")
def health() -> JSONResponse:
    """Return 200 when the service is up. Used by ALB/K8s health checks."""
    return JSONResponse({"status": "ok"})


@app.get("/version")
def version() -> JSONResponse:
    return JSONResponse({"version": APP_VERSION})
