const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const express = require('express');

// Import routes and middleware
const authRoutes = require('../src/routes/auth.routes');
const weatherRoutes = require('../src/routes/weather.routes');
const aiRoutes = require('../src/routes/ai.routes');
const {
  publicRateLimiter,
  publicStore,
  authIpStore,
  authAccountStore,
  userStore,
} = require('../src/middleware/rateLimiter');

describe('Full HTTP Integration, Validation & Rate Limiting Tests', () => {
  let server;
  let baseUrl;

  before(async () => {
    const app = express();
    app.use(express.json());

    // Health with public rate limiter
    app.get('/health', publicRateLimiter, (req, res) => {
      res.json({ status: 'ok' });
    });

    app.use('/api/auth', authRoutes);
    app.use('/api/weather', weatherRoutes);
    app.use('/api/ai', aiRoutes);

    // Global error handler
    app.use((err, req, res, next) => {
      res.status(500).json({ error: err.message });
    });

    // Start ephemeral test server on port 0
    await new Promise((resolve) => {
      server = app.listen(0, '127.0.0.1', () => {
        const port = server.address().port;
        baseUrl = `http://127.0.0.1:${port}`;
        resolve();
      });
    });
  });

  after((done) => {
    if (server) server.close(done);
    else done();
  });

  function makeRequest(path, options = {}) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, baseUrl);
      const reqOptions = {
        method: options.method || 'GET',
        headers: options.headers || {},
      };

      const req = http.request(url, reqOptions, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {
          rawData += chunk;
        });
        res.on('end', () => {
          let json = null;
          try {
            json = JSON.parse(rawData);
          } catch (_) {
            json = rawData;
          }
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: json,
          });
        });
      });

      req.on('error', reject);

      if (options.body) {
        req.write(typeof options.body === 'string' ? options.body : JSON.stringify(options.body));
      }
      req.end();
    });
  }

  test('GET /health returns 200 with RateLimit headers', async () => {
    const res = await makeRequest('/health');
    assert.equal(res.statusCode, 200);
    assert.equal(res.body.status, 'ok');
    assert.ok(res.headers['ratelimit-limit']);
    assert.ok(res.headers['ratelimit-remaining']);
  });

  test('POST /api/auth/login handles credentials and rate limits', async () => {
    const email = 'client_test@fitlens.app';

    // Successful dev login
    const res = await makeRequest('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email, password: 'correct_password' },
    });

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.user.email, email);
    assert.ok(res.headers['ratelimit-limit']);
  });

  test('POST /api/auth/login triggers exponential backoff on repeated wrong password', async () => {
    const email = 'victim@fitlens.app';

    // 3 failed attempts (within threshold)
    for (let i = 0; i < 3; i++) {
      const res = await makeRequest('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: { email, password: 'wrong_password' },
      });
      assert.equal(res.statusCode, 401);
    }

    // 4th failed attempt triggers backoff
    const fourthRes = await makeRequest('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email, password: 'wrong_password' },
    });
    assert.equal(fourthRes.statusCode, 401);

    // 5th attempt immediately after should be throttled by 429 Too Many Requests
    const throttledRes = await makeRequest('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email, password: 'any_password' },
    });

    assert.equal(throttledRes.statusCode, 429);
    assert.equal(throttledRes.body.rateLimitType, 'auth_account_exponential_backoff');
    assert.ok(throttledRes.headers['retry-after']);
  });

  test('GET /api/auth/account-status returns backoff info', async () => {
    const res = await makeRequest('/api/auth/account-status?email=victim@fitlens.app');
    assert.equal(res.statusCode, 200);
    assert.equal(res.body.email, 'victim@fitlens.app');
    assert.ok(res.body.attempts >= 4);
    assert.equal(res.body.isThrottled, true);
  });

  test('POST /api/auth/signup rejects weak passwords (< 9 chars or missing complexity)', async () => {
    // 8 chars password
    const res1 = await makeRequest('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'weak@fitlens.app', password: 'Abc123!@' },
    });
    assert.equal(res1.statusCode, 400);
    assert.equal(res1.body.error, 'Validation Error');

    // Missing special character
    const res2 = await makeRequest('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'weak2@fitlens.app', password: 'Password12345' },
    });
    assert.equal(res2.statusCode, 400);
    assert.equal(res2.body.error, 'Validation Error');
  });

  test('POST /api/auth/signup creates account with valid strong password', async () => {
    const res = await makeRequest('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'newbie@fitlens.app', password: 'SecurePassword123!', displayName: 'Newbie User' },
    });

    assert.equal(res.statusCode, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.user.email, 'newbie@fitlens.app');
  });

  test('POST /api/auth/password-reset validates email strictly', async () => {
    // Invalid email
    const invalidRes = await makeRequest('/api/auth/password-reset', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'invalid_email_format' },
    });
    assert.equal(invalidRes.statusCode, 400);
    assert.equal(invalidRes.body.error, 'Validation Error');

    // Valid email
    const validRes = await makeRequest('/api/auth/password-reset', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'resetme@fitlens.app' },
    });
    assert.equal(validRes.statusCode, 200);
    assert.equal(validRes.body.success, true);
  });

  test('GET /api/weather/current rejects invalid latitude / longitude values', async () => {
    const res = await makeRequest('/api/weather/current?lat=999&lon=0');
    assert.equal(res.statusCode, 400);
    assert.equal(res.body.error, 'Validation Error');
    assert.ok(res.body.details.some((d) => d.field === 'lat'));
  });

  test('POST /api/auth/delete-account schedules deletion with 10-day grace period', async () => {
    const res = await makeRequest('/api/auth/delete-account', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'user_delete@fitlens.app' },
    });

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.status, 'pending_deletion');
    assert.equal(res.body.gracePeriodDays, 10);
    assert.ok(res.body.permanentDeleteAt);
    assert.ok(new Date(res.body.permanentDeleteAt).getTime() > Date.now());
  });
});
