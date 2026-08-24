const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const outputPath1 = path.join(__dirname, '..', 'FitLens_Comprehensive_Project_Report.pdf');
const docsDir = path.join(__dirname, '..', 'Documents');
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}
const outputPath2 = path.join(docsDir, 'FitLens_Comprehensive_Project_Report.pdf');

const doc = new PDFDocument({
  size: 'A4',
  margins: { top: 50, bottom: 50, left: 50, right: 50 },
  bufferPages: true,
});

const stream1 = fs.createWriteStream(outputPath1);
const stream2 = fs.createWriteStream(outputPath2);

doc.pipe(stream1);
doc.pipe(stream2);

// Colors
const PRIMARY = '#1E1E2D';
const ACCENT = '#6366F1';
const SECONDARY_ACCENT = '#EC4899';
const TEXT_DARK = '#1F2937';
const TEXT_MUTED = '#4B5563';
const BG_LIGHT = '#F3F4F6';
const BG_CARD = '#FAFAFA';
const BORDER_COLOR = '#E5E7EB';
const SUCCESS = '#10B981';
const WARNING = '#F59E0B';

function drawHeader(title, subtitle) {
  doc.fillColor(PRIMARY).fontSize(20).font('Helvetica-Bold').text(title, { align: 'left' });
  if (subtitle) {
    doc.fillColor(ACCENT).fontSize(11).font('Helvetica-Bold').text(subtitle.toUpperCase(), { align: 'left' });
  }
  doc.moveDown(0.5);
  doc.strokeColor(ACCENT).lineWidth(2).moveTo(50, doc.y).lineTo(545, doc.y).stroke();
  doc.moveDown(1);
}

function drawSectionHeading(heading) {
  if (doc.y > 680) doc.addPage();
  doc.moveDown(0.8);
  doc.fillColor(PRIMARY).fontSize(14).font('Helvetica-Bold').text(heading);
  doc.moveDown(0.3);
  doc.strokeColor(BORDER_COLOR).lineWidth(1).moveTo(50, doc.y).lineTo(545, doc.y).stroke();
  doc.moveDown(0.6);
}

function drawSubHeading(subheading) {
  if (doc.y > 700) doc.addPage();
  doc.moveDown(0.4);
  doc.fillColor(ACCENT).fontSize(11).font('Helvetica-Bold').text(subheading);
  doc.moveDown(0.3);
}

function drawParagraph(text) {
  if (doc.y > 720) doc.addPage();
  doc.fillColor(TEXT_DARK).fontSize(9.5).font('Helvetica').text(text, {
    lineGap: 3,
    paragraphGap: 4,
  });
}

function drawBullet(title, desc) {
  if (doc.y > 720) doc.addPage();
  doc.fillColor(ACCENT).fontSize(9.5).font('Helvetica-Bold').text('• ' + title + ': ', { continued: true });
  doc.fillColor(TEXT_DARK).font('Helvetica').text(desc, { lineGap: 2 });
  doc.moveDown(0.2);
}

function drawCard(title, items, bgColor = BG_LIGHT) {
  if (doc.y > 660) doc.addPage();
  const startY = doc.y;
  doc.moveDown(0.3);
  
  doc.fillColor(PRIMARY).fontSize(10.5).font('Helvetica-Bold').text(title, 60, doc.y);
  doc.moveDown(0.3);
  
  items.forEach(item => {
    doc.fillColor(TEXT_MUTED).fontSize(9).font('Helvetica').text('  - ' + item, 65, doc.y, { lineGap: 2 });
    doc.moveDown(0.2);
  });
  
  const endY = doc.y + 4;
  const height = endY - startY;
  
  doc.save();
  doc.roundedRect(50, startY - 4, 495, height + 8, 4).lineWidth(1).strokeColor(BORDER_COLOR).fillAndStroke(bgColor, BORDER_COLOR);
  doc.restore();

  // Re-render text on top of card background
  doc.y = startY;
  doc.fillColor(PRIMARY).fontSize(10.5).font('Helvetica-Bold').text(title, 60, doc.y);
  doc.moveDown(0.3);
  items.forEach(item => {
    doc.fillColor(TEXT_DARK).fontSize(9).font('Helvetica').text('• ' + item, 65, doc.y, { lineGap: 2 });
    doc.moveDown(0.2);
  });
  doc.y = endY + 8;
}

