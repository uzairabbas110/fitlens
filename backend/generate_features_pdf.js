const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const outputPath1 = path.join(__dirname, '..', 'FitLens_All_Features_Specification_Guide.pdf');
const docsDir = path.join(__dirname, '..', 'Documents');
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}
const outputPath2 = path.join(docsDir, 'FitLens_All_Features_Specification_Guide.pdf');

const doc = new PDFDocument({
  size: 'A4',
  margins: { top: 40, bottom: 40, left: 40, right: 40 },
  bufferPages: true,
});

const stream1 = fs.createWriteStream(outputPath1);
const stream2 = fs.createWriteStream(outputPath2);

doc.pipe(stream1);
doc.pipe(stream2);

// Luxury Brand Palette
const PRIMARY = '#3D2930';
const BURGUNDY = '#7E3B50';
const GOLD = '#C5A267';
const TEXT_DARK = '#1F2937';
const TEXT_MUTED = '#4B5563';
const BG_LIGHT = '#F9FAFB';
const BG_CARD = '#FAFAFA';
const BORDER_COLOR = '#E5E7EB';
const SUCCESS_GREEN = '#10B981';

function drawHeader(title, subtitle) {
  doc.fillColor(PRIMARY).fontSize(16).font('Helvetica-Bold').text(title);
  if (subtitle) {
    doc.fillColor(BURGUNDY).fontSize(9.5).font('Helvetica-Bold').text(subtitle.toUpperCase());
  }
  doc.moveDown(0.3);
  doc.strokeColor(GOLD).lineWidth(2).moveTo(40, doc.y).lineTo(555, doc.y).stroke();
  doc.moveDown(0.6);
}

function drawSectionHeading(heading) {
  if (doc.y > 690) doc.addPage();
  doc.moveDown(0.5);
  doc.fillColor(PRIMARY).fontSize(12).font('Helvetica-Bold').text(heading);
  doc.moveDown(0.2);
  doc.strokeColor(BORDER_COLOR).lineWidth(1).moveTo(40, doc.y).lineTo(555, doc.y).stroke();
  doc.moveDown(0.4);
}

function drawBullet(title, description) {
  if (doc.y > 715) doc.addPage();
  doc.fillColor(TEXT_DARK).fontSize(9).font('Helvetica-Bold').text(`• ${title}: `, { continued: true });
  doc.font('Helvetica').fillColor(TEXT_MUTED).text(description);
  doc.moveDown(0.25);
}

function drawFeatureCard(icon, title, badge, description, bulletPoints = []) {
  if (doc.y > 670) doc.addPage();
  const startY = doc.y;
  
  // Calculate height dynamically
  const cardHeight = 52 + (bulletPoints.length * 15);
  doc.rect(40, startY, 515, cardHeight).fillAndStroke(BG_CARD, BORDER_COLOR);
  
  // Title & Icon
  doc.fillColor(PRIMARY).fontSize(11).font('Helvetica-Bold').text(`${icon}  ${title}`, 52, startY + 8);
  
  // Badge if present
  if (badge) {
    const badgeWidth = 90;
    doc.rect(455, startY + 7, badgeWidth, 16).fillAndStroke(BURGUNDY, BURGUNDY);
    doc.fillColor('#FFFFFF').fontSize(7.5).font('Helvetica-Bold').text(badge, 455, startY + 11, { width: badgeWidth, align: 'center' });
  }
  
  // Description
  doc.fillColor(TEXT_MUTED).fontSize(8.5).font('Helvetica').text(description, 52, startY + 24, { width: 490 });
  
  // Sub-bullets
  let currentY = startY + 40;
  bulletPoints.forEach(bp => {
    doc.fillColor(BURGUNDY).fontSize(8).font('Helvetica-Bold').text('▸ ', 52, currentY, { continued: true });
    doc.fillColor(TEXT_DARK).font('Helvetica-Bold').text(`${bp.label}: `, { continued: true });
    doc.fillColor(TEXT_MUTED).font('Helvetica').text(bp.detail);
    currentY += 14;
  });
  
  doc.y = startY + cardHeight + 8;
}

// =================== PAGE 1: COVER & EXECUTIVE OVERVIEW ===================
doc.rect(40, 40, 515, 135).fillAndStroke(PRIMARY, PRIMARY);

