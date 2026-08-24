const { GoogleGenerativeAI } = require('@google/generative-ai');
const axios = require('axios');

class GeminiService {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY;
    if (!this.apiKey) {
      console.warn('WARNING: GEMINI_API_KEY environment variable is not set!');
    }
    this.client = new GoogleGenerativeAI(this.apiKey);

    // Preferred active multimodal vision models from official Google Gemini API
    this.preferredModels = [
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-flash-8b',
      'gemini-2.0-flash-lite-preview-02-05',
      'gemini-1.5-pro',
    ];
  }

  _isTransientError(error) {
    const str = String(error).toLowerCase();
    return (
      str.includes('503') ||
      str.includes('high demand') ||
      str.includes('unavailable') ||
      str.includes('429') ||
      str.includes('quota') ||
      str.includes('resource_exhausted') ||
      str.includes('500') ||
      str.includes('internal') ||
      str.includes('timeout') ||
      str.includes('econnreset')
    );
  }

  async _delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * Generates content with text prompt and optional base64 image(s).
   */
  async generateContent({ prompt, imageBase64, imageMimeType = 'image/jpeg', multipleImages }) {
    const parts = [prompt];

    if (imageBase64) {
      // Strip potential base64 prefix if passed
      const cleanBase64 = imageBase64.replace(/^data:image\/[a-z]+;base64,/, '');
      parts.push({
        inlineData: {
          data: cleanBase64,
          mimeType: imageMimeType,
        },
      });
    }

    if (Array.isArray(multipleImages)) {
      for (const img of multipleImages) {
        const clean = img.replace(/^data:image\/[a-z]+;base64,/, '');
        parts.push({
          inlineData: {
            data: clean,
            mimeType: imageMimeType,
          },
        });
      }
    }

    let responseText = null;
    const errors = [];
    const triedModels = new Set();

    // 1. Try preferred models with backoff retry
    for (const modelName of this.preferredModels) {
      triedModels.add(modelName);
      for (let attempt = 1; attempt <= 2; attempt++) {
        try {
          const model = this.client.getGenerativeModel({ model: modelName });
          const result = await model.generateContent(parts);
          const response = await result.response;
          const text = response.text();
          if (text && text.trim().length > 0) {
            responseText = text;
            break;
          }
        } catch (err) {
          errors.push(`${modelName} (attempt ${attempt}): ${err.message}`);
          if (attempt < 2 && this._isTransientError(err)) {
            await this._delay(500 * attempt);
            continue;
          }
          break;
        }
      }
      if (responseText) break;
    }

    // 2. Dynamic discovery fallback
    if (!responseText) {
      try {
        const dynamicModels = await this._fetchAvailableGenerateModels();
        for (const modelName of dynamicModels) {
          if (triedModels.has(modelName)) continue;
          triedModels.add(modelName);
          try {
            const model = this.client.getGenerativeModel({ model: modelName });
            const result = await model.generateContent(parts);
            const response = await result.response;
            const text = response.text();
            if (text && text.trim().length > 0) {
              responseText = text;
              break;
            }
          } catch (err) {
            errors.push(`${modelName}: ${err.message}`);
          }
        }
      } catch (discErr) {
        errors.push(`Dynamic discovery failed: ${discErr.message}`);
      }
    }

    if (!responseText) {
      throw new Error(`All AI models failed to respond. Tried: ${Array.from(triedModels).join(', ')}\nErrors:\n${errors.join('\n')}`);
    }

    return responseText;
  }

  /**
   * Multi-turn chat generation
   */
  async generateChatContent({ history, message }) {
    const formattedHistory = (history || []).map((h) => ({
      role: h.role === 'user' ? 'user' : 'model',
      parts: [{ text: h.text || h.message || '' }],
    }));

    let responseText = null;
    const errors = [];
    const triedModels = new Set();

    for (const modelName of this.preferredModels) {
      triedModels.add(modelName);
      for (let attempt = 1; attempt <= 2; attempt++) {
        try {
          const model = this.client.getGenerativeModel({ model: modelName });
          const chat = model.startChat({ history: formattedHistory });
          const result = await chat.sendMessage(message);
          const response = await result.response;
          const text = response.text();
          if (text && text.trim().length > 0) {
            responseText = text;
            break;
          }
        } catch (err) {
          errors.push(`${modelName} (attempt ${attempt}): ${err.message}`);
          if (attempt < 2 && this._isTransientError(err)) {
            await this._delay(500 * attempt);
            continue;
          }
          break;
        }
      }
      if (responseText) break;
    }

    if (!responseText) {
      throw new Error(`All AI models failed in chat. Tried: ${Array.from(triedModels).join(', ')}\nErrors:\n${errors.join('\n')}`);
    }

    return responseText;
  }

  async _fetchAvailableGenerateModels() {
    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${this.apiKey}`;
      const res = await axios.get(url);
      if (res.status === 200 && res.data && Array.isArray(res.data.models)) {
        return res.data.models
          .filter((m) => {
            const methods = m.supportedGenerationMethods || [];
            const name = m.name.replace('models/', '');
            return methods.includes('generateContent') && !name.includes('embedding') && !name.includes('tts') && !name.includes('aqa');
          })
          .map((m) => m.name.replace('models/', ''));
      }
    } catch (e) {
      console.error('Failed to list Gemini models:', e.message);
    }
    return [];
  }

  /**
   * Robust JSON extraction
   */
  extractJson(rawText) {
    try {
      let cleaned = rawText.trim();
      const startIndex = cleaned.indexOf('{');
      const endIndex = cleaned.lastIndexOf('}');

      if (startIndex !== -1 && endIndex !== -1 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      } else {
        if (cleaned.startsWith('```')) {
          cleaned = cleaned.replace(/^```[a-zA-Z]*\n?/, '').replace(/\n?```$/, '').trim();
        }
      }

      // Repair trailing commas before closing braces/brackets
      cleaned = cleaned.replace(/,\s*([\}\]])/g, '$1');
      return JSON.parse(cleaned);
    } catch (e) {
      throw new Error(`Failed to decode JSON from AI response: ${e.message}\nRaw: ${rawText}`);
    }
  }
}

module.exports = new GeminiService();
