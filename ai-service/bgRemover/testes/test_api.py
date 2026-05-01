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
    "item_id": "item_123",
    "s3_key": "users/user_42/items/item_123.png",
    "url": "https://drape-wardrobe-images.s3.us-east-1.amazonaws.com/users/user_42/items/item_123.png",
    "user_id": "user_42",
}


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("app.main.upload_to_s3", return_value=FAKE_S3_RESULT)
@patch("app.main.notify_wardrobe")
@patch("app.main.remove_background", return_value=b"png")
def test_background_removal_accepts_request(mock_remove, mock_callback, mock_s3):
    img_bytes = make_test_image()
    response = client.post(
        "/api/background-removal",
        data={"itemId": "item_123", "userId": "user_42"},
        files={"image": ("veste.jpg", img_bytes, "image/jpeg")},
    )
    assert response.status_code == 202
    body = response.json()
    assert body["accepted"] is True
    assert body["itemId"] == "item_123"
    mock_callback.assert_called_once_with("item_123", image_url=FAKE_S3_RESULT["url"], status="READY")


@patch("app.main.upload_to_s3", return_value=FAKE_S3_RESULT)
def test_background_removal_rejects_non_image(mock_s3):
    response = client.post(
        "/api/background-removal",
        data={"itemId": "item_123", "userId": "user_42"},
        files={"image": ("test.txt", b"hello", "text/plain")},
    )
    assert response.status_code == 400


@patch("app.main.upload_to_s3", side_effect=RuntimeError("S3 down"))
@patch("app.main.notify_wardrobe")
@patch("app.main.remove_background", return_value=b"png")
def test_background_task_reports_failure(mock_remove, mock_callback, mock_s3):
    img_bytes = make_test_image()
    response = client.post(
        "/api/background-removal",
        data={"itemId": "item_123", "userId": "user_42"},
        files={"image": ("veste.jpg", img_bytes, "image/jpeg")},
    )
    assert response.status_code == 202
    mock_callback.assert_called_once_with("item_123", image_url=None, status="FAILED")