doc.fillColor(GOLD).fontSize(10).font('Helvetica-Bold').text('FITLENS AI FASHION STYLIST', 60, 56, { letterSpacing: 1.5 });
doc.fillColor('#FFFFFF').fontSize(22).font('Helvetica-Bold').text('Complete Features Specification Guide', 60, 74);
doc.fillColor('#E5E7EB').fontSize(9.5).font('Helvetica').text('Comprehensive Architecture, Functional Capabilities & Feature Ecosystem', 60, 105);
doc.fillColor(GOLD).fontSize(8.5).font('Helvetica').text('Release Version: v1.2.0-VIP-Production | Platforms: Flutter Mobile (Android/iOS) & Web', 60, 126);

doc.y = 190;

drawSectionHeading('1. Application Overview & Core Value Proposition');
doc.fillColor(TEXT_DARK).fontSize(8.5).font('Helvetica').text(
  'FitLens is an enterprise-grade AI Fashion Stylist and Wardrobe Intelligence platform designed with high-fashion luxury aesthetics. It empowers users with intelligent body sizing, personalized colorimetry, multi-turn AI styling advice, virtual wardrobe management, weather-informed outfit generation, and frictionless mobile wallet checkout.'
);
doc.moveDown(0.5);

drawFeatureCard(
  '👑',
  'FitLens VIP Ecosystem & Freemium Architecture',
  'CORE MODEL',
  'Engineered with a freemium model providing 3 free AI Sizing demo tries and full VIP unlimited access upon subscription.',
  [
    { label: 'Freemium Gate', detail: 'Free users enjoy 3 full AI body proportion scans before entering the VIP upgrade flow.' },
    { label: 'VIP Status', detail: 'Subscribers unlock unlimited AI sizing scans, brand fit predictions, and personal AI stylist concierge.' },
    { label: 'Visual VIP Identity', detail: 'Dynamic [👑 VIP] crown badge on the Home Screen and glowing Soft Gold avatar ring.' }
  ]
);

drawFeatureCard(
  '📱',
  'Cross-Platform UI & High-Fashion Aesthetics',
  'LUXURY UI',
  'Crafted using Flutter with responsive layouts for mobile and web with custom animations and editorial typography.',
  [
    { label: 'Color Palette', detail: 'Deep Burgundy (#7E3B50), Soft Gold (#C5A267), Dark Charcoal (#3D2930).' },
    { label: '3D Perspective', detail: 'Custom 3D Matrix4 fold and perspective transitions for editorial luxury feel.' },
    { label: 'Theme Support', detail: 'Instant Dark / Light mode switching with persistent local preferences.' }
  ]
);

// =================== PAGE 2: CORE AI & STYLING FEATURES ===================
doc.addPage();
drawHeader('2. Core AI Styling & Vision Engine Features', 'AI Multimodal Capabilities');

drawFeatureCard(
  '👗',
  'AI Outfit Analysis & Virtual Try-On Engine',
  'GEMINI VISION',
  'Combines user portrait photos with clothing items to deliver deep multimodal aesthetic and fit evaluations.',
  [
    { label: 'Dual Image Ingestion', detail: 'Accepts portrait + clothing images with client-side base64 pre-compression (< 400KB).' },
    { label: 'Color Harmony Score', detail: 'Evaluates color theory, contrast ratios, and outputs a 0-100 numeric score.' },
    { label: 'Occasion Matching', detail: 'Evaluates suitability for Formal, Casual, Date Night, Streetwear, or Office.' },
    { label: 'Styling Dos & Don\'ts', detail: 'Generates specific tailoring, accessory, and footwear pairing recommendations.' },
    { label: 'History Persistence', detail: 'Saves analysis cards into Cloud Firestore for ongoing wardrobe tracking.' }
  ]
);

drawFeatureCard(
  '📐',
  'AI Body Sizing & Proportions (Tailor Fit Engine)',
  'FREEMIUM GATED',
  'Offers dual-mode body measurement computation with automated body shape classification and brand chart matching.',
  [
    { label: 'Manual Math Calculation', detail: '100% free numerical calculation of Hourglass, Pear, Inverted Triangle, Rectangle, and Apple shapes.' },
    { label: 'AI Vision Photo Scan', detail: 'Scans anatomical landmarks and body proportions from full-body photos using AI.' },
    { label: '3-Demo Try Gating', detail: 'Free users receive 3 scans; counter decrements automatically (3 -> 2 -> 1 -> 0).' },
    { label: 'Dynamic Trial Banner', detail: 'Live counter banner displays remaining tries or alerts user when limit is reached.' },
    { label: 'Brand Size Prediction', detail: 'Predicts exact size for Zara, ASOS, Nike, H&M, Levi\'s, and international size charts.' }
  ]
);

