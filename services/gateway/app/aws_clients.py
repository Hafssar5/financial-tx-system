import aioboto3
from .config import settings

_session = aioboto3.Session(region_name=settings.aws_region)

def dynamodb():
    return _session.resource("dynamodb", endpoint_url=settings.aws_endpoint)

def kinesis():
    return _session.client("kinesis", endpoint_url=settings.aws_endpoint)