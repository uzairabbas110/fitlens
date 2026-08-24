const crypto = require('crypto');

/**
 * Generates a short, unique error incident reference ID
 */
function generateErrorId() {
  return `err_${crypto.randomBytes(4).toString('hex')}`;
}

/**
 * Securely logs full error details server-side with metadata and stack trace
 * Returns a clean, sanitized error object for client response (no internal paths or stack traces)
 */
function logAndSanitizeError(err, req = null, customClientMessage = null) {
  const errorId = generateErrorId();
  const timestamp = new Date().toISOString();
  const path = req ? `${req.method} ${req.originalUrl || req.path}` : 'N/A';
  const ip = req ? req.ip || (req.headers && req.headers['x-forwarded-for']) || '127.0.0.1' : 'N/A';

  // Log full detailed trace server-side
  console.error(`\n[${timestamp}] [ERROR_ID: ${errorId}] [ROUTE: ${path}] [IP: ${ip}]`);
  if (err instanceof Error) {
    console.error(`Message: ${err.message}`);
    if (err.stack) {
      console.error(`Stack:\n${err.stack}`);
    }
  } else {
    console.error(`Error:`, err);
  }
  console.error(`------------------------------------------------------------\n`);

  // Return clean, safe response payload for client consumption
  return {
    error: 'Internal Server Error',
    message: customClientMessage || 'An unexpected error occurred. Please try again later.',
    errorId,
  };
}

module.exports = {
  generateErrorId,
  logAndSanitizeError,
};
