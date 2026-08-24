/**
 * Multi-Tiered Rate Limiter Middleware for FitLens Backend
 * - Public endpoint rate limiter (IP-based sliding window)
 * - Authenticated user rate limiter (User ID-based sliding window)
 * - Authentication routes rate limiter (Per-IP limit + Per-Account Exponential Backoff)
 */

const defaultConfig = require('../config/rateLimit.config');

/**
 * Extracts client IP from request headers or socket
 */
function getClientIp(req) {
  if (!req) return '127.0.0.1';

  // Cloudflare header
  if (req.headers && req.headers['cf-connecting-ip']) {
    return req.headers['cf-connecting-ip'].trim();
  }

  // Standard reverse proxy forwarded header
  if (req.headers && req.headers['x-forwarded-for']) {
    const forwarded = req.headers['x-forwarded-for'];
    const ips = forwarded.split(',');
    if (ips.length > 0 && ips[0].trim()) {
      return ips[0].trim();
    }
  }

  // Real IP header
  if (req.headers && req.headers['x-real-ip']) {
    return req.headers['x-real-ip'].trim();
  }

  return req.ip || (req.socket && req.socket.remoteAddress) || '127.0.0.1';
}

/**
 * Extracts account identifier (e.g. email, username) from request body or query
 */
function getAccountIdentifier(req) {
  if (!req) return null;

  const candidate =
    (req.body && (req.body.email || req.body.username || req.body.identifier || req.body.account)) ||
    (req.query && (req.query.email || req.query.username || req.query.identifier));

  if (typeof candidate === 'string' && candidate.trim().length > 0) {
    return candidate.trim().toLowerCase();
  }

  return null;
}

/**
 * In-Memory Sliding Window Store for general IP/User rate limiting
 */
class SlidingWindowStore {
  constructor() {
    this.hits = new Map(); // key -> [timestamp1, timestamp2, ...]
  }

  /**
   * Records a hit and returns status { totalHits, resetTimeSeconds, oldestTimestamp }
   */
  hit(key, windowMs) {
    const now = Date.now();
    const windowStart = now - windowMs;

    let timestamps = this.hits.get(key) || [];
    // Remove expired entries outside the sliding window
    timestamps = timestamps.filter((ts) => ts > windowStart);

    // Append current hit
    timestamps.push(now);
    this.hits.set(key, timestamps);

    const oldest = timestamps[0];
    const resetTimeSeconds = Math.ceil((oldest + windowMs - now) / 1000);

    return {
      totalHits: timestamps.length,
      resetTimeSeconds: Math.max(1, resetTimeSeconds),
      resetTimestamp: Math.ceil((oldest + windowMs) / 1000),
    };
  }

  /**
   * Resets hit history for a specific key
   */
  reset(key) {
    this.hits.delete(key);
  }

  /**
   * Garbage collection: removes keys with no timestamps within windowMs
   */
  cleanup(windowMs) {
    const windowStart = Date.now() - windowMs;
    for (const [key, timestamps] of this.hits.entries()) {
      const valid = timestamps.filter((ts) => ts > windowStart);
      if (valid.length === 0) {
        this.hits.delete(key);
      } else {
        this.hits.set(key, valid);
      }
    }
  }

  clear() {
    this.hits.clear();
  }
}

/**
 * In-Memory Store for Account Exponential Backoff
 */
class AccountBackoffStore {
  constructor() {
    this.accounts = new Map(); // identifier -> { attempts: number, lastAttemptTime: number, nextAllowedTime: number }
  }

  /**
   * Checks if an account is currently delayed under exponential backoff
   */
  check(identifier, resetWindowMs) {
    if (!identifier) return { isBlocked: false, retryAfterSeconds: 0, attempts: 0 };

    const now = Date.now();
    const record = this.accounts.get(identifier);

    if (!record) {
      return { isBlocked: false, retryAfterSeconds: 0, attempts: 0 };
    }

    // Inactivity reset: If quiet for more than resetWindowMs, reset attempts
    if (now - record.lastAttemptTime > resetWindowMs) {
      this.accounts.delete(identifier);
      return { isBlocked: false, retryAfterSeconds: 0, attempts: 0 };
    }

    // Check if within backoff delay window
    if (now < record.nextAllowedTime) {
      const retryAfterSeconds = Math.ceil((record.nextAllowedTime - now) / 1000);
      return {
        isBlocked: true,
        retryAfterSeconds: Math.max(1, retryAfterSeconds),
        attempts: record.attempts,
      };
    }

    return { isBlocked: false, retryAfterSeconds: 0, attempts: record.attempts };
  }

