const crypto = require('crypto');

/**
 * Supported Authentic Image MIME types and their validated signatures
 */
const ALLOWED_MIME_TYPES = {
  'image/jpeg': { ext: 'jpg', contentType: 'image/jpeg' },
  'image/png': { ext: 'png', contentType: 'image/png' },
  'image/webp': { ext: 'webp', contentType: 'image/webp' },
  'image/gif': { ext: 'gif', contentType: 'image/gif' },
  'image/heic': { ext: 'heic', contentType: 'image/heic' },
};

const MAX_FILE_SIZE_BYTES = 15 * 1024 * 1024; // 15 Megabytes
const MIN_FILE_SIZE_BYTES = 32; // Minimum byte length for valid image header

/**
 * Inspects raw buffer magic bytes to accurately determine the true file type
 * Prevents disguised executables, scripts, HTML/SVG polyglots, and fake extensions.
 *
 * @param {Buffer} buffer - File buffer to inspect
 * @returns {{ valid: boolean, mimeType?: string, ext?: string, error?: string }}
 */
function inspectImageBuffer(buffer) {
  if (!Buffer.isBuffer(buffer)) {
    return { valid: false, error: 'Invalid file buffer provided.' };
  }

  if (buffer.length < MIN_FILE_SIZE_BYTES) {
    return { valid: false, error: 'File is too small to be a valid image.' };
  }

  if (buffer.length > MAX_FILE_SIZE_BYTES) {
    return { valid: false, error: `File size (${(buffer.length / (1024 * 1024)).toFixed(2)}MB) exceeds the maximum allowed limit of ${(MAX_FILE_SIZE_BYTES / (1024 * 1024))}MB.` };
  }

  // Check JPEG: FF D8 FF
  if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
    return { valid: true, mimeType: 'image/jpeg', ext: 'jpg' };
  }

  // Check PNG: 89 50 4E 47 0D 0A 1A 0A
  if (
    buffer[0] === 0x89 &&
    buffer[1] === 0x50 &&
    buffer[2] === 0x4e &&
    buffer[3] === 0x47 &&
    buffer[4] === 0x0d &&
    buffer[5] === 0x0a &&
    buffer[6] === 0x1a &&
    buffer[7] === 0x0a
  ) {
    return { valid: true, mimeType: 'image/png', ext: 'png' };
  }

  // Check WEBP: RIFF (bytes 0-3) + WEBP (bytes 8-11)
  if (
    buffer[0] === 0x52 &&
    buffer[1] === 0x49 &&
    buffer[2] === 0x46 &&
    buffer[3] === 0x46 &&
    buffer[8] === 0x57 &&
    buffer[9] === 0x45 &&
    buffer[10] === 0x42 &&
    buffer[11] === 0x50
  ) {
    return { valid: true, mimeType: 'image/webp', ext: 'webp' };
  }

  // Check GIF: GIF87a or GIF89a (47 49 46 38 37/39 61)
  if (
    buffer[0] === 0x47 &&
    buffer[1] === 0x49 &&
    buffer[2] === 0x46 &&
    buffer[3] === 0x38 &&
    (buffer[4] === 0x37 || buffer[4] === 0x39) &&
    buffer[5] === 0x61
  ) {
    return { valid: true, mimeType: 'image/gif', ext: 'gif' };
  }

  // Check HEIF/HEIC: bytes 4-11 contain ftyp (66 74 79 70) followed by heic, mif1, heix, etc.
  if (buffer.length >= 12) {
    const ftyp = buffer.toString('ascii', 4, 8);
    const brand = buffer.toString('ascii', 8, 12);
    if (ftyp === 'ftyp' && ['heic', 'heix', 'mif1', 'msf1', 'hevc'].includes(brand)) {
      return { valid: true, mimeType: 'image/heic', ext: 'heic' };
    }
  }

  // Explicitly check and flag dangerous executable or script headers
  const headerAscii = buffer.slice(0, 50).toString('ascii').toLowerCase();
  if (
    (buffer[0] === 0x4d && buffer[1] === 0x5a) || // Windows EXE / DLL
    (buffer[0] === 0x7f && buffer[1] === 0x45 && buffer[2] === 0x4c && buffer[3] === 0x46) || // Linux ELF
    headerAscii.includes('<?php') ||
    headerAscii.includes('<script') ||
    headerAscii.includes('<html') ||
    headerAscii.includes('<!doctype') ||
    headerAscii.includes('<svg') ||
    headerAscii.startsWith('#!')
  ) {
    return {
      valid: false,
      error: 'Security violation: Executable, script, or active markup file content detected and rejected.',
    };
  }

  return {
    valid: false,
    error: 'Invalid file format. Uploaded file content does not match any allowed image signature (JPEG, PNG, WEBP, GIF, HEIC).',
  };
}

/**
 * Generates an isolated, safe, collision-free storage filename
 * Guarantees zero directory traversal, null bytes, or dangerous extensions.
 *
 * @param {string} originalName - Suggested original name (optional)
 * @param {string} verifiedExtension - Verified file extension from magic bytes
 * @returns {string} - Safe random storage key
 */
function generateSafeStorageKey(originalName, verifiedExtension) {
  const ext = verifiedExtension.replace(/^\./, '').toLowerCase();
  const randomSuffix = crypto.randomBytes(8).toString('hex');
  const timestamp = Date.now();

  if (originalName && typeof originalName === 'string') {
    // Extract base name without user-supplied extension
    const baseWithoutExt = originalName.includes('.')
      ? originalName.split('.').slice(0, -1).join('_')
      : originalName;

    // Sanitize user provided stem: strip path traversal and non-alphanumeric chars
    const baseClean = baseWithoutExt
      .replace(/[\/\\]/g, '')
      .replace(/\.\./g, '')
      .replace(/[^a-zA-Z0-9_\-]/g, '_')
      .replace(/^_+|_+$/g, '')
      .slice(0, 30);

    if (baseClean.length > 0) {
      return `img_${timestamp}_${baseClean}_${randomSuffix}.${ext}`;
    }
  }

  return `img_${timestamp}_${randomSuffix}.${ext}`;
}

module.exports = {
  MAX_FILE_SIZE_BYTES,
  MIN_FILE_SIZE_BYTES,
  ALLOWED_MIME_TYPES,
  inspectImageBuffer,
  generateSafeStorageKey,
};
