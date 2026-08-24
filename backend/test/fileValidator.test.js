const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const {
  inspectImageBuffer,
  generateSafeStorageKey,
  MAX_FILE_SIZE_BYTES,
} = require('../src/utils/fileValidator');

describe('File Upload Security & Deep Content Inspection Tests', () => {
  test('validates authentic JPEG images by magic bytes (FF D8 FF)', () => {
    const validJpeg = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, ...new Array(30).fill(0)]);
    const result = inspectImageBuffer(validJpeg);

    assert.equal(result.valid, true);
    assert.equal(result.mimeType, 'image/jpeg');
    assert.equal(result.ext, 'jpg');
  });

  test('validates authentic PNG images by magic bytes (89 50 4E 47 0D 0A 1A 0A)', () => {
    const validPng = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, ...new Array(30).fill(0)]);
    const result = inspectImageBuffer(validPng);

    assert.equal(result.valid, true);
    assert.equal(result.mimeType, 'image/png');
    assert.equal(result.ext, 'png');
  });

  test('validates authentic WEBP images by RIFF...WEBP signature', () => {
    const validWebp = Buffer.alloc(40);
    // RIFF
    validWebp[0] = 0x52;
    validWebp[1] = 0x49;
    validWebp[2] = 0x46;
    validWebp[3] = 0x46;
    // WEBP
    validWebp[8] = 0x57;
    validWebp[9] = 0x45;
    validWebp[10] = 0x42;
    validWebp[11] = 0x50;

    const result = inspectImageBuffer(validWebp);
    assert.equal(result.valid, true);
    assert.equal(result.mimeType, 'image/webp');
    assert.equal(result.ext, 'webp');
  });

  test('rejects disguised executables (Windows PE MZ) even if named .jpg', () => {
    const exeBuffer = Buffer.from([0x4d, 0x5a, 0x90, 0x00, ...new Array(40).fill(0)]);
    const result = inspectImageBuffer(exeBuffer);

    assert.equal(result.valid, false);
    assert.ok(result.error.includes('Security violation'));
  });

  test('rejects Linux ELF binaries disguised as images', () => {
    const elfBuffer = Buffer.from([0x7f, 0x45, 0x4c, 0x46, ...new Array(40).fill(0)]);
    const result = inspectImageBuffer(elfBuffer);

    assert.equal(result.valid, false);
    assert.ok(result.error.includes('Security violation'));
  });

  test('rejects PHP scripts disguised as images', () => {
    const phpScript = Buffer.from('<?php echo system($_GET["cmd"]); ?>' + 'A'.repeat(20));
    const result = inspectImageBuffer(phpScript);

    assert.equal(result.valid, false);
    assert.ok(result.error.includes('Security violation'));
  });

  test('rejects HTML and SVG markup containing script payloads (XSS protection)', () => {
    const htmlPayload = Buffer.from('<svg onload=alert(1)>' + 'B'.repeat(30));
    const result = inspectImageBuffer(htmlPayload);

    assert.equal(result.valid, false);
    assert.ok(result.error.includes('Security violation'));
  });

  test('rejects oversized files exceeding 15MB limit', () => {
    const oversizedBuffer = Buffer.alloc(MAX_FILE_SIZE_BYTES + 100);
    oversizedBuffer[0] = 0xff;
    oversizedBuffer[1] = 0xd8;
    oversizedBuffer[2] = 0xff;

    const result = inspectImageBuffer(oversizedBuffer);
    assert.equal(result.valid, false);
    assert.ok(result.error.includes('exceeds the maximum allowed limit'));
  });

  test('generateSafeStorageKey removes path traversal and applies verified extension', () => {
    const maliciousName = '../../../../etc/cron.d/malicious.php';
    const key = generateSafeStorageKey(maliciousName, 'jpg');

    assert.ok(!key.includes('..'));
    assert.ok(!key.includes('/'));
    assert.ok(!key.includes('\\'));
    assert.ok(!key.includes('php'));
    assert.ok(key.endsWith('.jpg'));
    assert.match(key, /^img_\d+_[a-zA-Z0-9_\-]+_[a-f0-9]+\.jpg$/);
  });
});
