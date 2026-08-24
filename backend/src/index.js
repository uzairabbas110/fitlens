require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const aiRoutes = require('./routes/ai.routes');
const weatherRoutes = require('./routes/weather.routes');
const storageRoutes = require('./routes/storage.routes');
const paymentRoutes = require('./routes/payment.routes');
const { publicRateLimiter } = require('./middleware/rateLimiter');

const app = express();
const PORT = process.env.PORT || 3000;

// Trust reverse proxy headers (e.g. X-Forwarded-For)
app.set('trust proxy', 1);

// Enable CORS for mobile app & web clients
app.use(cors());

// Parse JSON bodies with up to 50MB payload limit for base64 images
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Health Check (Protected by Public Rate Limiter)
app.get('/health', publicRateLimiter, (req, res) => {
  res.json({
    status: 'ok',
    service: 'FitLens Secure API Server',
    timestamp: new Date().toISOString(),
  });
});

// Register API Routes with appropriate rate limiters
app.use('/api/auth', authRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/storage', storageRoutes);
app.use('/api/payment', paymentRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: `Cannot ${req.method} ${req.path}` });
});

const { logAndSanitizeError } = require('./utils/logger');

// Global Error Handler (Sanitizes user responses while preserving full server logs)
app.use((err, req, res, next) => {
  const sanitized = logAndSanitizeError(err, req);
  res.status(500).json(sanitized);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`=========================================`);
  console.log(` FitLens Secure API Server running`);
  console.log(` Port: ${PORT}`);
  console.log(` Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(` Health: http://localhost:${PORT}/health`);
  console.log(`=========================================`);
});
