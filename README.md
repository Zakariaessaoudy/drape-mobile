# Drape

Drape is a virtual wardrobe project with:

- `wardrobe-service`: Spring Boot API, PostgreSQL, JWT auth, items, categories, outfits.
- `ai-service/bgRemover`: FastAPI service that removes image backgrounds and uploads the result to S3.
- `client-mobile`: Flutter mobile app.

## Required Tools

- Docker Desktop
- Java 17
- Flutter SDK
- Python 3.11, only if running the AI service outside Docker

## Environment

Create a local `.env` at the repository root:

```bash
cp .env.example .env
```

Then fill:

- `APP_JWT_SECRET`: long random JWT secret.
- `AI_CALLBACK_SECRET`: shared secret between AI service and wardrobe service.
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET`: S3 upload credentials for the AI service.

Do not commit `.env`.

## Run Backend With Docker

From the repository root:

```bash
docker compose up --build
```

Services:

- Wardrobe API: `http://localhost:8084`
- AI API: `http://localhost:8000`
- PostgreSQL exposed locally on port `5434`

Health checks:

```bash
curl http://localhost:8000/health
curl http://localhost:8084/api/test/public
```

## Run Mobile App

Install dependencies:

```bash
cd client-mobile
flutter pub get
```

Deployed backend on Render + Hugging Face:

```bash
flutter run --dart-define=DRAPE_API_TARGET=production
```

The production URLs default to:

```text
Wardrobe API: https://drape-mobile.onrender.com
AI API: https://zkressaoudy-drape-bg-remover.hf.space
```

If you prefer direct overrides:

```bash
flutter run \
  --dart-define=WARDROBE_API_BASE_URL=https://drape-mobile.onrender.com \
  --dart-define=AI_API_BASE_URL=https://zkressaoudy-drape-bg-remover.hf.space
```

For a release APK using the deployed backend:

```bash
flutter build apk --release --dart-define=DRAPE_API_TARGET=production
```

iOS simulator:

```bash
flutter run --dart-define=DRAPE_API_TARGET=ios-simulator
```

Android emulator:

```bash
flutter run --dart-define=DRAPE_API_TARGET=android-emulator
```

Physical Android device over USB:

```bash
adb reverse tcp:8084 tcp:8084
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=DRAPE_API_TARGET=android-usb
```

With this USB setup, the app uses `127.0.0.1` on the phone and ADB forwards the
requests to your Mac, so your changing Wi-Fi IP does not matter.

Physical Android device over Wi-Fi/LAN:

```bash
flutter run \
  --dart-define=DRAPE_API_TARGET=android-device-mac \
  --dart-define=DRAPE_MAC_HOST_IP=192.168.1.166
```

Direct override if needed:

```bash
flutter run --dart-define=DRAPE_API_HOST=192.168.1.166
```

## Main API Flow

1. Mobile registers/logs in through `POST /api/auth/register` or `POST /api/auth/login`.
2. Mobile stores the JWT locally.
3. Mobile creates an item with `POST /api/items` using multipart form data.
4. Wardrobe creates the item immediately with `imageStatus=PROCESSING`.
5. Wardrobe sends the image to AI service at `POST /api/background-removal`.
6. AI removes the background, uploads the image to S3, then calls wardrobe callback:
   `PATCH /api/items/{itemId}/image`.
7. Wardrobe updates the item to `imageStatus=READY` and stores the final `imageUrl`.

## Useful API Requests

Register:

```bash
curl -X POST http://localhost:8084/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Zakaria","email":"zakaria@example.com","password":"password123"}'
```

Login:

```bash
curl -X POST http://localhost:8084/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"zakaria@example.com","password":"password123"}'
```

Add item:

```bash
curl -X POST http://localhost:8084/api/items \
  -H "Authorization: Bearer <TOKEN>" \
  -F "name=Black Hoodie" \
  -F "category=TOP" \
  -F "color=black" \
  -F "image=@/absolute/path/to/image.jpg"
```

Get items:

```bash
curl http://localhost:8084/api/items \
  -H "Authorization: Bearer <TOKEN>"
```

Get category items:

```bash
curl http://localhost:8084/api/items/tops -H "Authorization: Bearer <TOKEN>"
curl http://localhost:8084/api/items/bottoms -H "Authorization: Bearer <TOKEN>"
curl http://localhost:8084/api/items/shoes -H "Authorization: Bearer <TOKEN>"
curl "http://localhost:8084/api/items?categories=TOP,SHOE" -H "Authorization: Bearer <TOKEN>"
```

Create outfit:

```bash
curl -X POST http://localhost:8084/api/outfits \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Daily fit","description":"Simple outfit","topId":"<TOP_ID>","bottomId":"<BOTTOM_ID>","shoeId":"<SHOE_ID>"}'
```

Get outfits:

```bash
curl http://localhost:8084/api/outfits \
  -H "Authorization: Bearer <TOKEN>"
```

Delete outfit:

```bash
curl -X DELETE http://localhost:8084/api/outfits/<OUTFIT_ID> \
  -H "Authorization: Bearer <TOKEN>"
```

## Verification

Backend:

```bash
cd wardrobe-service
./mvnw test
```

Mobile:

```bash
cd client-mobile
flutter analyze
flutter test
```

AI service syntax check:

```bash
cd ai-service/bgRemover
python3 -m compileall app
```
