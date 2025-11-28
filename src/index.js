const express = require('express');
const cors = require('cors');
const awsSecrets = require('./utils/aws-secrets');

console.log('[BOOT] Starting application initialization...');
console.log('[BOOT] NODE_ENV:', process.env.NODE_ENV);
console.log('[BOOT] PORT:', process.env.PORT || '3000');

// Initialize AWS secrets or local .env BEFORE importing routes
(async () => {
  try {
    console.log('[BOOT] 🔧 Loading configuration...');

    // CRITICAL: Load configuration from AWS Secrets Manager or .env FIRST
    const config = await awsSecrets.getConfig();
    console.log('[BOOT] Configuration object received:', { hasDB: !!config.DATABASE_URL, hasJWT: !!config.JWT_SECRET });

    // Set environment variables BEFORE importing routes (which may use Prisma)
    process.env.DATABASE_URL = config.DATABASE_URL;
    process.env.JWT_SECRET = config.JWT_SECRET;
    // PORT is handled as direct environment variable, not from secrets

    console.log(`[BOOT] ✅ Configurations loaded from: ${process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'aws' ? 'AWS Secrets Manager' : 'local .env'}`);
    console.log(`[BOOT] 📊 DATABASE_URL: ${process.env.DATABASE_URL ? 'configured ✓' : 'MISSING ❌'}`);
    console.log(`[BOOT] 🔐 JWT_SECRET: ${process.env.JWT_SECRET ? 'configured ✓' : 'MISSING ❌'}`);

    // Validar configurações críticas
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL is not configured');
    }
    if (!process.env.JWT_SECRET) {
      throw new Error('JWT_SECRET is not configured');
    }

    // NOW import routes (after DATABASE_URL is set)
    console.log('[BOOT] Loading routes...');
    const healthRoutes = require('./routes/health.routes');
    const authRoutes = require('./routes/auth.routes');
    const urlRoutes = require('./routes/url.routes');
    console.log('[BOOT] Routes loaded successfully');

    const app = express();

    // Configure CORS with proper settings
    const corsOptions = {
      origin: function (origin, callback) {
        // Lista de origens permitidas
        const allowedOrigins = [
          'http://localhost:5000',
          'http://localhost:3001', 
          'http://localhost:3000',
          'https://d2nvo495vv8bz5.cloudfront.net',
          // Adicione outras origens conforme necessário
        ];
        
        // Permitir requisições sem origin (como mobile apps, curl, etc)
        if (!origin || allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
      allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'Accept'],
      optionsSuccessStatus: 200
    };

    app.use(cors(corsOptions));

    app.use(express.json());

    app.get('/', (req, res) => {
      res.send('URL Shortener Backend API');
    });

    // Health check route for AWS Load Balancer (no auth required)
    app.use('/health', healthRoutes);

    app.use('/api/auth', authRoutes);
    
    // Mount the public redirect route BEFORE the /api/urls routes
    const { redirectUrl } = require('./controllers/url.controller');
    app.get('/:shortCode', redirectUrl);
    
    app.use('/api/urls', urlRoutes);

    const PORT = process.env.PORT || 3000;

    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`[BOOT] ✅ Server is running on port ${PORT}`);
      console.log(`[BOOT] 🔒 Environment: ${process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'aws' ? 'AWS' : 'LOCAL'}`);
      console.log('[BOOT] 🎉 Application ready to accept requests');
    });

    // Handle server errors
    server.on('error', (err) => {
      console.error('[ERROR] Server error:', err);
      process.exit(1);
    });
  } catch (error) {
    console.error('[BOOT] ❌ Failed to initialize application:');
    console.error('[BOOT] Error:', error.message);
    console.error('[BOOT] Stack:', error.stack);
    process.exit(1);
  }
})();
