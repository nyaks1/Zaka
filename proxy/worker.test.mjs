import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';

import worker from './src/index.js';

const TOKEN = 'test-install-token-1234567890';
const VALID = {
  runwayDays: 3,
  dailyBurnRand: 90,
  categoryPercent: { Taxi: 48, Food: 52 },
  periodDays: 14,
};

const env = {
  GEMINI_API_KEY: 'test-key',
  GEMINI_MODEL: 'test-model',
  DAILY_LIMIT: '20',
  DAILY_ALERT_CALLS: '100',
  ALLOWED_ORIGIN: '*',
};

const originalFetch = globalThis.fetch;

afterEach(() => {
  globalThis.fetch = originalFetch;
});

function request(body, { method = 'POST', token = TOKEN, type = 'application/json' } = {}) {
  const headers = { 'content-type': type };
  if (token) headers['x-install-token'] = token;
  return new Request('https://proxy.example.test/tips', {
    method,
    headers,
    body: method === 'GET' ? undefined : typeof body === 'string' ? body : JSON.stringify(body),
  });
}

function stubGemini(tips) {
  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        candidates: [
          {
            content: {
              parts: [{ text: JSON.stringify({ tips }) }],
            },
          },
        ],
      }),
      { status: 200, headers: { 'content-type': 'application/json' } },
    );
}

test('GET is rejected', async () => {
  const response = await worker.fetch(request(null, { method: 'GET' }), env);
  assert.equal(response.status, 405);
});

test('a valid summary returns tips', async () => {
  stubGemini(['Watch the food spend.', 'Keep taxi fares steady.']);
  const response = await worker.fetch(request(VALID), env);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    tips: ['Watch the food spend.', 'Keep taxi fares steady.'],
  });
});

test('an extra field is rejected', async () => {
  const response = await worker.fetch(
    request({ ...VALID, note: "Sipho's tuckshop" }),
    env,
  );
  assert.equal(response.status, 400);
});

test('an unknown category is rejected', async () => {
  const response = await worker.fetch(
    request({ ...VALID, categoryPercent: { Secret: 50 } }),
    env,
  );
  assert.equal(response.status, 400);
});

test('a missing install token is rejected', async () => {
  const response = await worker.fetch(request(VALID, { token: '' }), env);
  assert.equal(response.status, 401);
});

test('an oversized body is rejected', async () => {
  const response = await worker.fetch(
    request({ ...VALID, padding: 'x'.repeat(1200) }),
    env,
  );
  assert.equal(response.status, 413);
});

test('the wrong content type is rejected', async () => {
  const response = await worker.fetch(
    request(VALID, { type: 'text/plain' }),
    env,
  );
  assert.equal(response.status, 415);
});

test('the per-install daily limit returns 429', async () => {
  stubGemini(['One tip.']);
  const values = new Map();
  const kv = {
    get: async (key) => values.get(key) ?? null,
    put: async (key, value) => values.set(key, value),
  };
  const limitedEnv = { ...env, ADVISOR_RATE_LIMIT: kv, DAILY_LIMIT: '1' };

  const first = await worker.fetch(request(VALID), limitedEnv);
  const second = await worker.fetch(request(VALID), limitedEnv);

  assert.equal(first.status, 200);
  assert.equal(second.status, 429);
});

test('a model that says "financial advice" is rejected', async () => {
  stubGemini(['This is financial advice: take a loan.']);
  const response = await worker.fetch(request(VALID), env);
  assert.equal(response.status, 502);
});

test('the Gemini request contains only the four-field summary and uses x-goog-api-key header', async () => {
  let captured;
  let capturedUrl;
  let capturedHeaders;
  globalThis.fetch = async (url, init) => {
    capturedUrl = url;
    capturedHeaders = init.headers;
    captured = JSON.parse(init.body);
    return new Response(
      JSON.stringify({
        candidates: [
          {
            content: {
              parts: [{ text: JSON.stringify({ tips: ['One tip.'] }) }],
            },
          },
        ],
      }),
      { status: 200, headers: { 'content-type': 'application/json' } },
    );
  };

  const response = await worker.fetch(request(VALID), env);
  assert.equal(response.status, 200);

  assert.equal(
    capturedUrl,
    'https://generativelanguage.googleapis.com/v1beta/models/test-model:generateContent',
  );
  assert.doesNotMatch(capturedUrl, /[?&]key=/);
  assert.equal(capturedHeaders['x-goog-api-key'], 'test-key');

  const prompt = captured.contents[0].parts[0].text;
  assert.match(prompt, /"runwayDays":3/);
  assert.match(prompt, /"dailyBurnRand":90/);
  assert.match(prompt, /"categoryPercent":\{"Taxi":48,"Food":52\}/);
  assert.match(prompt, /"periodDays":14/);
  assert.doesNotMatch(prompt, /Sipho/);
});

test('dailyBurnRand is rounded to the nearest whole rand for the prompt', async () => {
  let captured;
  globalThis.fetch = async (_url, init) => {
    captured = JSON.parse(init.body);
    return new Response(
      JSON.stringify({
        candidates: [
          {
            content: {
              parts: [{ text: JSON.stringify({ tips: ['One tip.'] }) }],
            },
          },
        ],
      }),
      { status: 200, headers: { 'content-type': 'application/json' } },
    );
  };

  const response = await worker.fetch(
    request({ ...VALID, dailyBurnRand: 89.6 }),
    env,
  );
  assert.equal(response.status, 200);

  const prompt = captured.contents[0].parts[0].text;
  assert.match(prompt, /"dailyBurnRand":90/);
});

