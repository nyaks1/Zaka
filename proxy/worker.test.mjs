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
  FEEDBACK_WEBHOOK: 'https://hooks.example.test/feedback',
  FEEDBACK_DAILY_LIMIT: '3',
};

const originalFetch = globalThis.fetch;

afterEach(() => {
  globalThis.fetch = originalFetch;
});

function request(body, { method = 'POST', token = TOKEN, type = 'application/json', path = '/tips' } = {}) {
  const headers = { 'content-type': type };
  if (token) headers['x-install-token'] = token;
  return new Request(`https://proxy.example.test${path}`, {
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

test('a clean projection tip is returned', async () => {
  const tip = 'At R80 a day your cash lasts 5 days; Taxi is 60% of spend.';
  stubGemini([tip]);
  const response = await worker.fetch(request(VALID), env);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { tips: [tip] });
});

test('a tip that names a bank or product is rejected', async () => {
  stubGemini(['Move your money to Capitec.']);
  const response = await worker.fetch(request(VALID), env);
  assert.equal(response.status, 502);
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

  const systemPrompt = captured.systemInstruction.parts[0].text;
  assert.match(systemPrompt, /You are Zaka/);
  assert.match(systemPrompt, /Phrase tips as projections/);
  assert.doesNotMatch(systemPrompt, /"runwayDays":3/);

  const summaryText = captured.contents[0].parts[0].text;
  assert.match(summaryText, /"runwayDays":3/);
  assert.match(summaryText, /"dailyBurnRand":90/);
  assert.match(summaryText, /"categoryPercent":\{"Taxi":48,"Food":52\}/);
  assert.match(summaryText, /"periodDays":14/);
  assert.doesNotMatch(summaryText, /You are Zaka/);
  assert.doesNotMatch(summaryText, /Sipho/);
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

  const summaryText = captured.contents[0].parts[0].text;
  assert.match(summaryText, /"dailyBurnRand":90/);
});

function feedback(body, options = {}) {
  return request(body, { path: '/feedback', ...options });
}

function stubWebhook() {
  const captured = [];
  globalThis.fetch = async (url, init) => {
    captured.push({ url, body: JSON.parse(init.body) });
    return new Response('ok', { status: 200 });
  };
  return captured;
}

test('valid feedback is forwarded to the webhook and accepted', async () => {
  const captured = stubWebhook();
  const response = await worker.fetch(
    feedback({
      message: 'The import preview was hard to read @everyone and @here.',
      appVersion: '0.1.0+1',
      androidVersion: 'Android 16 (SDK 36)',
      replyTo: 'tester@example.com',
    }),
    env,
  );

  assert.equal(response.status, 202);
  assert.deepEqual(await response.json(), { ok: true });
  assert.equal(captured.length, 1);
  assert.equal(captured[0].url, env.FEEDBACK_WEBHOOK);
  assert.match(captured[0].body.text, /import preview/);
  assert.match(captured[0].body.text, /tester@example\.com/);
  assert.match(captured[0].body.text, /Android 16/);
  assert.doesNotMatch(captured[0].body.text, /@everyone/);
  assert.doesNotMatch(captured[0].body.text, /@here/);
  assert.match(captured[0].body.text, /@\u200beveryone/);
  assert.deepEqual(captured[0].body.allowed_mentions, { parse: [] });
});

test('feedback with an extra field is rejected', async () => {
  const response = await worker.fetch(
    feedback({ message: 'Hello', bank: 'FNB' }),
    env,
  );
  assert.equal(response.status, 400);
});

test('feedback without a message is rejected', async () => {
  const response = await worker.fetch(feedback({ message: '   ' }), env);
  assert.equal(response.status, 400);
});

test('feedback without an install token is rejected', async () => {
  const response = await worker.fetch(
    feedback({ message: 'Hello' }, { token: '' }),
    env,
  );
  assert.equal(response.status, 401);
});

test('oversized feedback is rejected before delivery', async () => {
  const response = await worker.fetch(
    feedback({ message: 'x'.repeat(5000) }),
    env,
  );
  assert.equal(response.status, 413);
});

test('feedback returns 503 when no webhook is configured', async () => {
  const response = await worker.fetch(
    feedback({ message: 'Hello' }),
    { ...env, FEEDBACK_WEBHOOK: '' },
  );
  assert.equal(response.status, 503);
});

test('an invalid reply-to email is rejected', async () => {
  const response = await worker.fetch(
    feedback({ message: 'Hello', replyTo: 'not-an-email' }),
    env,
  );
  assert.equal(response.status, 400);
});

test('the feedback route has its own daily limit', async () => {
  stubWebhook();
  const values = new Map();
  const kv = {
    get: async (key) => values.get(key) ?? null,
    put: async (key, value) => values.set(key, value),
  };
  const limitedEnv = {
    ...env,
    ADVISOR_RATE_LIMIT: kv,
    FEEDBACK_DAILY_LIMIT: '1',
  };

  const first = await worker.fetch(feedback({ message: 'One' }), limitedEnv);
  const second = await worker.fetch(feedback({ message: 'Two' }), limitedEnv);

  assert.equal(first.status, 202);
  assert.equal(second.status, 429);
});

test('GET on the feedback route is rejected', async () => {
  const response = await worker.fetch(
    feedback(null, { method: 'GET' }),
    env,
  );
  assert.equal(response.status, 405);
});

