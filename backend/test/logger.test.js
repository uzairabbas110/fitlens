const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const { generateErrorId, logAndSanitizeError } = require('../src/utils/logger');

describe('Error Handling & Sanitization Tests', () => {
  test('generateErrorId generates unique err_ prefixed tracking IDs', () => {
    const id1 = generateErrorId();
    const id2 = generateErrorId();

    assert.match(id1, /^err_[a-f0-9]{8}$/);
    assert.match(id2, /^err_[a-f0-9]{8}$/);
    assert.notEqual(id1, id2);
  });

  test('logAndSanitizeError hides internal stack traces and file paths from client response', () => {
    const internalError = new Error('Database connection failed: /var/lib/postgresql/data error: permission denied');
    internalError.stack = 'Error: Database connection failed\n    at query (d:\\Development\\Backend\\src\\db.js:45:12)\n    at processTicksAndRejections (internal/process/task_queues.js:95:5)';

    const mockReq = {
      method: 'GET',
      originalUrl: '/api/weather/current',
      ip: '192.168.1.10',
    };

    const sanitized = logAndSanitizeError(internalError, mockReq);

    // Verify client payload is generic and safe
    assert.equal(sanitized.error, 'Internal Server Error');
    assert.equal(sanitized.message, 'An unexpected error occurred. Please try again later.');
    assert.match(sanitized.errorId, /^err_[a-f0-9]{8}$/);

    // Verify no internal paths, database details, or stack trace leaked in response
    assert.equal(sanitized.stack, undefined);
    assert.equal(sanitized.details, undefined);
    assert.ok(!JSON.stringify(sanitized).includes('postgresql'));
    assert.ok(!JSON.stringify(sanitized).includes('db.js'));
    assert.ok(!JSON.stringify(sanitized).includes('Development'));
  });

  test('logAndSanitizeError respects custom friendly client messages', () => {
    const internalError = new Error('Gemini API 500: High load internal error at https://generativelanguage.googleapis.com');
    const customMessage = 'Unable to generate outfit recommendations. Please try again.';

    const sanitized = logAndSanitizeError(internalError, null, customMessage);

    assert.equal(sanitized.error, 'Internal Server Error');
    assert.equal(sanitized.message, customMessage);
    assert.match(sanitized.errorId, /^err_[a-f0-9]{8}$/);
    assert.ok(!JSON.stringify(sanitized).includes('googleapis.com'));
  });

  test('handles non-Error objects gracefully', () => {
    const rawStringError = 'String error without object wrapper';
    const sanitized = logAndSanitizeError(rawStringError);

    assert.equal(sanitized.error, 'Internal Server Error');
    assert.equal(sanitized.message, 'An unexpected error occurred. Please try again later.');
    assert.match(sanitized.errorId, /^err_[a-f0-9]{8}$/);
  });
});
