from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    ENVIRONMENT: str = "local"
    PORT: int = 7860

    AWS_ACCESS_KEY_ID: str | None = None
    AWS_SECRET_ACCESS_KEY: str | None = None
    AWS_REGION: str = "us-east-1"
    AWS_S3_BUCKET: str = "drape-wardrobe-images"
    AWS_ENDPOINT_URL: str | None = None

    WARDROBE_SERVICE_URL: str = "http://localhost:8084"
    WARDROBE_CALLBACK_SECRET: str = "local-ai-secret"
    IMAGE_PROCESS_TIMEOUT_SECONDS: int = 120

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
        case_sensitive=True,
    )

    @property
    def has_s3_credentials(self) -> bool:
        return bool(self.AWS_ACCESS_KEY_ID and self.AWS_SECRET_ACCESS_KEY)


settings = Settings()
