import uuid, datetime as dt
from pydantic import BaseModel, Field, condecimal, constr

class TransactionRequest(BaseModel):
    idempotency_key: constr(min_length=6, max_length=64)
    source_account:  constr(min_length=3, max_length=30)
    destination_account: constr(min_length=3, max_length=30)
    amount: condecimal(gt=0, lt=1_000_000)
    currency: constr(min_length=3, max_length=3) = "USD"

class TransactionAccepted(BaseModel):
    transaction_id: uuid.UUID = Field(..., description="Server-generated UUID")
    status: str = "ACCEPTED"
    timestamp: dt.datetime = Field(default_factory=dt.datetime.utcnow)