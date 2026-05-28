import json
import logging
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeoutError
from urllib.error import URLError
from urllib.request import Request, urlopen

from fastapi import BackgroundTasks, FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.remover import remove_background
from app.storage import create_presigned_url, upload_to_s3
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Fashion Background Remover",
    description="Removes image backgrounds and stores the result in S3",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/image/{s3_key:path}")
def get_image_url(s3_key: str):
    return {"url": create_presigned_url(s3_key)}


@app.post("/api/background-removal", status_code=202)
async def start_background_removal(
    background_tasks: BackgroundTasks,
    itemId: str = Form(...),
    userId: str = Form(...),
    image: UploadFile = File(...),
):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="The uploaded file must be an image")

    contents = await image.read()
    logger.info(
        "Accepted background-removal job itemId=%s userId=%s filename=%s size=%s",
        itemId,
        userId,
        image.filename,
        len(contents),
    )

    background_tasks.add_task(
        process_image_and_callback,
        itemId,
        userId,
        contents,
        image.filename,
    )

    return {"accepted": True, "itemId": itemId, "userId": userId}


def process_image_and_callback(
    item_id: str,
    user_id: str,
    image_bytes: bytes,
    filename: str | None,
) -> None:
    try:
        logger.info("Started processing item %s", item_id)
        with ThreadPoolExecutor(max_workers=1) as executor:
            future = executor.submit(remove_background, image_bytes)
            result_bytes = future.result(
                timeout=settings.IMAGE_PROCESS_TIMEOUT_SECONDS,
            )

        s3_result = upload_to_s3(
            result_bytes,
            user_id,
            item_id,
            filename or "item.png",
        )
        logger.info("Upload complete for item %s", item_id)
        notify_wardrobe(item_id, image_url=s3_result["url"], status="READY")
        logger.info("Item %s marked READY", item_id)
    except FutureTimeoutError:
        logger.exception("Background removal timed out for item %s", item_id)
        notify_wardrobe(item_id, image_url=None, status="FAILED")
    except Exception:
        logger.exception("Background removal failed for item %s", item_id)
        notify_wardrobe(item_id, image_url=None, status="FAILED")


def notify_wardrobe(item_id: str, image_url: str | None, status: str) -> None:
    callback_url = f"{settings.WARDROBE_SERVICE_URL.rstrip('/')}/api/items/{item_id}/image"
    payload = json.dumps({"imageUrl": image_url, "status": status}).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "X-AI-Service-Secret": settings.WARDROBE_CALLBACK_SECRET,
    }
    request = Request(callback_url, data=payload, headers=headers, method="PATCH")

    try:
        with urlopen(request, timeout=10) as response:
            if response.status >= 400:
                logger.error(
                    "Wardrobe callback failed for item %s with status %s",
                    item_id,
                    response.status,
                )
            else:
                logger.info(
                    "Wardrobe callback succeeded for item %s with status %s",
                    item_id,
                    status,
                )
    except URLError:
        logger.exception("Could not call Wardrobe Service for item %s", item_id)


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=False)
