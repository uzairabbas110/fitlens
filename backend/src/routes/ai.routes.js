const express = require('express');
const router = express.Router();
const geminiService = require('../services/gemini.service');
const { authenticate } = require('../middleware/auth');
const { authenticatedUserRateLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validator');
const { generateSchema, chatSchema, measureSchema } = require('../schemas/ai.schema');
const { logAndSanitizeError } = require('../utils/logger');

// Apply authentication followed by authenticated user rate limiter
router.use(authenticate);
router.use(authenticatedUserRateLimiter);

/**
 * POST /api/ai/generate
 * Generates AI content from prompt and optional image (strictly validated)
 */
router.post('/generate', validate({ body: generateSchema }), async (req, res) => {
  try {
    const { prompt, imageBase64, imageMimeType, multipleImages, extractJson } = req.body;

    const responseText = await geminiService.generateContent({
      prompt,
      imageBase64,
      imageMimeType,
      multipleImages,
    });

    if (extractJson === true) {
      const parsedJson = geminiService.extractJson(responseText);
      return res.json({ success: true, text: responseText, data: parsedJson });
    }

    return res.json({ success: true, text: responseText });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to generate AI content at this time. Please try again later.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

/**
 * POST /api/ai/chat
 * Multi-turn conversational styling chat (strictly validated)
 */
router.post('/chat', validate({ body: chatSchema }), async (req, res) => {
  try {
    const { history, message } = req.body;

    const responseText = await geminiService.generateChatContent({
      history: history || [],
      message,
    });

    return res.json({ success: true, text: responseText });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to process chat message with AI Stylist. Please try again.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

/**
 * POST /api/ai/measure
 * Specialized body proportion and sizing analysis endpoint (strictly validated)
 */
router.post('/measure', validate({ body: measureSchema }), async (req, res) => {
  try {
    const { imageBase64, imageMimeType = 'image/jpeg' } = req.body;

    const prompt = `
You are an expert fashion stylist and tailor.
Analyze the attached full-body photo of the user. Estimate their exact body measurements (chest_inches, waist_inches, hips_inches) as realistic numbers.
Estimate their general body type (e.g., Athletic, Slim, Curvy, Broad Shoulders, Hourglass, Rectangle) and standard clothing size (e.g., Small (S), Medium (M), Large (L)).
Provide 2-3 concise sentences of personalized style advice on what fits, necklines, and silhouettes flatter them best.

Return ONLY a valid JSON object matching this schema:
{
  "estimated_size": "Medium (M)",
  "body_type": "Athletic with broad shoulders",
  "chest_inches": 40.0,
  "waist_inches": 32.0,
  "hips_inches": 38.0,
  "advice": "Opt for structured jackets and tailored fits to complement your shoulders. V-necks and vertical silhouettes will balance your proportions."
}
`;

    const responseText = await geminiService.generateContent({
      prompt,
      imageBase64,
      imageMimeType,
    });

    const jsonMap = geminiService.extractJson(responseText);

    return res.json({
      success: true,
      data: jsonMap,
      rawText: responseText,
    });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to complete body sizing analysis. Please try again with a clear photo.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

module.exports = router;