drawFeatureCard(
  '🎨',
  'Personal Color & Seasonal Analysis Matrix',
  'COLOR THEORY',
  'Classifies user skin undertones and extracts flattering seasonal color palettes from selfie photos.',
  [
    { label: 'Undertone Detection', detail: 'Classifies facial features into Warm, Cool, or Neutral undertones.' },
    { label: 'Seasonal Classification', detail: 'Maps user to Spring, Summer, Autumn, or Winter color seasons.' },
    { label: 'Curated Hex Swatches', detail: 'Generates 8 complementary hex color codes with one-tap clipboard copy.' },
    { label: 'Wardrobe Guidance', detail: 'Provides specific guidance on metals (Gold vs. Silver) and jewelry pairings.' }
  ]
);

// =================== PAGE 3: WARDROBE, CONCIERGE & PAYMENTS ===================
doc.addPage();
drawHeader('3. Wardrobe, Weather Concierge & Payment Systems', 'Smart Utilities & Localized Checkout');

drawFeatureCard(
  '🚪',
  'Virtual Digital Wardrobe & Closet Management',
  'CLOUDFLARE R2',
  'Centralized cloud wardrobe storage allowing users to digitize, organize, and filter their entire clothing collection.',
  [
    { label: 'Encrypted Storage', detail: 'Uploads and compresses clothing photos directly to Cloudflare R2 bucket storage.' },
    { label: 'AI Auto-Tagging', detail: 'Automatically identifies garment category (Tops/Bottoms/Footwear), season, and color.' },
    { label: 'Multi-Filter Engine', detail: 'Simultaneous multi-predicate filtering across Gender, Season, and Clothing Category.' },
    { label: 'Instant Sync', detail: 'Real-time synchronization with Firestore and cached Riverpod state.' }
  ]
);

drawFeatureCard(
  '🌦️',
  'Live Weather-Driven Fashion Concierge & AI Chat',
  'OPEN-METEO + LLM',
  'Context-aware styling assistant that recommends outfits based on real-time local weather and personal closet items.',
  [
    { label: 'GPS Location Query', detail: 'Queries precise device coordinates via Geolocator or allows manual city search.' },
    { label: 'Weather Outfits', detail: 'Displays live temperature, sky conditions, and weather-appropriate layering advice.' },
    { label: 'Conversational Memory', detail: 'Multi-turn interactive fashion styling chat powered by Google Gemini LLM.' },
    { label: 'Wardrobe Awareness', detail: 'Injects digitized closet items into stylist prompts for personalized suggestions.' }
  ]
);

drawFeatureCard(
  '💳',
  'Localized Payment Gateways & VIP Upgrade Checkout',
  'SBP COMPLIANT',
  'Frictionless checkout experience supporting Pakistan\'s top mobile wallets and international banking cards.',
  [
    { label: '🟢 Easypaisa Wallet', detail: 'Validates 11-digit mobile number (03001234567), simulates push/OTP handshake, EP-XXXXXX ref.' },
    { label: '🔴 JazzCash Wallet', detail: 'Validates 11-digit mobile number + optional 6-digit CNIC for biometric/MPIN, JC-XXXXXX ref.' },
    { label: '💳 Debit / Credit Cards', detail: 'Visa & Mastercard 16-digit card formatting, MM/YY expiry, CVV validation, masks account on receipt.' },
    { label: 'Localized PKR Pricing', detail: 'Annual VIP (Rs. 2,899 - 50% OFF), Monthly Pass (Rs. 1,499), Lifetime Perpetual (Rs. 9,999).' },
    { label: 'Digital Invoice Receipt', detail: 'Interactive receipt dialog with transaction ref, amount in PKR, and instant VIP unlocking.' }
  ]
);

// =================== PAGE 4: SECURITY, MANAGEMENT & AUDIT ===================
doc.addPage();
drawHeader('4. Security, Subscription Lifecycle & Architecture', 'Infrastructure & Quality Assurance');

