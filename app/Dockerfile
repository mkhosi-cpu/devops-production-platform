FROM python:3.12-slim

WORKDIR /app

# Install runtime deps first for better layer caching.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Build metadata; overridden at deploy time by CI (--build-arg / env).
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION

EXPOSE 8080

# Matches the devops-lab-app-sg rule (TCP 8080 from the ALB SG only).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:8080/health').status==200 else 1)"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
