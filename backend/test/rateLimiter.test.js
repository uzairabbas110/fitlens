const { test, describe, beforeEach } = require('node:test');
const assert = require('node:assert/strict');

const {
  createPublicRateLimiter,
  createAuthenticatedUserRateLimiter,
  createAuthRouteRateLimiter,
  publicStore,
  userStore,
  authIpStore,
  authAccountStore,
  recordAuthFailure,
  resetAuthAccount,
  getAuthAccountStatus,
  getClientIp,
  getAccountIdentifier,
} = require('../src/middleware/rateLimiter');

// Helper to create mock Express req, res, next objects
function createMockReqRes({ ip = '192.168.1.10', user = null, body = {}, query = {}, headers = {} } = {}) {
  const req = {
    ip,
    user,
    body,
    query,
    headers: { ...headers },
    socket: { remoteAddress: ip },
  };

  const res = {
    statusCode: 200,
    headers: {},
    body: null,
    setHeader(name, value) {
      this.headers[name.toLowerCase()] = value;
      return this;
    },
    getHeader(name) {
      return this.headers[name.toLowerCase()];
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    },
  };

  let nextCalled = false;
  const next = () => {
    nextCalled = true;
  };

  return { req, res, next, wasNextCalled: () => nextCalled };
}

describe('Rate Limiter Engine Tests', () => {
  beforeEach(() => {
    publicStore.clear();
    userStore.clear();
    authIpStore.clear();
    authAccountStore.clear();
  });

  describe('1. Public Rate Limiter (IP-based)', () => {
    test('allows requests within limit and sets standard headers', () => {
      const limiter = createPublicRateLimiter({
        windowMs: 60000,
        maxRequests: 3,
      });

      const { req, res, next, wasNextCalled } = createMockReqRes({ ip: '10.0.0.1' });
      limiter(req, res, next);

      assert.equal(wasNextCalled(), true);
      assert.equal(res.getHeader('ratelimit-limit'), 3);
      assert.equal(res.getHeader('ratelimit-remaining'), 2);
      assert.ok(res.getHeader('ratelimit-reset') > 0);
    });

    test('blocks requests exceeding configured maxRequests with 429', () => {
      const limiter = createPublicRateLimiter({
        windowMs: 60000,
        maxRequests: 2,
        message: 'Public limit hit',
      });

      // 1st request -> OK
      let mock = createMockReqRes({ ip: '10.0.0.2' });
      limiter(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);

      // 2nd request -> OK
      mock = createMockReqRes({ ip: '10.0.0.2' });
      limiter(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);

      // 3rd request -> Blocked with 429
      mock = createMockReqRes({ ip: '10.0.0.2' });
      limiter(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 429);
      assert.equal(mock.res.body.error, 'Too Many Requests');
      assert.equal(mock.res.body.rateLimitType, 'public_rate_limit');
      assert.ok(mock.res.getHeader('retry-after') > 0);
    });

    test('different IPs have independent public limits', () => {
      const limiter = createPublicRateLimiter({
        windowMs: 60000,
        maxRequests: 1,
      });

      // IP 1 -> Hit limit
      let mock1 = createMockReqRes({ ip: '10.0.0.10' });
      limiter(mock1.req, mock1.res, mock1.next);
      assert.equal(mock1.wasNextCalled(), true);

      let mock1Blocked = createMockReqRes({ ip: '10.0.0.10' });
      limiter(mock1Blocked.req, mock1Blocked.res, mock1Blocked.next);
      assert.equal(mock1Blocked.res.statusCode, 429);

      // IP 2 -> Should still be allowed
      let mock2 = createMockReqRes({ ip: '10.0.0.20' });
      limiter(mock2.req, mock2.res, mock2.next);
      assert.equal(mock2.wasNextCalled(), true);
    });
  });

  describe('2. Authenticated User Rate Limiter', () => {
    test('keys by req.user.uid for authenticated users', () => {
      const limiter = createAuthenticatedUserRateLimiter({
        windowMs: 60000,
        maxRequests: 2,
      });

      // User A (from IP 1.1.1.1)
      let userA1 = createMockReqRes({ ip: '1.1.1.1', user: { uid: 'user_123' } });
      limiter(userA1.req, userA1.res, userA1.next);
      assert.equal(userA1.wasNextCalled(), true);

      let userA2 = createMockReqRes({ ip: '1.1.1.1', user: { uid: 'user_123' } });
      limiter(userA2.req, userA2.res, userA2.next);
      assert.equal(userA2.wasNextCalled(), true);

      let userABlocked = createMockReqRes({ ip: '1.1.1.1', user: { uid: 'user_123' } });
      limiter(userABlocked.req, userABlocked.res, userABlocked.next);
      assert.equal(userABlocked.wasNextCalled(), false);
      assert.equal(userABlocked.res.statusCode, 429);
      assert.equal(userABlocked.res.body.rateLimitType, 'authenticated_user_rate_limit');

      // User B (even on same IP 1.1.1.1) is not blocked
      let userB = createMockReqRes({ ip: '1.1.1.1', user: { uid: 'user_456' } });
      limiter(userB.req, userB.res, userB.next);
      assert.equal(userB.wasNextCalled(), true);
    });
  });

  describe('3. Auth Routes Rate Limiter (Per-IP & Exponential Backoff Per-Account)', () => {
    test('enforces strict per-IP limit across auth endpoints', () => {
      const limiter = createAuthRouteRateLimiter({
        ip: { windowMs: 60000, maxRequests: 2 },
        account: { failThreshold: 10 },
      });

      // Request 1 with account A -> OK
      let mock1 = createMockReqRes({ ip: '203.0.113.1', body: { email: 'user1@example.com' } });
      limiter(mock1.req, mock1.res, mock1.next);
      assert.equal(mock1.wasNextCalled(), true);

      // Request 2 with account B -> OK
      let mock2 = createMockReqRes({ ip: '203.0.113.1', body: { email: 'user2@example.com' } });
      limiter(mock2.req, mock2.res, mock2.next);
      assert.equal(mock2.wasNextCalled(), true);

      // Request 3 -> Exceeds IP limit of 2 -> 429
      let mock3 = createMockReqRes({ ip: '203.0.113.1', body: { email: 'user3@example.com' } });
      limiter(mock3.req, mock3.res, mock3.next);
      assert.equal(mock3.wasNextCalled(), false);
      assert.equal(mock3.res.statusCode, 429);
      assert.equal(mock3.res.body.rateLimitType, 'auth_ip_rate_limit');
    });

    test('implements exponential backoff for repeatedly failing account', () => {
      const accountOpts = {
        failThreshold: 3,
        baseDelayMs: 2000,
        backoffFactor: 2,
        maxDelayMs: 60000,
        resetWindowMs: 900000,
      };

      const limiter = createAuthRouteRateLimiter({
        ip: { maxRequests: 100 },
        account: accountOpts,
      });

      const email = 'target@example.com';

      // 1. Initial 3 failed attempts (within threshold)
      for (let i = 1; i <= 3; i++) {
        const mock = createMockReqRes({ ip: `10.0.0.${i}`, body: { email } });
        limiter(mock.req, mock.res, mock.next);
        assert.equal(mock.wasNextCalled(), true, `Attempt ${i} should pass middleware`);

        // Record failure
        recordAuthFailure(email, accountOpts);
        const status = getAuthAccountStatus(email);
        assert.equal(status.attempts, i);
      }

      // 2. 4th failed attempt (exceeds threshold 3) -> should trigger base delay (2000ms)
      recordAuthFailure(email, accountOpts);
      const statusAfter4 = getAuthAccountStatus(email);
      assert.equal(statusAfter4.attempts, 4);
      assert.ok(statusAfter4.nextAllowedTime > Date.now());

      // 3. Immediate next request for same account should be rejected with 429 and exponential backoff notice
      const blockedMock = createMockReqRes({ ip: '10.0.0.99', body: { email } });
      limiter(blockedMock.req, blockedMock.res, blockedMock.next);
      assert.equal(blockedMock.wasNextCalled(), false);
      assert.equal(blockedMock.res.statusCode, 429);
      assert.equal(blockedMock.res.body.rateLimitType, 'auth_account_exponential_backoff');
      assert.equal(blockedMock.res.body.attempts, 4);
      assert.ok(blockedMock.res.getHeader('retry-after') >= 1);

      // 4. Different account is unaffected
      const otherMock = createMockReqRes({ ip: '10.0.0.99', body: { email: 'other@example.com' } });
      limiter(otherMock.req, otherMock.res, otherMock.next);
      assert.equal(otherMock.wasNextCalled(), true);

      // 5. 5th failure increases backoff exponentially (2000 * 2^1 = 4000ms)
      recordAuthFailure(email, accountOpts);
      const statusAfter5 = getAuthAccountStatus(email);
      assert.equal(statusAfter5.attempts, 5);
      const delay = statusAfter5.nextAllowedTime - statusAfter5.lastAttemptTime;
      assert.ok(delay >= 3900 && delay <= 4100, `Expected ~4000ms delay, got ${delay}ms`);

      // 6. Successful login resets backoff immediately
      resetAuthAccount(email);
      assert.equal(getAuthAccountStatus(email), null);

      // Next request for that account is immediately permitted
      const unblockedMock = createMockReqRes({ ip: '10.0.0.99', body: { email } });
      limiter(unblockedMock.req, unblockedMock.res, unblockedMock.next);
      assert.equal(unblockedMock.wasNextCalled(), true);
    });

    test('respects max delay cap on high failure counts', () => {
      const maxDelayMs = 10000; // 10s cap
      const accountOpts = {
        failThreshold: 1,
        baseDelayMs: 2000,
        backoffFactor: 2,
        maxDelayMs,
        resetWindowMs: 900000,
      };

      const email = 'spam@example.com';
      // Record 10 failures
      for (let i = 0; i < 10; i++) {
        recordAuthFailure(email, accountOpts);
      }

      const status = getAuthAccountStatus(email);
      const delay = status.nextAllowedTime - status.lastAttemptTime;
      assert.equal(delay, maxDelayMs, `Delay should be capped at maxDelayMs (${maxDelayMs}ms)`);
    });
  });

  describe('4. IP Resolution & Identifier Extraction', () => {
    test('extracts client IP from various proxy headers', () => {
      assert.equal(getClientIp({ headers: { 'cf-connecting-ip': '1.2.3.4' } }), '1.2.3.4');
      assert.equal(getClientIp({ headers: { 'x-forwarded-for': '5.6.7.8, 10.0.0.1' } }), '5.6.7.8');
      assert.equal(getClientIp({ headers: { 'x-real-ip': '9.10.11.12' } }), '9.10.11.12');
      assert.equal(getClientIp({ ip: '13.14.15.16', headers: {} }), '13.14.15.16');
    });

    test('extracts and normalizes account identifiers', () => {
      assert.equal(getAccountIdentifier({ body: { email: '  Test@Domain.COM  ' } }), 'test@domain.com');
      assert.equal(getAccountIdentifier({ body: { username: 'MyUser' } }), 'myuser');
      assert.equal(getAccountIdentifier({ query: { email: 'Query@test.org' } }), 'query@test.org');
      assert.equal(getAccountIdentifier({ body: {} }), null);
    });
  });

  describe('5. Custom Threshold & Environment Configurability', () => {
    test('disabled rate limiting bypasses checks when enabled is false', () => {
      const limiter = createPublicRateLimiter({
        enabled: false,
        maxRequests: 1,
      });

      // Send 5 requests -> all should pass
      for (let i = 0; i < 5; i++) {
        const mock = createMockReqRes({ ip: '192.168.1.1' });
        limiter(mock.req, mock.res, mock.next);
        assert.equal(mock.wasNextCalled(), true);
      }
    });
  });
});
