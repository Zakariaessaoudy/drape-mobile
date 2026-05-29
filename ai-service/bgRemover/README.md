---
title: Drape BG Remover
emoji: ":shirt:"
colorFrom: purple
colorTo: gray
sdk: docker
app_port: 7860
---

# Drape BG Remover

FastAPI service for Drape item background removal.

Required Hugging Face Space secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_S3_BUCKET
WARDROBE_SERVICE_URL
WARDROBE_CALLBACK_SECRET
```

Health check:

```text
/health
```
