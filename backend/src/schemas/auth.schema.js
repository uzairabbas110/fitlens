const { PATTERNS } = require('../middleware/validator');

const passwordRule = {
  type: 'string',
  required: true,
  minLength: 9,
  maxLength: 128,
  minLengthMessage: '"password" must be longer than 8 characters (minimum 9 characters).',
  maxLengthMessage: '"password" must not exceed 128 characters.',
  pattern: PATTERNS.STRONG_PASSWORD,
  patternMessage:
    '"password" must be longer than 8 characters and contain at least one uppercase letter (A-Z), one lowercase letter (a-z), one number (0-9), and one special character (e.g. !@#$%^&*).',
};

const emailRule = {
  type: 'string',
  required: true,
  minLength: 5,
  maxLength: 254,
  pattern: PATTERNS.EMAIL,
  patternMessage: '"email" must be a valid email address format (e.g. user@example.com).',
};

const loginSchema = {
  allowUnknown: false,
  properties: {
    email: emailRule,
    password: {
      type: 'string',
      required: true,
      minLength: 1,
      maxLength: 128,
    },
  },
};

const signupSchema = {
  allowUnknown: false,
  properties: {
    email: emailRule,
    password: passwordRule,
    displayName: {
      type: 'string',
      required: false,
      minLength: 1,
      maxLength: 100,
      pattern: /^[a-zA-Z0-9\s'._-]{1,100}$/,
      patternMessage: '"displayName" may only contain letters, numbers, spaces, and basic punctuation (.\'_-).',
    },
  },
};

const passwordResetSchema = {
  allowUnknown: false,
  properties: {
    email: emailRule,
  },
};

const accountStatusSchema = {
  allowUnknown: false,
  properties: {
    email: emailRule,
  },
};

module.exports = {
  loginSchema,
  signupSchema,
  passwordResetSchema,
  accountStatusSchema,
  passwordRule,
  emailRule,
};
