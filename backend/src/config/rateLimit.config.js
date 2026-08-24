/**
 * Rate Limiting Configuration
 * All thresholds and windows can be overridden via environment variables.
 */

function parseNumber(envVar, defaultValue) {
  if (envVar === undefined || envVar === null || envVar.trim() === '') {
    return defaultValue;
  }
  const parsed = Number(envVar);
  return Number.isFinite(parsed) ? parsed : defaultValue;
}

function parseBoolean(envVar, defaultValue) {
  if (envVar === undefined || envVar === null || envVar.trim() === '') {
    return defaultValue;
  }
  return envVar.toLowerCase() === 'true' || envVar === '1';
}

const rateLimitConfig = {
  // Global master switch to enable/disable rate limiting (useful for certain test scenarios)
  enabled: parseBoolean(process.env.RATE_LIMIT_ENABLED, true),

  // Public Endpoints (e.g. /health, /api/weather/*)
  public: {
    windowMs: parseNumber(process.env.RATE_LIMIT_PUBLIC_WINDOW_MS, 15 * 60 * 1000), // 15 minutes
    maxRequests: parseNumber(process.env.RATE_LIMIT_PUBLIC_MAX_REQUESTS, 100), // 100 requests per IP per window
    message: 'Too many requests from this IP to public endpoints. Please try again later.',
  },

  // Authenticated User Endpoints (e.g. /api/ai/*, /api/storage/*)
  authenticatedUser: {
    windowMs: parseNumber(process.env.RATE_LIMIT_AUTH_USER_WINDOW_MS, 15 * 60 * 1000), // 15 minutes
    maxRequests: parseNumber(process.env.RATE_LIMIT_AUTH_USER_MAX_REQUESTS, 300), // 300 requests per user ID per window
    message: 'API rate limit exceeded for this account. Please wait before sending more requests.',
  },

  // Authentication Routes (e.g. /api/auth/login, /api/auth/signup, /api/auth/password-reset)
  auth: {
    // 1. Stricter Per-IP limit for auth endpoints
    ip: {
      windowMs: parseNumber(process.env.RATE_LIMIT_AUTH_IP_WINDOW_MS, 15 * 60 * 1000), // 15 minutes
      maxRequests: parseNumber(process.env.RATE_LIMIT_AUTH_IP_MAX_REQUESTS, 20), // max 20 auth attempts per IP per 15 min
      message: 'Too many authentication attempts from this IP. Please try again later.',
    },

    // 2. Per-Account limit with Exponential Backoff (no permanent lockout)
    account: {
      // Number of free attempts allowed before backoff delay begins
      failThreshold: parseNumber(process.env.RATE_LIMIT_AUTH_ACCOUNT_FAIL_THRESHOLD, 3),
      // Base backoff delay in milliseconds (e.g. 2000 ms = 2 seconds)
      baseDelayMs: parseNumber(process.env.RATE_LIMIT_AUTH_ACCOUNT_BASE_DELAY_MS, 2000),
      // Multiplier factor for exponential backoff (e.g. 2 means 2s -> 4s -> 8s -> 16s -> ...)
      backoffFactor: parseNumber(process.env.RATE_LIMIT_AUTH_ACCOUNT_BACKOFF_FACTOR, 2),
      // Maximum backoff delay cap (e.g. 5 minutes = 300,000 ms)
      maxDelayMs: parseNumber(process.env.RATE_LIMIT_AUTH_ACCOUNT_MAX_DELAY_MS, 5 * 60 * 1000),
      // Inactivity window after which account attempt counters reset
      resetWindowMs: parseNumber(process.env.RATE_LIMIT_AUTH_ACCOUNT_RESET_WINDOW_MS, 15 * 60 * 1000),
      message: 'Too many failed login attempts for this account. Please wait before trying again.',
    },
  },

  // Background garbage collection cleanup frequency for expired memory records
  cleanupIntervalMs: parseNumber(process.env.RATE_LIMIT_CLEANUP_INTERVAL_MS, 5 * 60 * 1000),
};

module.exports = rateLimitConfig;