function drawTable(headers, rows, columnWidths) {
  const startX = 50;
  const rowHeight = 22;

  if (doc.y + (rows.length * rowHeight) > 730) {
    doc.addPage();
  }

  let curY = doc.y;

  // Header Background
  doc.rect(startX, curY, 495, rowHeight).fill(PRIMARY);
  
  // Header Text
  let curX = startX;
  headers.forEach((h, i) => {
    doc.fillColor('#FFFFFF').fontSize(9).font('Helvetica-Bold').text(h, curX + 5, curY + 6, {
      width: columnWidths[i] - 10,
      align: i === 0 ? 'left' : (i === 1 ? 'left' : 'center')
    });
    curX += columnWidths[i];
  });

  curY += rowHeight;

  // Rows
  rows.forEach((row, rIndex) => {
    if (curY > 740) {
      doc.addPage();
      curY = 50;
    }

    const rowBg = rIndex % 2 === 0 ? '#FFFFFF' : '#F9FAFB';
    doc.rect(startX, curY, 495, rowHeight).fill(rowBg);
    doc.rect(startX, curY, 495, rowHeight).strokeColor(BORDER_COLOR).lineWidth(0.5).stroke();

    curX = startX;
    row.forEach((cell, cIndex) => {
      let cellColor = TEXT_DARK;
      if (cell.includes('Complete') || cell.includes('10/10') || cell.includes('9.5/10')) cellColor = SUCCESS;
      if (cell.includes('Action') || cell.includes('4/10') || cell.includes('5/10')) cellColor = WARNING;
      if (cell.includes('Pending') || cell.includes('2/10')) cellColor = '#EF4444';

      doc.fillColor(cellColor).fontSize(8.5).font(cIndex === 0 || cIndex === 1 ? 'Helvetica-Bold' : 'Helvetica').text(cell, curX + 5, curY + 6, {
        width: columnWidths[cIndex] - 10,
        align: cIndex === 0 ? 'left' : (cIndex === 1 ? 'left' : 'center')
      });
      curX += columnWidths[cIndex];
    });

    curY += rowHeight;
  });

  doc.y = curY + 10;
}

// ==========================================
// COVER PAGE / HEADER
// ==========================================
doc.rect(0, 0, 595, 200).fill(PRIMARY);

doc.fillColor('#FFFFFF').fontSize(26).font('Helvetica-Bold').text('FitLens AI Fashion Stylist', 50, 55);
doc.fillColor(SECONDARY_ACCENT).fontSize(14).font('Helvetica-Bold').text('ENGINEERING & ARCHITECTURE SPECIFICATION REPORT', 50, 90);
doc.fillColor('#9CA3AF').fontSize(9.5).font('Helvetica').text('Runtime Flow | API Security | Complete Testing Suite | Development Audit', 50, 115);
doc.fillColor('#D1D5DB').fontSize(8.5).font('Helvetica').text(`Generated: August 2026  |  Platform: Flutter + Node.js + Cloudflare + Firebase`, 50, 140);

doc.y = 230;

drawSectionHeading('Executive Summary');
drawParagraph('FitLens is an AI-powered personalized fashion assistant and smart wardrobe management mobile platform. It integrates multimodal computer vision (Google Gemini AI), serverless edge compute (Cloudflare Workers & R2 object storage), real-time database indexing (Google Firebase Auth & Cloud Firestore), and localized weather intelligence (Open-Meteo & Weatherstack).');
drawParagraph('This comprehensive technical document details the runtime architecture, backend communication hierarchy, API security governance, end-to-end testing matrix, standard development methodology, and a complete codebase audit.');

doc.moveDown(0.5);
drawCard('Core Architectural Highlights', [
  'Hybrid multi-tier execution with direct high-speed cloud calls and fallback proxying.',
  'Zero client-side secrets architecture with server-side isolation and Firebase JWT auth.',
  'Intelligent AI caching using SHA-256 fingerprinting in Firestore (0-latency & 0-cost repeats).',
  'Automated multi-tier fallback cascade (Direct -> Proxy -> Dynamic Model Discovery -> Safe Defaults).',
  'Full dark/light theme design system across 50+ screens with 3D transition choreography.'
]);

// ==========================================
// SECTION 1: EXECUTION FLOW & RUNTIME ARCHITECTURE
// ==========================================
doc.addPage();
drawHeader('Section 1: Execution Flow & Runtime Architecture', 'System Lifecycle');

