const express = require('express');
const router = express.Router();
const multer = require('multer');
const axios = require('axios');
const { authenticate } = require('../middleware/auth');
const { authenticatedUserRateLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validator');
const { uploadSchema } = require('../schemas/storage.schema');
const { logAndSanitizeError } = require('../utils/logger');
const {
  MAX_FILE_SIZE_BYTES,
  inspectImageBuffer,
  generateSafeStorageKey,
} = require('../utils/fileValidator');

// Apply authentication followed by authenticated user rate limiter
router.use(authenticate);
router.use(authenticatedUserRateLimiter);

// In-memory Multer with strict byte limit to prevent server memory exhaustion
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_FILE_SIZE_BYTES,
    files: 1,
  },
});

/**
 * POST /api/storage/upload
 * Validates file type, size, and magic-byte content, sanitizes storage key,
 * and securely saves to isolated Cloudflare R2 object storage (outside web root).
 */
router.post('/upload', upload.single('image'), validate({ body: uploadSchema }), async (req, res) => {
  try {
    let fileBuffer;
    let requestedFileName = (req.body && req.body.fileName) || null;

    if (req.file) {
      fileBuffer = req.file.buffer;
      if (!requestedFileName && req.file.originalname) {
        requestedFileName = req.file.originalname;
      }
    } else if (req.body && req.body.imageBase64) {
      const cleanBase64 = req.body.imageBase64.replace(/^data:image\/[a-z0-9\+\-\.]+;base64,/, '');
      fileBuffer = Buffer.from(cleanBase64, 'base64');
    }

    if (!fileBuffer || fileBuffer.length === 0) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'No file content provided for upload.',
      });
    }

    // 1. Deep Magic-Byte Content & File Size Inspection
    const inspection = inspectImageBuffer(fileBuffer);
    if (!inspection.valid) {
      return res.status(400).json({
        error: 'Invalid File Content',
        message: inspection.error || 'Uploaded file is not a supported authentic image format.',
      });
    }

    // 2. Enforce Safe, Collision-Free, Traversal-Proof Storage Key with Verified Extension
    const safeStorageKey = generateSafeStorageKey(requestedFileName, inspection.ext);

    const workerUrl = process.env.CLOUDFLARE_WORKER_URL;
    const appSecret = process.env.CLOUDFLARE_APP_SECRET;
    const publicUrl = process.env.CLOUDFLARE_PUBLIC_R2_URL;

    if (!workerUrl || !appSecret) {
      return res.status(500).json({ error: 'Cloudflare storage is not configured on the server.' });
    }

    // 3. Proxy upload to isolated Cloudflare R2 Object Storage with strict nosniff Content-Type
    const uploadRes = await axios.put(workerUrl, fileBuffer, {
      headers: {
        'X-App-Secret': appSecret,
        'X-File-Name': safeStorageKey,
        'Content-Type': inspection.mimeType,
        'X-Content-Type-Options': 'nosniff',
      },
      maxBodyLength: MAX_FILE_SIZE_BYTES + 1024,
      maxContentLength: MAX_FILE_SIZE_BYTES + 1024,
    });

    if (uploadRes.status === 200 && uploadRes.data) {
      const uploadedFilename = uploadRes.data.filename || safeStorageKey;
      const finalUrl = `${publicUrl}/${uploadedFilename}`;
      return res.json({
        success: true,
        url: finalUrl,
        filename: uploadedFilename,
        mimeType: inspection.mimeType,
        sizeBytes: fileBuffer.length,
      });
    }

    throw new Error(`Cloudflare upload returned status ${uploadRes.status}`);
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Failed to upload image to cloud storage. Please try again.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

module.exports = router;
