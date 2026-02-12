const request = require('supertest');
const app = require('./index');

describe('GET /', () => {
  it('should return Hello from Jenkins Pipeline!', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.text).toBe('Hello from Jenkins Pipeline!');
  });
});

describe('GET /health', () => {
  it('should return status UP', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'UP' });
  });
});
