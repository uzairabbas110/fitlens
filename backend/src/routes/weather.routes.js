const express = require('express');
const router = express.Router();
const axios = require('axios');
const geminiService = require('../services/gemini.service');
const { publicRateLimiter } = require('../middleware/rateLimiter');
const { validate } = require('../middleware/validator');
const { currentWeatherSchema } = require('../schemas/weather.schema');
const { logAndSanitizeError } = require('../utils/logger');

// Apply public rate limiter to weather routes
router.use(publicRateLimiter);

/**
 * GET /api/weather/current
 * Returns current weather and AI clothing suggestion for city or coordinates (strictly validated)
 */
router.get('/current', validate({ query: currentWeatherSchema }), async (req, res) => {
  try {
    const { lat, lon, city } = req.query;
    const apiKey = process.env.WEATHER_API_KEY;

    if (!apiKey) {
      return res.status(500).json({
        error: 'Configuration Error',
        message: 'Weather service is temporarily unavailable.',
      });
    }

    let query = '';
    if (lat !== undefined && lon !== undefined) {
      query = `${lat},${lon}`;
    } else if (city) {
      query = city.trim();
    }

    // Call Weatherstack API over secure HTTPS
    const weatherUrl = `https://api.weatherstack.com/current?access_key=${apiKey}&query=${encodeURIComponent(query)}`;
    const weatherResponse = await axios.get(weatherUrl);
    const data = weatherResponse.data;

    if (data.error) {
      console.warn('Weatherstack Provider Warning:', data.error);
      return res.status(400).json({
        error: 'Weather Lookup Error',
        message: 'Unable to find weather for the specified location. Please check spelling or coordinates.',
      });
    }

    const temp = data.current?.temperature ?? 22;
    const condition = (data.current?.weather_descriptions && data.current.weather_descriptions[0]) || 'Clear';
    const cityName = data.location?.name || city || 'your area';

    // Generate AI clothing advice for the weather
    let suggestion = 'Dress comfortably for the weather.';
    try {
      const prompt = `You are a fashion assistant. It is ${temp}°C and ${condition} in ${cityName}. Give a single, short sentence of clothing advice for this weather.`;
      const aiResponse = await geminiService.generateContent({ prompt });
      if (aiResponse) {
        suggestion = aiResponse.replace(/\n/g, '').trim();
      }
    } catch (_) {}

    return res.json({
      success: true,
      data: {
        ...data,
        ai_suggestion: suggestion,
      },
    });
  } catch (error) {
    const sanitized = logAndSanitizeError(
      error,
      req,
      'Unable to fetch weather information. Please try again later.'
    );
    return res.status(500).json({
      success: false,
      error: sanitized.message,
      errorId: sanitized.errorId,
    });
  }
});

module.exports = router;
