const { PATTERNS } = require('../middleware/validator');

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'];

const generateSchema = {
  allowUnknown: false,
  properties: {
    prompt: {
      type: 'string',
      required: true,
      minLength: 1,
      maxLength: 10000,
      minLengthMessage: '"prompt" must not be empty.',
      maxLengthMessage: '"prompt" length must not exceed 10,000 characters.',
    },
    imageBase64: {
      type: 'string',
      required: false,
      maxLength: 50 * 1024 * 1024, // 50MB base64 payload
      pattern: PATTERNS.BASE64_DATA,
      patternMessage: '"imageBase64" must be a valid base64-encoded image string.',
    },
    imageMimeType: {
      type: 'string',
      required: false,
      enum: ALLOWED_MIME_TYPES,
    },
    multipleImages: {
      type: 'array',
      required: false,
      maxItems: 10,
      items: {
        type: 'string',
        maxLength: 50 * 1024 * 1024,
        pattern: PATTERNS.BASE64_DATA,
        patternMessage: 'Each item in "multipleImages" must be a valid base64-encoded image string.',
      },
    },
    extractJson: {
      type: 'boolean',
      required: false,
    },
  },
};

const chatSchema = {
  allowUnknown: false,
  properties: {
    message: {
      type: 'string',
      required: true,
      minLength: 1,
      maxLength: 5000,
      minLengthMessage: '"message" must not be empty.',
      maxLengthMessage: '"message" length must not exceed 5,000 characters.',
    },
    history: {
      type: 'array',
      required: false,
      maxItems: 100,
      items: {
        type: 'object',
        properties: {
          role: {
            type: 'string',
            required: true,
            enum: ['user', 'model', 'assistant'],
          },
          text: {
            type: 'string',
            required: false,
            maxLength: 5000,
          },
          content: {
            type: 'string',
            required: false,
            maxLength: 5000,
          },
          parts: {
            type: 'array',
            required: false,
            maxItems: 10,
            items: {
              type: 'object',
              properties: {
                text: {
                  type: 'string',
                  required: false,
                  maxLength: 5000,
                },
              },
            },
          },
        },
      },
    },
  },
};

const measureSchema = {
  allowUnknown: false,
  properties: {
    imageBase64: {
      type: 'string',
      required: true,
      maxLength: 50 * 1024 * 1024,
      pattern: PATTERNS.BASE64_DATA,
      patternMessage: '"imageBase64" is required and must be a valid base64-encoded image string.',
    },
    imageMimeType: {
      type: 'string',
      required: false,
      enum: ALLOWED_MIME_TYPES,
    },
  },
};

module.exports = {
  generateSchema,
  chatSchema,
  measureSchema,
  ALLOWED_MIME_TYPES,
};
