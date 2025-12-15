#!/bin/bash
# Bootstrap LocalStack with required AWS resources

echo "🚀 Bootstrapping LocalStack..."

# Wait for LocalStack to be ready
sleep 5

# Create Kinesis Stream
awslocal kinesis create-stream \
    --stream-name tx-stream \
    --shard-count 1 \
    2>/dev/null || echo "Stream already exists"

# Create DynamoDB Tables
awslocal dynamodb create-table \
    --table-name idempotency \
    --attribute-definitions AttributeName=idempotency_key,AttributeType=S \
    --key-schema AttributeName=idempotency_key,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    2>/dev/null || echo "Idempotency table already exists"

awslocal dynamodb create-table \
    --table-name saga_state \
    --attribute-definitions AttributeName=saga_id,AttributeType=S \
    --key-schema AttributeName=saga_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    2>/dev/null || echo "Saga table already exists"

# Create SQS Queues
awslocal sqs create-queue --queue-name notification-queue 2>/dev/null || true
awslocal sqs create-queue --queue-name fraud-alert-queue 2>/dev/null || true

# Create S3 Bucket for reports
awslocal s3 mb s3://tx-reports 2>/dev/null || true

echo "✅ LocalStack bootstrap complete!"

# List created resources
echo ""
echo "📋 Created Resources:"
echo "Kinesis Streams:"
awslocal kinesis list-streams
echo ""
echo "DynamoDB Tables:"
awslocal dynamodb list-tables
echo ""
echo "SQS Queues:"
awslocal sqs list-queues