drawSubHeading('1. Client Startup & Dynamic Network Routing');
drawParagraph('Upon app initialization (main.dart), Firebase is bound and ApiConstants initializes environment-aware networking:');
drawBullet('Android Emulator', 'Routes seamlessly to loopback alias http://10.0.2.2:3000.');
drawBullet('Physical Mobile Device', 'Connects globally over 4G/5G/Wi-Fi via Public HTTPS Tunnel (fitlens-api-uzair.loca.lt) or host machine LAN IP.');
drawBullet('Web / Desktop / USB', 'Routes to http://localhost:3000.');
drawBullet('Dynamic Settings Override', 'Allows users/developers to switch backend URLs on-the-fly without rebuilding the app.');

drawSubHeading('2. Core Feature Execution Workflows');
drawBullet('AI Outfit Analysis', 'Camera/Gallery photo -> Client-side resizing (<=1024px, JPEG 85%) -> SHA-256 cache check -> Gemini Multimodal Vision analysis -> JSON extraction & repair -> UI Dashboard render.');
drawBullet('AI Stylist Chat', 'Multi-turn chat context maintained in memory and synchronized with Cloud Firestore (stylist_chats collection) for persistence across app restarts.');
drawBullet('Smart Wardrobe Management', 'Binary image PUT to Cloudflare Edge Worker -> R2 bucket storage -> Public CDN URL generated -> Item document written to Firestore closet_items collection.');
drawBullet('Dynamic Weather-Tailored Styling', 'Device GPS coordinates -> Open-Meteo API (WMO code translation) -> Gemini AI weather prompt synthesis -> Contextual clothing suggestions rendered on Home screen.');

// ==========================================
// SECTION 2: BACKEND & API CALLING STRATEGY
// ==========================================
drawSectionHeading('Section 2: Backend Architecture & API Calling Strategy');

drawParagraph('FitLens leverages a dual-backend infrastructure paired with a fault-tolerant multi-tier calling hierarchy:');

drawCard('Dual-Backend Stack Components', [
  'Node.js + Express API Server (src/index.js): Handles REST routing for /api/ai/*, /api/weather/*, and /api/storage/* with 50MB payload limits.',
  'Cloudflare Serverless Edge Worker (cloudflare/worker.js): Worldwide low-latency edge computing with native R2 bucket bindings (env.R2_BUCKET.put).',
  'Firebase Authentication: Managed authentication providing verifiable JWT Bearer tokens.',
  'Cloud Firestore: Scalable NoSQL real-time document database.'
]);

drawSubHeading('The 5-Tier Resilient Calling Hierarchy');
drawBullet('Tier 1: AI Cache Lookup', 'Computes SHA-256 fingerprint of prompt + image bytes against firestore.collection("ai_cache"). Returns in milliseconds if matched.');
drawBullet('Tier 2: Direct High-Speed Cloud Call', 'Direct connection to Google Gemini API using active preferred models (gemini-flash-lite-latest, gemini-3.5-flash, gemini-3.7-flash).');
drawBullet('Tier 3: Backend Proxy Failover', 'If client encounters rate limits or network issues, request automatically fails over to Express/Cloudflare proxy endpoints.');
drawBullet('Tier 4: Dynamic Model Discovery', 'Backend queries Google Gemini /v1beta/models API to discover available models dynamically if static models are deprecated.');
drawBullet('Tier 5: Robust JSON Extraction & Repair', 'Cleans markdown fences (```json) and auto-repairs trailing commas before JSON decoding.');

// ==========================================
// SECTION 3: API SECURITY & INFRASTRUCTURE
// ==========================================
doc.addPage();
drawHeader('Section 3: API Security Management', 'Security Governance');

drawParagraph('The application adheres to enterprise mobile security principles to protect cloud resources and user data:');

