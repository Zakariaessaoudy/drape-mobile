import io
import pytest
from unittest.mock import patch
from fastapi.testclient import TestClient
from PIL import Image
from app.main import app

client = TestClient(app)


def make_test_image() -> bytes:
    img = Image.new("RGB", (100, 100), color=(200, 100, 50))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


FAKE_S3_RESULT = {
    "file_id": "abc-123",
    "s3_key": "users/user_42/2024-01-01/abc-123.png",
    "url": "https://fashion-bg-remover.s3.eu-west-3.amazonaws.com/users/user_42/2024-01-01/abc-123.png",
    "user_id": "user_42",
}


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("app.main.upload_to_s3", return_value=FAKE_S3_RESULT)
def test_remove_bg_returns_s3_url(mock_s3):
    img_bytes = make_test_image()
    response = client.post(
        "/remove-bg",
        data={"user_id": "user_42"},
        files={"file": ("veste.jpg", img_bytes, "image/jpeg")},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["user_id"] == "user_42"
    assert body["file_id"] == "abc-123"
    assert "s3.eu-west-3.amazonaws.com" in body["url"]


@patch("app.main.upload_to_s3", return_value=FAKE_S3_RESULT)
def test_remove_bg_rejects_non_image(mock_s3):
    response = client.post(
        "/remove-bg",
        data={"user_id": "user_42"},
        files={"file": ("test.txt", b"hello", "text/plain")},
    )
    assert response.status_code == 400


@patch("app.main.upload_to_s3", side_effect=RuntimeError("S3 down"))
def test_remove_bg_handles_s3_error(mock_s3):
    img_bytes = make_test_image()
    response = client.post(
        "/remove-bg",
        data={"user_id": "user_42"},
        files={"file": ("veste.jpg", img_bytes, "image/jpeg")},
    )
    assert response.status_code == 500
    assert "S3 down" in response.json()["detail"]