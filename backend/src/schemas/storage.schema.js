const { PATTERNS } = require('../middleware/validator');

const uploadSchema = {
  allowUnknown: false,
  validateRoot(body, req) {
    const hasFile = req && req.file && req.file.buffer && req.file.buffer.length > 0;
    const hasBase64 = body && typeof body.imageBase64 === 'string' && body.imageBase64.trim().length > 0;

    if (!hasFile && !hasBase64) {
      return 'You must provide either a multipart file upload ("image") or a base64-encoded string ("imageBase64").';
    }
    return null;
  },
  properties: {
    fileName: {
      type: 'string',
      required: false,
      minLength: 1,
      maxLength: 255,
      pattern: PATTERNS.SAFE_FILENAME,
      patternMessage: '"fileName" must be a valid filename without directory traversal characters (/ \\ ..).',
    },
    imageBase64: {
      type: 'string',
      required: false,
      maxLength: 28 * 1024 * 1024, // ~20MB binary image in base64
      pattern: PATTERNS.BASE64_DATA,
      patternMessage: '"imageBase64" must be a valid base64-encoded image string.',
    },
  },
};

module.exports = {
  uploadSchema,
};
