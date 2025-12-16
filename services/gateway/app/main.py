import uuid, json
from fastapi import FastAPI, HTTPException, status, Depends
from botocore.exceptions import ClientError
from loguru import logger

from .config import settings
from .schemas import TransactionRequest, TransactionAccepted
from .aws_clients import dynamodb, kinesis

# ─────────────────────────────────────────────
# JSON log file (rotates at 10 MB)
logger.add(
    "logs/gateway_{time}.log",
    rotation="10 MB",
    serialize=True,
    enqueue=True,
)
# ─────────────────────────────────────────────
app = FastAPI(
    title="Transaction Gateway",
    version="0.1.0",
    description="REST entry-point for the financial transaction system",
)

# Small health probe -----------------------------------------------------------
@app.get("/health", tags=["meta"])
async def health():
    return {"status": "ok"}

# Dependencies (injected so we can stub during tests) --------------------------
async def get_ddb():
    yield dynamodb().Table(settings.idempotency_table)

async def get_kinesis():
    yield kinesis()

# Business route ---------------------------------------------------------------
@app.post(
    "/api/v1/transactions",
    response_model=TransactionAccepted,
    status_code=status.HTTP_202_ACCEPTED,
    tags=["transactions"],
)
async def create_transaction(
    body: TransactionRequest,
    ddb = Depends(get_ddb),
    kin = Depends(get_kinesis),
):
    tx_id = str(uuid.uuid4())

    # 1. Idempotency guard -------------------------------------------
    try:
        ddb.put_item(
            Item={"idempotency_key": body.idempotency_key, "tx_id": tx_id},
            ConditionExpression="attribute_not_exists(idempotency_key)",
        )
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code == "ConditionalCheckFailedException":
            raise HTTPException(409, "Duplicate request – idempotency_key used")
        logger.error("DynamoDB error: {}", e)
        raise HTTPException(500, "Datastore error")

    # 2. Publish event to Kinesis ------------------------------------
    await kin.put_record(
        StreamName=settings.kinesis_stream,
        Data=json.dumps(body.model_dump()).encode(),
        PartitionKey=body.source_account,
    )

    # 3. Return immediate 202 ----------------------------------------
    return TransactionAccepted(transaction_id=tx_id)

# Stand-alone start for `python -m app.main`
if __name__ == "__main__":         # useful for local debugging w/o Docker
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.gateway_host,
        port=settings.gateway_port,
        log_level=settings.log_level,
        reload=False,
    )