  /**
   * Records a failed/repeated auth attempt and applies exponential backoff delay if threshold exceeded
   */
  recordFailure(identifier, options = {}) {
    if (!identifier) return;

    const {
      failThreshold = 3,
      baseDelayMs = 2000,
      backoffFactor = 2,
      maxDelayMs = 300000,
      resetWindowMs = 900000,
    } = options;

    const now = Date.now();
    let record = this.accounts.get(identifier);

    // Reset if inactivity window expired
    if (!record || now - record.lastAttemptTime > resetWindowMs) {
      record = { attempts: 0, lastAttemptTime: now, nextAllowedTime: 0 };
    }

    record.attempts += 1;
    record.lastAttemptTime = now;

    if (record.attempts > failThreshold) {
      // Calculate exponential backoff delay: baseDelay * factor ^ (attempts - failThreshold - 1)
      const exponent = record.attempts - failThreshold - 1;
      const delayMs = Math.min(maxDelayMs, baseDelayMs * Math.pow(backoffFactor, exponent));
      record.nextAllowedTime = now + delayMs;
    } else {
      record.nextAllowedTime = now;
    }

    this.accounts.set(identifier, record);
    return record;
  }

  /**
   * Resets backoff state for an account upon successful authentication
   */
  reset(identifier) {
    if (!identifier) return;
    this.accounts.delete(identifier);
  }

  /**
   * Inspects current status of an account
   */
  getStatus(identifier) {
    if (!identifier) return null;
    return this.accounts.get(identifier) || null;
  }

  /**
   * Garbage collection: removes records older than resetWindowMs
   */
  cleanup(resetWindowMs) {
    const now = Date.now();
    for (const [id, record] of this.accounts.entries()) {
      if (now - record.lastAttemptTime > resetWindowMs) {
        this.accounts.delete(id);
      }
    }
  }

  clear() {
    this.accounts.clear();
  }
}

// Global store singletons
const publicStore = new SlidingWindowStore();
const userStore = new SlidingWindowStore();
const authIpStore = new SlidingWindowStore();
const authAccountStore = new AccountBackoffStore();

// Setup periodic garbage collection to prevent memory leaks
let cleanupTimer = null;
function startCleanupTimer(intervalMs, resetWindowMs) {
  if (cleanupTimer) clearInterval(cleanupTimer);
  cleanupTimer = setInterval(() => {
    publicStore.cleanup(resetWindowMs);
    userStore.cleanup(resetWindowMs);
    authIpStore.cleanup(resetWindowMs);
    authAccountStore.cleanup(resetWindowMs);
  }, intervalMs);

  // Unref timer so Node process is not held open in test environments
  if (cleanupTimer.unref) {
    cleanupTimer.unref();
  }
}

startCleanupTimer(defaultConfig.cleanupIntervalMs, defaultConfig.public.windowMs);

/**
 * 1. Public Endpoint Rate Limiter
 * Moderate limits keyed by client IP (e.g. /health, /api/weather/*)
 */
function createPublicRateLimiter(options = {}) {
  const cfg = {
    ...defaultConfig.public,
    ...options,
    enabled: options.enabled !== undefined ? options.enabled : defaultConfig.enabled,
  };

  return function publicRateLimitMiddleware(req, res, next) {
    if (!cfg.enabled) return next();

    const ip = getClientIp(req);
    const key = `pub:${ip}`;
    const result = publicStore.hit(key, cfg.windowMs);

    // Standard HTTP Rate Limit headers
    res.setHeader('RateLimit-Limit', cfg.maxRequests);
    res.setHeader('RateLimit-Remaining', Math.max(0, cfg.maxRequests - result.totalHits));
    res.setHeader('RateLimit-Reset', result.resetTimestamp);

    if (result.totalHits > cfg.maxRequests) {
      res.setHeader('Retry-After', result.resetTimeSeconds);
      return res.status(429).json({
        error: 'Too Many Requests',
        message: cfg.message,
        retryAfter: result.resetTimeSeconds,
        rateLimitType: 'public_rate_limit',
      });
    }

    next();
  };
}

/**
 * 2. Authenticated User Rate Limiter
 * Looser limits keyed by authenticated user ID (e.g. /api/ai/*, /api/storage/*)
 */
