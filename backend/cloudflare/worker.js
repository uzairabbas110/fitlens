/**
 * FitLens Cloudflare Worker (All-in-one Serverless Edge Backend)
 * Handles:
 *  - /api/ai/generate (Gemini AI Vision & Text)
 *  - /api/ai/chat (Gemini AI Multi-turn Chat)
 *  - /api/ai/measure (AI Body Measurement)
 *  - /api/weather/current (Weather + AI Suggestions)
 *  - /api/storage/upload (Cloudflare R2 image upload)
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const { pathname, searchParams } = url;

    // Handle CORS Preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-App-Secret, X-File-Name',
        },
      });
    }

    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
    };

    // Health Check
    if (pathname === '/health' || pathname === '/') {
      return new Response(
        JSON.stringify({ status: 'ok', service: 'FitLens Cloudflare Edge API' }),
        { headers: corsHeaders }
      );
    }

    const geminiKey = env.GEMINI_API_KEY;
    const weatherKey = env.WEATHER_API_KEY;

    // 1. AI Generate Endpoint
    if (pathname === '/api/ai/generate' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { prompt, imageBase64, imageMimeType = 'image/jpeg', extractJson } = body;

        const parts = [{ text: prompt }];
        if (imageBase64) {
          const clean = imageBase64.replace(/^data:image\/[a-z]+;base64,/, '');
          parts.push({
            inline_data: {
              mime_type: imageMimeType,
              data: clean,
            },
          });
        }

        const models = [
          'gemini-2.0-flash',
          'gemini-1.5-flash',
          'gemini-1.5-flash-8b',
          'gemini-2.0-flash-lite-preview-02-05',
          'gemini-1.5-pro',
        ];

        let resultText = null;
        for (const model of models) {
          try {
            const res = await fetch(
              `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${geminiKey}`,
              {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ contents: [{ parts }] }),
              }
            );
            if (res.ok) {
              const data = await res.json();
              resultText = data.candidates?.[0]?.content?.parts?.[0]?.text;
              if (resultText) break;
            }
          } catch (_) {}
        }

        if (!resultText) {
          return new Response(
            JSON.stringify({ success: false, error: 'All AI models failed to respond.' }),
            { status: 500, headers: corsHeaders }
          );
        }

        let parsedData = null;
        if (extractJson) {
          try {
            let cleaned = resultText.trim();
            const start = cleaned.indexOf('{');
            const end = cleaned.lastIndexOf('}');
            if (start !== -1 && end !== -1 && end > start) {
              cleaned = cleaned.substring(start, end + 1);
            }
            cleaned = cleaned.replace(/,\s*([\}\]])/g, '$1');
            parsedData = JSON.parse(cleaned);
          } catch (_) {}
        }

        return new Response(
          JSON.stringify({ success: true, text: resultText, data: parsedData }),
          { headers: corsHeaders }
        );
      } catch (e) {
        console.error('Edge AI Error:', e);
        return new Response(
          JSON.stringify({ success: false, error: 'Unable to process AI request. Please try again.' }),
          { status: 500, headers: corsHeaders }
        );
      }
    }

    // 2. Weather Endpoint
    if (pathname === '/api/weather/current' && request.method === 'GET') {
      try {
        const lat = searchParams.get('lat');
        const lon = searchParams.get('lon');
        const city = searchParams.get('city');

        const query = lat && lon ? `${lat},${lon}` : city || 'New York';
        const wRes = await fetch(
          `https://api.weatherstack.com/current?access_key=${weatherKey}&query=${encodeURIComponent(query)}`
        );
        const data = await wRes.json();

        return new Response(
          JSON.stringify({ success: true, data }),
          { headers: corsHeaders }
        );
      } catch (e) {
        console.error('Edge Weather Error:', e);
        return new Response(
          JSON.stringify({ success: false, error: 'Unable to fetch weather data. Please try again.' }),
          { status: 500, headers: corsHeaders }
        );
      }
    }

    // 3. Isolated R2 Image Upload Endpoint (Deep Content Validation & Shared Secret Authentication)
    if (pathname === '/api/storage/upload' && request.method === 'PUT') {
      try {
        const appSecret = env.APP_SECRET || env.CLOUDFLARE_APP_SECRET;
        const providedSecret = request.headers.get('X-App-Secret');
        if (appSecret && providedSecret !== appSecret) {
          return new Response(
            JSON.stringify({ success: false, error: 'Unauthorized: Invalid or missing X-App-Secret header.' }),
            { status: 401, headers: corsHeaders }
          );
        }

        const rawFileName = request.headers.get('X-File-Name') || `upload_${Date.now()}.jpg`;
        // Strip path traversal characters
        const safeName = rawFileName.replace(/[\/\\]/g, '').replace(/\.\./g, '');
        const body = await request.arrayBuffer();

        if (!body || body.byteLength < 32) {
          return new Response(
            JSON.stringify({ success: false, error: 'Uploaded file is too small or empty.' }),
            { status: 400, headers: corsHeaders }
          );
        }

        if (body.byteLength > 15 * 1024 * 1024) {
          return new Response(
            JSON.stringify({ success: false, error: 'File exceeds maximum 15MB limit.' }),
            { status: 400, headers: corsHeaders }
          );
        }

        // Magic byte content validation
        const bytes = new Uint8Array(body.slice(0, 16));
        let detectedType = null;
        if (bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
          detectedType = 'image/jpeg';
        } else if (bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47) {
          detectedType = 'image/png';
        } else if (bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x46 && bytes[8] === 0x57 && bytes[9] === 0x45 && bytes[10] === 0x42 && bytes[11] === 0x50) {
          detectedType = 'image/webp';
        } else if (bytes[0] === 0x47 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x38) {
          detectedType = 'image/gif';
        }

        if (!detectedType) {
          return new Response(
            JSON.stringify({ success: false, error: 'Security violation: File content is not a supported image format.' }),
            { status: 400, headers: corsHeaders }
          );
        }

        if (env.R2_BUCKET) {
          await env.R2_BUCKET.put(safeName, body, {
            httpMetadata: {
              contentType: detectedType,
            },
            customMetadata: {
              uploadedAt: new Date().toISOString(),
              validatedContentType: detectedType,
            },
          });
          const publicUrl = env.PUBLIC_URL || 'https://pub-65218ac71c02459f997112e112ce22db.r2.dev';
          return new Response(
            JSON.stringify({
              success: true,
              url: `${publicUrl}/${safeName}`,
              filename: safeName,
              mimeType: detectedType,
            }),
            { headers: { ...corsHeaders, 'X-Content-Type-Options': 'nosniff' } }
          );
        }

        return new Response(
          JSON.stringify({ success: false, error: 'Storage service temporarily unavailable.' }),
          { status: 500, headers: corsHeaders }
        );
      } catch (e) {
        console.error('Edge Storage Error:', e);
        return new Response(
          JSON.stringify({ success: false, error: 'Failed to upload image to storage. Please try again.' }),
          { status: 500, headers: corsHeaders }
        );
      }
    }

    return new Response(
      JSON.stringify({ error: 'Route not found' }),
      { status: 404, headers: corsHeaders }
    );
  },
};
