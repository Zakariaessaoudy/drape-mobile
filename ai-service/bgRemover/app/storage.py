import boto3
import uuid
import unicodedata
from datetime import datetime
from botocore.exceptions import ClientError
from app.config import settings


s3_client = boto3.client(
    "s3",
    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    region_name=settings.AWS_REGION,
)


def sanitize_ascii(text: str) -> str:
    """Convertit les caractères non-ASCII en ASCII (é→e, ç→c, etc.)"""
    normalized = unicodedata.normalize("NFKD", text)
    return normalized.encode("ascii", "ignore").decode("ascii")


def upload_to_s3(image_bytes: bytes, user_id: str, original_filename: str) -> dict:
    """
    Upload le PNG transparent vers S3.
    Chemin : users/{user_id}/{date}/{uuid}.png
    """
    date_prefix = datetime.utcnow().strftime("%Y-%m-%d")
    file_id = str(uuid.uuid4())
    s3_key = f"users/{user_id}/{date_prefix}/{file_id}.png"

    # S3 metadata n'accepte que l'ASCII — on nettoie le nom du fichier
    safe_filename = sanitize_ascii(original_filename or "unknown.png")

    try:
        s3_client.put_object(
            Bucket=settings.AWS_S3_BUCKET,
            Key=s3_key,
            Body=image_bytes,
            ContentType="image/png",
            Metadata={
                "user_id": user_id,
                "original_filename": safe_filename,
            },
        )
    except ClientError as e:
        raise RuntimeError(f"Erreur upload S3 : {e.response['Error']['Message']}")

    url = f"https://{settings.AWS_S3_BUCKET}.s3.{settings.AWS_REGION}.amazonaws.com/{s3_key}"

    return {
        "file_id": file_id,
        "s3_key": s3_key,
        "url": url,
        "user_id": user_id,
    }