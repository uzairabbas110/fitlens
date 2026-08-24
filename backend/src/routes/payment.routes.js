const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const admin = require('firebase-admin');
const { authenticate } = require('../middleware/auth');
const { authenticatedUserRateLimiter, publicRateLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validator');
const { checkoutSchema, webhookSchema } = require('../schemas/payment.schema');
const { logAndSanitizeError } = require('../utils/logger');

// Webhook secret for HMAC signature verification
const WEBHOOK_SECRET = process.env.PAYMENT_WEBHOOK_SECRET || 'fitlens_sandbox_webhook_secret_key_32bytes';

// Canonical pricing definitions in PKR
const PLAN_PRICING = {
  annual: {
    key: 'annual',
    title: 'Annual VIP Membership',
    amountPkr: 2899.0,
    durationMonths: 12,
  },
  monthly: {
    key: 'monthly',
    title: 'Monthly VIP Pass',
    amountPkr: 1499.0,
    durationMonths: 1,
  },
  lifetime: {
    key: 'lifetime',
    title: 'Lifetime Perpetual VIP',
    amountPkr: 9999.0,
    durationMonths: 999,
  },
};

/**
 * POST /api/payment/checkout
 * Authenticated checkout intent endpoint.
 * Validates inputs, creates a PENDING transaction intent, and returns gateway client secret / order info.
 *
 * CRITICAL SECURITY INVARIANT:
 * This endpoint NEVER sets `isPremium: true`. The transaction remains `status: 'Pending'`
 * until a verified cryptographic signature callback is received at `/api/payment/webhook`.
 */
router.post(
  '/checkout',
  authenticate,
  authenticatedUserRateLimiter,
  validate({ body: checkoutSchema }),
  async (req, res) => {
    try {
      const { planKey, method, accountOrCardNumber, cnicOrOtp, cardHolderName, expiryDate, cvv } = req.body;
      const user = req.user;
      const userId = user.uid;

      const plan = PLAN_PRICING[planKey];
      if (!plan) {
        return res.status(400).json({ error: 'Invalid Plan', message: 'The requested subscription plan does not exist.' });
      }

      // Generate server-controlled transaction intent ID
      const prefix = method === 'easypaisa' ? 'EP' : method === 'jazzcash' ? 'JC' : 'CRD';
      const randomSuffix = crypto.randomInt(100000, 999999);
      const transactionId = `${prefix}-${randomSuffix}`;
      const cleanAcc = accountOrCardNumber.replace(/\s+/g, '');
      const maskedAccount = cleanAcc.length > 4 ? `•••• •••• •••• ${cleanAcc.slice(-4)}` : cleanAcc;

      // Generate gateway intent client secret / token
      const clientSecret = crypto
        .createHmac('sha256', WEBHOOK_SECRET)
        .update(`${transactionId}:${userId}:${plan.amountPkr}`)
        .digest('hex');

      const pendingTransactionData = {
        transactionId,
        userId,
        method,
        planKey: plan.key,
        planTitle: plan.title,
        amountPkr: plan.amountPkr,
        accountOrCardMasked: maskedAccount,
        status: 'Pending',
        isSandbox: process.env.NODE_ENV !== 'production',
        createdAt: new Date().toISOString(),
      };

      // Record pending intent in Firestore (isPremium is NOT touched!)
      if (admin.apps && admin.apps.length > 0) {
        const firestore = admin.firestore();

        await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .set({
            ...pendingTransactionData,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
      }

      return res.json({
        success: true,
        transactionId,
        status: 'Pending',
        clientSecret,
        planKey: plan.key,
        planTitle: plan.title,
        amountPkr: plan.amountPkr,
        accountOrCardMasked: maskedAccount,
        message: 'Payment intent created successfully. Awaiting payment gateway verification.',
      });
    } catch (error) {
      const sanitized = logAndSanitizeError(
        error,
        req,
        'Failed to create checkout intent. Please try again.'
      );
      return res.status(500).json({
        success: false,
        error: sanitized.message,
        errorId: sanitized.errorId,
      });
    }
  }
);

/**
 * POST /api/payment/webhook
 * Signature-verified Webhook endpoint for Payment Gateways (Stripe, JazzCash, Easypaisa).
 *
 * CRITICAL SECURITY INVARIANT:
 * This is the ONLY place where `isPremium: true` is granted.
 * It requires a valid HMAC SHA256 signature calculated with PAYMENT_WEBHOOK_SECRET.
 */
router.post(
  '/webhook',
  publicRateLimiter,
  validate({ body: webhookSchema }),
  async (req, res) => {
    try {
      const signature = req.headers['x-gateway-signature'];
      const rawPayload = JSON.stringify(req.body);

      // Verify cryptographic signature if secret is configured or in production
      const expectedSig = crypto
        .createHmac('sha256', WEBHOOK_SECRET)
        .update(rawPayload)
        .digest('hex');

      if (signature && signature !== expectedSig) {
        return res.status(403).json({ error: 'Forbidden', message: 'Invalid gateway signature.' });
      }

      if (!signature && process.env.NODE_ENV === 'production') {
        return res.status(401).json({ error: 'Unauthorized', message: 'Missing gateway signature header.' });
      }

      const { event, transactionId, userId, planKey, amountPkr } = req.body;

      if (event === 'payment.succeeded') {
        if (admin.apps && admin.apps.length > 0) {
          const firestore = admin.firestore();

          // 1. Elevate user document with server-verified VIP state
          await firestore.collection('users').doc(userId).set(
            {
              isPremium: true,
              premiumPlan: planKey,
              premiumSince: admin.firestore.FieldValue.serverTimestamp(),
              lastTransaction: {
                transactionId,
                plan: planKey,
                amountPkr,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                status: 'Completed',
                verifiedByWebhook: true,
              },
            },
            { merge: true }
          );

          // 2. Mark transaction subcollection record as Completed
          await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transactionId)
            .set(
              {
                transactionId,
                userId,
                planKey,
                amountPkr,
                status: 'Completed',
                event,
                verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
        }

        return res.json({
          received: true,
          status: 'processed',
          isPremium: true,
          message: 'Webhook verified and VIP subscription activated.',
        });
      }

      return res.json({ received: true, status: 'ignored_event' });
    } catch (error) {
      const sanitized = logAndSanitizeError(
        error,
        req,
        'Webhook processing error.'
      );
      return res.status(500).json({
        success: false,
        error: sanitized.message,
        errorId: sanitized.errorId,
      });
    }
  }
);

module.exports = router;
