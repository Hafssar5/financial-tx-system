-- =============================================
-- Financial Transaction System - Database Schema
-- =============================================

-- Transaction Log (main transaction record)
CREATE TABLE IF NOT EXISTS transaction_log (
    tx_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(64) UNIQUE NOT NULL,
    source_account VARCHAR(30) NOT NULL,
    destination_account VARCHAR(30) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ledger Accounts (account balances)
CREATE TABLE IF NOT EXISTS ledger_accounts (
    account_id VARCHAR(30) PRIMARY KEY,
    balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fraud Cases (flagged transactions)
CREATE TABLE IF NOT EXISTS fraud_cases (
    case_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tx_id UUID REFERENCES transaction_log(tx_id),
    reason VARCHAR(500) NOT NULL,
    severity VARCHAR(20) DEFAULT 'MEDIUM',
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Outbox (for event-driven communication)
CREATE TABLE IF NOT EXISTS outbox (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_type VARCHAR(50) NOT NULL,
    aggregate_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_transaction_status ON transaction_log(status);
CREATE INDEX idx_transaction_created ON transaction_log(created_at);
CREATE INDEX idx_outbox_unprocessed ON outbox(processed) WHERE processed = FALSE;
CREATE INDEX idx_fraud_status ON fraud_cases(status);

-- Insert sample accounts
INSERT INTO ledger_accounts (account_id, balance, currency) VALUES
    ('ACC-001', 10000.00, 'USD'),
    ('ACC-002', 5000.00, 'USD'),
    ('ACC-003', 25000.00, 'USD')
ON CONFLICT DO NOTHING;

-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trg_transaction_updated
    BEFORE UPDATE ON transaction_log
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_account_updated
    BEFORE UPDATE ON ledger_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DO $$
BEGIN
    RAISE NOTICE 'Database initialization complete!';
END $$;
