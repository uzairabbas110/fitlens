const { test, describe } = require('node:test');
const assert = require('node:assert/strict');

const { validate, validateField, validateObject, PATTERNS } = require('../src/middleware/validator');
const { signupSchema, loginSchema, passwordRule, emailRule } = require('../src/schemas/auth.schema');
const { generateSchema, chatSchema, measureSchema } = require('../src/schemas/ai.schema');
const { currentWeatherSchema } = require('../src/schemas/weather.schema');
const { uploadSchema } = require('../src/schemas/storage.schema');

// Helper to create mock Express req, res, next objects
function createMockReqRes({ body = {}, query = {}, params = {}, file = null } = {}) {
  const req = {
    body,
    query,
    params,
    file,
  };

  const res = {
    statusCode: 200,
    body: null,
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

describe('Strict Input Schema Validator Tests', () => {
  describe('1. Password Strict Rules (> 8 chars, Upper, Lower, Number, Special)', () => {
    test('rejects passwords <= 8 characters', () => {
      // 8 characters long
      const err8 = validateField('password', 'Abc123!@', passwordRule);
      assert.ok(err8, 'Should reject 8-character password (must be longer than 8)');

      // 6 characters long
      const err6 = validateField('password', 'Ab12!@', passwordRule);
      assert.ok(err6, 'Should reject 6-character password');
    });

    test('rejects passwords missing uppercase letter', () => {
      const err = validateField('password', 'lowercase123!@#', passwordRule);
      assert.ok(err, 'Should reject password without uppercase');
    });

    test('rejects passwords missing lowercase letter', () => {
      const err = validateField('password', 'UPPERCASE123!@#', passwordRule);
      assert.ok(err, 'Should reject password without lowercase');
    });

    test('rejects passwords missing numeric digit', () => {
      const err = validateField('password', 'NoNumbersHere!@#', passwordRule);
      assert.ok(err, 'Should reject password without number');
    });

    test('rejects passwords missing special character', () => {
      const err = validateField('password', 'NoSpecialChars12345', passwordRule);
      assert.ok(err, 'Should reject password without special character');
    });

    test('accepts strong compliant passwords (> 8 chars, upper, lower, digit, special)', () => {
      const valid1 = validateField('password', 'FitLens2026!Secure', passwordRule);
      assert.equal(valid1, null);

      const valid2 = validateField('password', 'P@ssw0rd123', passwordRule);
      assert.equal(valid2, null);

      const valid3 = validateField('password', 'Abcdefg1#', passwordRule); // 9 chars
      assert.equal(valid3, null);
    });
  });

  describe('2. Email Format Validation', () => {
    test('rejects invalid email formats', () => {
      const invalidEmails = ['plainaddress', '@missingusername.com', 'user@.com', 'user@domain', 'user @domain.com'];
      for (const email of invalidEmails) {
        const err = validateField('email', email, emailRule);
        assert.ok(err, `Should reject invalid email: "${email}"`);
      }
    });

    test('accepts valid email formats', () => {
      const validEmails = ['user@example.com', 'first.last@fitlens.app', 'user+tag@domain.co.uk'];
      for (const email of validEmails) {
        const err = validateField('email', email, emailRule);
        assert.equal(err, null, `Should accept valid email: "${email}"`);
      }
    });
  });

  describe('3. Unknown Field Rejection (allowUnknown: false)', () => {
    test('rejects payloads containing unmodeled/unexpected properties', () => {
      const middleware = validate({ body: loginSchema });
      const { req, res, next, wasNextCalled } = createMockReqRes({
        body: {
          email: 'user@example.com',
          password: 'Password123!',
          maliciousField: 'exploit_code',
          adminBypass: true,
        },
      });

      middleware(req, res, next);
      assert.equal(wasNextCalled(), false);
      assert.equal(res.statusCode, 400);
      assert.equal(res.body.error, 'Validation Error');
      assert.ok(res.body.details.some((d) => d.field === 'maliciousField'));
      assert.ok(res.body.details.some((d) => d.field === 'adminBypass'));
    });
  });

  describe('4. AI Routes Schema Validation', () => {
    const generateMiddleware = validate({ body: generateSchema });

    test('rejects empty or excessively long prompt', () => {
      // Empty prompt
      let mock = createMockReqRes({ body: { prompt: '' } });
      generateMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);

      // Non-string prompt
      mock = createMockReqRes({ body: { prompt: 12345 } });
      generateMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);

      // Prompt > 10,000 chars
      mock = createMockReqRes({ body: { prompt: 'a'.repeat(10001) } });
      generateMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);
    });

    test('rejects invalid image MIME type', () => {
      const mock = createMockReqRes({
        body: {
          prompt: 'Analyze my outfit',
          imageBase64: 'aGVsbG8gd29ybGQ=',
          imageMimeType: 'application/x-executable',
        },
      });

      generateMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);
      assert.ok(mock.res.body.details.some((d) => d.field === 'imageMimeType'));
    });

    test('accepts valid AI generate payload', () => {
      const mock = createMockReqRes({
        body: {
          prompt: 'Analyze my style',
          imageBase64: 'aGVsbG8gd29ybGQ=',
          imageMimeType: 'image/jpeg',
          extractJson: true,
        },
      });

      generateMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);
    });
  });

  describe('5. Weather Route Query Validation', () => {
    const weatherMiddleware = validate({ query: currentWeatherSchema });

    test('rejects requests missing both city and coordinates', () => {
      const mock = createMockReqRes({ query: {} });
      weatherMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);
    });

    test('rejects out-of-range latitude or longitude', () => {
      // Lat > 90
      let mock = createMockReqRes({ query: { lat: '95.5', lon: '10.0' } });
      weatherMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);

      // Lon < -180
      mock = createMockReqRes({ query: { lat: '45.0', lon: '-195.0' } });
      weatherMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), false);
      assert.equal(mock.res.statusCode, 400);
    });

    test('accepts valid coordinates or city query', () => {
      // Valid city
      let mock = createMockReqRes({ query: { city: 'San Francisco, CA' } });
      weatherMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);

      // Valid lat/lon
      mock = createMockReqRes({ query: { lat: '37.7749', lon: '-122.4194' } });
      weatherMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);
    });
  });

  describe('6. Storage Route Safe Filename & Payload Validation', () => {
    const storageMiddleware = validate({ body: uploadSchema });

    test('rejects path traversal attempts in filename', () => {
      const traversalNames = ['../../evil.jpg', '/etc/passwd', '..\\boot.ini', 'file\0.jpg'];
      for (const name of traversalNames) {
        const mock = createMockReqRes({
          body: { fileName: name, imageBase64: 'aGVsbG8=' },
        });
        storageMiddleware(mock.req, mock.res, mock.next);
        assert.equal(mock.wasNextCalled(), false, `Should reject filename: ${name}`);
        assert.equal(mock.res.statusCode, 400);
      }
    });

    test('accepts clean filenames and base64 payloads', () => {
      const mock = createMockReqRes({
        body: { fileName: 'my_outfit_2026.jpg', imageBase64: 'aGVsbG8gd29ybGQ=' },
      });
      storageMiddleware(mock.req, mock.res, mock.next);
      assert.equal(mock.wasNextCalled(), true);
    });
  });
});
