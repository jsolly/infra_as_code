import boto3
from typing import Any, Dict


class StorageHelper:
    def __init__(self, bucket_name: str, table_name: str):
        self.s3 = boto3.client("s3")
        self.dynamodb = boto3.resource("dynamodb")
        self.bucket_name = bucket_name
        self.table_name = table_name
        self.table = self.dynamodb.Table(table_name)

    def store_image(
        self, key: str, image_data: bytes, content_type: str = "image/jpeg"
    ) -> None:
        """Store an image in S3"""
        self.s3.put_object(
            Bucket=self.bucket_name, Key=key, Body=image_data, ContentType=content_type
        )

    def save_metadata(self, metadata: Dict[str, Any]) -> None:
        """Save metadata to DynamoDB"""
        self.table.put_item(Item=metadata)