drawBullet('Zero Client-Side Master Secrets', 'Master API keys (GEMINI_API_KEY, WEATHER_API_KEY, R2 secrets) reside strictly in server environment variables (.env) and Cloudflare Wrangler encrypted secrets.');
drawBullet('Firebase Auth JWT Verification Middleware', 'The Express server (src/middleware/auth.js) validates incoming Authorization: Bearer <token> headers using admin.auth().verifyIdToken(token). Unauthenticated requests are rejected with HTTP 401.');
drawBullet('Cloudflare Worker Custom Secret Header', 'Storage uploads to Cloudflare R2 require a valid X-App-Secret header, preventing unauthorized public bucket writes.');
drawBullet('Strict CORS & Preflight Handling', 'Express (cors()) and Cloudflare Workers explicitly handle OPTIONS preflight headers, whitelisting permitted methods and custom headers.');
drawBullet('Payload Limiting & DoS Protection', 'Express enforces strict body limits (50MB base64, 20MB Multer) to prevent server memory exhaustion.');
drawBullet('Client-Side Image Pre-Compression', 'Raw camera images are compressed and downscaled before transmission, reducing network attack surface and bandwidth consumption.');
drawBullet('Email Verification Gatekeeper', 'AuthRepository enforces email verification before granting session access, preventing spam/bot accounts.');

// ==========================================
// SECTION 4: COMPREHENSIVE TESTING LIST
// ==========================================
drawSectionHeading('Section 4: Comprehensive Testing Matrix');

drawParagraph('The following structured test suite covers functional, security, resilience, and UI test cases:');

const testRows = [
  ['1.1', 'User Registration & Email Verification', 'Sign up with valid email/pwd', 'Account created; verification email sent; forced logout until verified.'],
  ['1.2', 'Unverified Login Attempt', 'Login before email confirmation', 'Blocked with descriptive verification reminder message.'],
  ['1.3', 'Google OAuth Sign-In', 'Tap Continue with Google', 'Authenticates popup/redirect; auto-generates Firestore user profile.'],
  ['2.1', 'Outfit Image Multimodal Analysis', 'Upload clothing photo', 'Compresses image; Gemini outputs valid structured JSON analysis.'],
  ['2.2', 'AI Response Cache Hit', 'Submit duplicate image/prompt', 'Instantly retrieved from Firestore ai_cache with zero API token cost.'],
  ['2.3', 'JSON Markdown & Comma Repair', 'Malformed AI output', 'extractJson() cleans markdown fences and trailing commas cleanly.'],
  ['2.4', 'Multi-Turn Stylist Chat Memory', 'Send sequential stylist prompts', 'Context preserved across conversation; synced to stylist_chats.'],
  ['3.1', 'Cloudflare R2 Direct Upload', 'Add clothing item to closet', 'Binary PUT with X-App-Secret stores image in R2 and returns CDN URL.'],
  ['4.1', 'GPS Weather Forecast & AI Suggestion', 'Fetch weather by device lat/lon', 'Translates WMO code; Gemini synthesizes weather-tailored outfit advice.'],
  ['5.1', 'Server JWT Auth Verification', 'Call /api/ai/generate with Bearer token', 'Decodes Firebase JWT; attaches user context; returns AI response.'],
  ['5.2', 'Unauthorized Request Rejection', 'Call /api/ai/generate without token', 'HTTP 401 Unauthorized returned in production mode.'],
  ['6.1', 'Gemini Transient Error Recovery', 'Simulate 429 quota or 503 outage', 'Exponential backoff retry triggers; cascades down model hierarchy.'],
  ['7.1', 'Dark / Light Theme Consistency', 'Toggle theme in App Settings', 'All 50+ screens adapt instantly with WCAG-compliant contrast.']
];

drawTable(['ID', 'Test Scenario', 'Action / Input', 'Expected Result'], testRows, [30, 135, 140, 190]);

// ==========================================
// SECTION 5: DEVELOPMENT LIFECYCLE ROADMAP
// ==========================================
doc.addPage();
drawHeader('Section 5: End-to-End App Development Lifecycle', 'Methodology');

drawParagraph('Industry standard 7-phase methodology for building and scaling full-stack mobile applications:');

