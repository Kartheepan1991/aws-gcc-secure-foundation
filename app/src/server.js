const express = require('express');
const prometheusClient = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Prometheus metrics
const register = new prometheusClient.Registry();
prometheusClient.collectDefaultMetrics({ register });

const httpRequestDuration = new prometheusClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Middleware
app.use(express.json());
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});

// Health check endpoint (required for ALB)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Readiness check
app.get('/ready', (req, res) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString()
  });
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Main application endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'GCC Secure Foundation - Sample Microservice',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    service: 'gcc-sample-service',
    version: '1.0.0',
    compliance: {
      gcc: true,
      encryption: 'KMS',
      logging: 'CloudWatch'
    },
    deployment: {
      platform: 'EKS',
      region: process.env.AWS_REGION || 'ap-southeast-1'
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
