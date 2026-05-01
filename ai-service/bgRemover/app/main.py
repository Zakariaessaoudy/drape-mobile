from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from app.remover import remove_background
from app.storage import upload_to_s3
import uvicorn

app = FastAPI(
    title="Fashion Background Remover",
    description="Supprime le fond d'une image et stocke le résultat sur S3",
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
    """Génère une URL signée fraîche pour afficher une image"""
    signed_url = s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.AWS_S3_BUCKET, "Key": s3_key},
        ExpiresIn=3600,
    )
    return {"url": signed_url}
@app.post("/remove-bg")
async def remove_bg(
    file: UploadFile = File(...),
    user_id: str = Form(..., description="ID de l'utilisateur"),
):
    """
    - Reçoit une image + un user_id
    - Supprime le fond
    - Stocke le PNG transparent sur S3
    - Retourne l'URL S3 et les métadonnées
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Le fichier doit être une image")

    contents = await file.read()

    # Suppression du fond
    try:
        result_bytes = remove_background(contents)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur traitement image : {str(e)}")

    # Upload S3
    try:
        s3_result = upload_to_s3(result_bytes, user_id, file.filename)
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {
        "success": True,
        "user_id": user_id,
        "file_id": s3_result["file_id"],
        "url": s3_result["url"],
        "s3_key": s3_result["s3_key"],
    }


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=False)