drawCard('Phase 1: Ideation, Discovery & Scope Definition', [
  'Define target user personas and core problem statement.',
  'Differentiate Must-Have MVP features from nice-to-have future iterations.',
  'Perform technical feasibility assessment on required 3rd-party APIs.'
]);
drawCard('Phase 2: UI/UX Design & Prototyping', [
  'Establish complete Information Architecture (IA) and user journey wireframes.',
  'Build design system tokens (typography, color palettes, spacing, dark/light themes).',
  'Create interactive prototypes in Figma for ergonomics and usability testing.'
]);
drawCard('Phase 3: System Architecture & Tech Stack Selection', [
  'Decouple frontend layers using Clean Architecture (Data, Domain, Presentation).',
  'Select high-performance cross-platform framework (Flutter) with reactive state (Riverpod).',
  'Design secure backend proxy architecture with serverless edge scalability.'
]);
drawCard('Phase 4: Development & Cloud Integration', [
  'Implement core routing, stateful navigation shells, and responsive UI components.',
  'Integrate BaaS databases, object storage buckets, and AI vision inference pipelines.',
  'Implement client-side optimization (compression, caching, error recovery).'
]);
drawCard('Phase 5: Testing & Quality Assurance', [
  'Execute unit tests, repository contract tests, and widget UI tests.',
  'Perform chaos and degradation tests (rate limiting, network timeouts, offline mode).',
  'Conduct internal User Acceptance Testing (UAT) via TestFlight / Firebase Distribution.'
]);
drawCard('Phase 6: Deployment & App Store Release', [
  'Deploy production backend with SSL/TLS and custom domain routing.',
  'Configure production app bundle signing keys, bundle identifiers, and native splash screens.',
  'Submit app to Google Play Store and Apple App Store with staged rollout.'
]);
drawCard('Phase 7: Post-Launch Monitoring & Maintenance', [
  'Integrate real-time crash reporting (Crashlytics) and event analytics.',
  'Monitor API latency, user retention, and customer feedback for continuous iteration.'
]);

// ==========================================
// SECTION 6: CODEBASE AUDIT & ACTION PLAN
// ==========================================
doc.addPage();
drawHeader('Section 6: Codebase Audit & Action Plan', 'Project Scorecard');

drawParagraph('An objective audit of the current FitLens codebase against the 7-phase development lifecycle:');

const auditRows = [
  ['Phase 1', 'Scope & MVP Definition', 'Complete', '10 / 10'],
  ['Phase 2', 'UI/UX & Design System', 'Complete', '10 / 10'],
  ['Phase 3', 'Architecture & Tech Stack', 'Complete', '9.5 / 10'],
  ['Phase 4', 'Development & Integration', 'Complete', '9.5 / 10'],
  ['Phase 5', 'Testing & Quality Assurance', 'Action Needed', '4.0 / 10'],
  ['Phase 6', 'Deployment Readiness', 'Action Needed', '5.0 / 10'],
  ['Phase 7', 'Post-Launch Monitoring', 'Pending', '2.0 / 10']
];

drawTable(['Phase', 'Phase Description', 'Implementation Status', 'Score'], auditRows, [60, 200, 135, 100]);

drawSubHeading('Detailed Audit Findings');
drawBullet('Strengths', 'Comprehensive feature set, 50+ polished screens, robust Clean Architecture, Riverpod state management, SHA-256 AI response caching, resilient 5-tier fallback cascades, and zero-trust API security.');
drawBullet('Testing Gaps', 'test/widget_test.dart contains only a placeholder test. Needs automated unit test suites for AuthRepository, model serialization, extractJson(), and widget interactions.');
drawBullet('Deployment Gaps', 'android/app/build.gradle.kts still uses default "com.example.fitlens" and debug signing keys. Production URL in api_constants.dart needs deployment update.');
drawBullet('Monitoring Gaps', 'firebase_crashlytics and firebase_analytics need to be added to pubspec.yaml.');

drawSectionHeading('Immediate Production Readiness Action Plan');
drawBullet('Step 1: Automated Unit Tests', 'Write unit tests for JSON parsing, UserModel/ClosetModel serialization, and WeatherRemoteDataSource.');
drawBullet('Step 2: Production Keystore & Package ID', 'Update applicationId to com.fitlens.app and configure Android release keystore (upload-keystore.jks).');
drawBullet('Step 3: Crashlytics & Analytics', 'Install firebase_crashlytics and firebase_analytics to capture live production telemetry.');
drawBullet('Step 4: Backend Production Deployment', 'Deploy Express server (Render/Railway) or Cloudflare Worker (npx wrangler deploy) and set production URL in api_constants.dart.');

// ==========================================
// FOOTERS (Page Numbers)
// ==========================================
const range = doc.bufferedPageRange();
for (let i = range.start; i < range.start + range.count; i++) {
  doc.switchToPage(i);
  doc.fillColor('#9CA3AF').fontSize(8).font('Helvetica').text(
    `FitLens Engineering Specification Report  |  Page ${i + 1} of ${range.count}`,
    50,
    795,
    { align: 'center', width: 495 }
  );
}

doc.end();

console.log('PDF Generation Completed successfully!');
console.log('Output 1:', outputPath1);
console.log('Output 2:', outputPath2);