function createAuthenticatedUserRateLimiter(options = {}) {
  const cfg = {
    ...defaultConfig.authenticatedUser,
    ...options,
    enabled: options.enabled !== undefined ? options.enabled : defaultConfig.enabled,
  };

  return function authenticatedUserRateLimitMiddleware(req, res, next) {
    if (!cfg.enabled) return next();

    // Key by user UID (if set by auth middleware) or fallback to IP
    const userId = (req.user && (req.user.uid || req.user.id || req.user.email)) || getClientIp(req);
    const key = `user:${userId}`;
    const result = userStore.hit(key, cfg.windowMs);

    res.setHeader('RateLimit-Limit', cfg.maxRequests);
    res.setHeader('RateLimit-Remaining', Math.max(0, cfg.maxRequests - result.totalHits));
    res.setHeader('RateLimit-Reset', result.resetTimestamp);

    if (result.totalHits > cfg.maxRequests) {
      res.setHeader('Retry-After', result.resetTimeSeconds);
      return res.status(429).json({
        error: 'Too Many Requests',
        message: cfg.message,
        retryAfter: result.resetTimeSeconds,
        rateLimitType: 'authenticated_user_rate_limit',
      });
    }

    next();
  };
}

/**
 * 3. Authentication Routes Rate Limiter
 * Strictest limits combining Per-IP checks with Per-Account Exponential Backoff
 */
function createAuthRouteRateLimiter(options = {}) {
  const ipCfg = {
    ...defaultConfig.auth.ip,
    ...(options.ip || {}),
  };

  const accountCfg = {
    ...defaultConfig.auth.account,
    ...(options.account || {}),
  };

  const isEnabled = options.enabled !== undefined ? options.enabled : defaultConfig.enabled;

  return function authRouteRateLimitMiddleware(req, res, next) {
    if (!isEnabled) return next();

    // 1. Check Per-IP rate limit to mitigate distributed/random brute-force
    const ip = getClientIp(req);
    const ipKey = `auth_ip:${ip}`;
    const ipResult = authIpStore.hit(ipKey, ipCfg.windowMs);

    res.setHeader('RateLimit-Limit', ipCfg.maxRequests);
    res.setHeader('RateLimit-Remaining', Math.max(0, ipCfg.maxRequests - ipResult.totalHits));
    res.setHeader('RateLimit-Reset', ipResult.resetTimestamp);

    if (ipResult.totalHits > ipCfg.maxRequests) {
      res.setHeader('Retry-After', ipResult.resetTimeSeconds);
      return res.status(429).json({
        error: 'Too Many Requests',
        message: ipCfg.message,
        retryAfter: ipResult.resetTimeSeconds,
        rateLimitType: 'auth_ip_rate_limit',
      });
    }

    // 2. Check Per-Account Exponential Backoff
    const accountIdentifier = getAccountIdentifier(req);
    if (accountIdentifier) {
      const accountStatus = authAccountStore.check(accountIdentifier, accountCfg.resetWindowMs);
      if (accountStatus.isBlocked) {
        res.setHeader('Retry-After', accountStatus.retryAfterSeconds);
        return res.status(429).json({
          error: 'Too Many Requests',
          message: `Too many authentication attempts for this account. Please wait ${accountStatus.retryAfterSeconds} second(s) before trying again.`,
          retryAfter: accountStatus.retryAfterSeconds,
          attempts: accountStatus.attempts,
          rateLimitType: 'auth_account_exponential_backoff',
        });
      }
    }

    next();
  };
}

/**
 * Helper to record a failed auth attempt for account backoff tracking
 */
function recordAuthFailure(identifier, options = {}) {
  if (!identifier) return;
  const cfg = {
    ...defaultConfig.auth.account,
    ...options,
  };
  const normalized = typeof identifier === 'string' ? identifier.trim().toLowerCase() : identifier;
  return authAccountStore.recordFailure(normalized, cfg);
}

/**
 * Helper to reset account backoff tracking on successful authentication
 */
function resetAuthAccount(identifier) {
  if (!identifier) return;
  const normalized = typeof identifier === 'string' ? identifier.trim().toLowerCase() : identifier;
  authAccountStore.reset(normalized);
}

/**
 * Helper to inspect account status
 */
function getAuthAccountStatus(identifier) {
  if (!identifier) return null;
  const normalized = typeof identifier === 'string' ? identifier.trim().toLowerCase() : identifier;
  return authAccountStore.getStatus(normalized);
}

// Create default middleware instances
const publicRateLimiter = createPublicRateLimiter();
const authenticatedUserRateLimiter = createAuthenticatedUserRateLimiter();
const authRouteRateLimiter = createAuthRouteRateLimiter();

module.exports = {
  // Middleware instances
  publicRateLimiter,
  authenticatedUserRateLimiter,
  authRouteRateLimiter,

  // Middleware factory functions
  createPublicRateLimiter,
  createAuthenticatedUserRateLimiter,
  createAuthRouteRateLimiter,

  // Stores (exported for testing and inspection)
  publicStore,
  userStore,
  authIpStore,
  authAccountStore,

  // Account backoff helpers
  recordAuthFailure,
  resetAuthAccount,
  getAuthAccountStatus,

  // Utility helpers
  getClientIp,
  getAccountIdentifier,
};
