import uuid, json
from fastapi.testclient import TestClient

from app.main import app   # imports the in-memory FastAPI instance

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}

def test_idempotency():
    data = {
        "idempotency_key": str(uuid.uuid4()),
        "source_account": "ACC-001",
        "destination_account": "ACC-002",
        "amount": 1.23,
        "currency": "USD",
    }
    # first call => 202
    r1 = client.post("/api/v1/transactions", json=data)
    assert r1.status_code == 202

    # duplicate => 409
    r2 = client.post("/api/v1/transactions", json=data)
    assert r2.status_code == 409