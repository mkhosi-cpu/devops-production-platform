from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health_returns_ok():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_version_reports_a_value():
    r = client.get("/version")
    assert r.status_code == 200
    assert "version" in r.json()


def test_root_serves_html():
    r = client.get("/")
    assert r.status_code == 200
    assert "DevOps Lab App" in r.text
