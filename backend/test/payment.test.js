const { describe, it, before, after } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const express = require('express');
const crypto = require('crypto');

process.env.NODE_ENV = 'development';
const paymentRoutes = require('../src/routes/payment.routes');
const WEBHOOK_SECRET = process.env.PAYMENT_WEBHOOK_SECRET || 'fitlens_sandbox_webhook_secret_key_32bytes';

describe('Payment & VIP Subscription Security Tests', () => {
  let server;
  let baseUrl;

  before(async () => {
    const app = express();
    app.use(express.json());
    app.use('/api/payment', paymentRoutes);

    server = http.createServer(app);
    await new Promise((resolve) => {
      server.listen(0, '127.0.0.1', () => {
        const port = server.address().port;
        baseUrl = `http://127.0.0.1:${port}`;
        resolve();
      });
    });
  });

  after(async () => {
    await new Promise((resolve) => server.close(resolve));
  });

  it('rejects checkout without required planKey or method', async () => {
    const res = await fetch(`${baseUrl}/api/payment/checkout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer test_token',
      },
      body: JSON.stringify({ accountOrCardNumber: '03001234567' }),
    });

    const data = await res.json();
    assert.strictEqual(res.status, 400);
    assert.strictEqual(data.error, 'Validation Error');
  });

  it('rejects checkout with unsupported payment method', async () => {
    const res = await fetch(`${baseUrl}/api/payment/checkout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer test_token',
      },
      body: JSON.stringify({
        planKey: 'annual',
        method: 'bitcoin',
        accountOrCardNumber: '03001234567',
      }),
    });

    const data = await res.json();
    assert.strictEqual(res.status, 400);
    assert.strictEqual(data.error, 'Validation Error');
  });

  it('checkout creates a PENDING intent and NEVER sets isPremium: true', async () => {
    const res = await fetch(`${baseUrl}/api/payment/checkout`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer test_token',
      },
      body: JSON.stringify({
        planKey: 'annual',
        method: 'easypaisa',
        accountOrCardNumber: '03001234567',
      }),
    });

    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.status, 'Pending');
    assert.strictEqual(data.isPremium, undefined, 'checkout MUST NOT grant isPremium: true!');
    assert.strictEqual(data.planKey, 'annual');
    assert.strictEqual(data.amountPkr, 2899.0);
    assert.ok(data.transactionId.startsWith('EP-'));
    assert.ok(data.clientSecret.length > 16);
  });

  it('rejects webhook with invalid HMAC signature', async () => {
    const payload = {
      event: 'payment.succeeded',
      transactionId: 'EP-998877',
      userId: 'test-user-123',
      planKey: 'annual',
      amountPkr: 2899.0,
    };

    const res = await fetch(`${baseUrl}/api/payment/webhook`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-gateway-signature': 'invalid_signature_hash',
      },
      body: JSON.stringify(payload),
    });

    assert.strictEqual(res.status, 403);
  });

  it('webhook verifies HMAC signature and is the ONLY handler that grants isPremium: true', async () => {
    const payload = {
      event: 'payment.succeeded',
      transactionId: 'EP-998877',
      userId: 'test-user-123',
      planKey: 'annual',
      amountPkr: 2899.0,
    };
    const rawPayload = JSON.stringify(payload);
    const validSignature = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(rawPayload)
      .digest('hex');

    const res = await fetch(`${baseUrl}/api/payment/webhook`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-gateway-signature': validSignature,
      },
      body: rawPayload,
    });

    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.received, true);
    assert.strictEqual(data.status, 'processed');
    assert.strictEqual(data.isPremium, true, 'Webhook MUST be the entity granting isPremium!');
  });
});
