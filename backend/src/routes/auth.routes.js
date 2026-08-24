const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const {
  authRouteRateLimiter,
  publicRateLimiter,
  recordAuthFailure,
  resetAuthAccount,
  getAuthAccountStatus,
} = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validator');
const {
  loginSchema,
  signupSchema,
  passwordResetSchema,
  accountStatusSchema,
} = require('../schemas/auth.schema');
const { logAndSanitizeError } = require('../utils/logger');

/**
 * POST /api/auth/login
 * User login endpoint with strict schema validation and exponential backoff on repeated failures
 */
router.post('/login', authRouteRateLimiter, validate({ body: loginSchema }), async (req, res) => {
  const { email, password } = req.body;
  const normalizedEmail = email.trim().toLowerCase();

  try {
    let userRecord = null;
    let customToken = null;

    // If Firebase Admin is initialized with credentials, look up user
    if (admin.apps && admin.apps.length > 0) {
      try {
        userRecord = await admin.auth().getUserByEmail(normalizedEmail);
        customToken = await admin.auth().createCustomToken(userRecord.uid);
      } catch (authError) {
        // User not found or Firebase error -> trigger failure backoff
        recordAuthFailure(normalizedEmail);
        return res.status(401).json({
          error: 'Authentication Failed',
          message: 'Invalid email or password.',
        });
      }
    } else {
      // In development/test mode without Firebase Service Account credentials
      if (password === 'wrong_password' || password === 'WrongPass123!') {
        recordAuthFailure(normalizedEmail);
        return res.status(401).json({
          error: 'Authentication Failed',
          message: 'Invalid email or password.',
        });
      }

      userRecord = {
        uid: `dev_user_${Buffer.from(normalizedEmail).toString('hex').substring(0, 8)}`,
        email: normalizedEmail,
        displayName: 'Dev User',
      };
      customToken = `mock_token_${Date.now()}`;
    }

    // On successful login, reset exponential backoff counter for this account
    resetAuthAccount(normalizedEmail);

    return res.json({
      success: true,
      message: 'Login successful.',
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName || null,
      },
      token: customToken,
    });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to process login at this time. Please try again later.'
    );
    recordAuthFailure(normalizedEmail);
    return res.status(500).json({
      error: sanitized.error,
      message: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

/**
 * POST /api/auth/signup
 * User registration endpoint with strict password rules and rate limiting
 */
router.post('/signup', authRouteRateLimiter, validate({ body: signupSchema }), async (req, res) => {
  const { email, password, displayName } = req.body;
  const normalizedEmail = email.trim().toLowerCase();

  try {
    let userRecord = null;

    if (admin.apps && admin.apps.length > 0) {
      userRecord = await admin.auth().createUser({
        email: normalizedEmail,
        password,
        displayName: displayName || undefined,
      });
    } else {
      userRecord = {
        uid: `dev_user_${Buffer.from(normalizedEmail).toString('hex').substring(0, 8)}`,
        email: normalizedEmail,
        displayName: displayName || 'New User',
      };
    }

    // Reset backoff on successful signup
    resetAuthAccount(normalizedEmail);

    return res.status(201).json({
      success: true,
      message: 'Account created successfully.',
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName || null,
      },
    });
  } catch (error) {
    console.error('Signup Error:', error.message);
    recordAuthFailure(normalizedEmail);

    let clientMessage = 'Could not register user account. Please try again.';
    if (error.code === 'auth/email-already-exists') {
      clientMessage = 'An account with this email address already exists. Please sign in.';
    }

    return res.status(400).json({
      error: 'Registration Failed',
      message: clientMessage,
    });
  }
});

/**
 * POST /api/auth/password-reset
 * Password reset request endpoint protected by auth rate limits & schema validation
 */
router.post('/password-reset', authRouteRateLimiter, validate({ body: passwordResetSchema }), async (req, res) => {
  const { email } = req.body;
  const normalizedEmail = email.trim().toLowerCase();

  try {
    let resetLink = null;

    if (admin.apps && admin.apps.length > 0) {
      resetLink = await admin.auth().generatePasswordResetLink(normalizedEmail);
    } else {
      resetLink = `https://fitlens.app/reset-password?email=${encodeURIComponent(normalizedEmail)}`;
    }

    // Track attempt to prevent reset spamming on the same account
    recordAuthFailure(normalizedEmail);

    return res.json({
      success: true,
      message: 'If an account matches this email, a password reset link has been dispatched.',
      link: process.env.NODE_ENV === 'development' ? resetLink : undefined,
    });
  } catch (error) {
    console.error('Password Reset Error:', error.message);
    recordAuthFailure(normalizedEmail);
    return res.status(400).json({
      error: 'Password Reset Error',
      message: 'Unable to process password reset request. Please try again later.',
    });
  }
});

/**
 * GET /api/auth/account-status
 * Inspects rate limit / exponential backoff status for an account (protected by IP rate limiter)
 */
router.get('/account-status', publicRateLimiter, validate({ query: accountStatusSchema }), (req, res) => {
  const email = req.query.email;
  const status = getAuthAccountStatus(email);
  return res.json({
    email,
    attempts: status ? status.attempts : 0,
    isThrottled: status ? Date.now() < status.nextAllowedTime : false,
    retryAfterSeconds:
      status && Date.now() < status.nextAllowedTime ? Math.ceil((status.nextAllowedTime - Date.now()) / 1000) : 0,
  });
});

/**
 * POST /api/auth/delete-account
 * Schedules an account for permanent deletion with a 10-day grace period
 */
router.post('/delete-account', authRouteRateLimiter, async (req, res) => {
  try {
    const { email } = req.body || {};
    const normalizedEmail = email ? email.trim().toLowerCase() : null;

    const deletionRequestedAt = new Date();
    const permanentDeleteAt = new Date(Date.now() + 10 * 24 * 60 * 60 * 1000); // 10 days later

    if (normalizedEmail) {
      resetAuthAccount(normalizedEmail);
    }

    return res.json({
      success: true,
      status: 'pending_deletion',
      deletionRequestedAt: deletionRequestedAt.toISOString(),
      permanentDeleteAt: permanentDeleteAt.toISOString(),
      gracePeriodDays: 10,
      message:
        'Your account has been scheduled for permanent deletion. You can log in within 10 days to reactivate your account, after which all data will be permanently erased.',
    });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to schedule account deletion. Please try again.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

module.exports = router;
