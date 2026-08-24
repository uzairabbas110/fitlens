require('dotenv').config();
const geminiService = require('../src/services/gemini.service');

async function testGeminiRealCall() {
  console.log('Testing Gemini API call with preferred model list:', geminiService.preferredModels);

  const start = Date.now();
  try {
    const response = await geminiService.generateContent({
      prompt: 'Respond with exactly the word "FITLENS_VERIFIED_OK"',
    });
    const latency = Date.now() - start;
    console.log(`[SUCCESS] Gemini Call Completed in ${latency}ms`);
    console.log(`Response text: "${response.trim()}"`);
  } catch (err) {
    console.error('[ERROR] Gemini Call Failed:', err.message);
  }
}

testGeminiRealCall();
