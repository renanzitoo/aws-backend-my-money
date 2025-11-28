const express = require('express');
const cors = require('cors');
const awsSecrets = require('./utils/aws-secrets');

// Initialize AWS secrets or local .env BEFORE importing routes
(async () => {
  try {
    console.log('🔧 Initializing application configuration...');

    // CRITICAL: Load configuration from AWS Secrets Manager or .env FIRST
    const config = await awsSecrets.getConfig();

    // Set environment variables BEFORE importing routes (which may use Prisma)
    process.env.DATABASE_URL = config.DATABASE_URL;
    process.env.JWT_SECRET = config.JWT_SECRET;
    // PORT is handled as direct environment variable, not from secrets

    console.log(`✅ Configurations loaded from: ${process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'aws' ? 'AWS Secrets Manager' : 'local .env'}`);
    console.log(`📊 DATABASE_URL: ${process.env.DATABASE_URL ? 'configured' : 'MISSING'}`);
    console.log(`🔐 JWT_SECRET: ${process.env.JWT_SECRET ? 'configured' : 'MISSING'}`);

    // NOW import routes (after DATABASE_URL is set)
    const healthRoutes = require('./routes/health.routes');
    const authRoutes = require('./routes/auth.routes');
    const urlRoutes = require('./routes/url.routes');

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

    app.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
      console.log(`🔒 Database URL configured from ${process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'aws' ? 'AWS Secrets Manager' : '.env file'}`);
    });
  } catch (error) {
    console.error('❌ Failed to initialize application:', error);
    process.exit(1);
  }
})();
