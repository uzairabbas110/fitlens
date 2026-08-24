# FitLens Secure Server-Side Backend

This backend proxies all sensitive AI (Google Gemini), cloud storage (Cloudflare R2), weather, and authentication requests to ensure that **no API keys or shared secrets are exposed to client mobile devices**.

---

## Features

- **Zero Client-Side Credentials**: Gemini API key, Cloudflare R2 secrets, and Weather API keys are stored securely on the server in `.env`.
- **Multi-Tiered Configurable Rate Limiting**:
  - **Public Endpoints** (`/health`, `/api/weather/*`): Moderate sliding-window rate limits keyed by client IP.
  - **Authenticated User Endpoints** (`/api/ai/*`, `/api/storage/*`): Looser sliding-window rate limits keyed by user ID (`req.user.uid`).
  - **Authentication Routes** (`/api/auth/login`, `/api/auth/signup`, `/api/auth/password-reset`): Strict Per-IP rate limiting + **Per-Account Exponential Backoff** (delays scale as $\text{baseDelay} \times 2^{(\text{attempts} - \text{threshold})}$) rather than hard lockout.
  - **Standard Rate Limit Headers**: Emits `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`, and `Retry-After`.
  - **Configurable**: All limits, window durations, base delays, multipliers, and caps are configurable via `.env`.
- **Firebase Auth JWT Verification**: All sensitive endpoints (`/api/ai/*`, `/api/storage/*`) verify incoming Firebase ID tokens.
- **Multimodal AI Vision & Chat**: Server-side model fallback hierarchy, exponential backoff retries, and automatic JSON repair.
- **Dual Deployment**:
  - Run locally with Node.js/Express (`npm start`)
  - Deploy to Cloudflare Workers with serverless edge architecture (`cloudflare/worker.js`)

---

## Rate Limiting Configuration

All parameters can be tuned in `.env`:

```env
RATE_LIMIT_ENABLED=true

# Public Endpoints
RATE_LIMIT_PUBLIC_WINDOW_MS=900000        # 15 minutes
RATE_LIMIT_PUBLIC_MAX_REQUESTS=100        # 100 requests per IP

# Authenticated User Endpoints
RATE_LIMIT_AUTH_USER_WINDOW_MS=900000     # 15 minutes
RATE_LIMIT_AUTH_USER_MAX_REQUESTS=300     # 300 requests per User ID

# Authentication Routes (Per-IP & Exponential Backoff Per-Account)
RATE_LIMIT_AUTH_IP_WINDOW_MS=900000       # 15 minutes
RATE_LIMIT_AUTH_IP_MAX_REQUESTS=20        # 20 auth requests per IP
RATE_LIMIT_AUTH_ACCOUNT_FAIL_THRESHOLD=3  # 3 free attempts before delay
RATE_LIMIT_AUTH_ACCOUNT_BASE_DELAY_MS=2000 # 2s base delay
RATE_LIMIT_AUTH_ACCOUNT_BACKOFF_FACTOR=2   # Delay doubles: 2s -> 4s -> 8s -> 16s...
RATE_LIMIT_AUTH_ACCOUNT_MAX_DELAY_MS=300000 # 5 min max delay cap
RATE_LIMIT_AUTH_ACCOUNT_RESET_WINDOW_MS=900000 # 15 min cooldown window
```

---

## Quick Start (Local Node.js Server)

1. **Navigate to Backend folder**:
   ```bash
   cd d:\Development\Backend
   ```
2. **Configure `.env`**:
   Ensure `GEMINI_API_KEY`, `WEATHER_API_KEY`, and `FIREBASE_PROJECT_ID` are configured in `.env`.
3. **Run Tests**:
   ```bash
   node --test test/**/*.test.js
   ```
4. **Start the server**:
   ```bash
   npm start
   ```
   The server will start at `http://localhost:3000`.

---

## Connecting the Flutter App

In `d:\Development\FlutterProjects\fitlens\lib\core\constants\api_constants.dart`:
- **Android Emulator**: Automatically routes to `http://10.0.2.2:3000`.
- **iOS Simulator / Desktop / Web**: Automatically routes to `http://localhost:3000`.
- **Production**: Replace `_productionUrl` with your deployed Cloudflare Worker or backend URL.

---

## Deploying to Cloudflare Workers (Optional 1-Click Serverless)

If you prefer serverless edge hosting on Cloudflare:
1. `cd cloudflare`
2. Run `npx wrangler secret put GEMINI_API_KEY` to set your secret key.
3. Run `npx wrangler deploy`.
