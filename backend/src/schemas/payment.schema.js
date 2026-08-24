/**
 * Strict validation schemas for Payment & Subscription endpoints
 */

const checkoutSchema = {
  planKey: {
    type: 'string',
    required: true,
    enum: ['annual', 'monthly', 'lifetime'],
  },
  method: {
    type: 'string',
    required: true,
    enum: ['easypaisa', 'jazzcash', 'card'],
  },
  accountOrCardNumber: {
    type: 'string',
    required: true,
    minLength: 11,
    maxLength: 24,
  },
  cnicOrOtp: {
    type: 'string',
    required: false,
    maxLength: 16,
  },
  cardHolderName: {
    type: 'string',
    required: false,
    maxLength: 64,
  },
  expiryDate: {
    type: 'string',
    required: false,
    maxLength: 7,
  },
  cvv: {
    type: 'string',
    required: false,
    maxLength: 4,
  },
};

const webhookSchema = {
  event: {
    type: 'string',
    required: true,
    enum: ['payment.succeeded', 'payment.failed'],
  },
  transactionId: {
    type: 'string',
    required: true,
    minLength: 5,
    maxLength: 64,
  },
  userId: {
    type: 'string',
    required: true,
    minLength: 1,
    maxLength: 128,
  },
  planKey: {
    type: 'string',
    required: true,
    enum: ['annual', 'monthly', 'lifetime'],
  },
  amountPkr: {
    type: 'number',
    required: true,
    min: 1,
  },
};

module.exports = {
  checkoutSchema,
  webhookSchema,
};
