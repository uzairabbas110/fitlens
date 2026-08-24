const admin = require('firebase-admin');

// Initialize Firebase Admin if projectId is provided
let isFirebaseInitialized = false;
try {
  if (process.env.FIREBASE_PROJECT_ID) {
    admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID,
    });
    isFirebaseInitialized = true;
  }
} catch (e) {
  console.warn('Firebase Admin initialization notice:', e.message);
}

/**
 * Authentication Middleware:
 * Verifies Firebase Auth ID Token in Authorization header: `Bearer <token>`.
 * In development mode or if token is absent in non-strict mode, attaches fallback user context.
 */
async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // If running in development without auth header, allow test requests
    if (process.env.NODE_ENV === 'development') {
      req.user = { uid: 'dev-user', email: 'dev@fitlens.app' };
      return next();
    }
    return res.status(401).json({
      error: 'Unauthorized: Missing or invalid Authorization Bearer token.',
    });
  }

  const token = authHeader.split('Bearer ')[1].trim();

  if (!isFirebaseInitialized) {
    // Fallback if Firebase Admin credentials are not attached yet
    req.user = { uid: 'authenticated-user' };
    return next();
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification failed:', error.message);
    // In development mode, allow proceeding
    if (process.env.NODE_ENV === 'development') {
      req.user = { uid: 'dev-fallback-user' };
      return next();
    }
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid or expired authentication token. Please sign in again.',
    });
  }
}

module.exports = {
  authenticate,
};