drawFeatureCard(
  '🔄',
  'Subscription Lifecycle & Cancellation Management',
  'REVERSIBLE ACCESS',
  'Provides users with a transparent, secure subscription management workflow with real-time UI synchronization.',
  [
    { label: 'Active Plan Dashboard', detail: 'Displays active VIP tier, renewal/expiry metadata, and access privileges.' },
    { label: 'Cancellation Safety Dialog', detail: 'Presents warning modal detailing forfeited perks before user confirms cancellation.' },
    { label: 'Instant Cloud Sync', detail: 'Sets isPremium = false and records cancelledAt timestamp in Cloud Firestore.' },
    { label: 'Local Cache Wipe', detail: 'Clears cached_is_premium and cached_premium_plan in SharedPreferences.' },
    { label: 'Dynamic UI Reset', detail: 'Immediately removes Home VIP badge, restores trial banners, and locks VIP tools.' }
  ]
);

drawFeatureCard(
  '🔒',
  'Security Architecture & Backend Proxy Isolation',
  'DUAL BACKEND',
  'Hardened backend infrastructure separating client requests from sensitive AI model API keys.',
  [
    { label: 'X-App-Secret Guard', detail: 'All external proxy invocations must supply the authenticated header secret.' },
    { label: 'User Data Isolation', detail: 'Firestore security rules ensure users can strictly access only their own UID documents.' },
    { label: 'Client Sanitization', detail: 'Strict input format validation against SQL/NoSQL injections and buffer overflows.' }
  ]
);

drawSectionHeading('Summary Feature Inventory Matrix');

const featuresList = [
  { mod: 'Auth & Profile', name: 'Firebase Auth, Cloudflare R2 Uploads, GPS Search', access: 'Free' },
  { mod: 'Home & Weather', name: 'Live Weather Advice, Dynamic [👑 VIP] Badges, Quick Nav', access: 'All Users / VIP Dynamic' },
  { mod: 'AI Outfit Analysis', name: 'Gemini Vision scoring, Fit Analysis, 3D Transition', access: 'Full Access' },
  { mod: 'AI Body Sizing', name: 'Manual Math Calculation (Free) + AI Photo Scan', access: '3 Free Tries -> VIP' },
  { mod: 'Color Analysis', name: 'Facial undertone extraction, 4-Season palette, Hex swatches', access: 'Full Access' },
  { mod: 'Digital Closet', name: 'Cloudflare R2 storage, AI Auto-tagging, Multi-filtering', access: 'Full Access' },
  { mod: 'AI Stylist Chat', name: 'Multi-turn conversational styling with wardrobe context', access: 'Full Access' },
  { mod: 'Payment Gateways', name: 'Easypaisa, JazzCash, Visa/Mastercard (PKR Pricing)', access: 'Secure Checkout' },
  { mod: 'Subscription Hub', name: 'Active Plan Management & One-Tap Cancellation', access: 'VIP Subscribers' },
  { mod: 'Social & Themes', name: 'Community Lookbook, Post Creation, Dark/Light Mode', access: 'Full Access' }
];

let tableY = doc.y;
featuresList.forEach((item, idx) => {
  if (tableY > 730) {
    doc.addPage();
    tableY = 50;
  }
  doc.rect(40, tableY, 515, 18).fillAndStroke(idx % 2 === 0 ? '#FAFAFA' : '#FFFFFF', BORDER_COLOR);
  doc.fillColor(BURGUNDY).fontSize(7.5).font('Helvetica-Bold').text(item.mod, 48, tableY + 5, { width: 95 });
  doc.fillColor(TEXT_DARK).fontSize(7.5).font('Helvetica').text(item.name, 148, tableY + 5, { width: 280 });
  doc.fillColor(SUCCESS_GREEN).fontSize(7.5).font('Helvetica-Bold').text(item.access, 435, tableY + 5, { width: 110, align: 'right' });
  tableY += 18;
});

// Page Numbers Footer
const totalPages = doc.bufferedPageRange().count;
for (let i = 0; i < totalPages; i++) {
  doc.switchToPage(i);
  doc.fillColor(TEXT_MUTED).fontSize(7.5).font('Helvetica').text(
    `FitLens Features Specification Guide • Confidential • Page ${i + 1} of ${totalPages}`,
    40,
    800,
    { align: 'center', width: 515 }
  );
}

doc.end();
console.log('Features PDF Specification Guide Generated Successfully!');
