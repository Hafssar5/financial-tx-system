from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env.dev", case_sensitive=False)

    # pulled from the .env file
    gateway_host: str = "0.0.0.0"
    gateway_port: int = 80
    log_level:   str = "info"

    aws_region:      str = "us-east-1"
    aws_endpoint:    str | None = None     # LocalStack URL in dev
    idempotency_table: str = "idempotency"
    kinesis_stream:    str = "tx-stream"

settings = Settings()   # singleton used across the app