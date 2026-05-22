from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    AWS_ACCESS_KEY_ID: str | None = None
    AWS_SECRET_ACCESS_KEY: str | None = None
    AWS_REGION: str = "us-east-1"
    AWS_S3_BUCKET: str = "drape-wardrobe-images"
    WARDROBE_SERVICE_URL: str = "http://localhost:8080"
    WARDROBE_CALLBACK_SECRET: str = "local-ai-secret"
    IMAGE_PROCESS_TIMEOUT_SECONDS: int = 120

    class Config:
        env_file = ".env"


settings = Settings()
