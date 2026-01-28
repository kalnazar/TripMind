# TripMind

AI-powered trip planner built by KBTU students. The stack consists of a Spring Boot backend, a Next.js web client, and a SwiftUI iOS app. The backend calls the Groq Cloud API for fast LLM-powered itinerary generation ([Groq Cloud](https://console.groq.com/home)).

## Repository layout
- `tripmind-server/` — Spring Boot (Java 21, Maven)
- `tripmind-web/` — Next.js 15 App Router frontend
- `tripmind-mobile/` — SwiftUI client

## Prerequisites
- Java 21+, Maven wrapper (`./mvnw`)
- Node.js 18+ and npm (or pnpm/yarn)
- PostgreSQL 14+ running locally
- Xcode 15+ for iOS development
- Groq API key for AI generation (keep it secret)

## Quick start (local)

### 1) Backend (Spring Boot)
```bash
cd tripmind-server
# create local DB (example)
createdb tripmind

# supply environment (examples shown as shell exports)
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/tripmind
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
export APP_JWT_SECRET=change-me-long-random
export APP_JWT_EXP_MS=604800000
export GROK_API_KEY=your_groq_key
export APP_SITE_URL=http://localhost:8080

./mvnw spring-boot:run
```
Key API routes:
- `/api/auth/register`, `/api/auth/login`
- `/api/users/me`, `/api/users/me/avatar`
- `/api/ai`, `/api/ai/itinerary`
- `/api/itineraries` (POST/GET), `/api/itineraries/{id}`, `/api/itineraries/trip/{tripId}`

### 2) Web (Next.js)
```bash
cd tripmind-web
npm install
npm run dev
# visit http://localhost:3000
```
We keep a ready-to-use `tripmind-web/.env.local` in the repo so local setup is zero-config. Update values there if your backend URL or Cloudinary credentials differ.

### 3) Mobile (SwiftUI)
1. Open `tripmind-mobile/trip-mind-mobile.xcodeproj` in Xcode (we keep `Info.plist` with default `API_BASE_URL` checked in).
2. If you run on a physical device, change `API_BASE_URL` in `Info.plist` to your machine IP (e.g., `http://192.168.x.x:8080`).
3. Run on simulator/device (`⌘ + R`). JWT is stored in Keychain via `AuthManager`.

## What to keep out of source control

### Backend (`tripmind-server/src/main/resources/application.properties`)
Move these into environment variables or a non-committed `application-local.properties`:
- Database URL/username/password
- `app.jwt-secret`, `app.jwt-exp-ms`
- `grok.api.key` (and any other model provider keys)
- `app.site-url` (environment-specific)

### Web (`tripmind-web/.env.local`)
- `CLOUDINARY_API_SECRET` and related Cloudinary values
- `BACKEND_BASE` / `NEXT_PUBLIC_API_BASE_URL` (per environment)
- `JWT_COOKIE_NAME` (cookie naming, not secret but environment-specific)

### Mobile (`tripmind-mobile`)
- Do not embed API keys/secrets in the client. Only keep `API_BASE_URL` in `Info.plist`; tokens are already stored in Keychain. Keep signing assets, provisioning profiles, and any `.env` config files out of git.

General tips:
- Prefer `.env` / `application-local.properties` files that are gitignored.
- Rotate the committed Groq key in `application.properties` and replace it with an environment variable before release.
- Use separate configs per environment (local/stage/prod).

## Running order in development
1. Start PostgreSQL.
2. Run the backend (`./mvnw spring-boot:run`).
3. Run the web app (`npm run dev`).
4. Point the mobile app to the same backend URL and run in Xcode.

## Generating a Strong JWT Secret
------------------------------
The backend uses APP_JWT_SECRET to sign and verify tokens.
Use a long, random, cryptographically secure value.

Using OpenSSL:
    openssl rand -base64 64

Using Node.js:
    node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

Using Linux/macOS built-ins:
    head -c 64 /dev/urandom | base64

Set the value:
    export APP_JWT_SECRET="your-very-long-random-secret"

## Useful scripts
- Backend: `./mvnw test`, `./mvnw spring-boot:run`
- Web: `npm run dev`, `npm run build`, `npm run start`


