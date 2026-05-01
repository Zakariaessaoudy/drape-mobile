import io
from rembg import remove
from PIL import Image


def remove_background(image_bytes: bytes) -> bytes:
    """
    Prend les bytes d'une image (JPG, PNG, WEBP...)
    et retourne les bytes d'un PNG avec fond transparent.
    """
    result = remove(image_bytes)

    img = Image.open(io.BytesIO(result)).convert("RGBA")

    output = io.BytesIO()
    img.save(output, format="PNG")
    output.seek(0)

    return output.read()