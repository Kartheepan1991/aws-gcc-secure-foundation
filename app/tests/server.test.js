const request = require('supertest');
const app = require('../src/server');

describe('API Endpoints', () => {
  describe('GET /health', () => {
    it('should return 200 and health status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'healthy');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('uptime');
    });
  });

  describe('GET /ready', () => {
    it('should return 200 and ready status', async () => {
      const res = await request(app).get('/ready');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'ready');
    });
  });

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('version', '1.0.0');
    });
  });

  describe('GET /api/info', () => {
    it('should return service information', async () => {
      const res = await request(app).get('/api/info');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('service', 'gcc-sample-service');
      expect(res.body.compliance).toHaveProperty('gcc', true);
      expect(res.body.deployment).toHaveProperty('platform', 'EKS');
    });
  });

  describe('GET /metrics', () => {
    it('should return Prometheus metrics', async () => {
      const res = await request(app).get('/metrics');
      expect(res.statusCode).toBe(200);
      expect(res.text).toContain('# HELP');
    });
  });
});
