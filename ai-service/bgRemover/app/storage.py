import boto3
import unicodedata
from botocore.exceptions import ClientError
from app.config import settings


client_kwargs = {"region_name": settings.AWS_REGION}
if settings.AWS_ACCESS_KEY_ID and settings.AWS_SECRET_ACCESS_KEY:
    client_kwargs["aws_access_key_id"] = settings.AWS_ACCESS_KEY_ID
    client_kwargs["aws_secret_access_key"] = settings.AWS_SECRET_ACCESS_KEY

s3_client = boto3.client("s3", **client_kwargs)


def sanitize_ascii(text: str) -> str:
    """Convertit les caractères non-ASCII en ASCII (é→e, ç→c, etc.)"""
    normalized = unicodedata.normalize("NFKD", text)
    return normalized.encode("ascii", "ignore").decode("ascii")


def upload_to_s3(image_bytes: bytes, user_id: str, item_id: str, original_filename: str) -> dict:
    """
    Upload le PNG transparent vers S3.
    Chemin : users/{user_id}/items/{item_id}.png
    """
    s3_key = f"users/{user_id}/items/{item_id}.png"

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
                "item_id": item_id,
                "original_filename": safe_filename,
            },
        )
    except ClientError as e:
        raise RuntimeError(f"Erreur upload S3 : {e.response['Error']['Message']}")

    url = f"https://{settings.AWS_S3_BUCKET}.s3.{settings.AWS_REGION}.amazonaws.com/{s3_key}"

    return {
        "item_id": item_id,
        "s3_key": s3_key,
        "url": url,
        "user_id": user_id,
    }


def create_presigned_url(s3_key: str, expires_in: int = 3600) -> str:
    return s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.AWS_S3_BUCKET, "Key": s3_key},
        ExpiresIn=expires_in,
    )
