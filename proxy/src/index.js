/**
 * Zaka advisor proxy.
 *
 * The app sends exactly four fields. This worker is the only place that knows
 * the Gemini key. It rejects anything outside the allowlist, caps the request
 * size, and can rate-limit per install token and alert on daily usage.
 */

const ALLOWED_KEYS = new Set([
  'runwayDays',
  'dailyBurnRand',
  'categoryPercent',
  'periodDays',
]);

const CATEGORY_KEYS = new Set([
  'Taxi',
  'Vendor',
  'Airtime',
  'Electricity',
  'Food',
  'Other',
]);

const MAX_BODY_BYTES = 1024;
const MAX_BODY_CHARS = 1000;
const MAX_TIPS = 3;

const FEEDBACK_KEYS = new Set([
  'message',
  'appVersion',
  'androidVersion',
  'replyTo',
]);
const MAX_FEEDBACK_BYTES = 4096;
const MAX_FEEDBACK_CHARS = 4000;
const MAX_FEEDBACK_MESSAGE = 2000;

// A model can ignore the prompt. Block common product, provider and advice
// terms before they reach the app; a blocklist reduces risk, it is not a
// guarantee that every unsafe sentence is caught.
const FORBIDDEN =
  /\b(financial advice|invest\w*|loans?|credit|insurance|polic(?:y|ies)|unit trusts?|savings account|fnb|capitec|absa|nedbank|standard bank|tymebank|discovery|mashonisa)\b/i;

export default {
  async fetch(request, env) {
    const cors = corsHeaders(request, env);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }
    if (request.method !== 'POST') {
      return json({ error: 'Method not allowed' }, 405, cors);
    }

    const path = new URL(request.url).pathname.replace(/\/+$/, '');
    if (path === '/feedback') {
      return handleFeedback(request, env, cors);
    }

    const contentType = (request.headers.get('content-type') || '').toLowerCase();
    if (!contentType.startsWith('application/json')) {
      return json({ error: 'Content-Type must be application/json' }, 415, cors);
    }

    const declaredLength = Number(request.headers.get('content-length') || 0);
    if (declaredLength > MAX_BODY_BYTES) {
      return json({ error: 'Request body is too large' }, 413, cors);
    }

    let raw;
    try {
      raw = await request.text();
    } catch {
      return json({ error: 'Could not read request body' }, 400, cors);
    }
    if (raw.length > MAX_BODY_CHARS || new TextEncoder().encode(raw).length > MAX_BODY_BYTES) {
      return json({ error: 'Request body is too large' }, 413, cors);
    }

    let summary;
    try {
      summary = JSON.parse(raw);
    } catch {
      return json({ error: 'Body must be valid JSON' }, 400, cors);
    }

    const validation = validateSummary(summary);
    if (!validation.ok) {
      return json({ error: validation.error }, 400, cors);
    }

    const token = request.headers.get('x-install-token') || '';
    if (!/^[A-Za-z0-9_-]{24,128}$/.test(token)) {
      return json({ error: 'Missing or invalid install token' }, 401, cors);
    }

    const rate = await checkRateLimit(env, token);
    if (!rate.ok) {
      return json({ error: rate.error }, 429, cors);
    }

    const apiKey = String(env.GEMINI_API_KEY || '').trim();
    const model = String(env.GEMINI_MODEL || '').trim().replace(/^models\//, '');
    if (!apiKey || !model) {
      return json({ error: 'Advisor is not configured' }, 500, cors);
    }

    const promptSummary = {
      ...summary,
      dailyBurnRand: Math.round(summary.dailyBurnRand),
    };

    let upstream;
    try {
      upstream = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
        {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: JSON.stringify({
            systemInstruction: {
              parts: [{ text: PROMPT }],
            },
            contents: [
              {
                parts: [
                  {
                    text: `Summary JSON:\n${JSON.stringify(promptSummary)}`,
                  },
                ],
              },
            ],
            generationConfig: {
              temperature: 0.4,
              maxOutputTokens: 300,
              responseMimeType: 'application/json',
              responseSchema: {
                type: 'OBJECT',
                properties: {
                  tips: {
                    type: 'ARRAY',
                    items: { type: 'STRING' },
                  },
                },
                required: ['tips'],
              },
            },
          }),
        },
      );
    } catch {
      return json({ error: 'Could not reach the tips service' }, 502, cors);
    }

    if (!upstream.ok) {
      return json({ error: 'Tips service returned an error' }, 502, cors);
    }

    let upstreamJson;
    try {
      upstreamJson = await upstream.json();
    } catch {
      return json({ error: 'Tips service returned invalid JSON' }, 502, cors);
    }

    const text = upstreamJson?.candidates?.[0]?.content?.parts
      ?.map((part) => part?.text || '')
      .join('') || '';
    const tips = parseTips(text);
    if (!tips) {
      return json({ error: 'Tips service returned no tips' }, 502, cors);
    }

    await recordUsage(env);
    return json({ tips }, 200, cors);
  },
};

const PROMPT = `You are Zaka, a cash-flow tips assistant for a South African cash tracker.
You receive only this privacy-safe summary: runwayDays (days until cash runs out, or null if it lasts beyond the forecast), dailyBurnRand (average spend per day in rand), categoryPercent (share of spending by category over periodDays), and periodDays.
Do not ask for or infer names, notes, account numbers, banks, locations, exact dates, or individual transactions.
Write 2 short, practical tips in plain language. Use "tips" or "insights", never "financial advice". Do not recommend loans, credit, insurance, investments, or any financial product or provider. Phrase tips as projections ("at this pace…"), never as instructions about products, providers, banks or accounts. If runwayDays is low, suggest reducing the largest category or pausing non-essential spend. If runwayDays is null, say cash lasts beyond the forecast window.
Return strict JSON only: {"tips":["...","..."]}. Each tip must be under 240 characters. No markdown.`;

function validateSummary(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return { ok: false, error: 'Body must be a JSON object' };
  }

  const keys = Object.keys(value);
  if (keys.length !== ALLOWED_KEYS.size || !keys.every((key) => ALLOWED_KEYS.has(key))) {
    return { ok: false, error: 'Only the four summary fields are allowed' };
  }

  const { runwayDays, dailyBurnRand, categoryPercent, periodDays } = value;

  if (
    runwayDays !== null &&
    (!Number.isInteger(runwayDays) || runwayDays < 0 || runwayDays > 365)
  ) {
    return { ok: false, error: 'runwayDays must be null or an integer from 0 to 365' };
  }

  if (
    typeof dailyBurnRand !== 'number' ||
    !Number.isFinite(dailyBurnRand) ||
    dailyBurnRand < 0 ||
    dailyBurnRand > 1000000
  ) {
    return { ok: false, error: 'dailyBurnRand must be a number from 0 to 1000000' };
  }

  if (!Number.isInteger(periodDays) || periodDays < 1 || periodDays > 365) {
    return { ok: false, error: 'periodDays must be an integer from 1 to 365' };
  }

  if (
    !categoryPercent ||
    typeof categoryPercent !== 'object' ||
    Array.isArray(categoryPercent)
  ) {
    return { ok: false, error: 'categoryPercent must be an object' };
  }

  const entries = Object.entries(categoryPercent);
  if (entries.length > CATEGORY_KEYS.size) {
    return { ok: false, error: 'categoryPercent has too many categories' };
  }
  for (const [key, percent] of entries) {
    if (!CATEGORY_KEYS.has(key)) {
      return { ok: false, error: 'categoryPercent contains an unknown category' };
    }
    if (!Number.isInteger(percent) || percent < 0 || percent > 100) {
      return { ok: false, error: 'categoryPercent values must be integers from 0 to 100' };
    }
  }

  return { ok: true };
}

async function handleFeedback(request, env, cors) {
  const contentType = (request.headers.get('content-type') || '').toLowerCase();
  if (!contentType.startsWith('application/json')) {
    return json({ error: 'Content-Type must be application/json' }, 415, cors);
  }

  const declaredLength = Number(request.headers.get('content-length') || 0);
  if (declaredLength > MAX_FEEDBACK_BYTES) {
    return json({ error: 'Feedback is too large' }, 413, cors);
  }

  let raw;
  try {
    raw = await request.text();
  } catch {
    return json({ error: 'Could not read feedback' }, 400, cors);
  }
  if (
    raw.length > MAX_FEEDBACK_CHARS ||
    new TextEncoder().encode(raw).length > MAX_FEEDBACK_BYTES
  ) {
    return json({ error: 'Feedback is too large' }, 413, cors);
  }

  let value;
  try {
    value = JSON.parse(raw);
  } catch {
    return json({ error: 'Body must be valid JSON' }, 400, cors);
  }

  const validation = validateFeedback(value);
  if (!validation.ok) {
    return json({ error: validation.error }, 400, cors);
  }

  const token = request.headers.get('x-install-token') || '';
  if (!/^[A-Za-z0-9_-]{24,128}$/.test(token)) {
    return json({ error: 'Missing or invalid install token' }, 401, cors);
  }

  const rate = await checkFeedbackRateLimit(env, token);
  if (!rate.ok) {
    return json({ error: rate.error }, 429, cors);
  }

  const webhook = String(env.FEEDBACK_WEBHOOK || '').trim();
  if (!webhook) {
    return json({ error: 'Feedback is not configured' }, 503, cors);
  }

  // Defang broadcast mentions so webhooks (e.g. Discord, Slack) cannot be
  // exploited for channel-wide pings, and disable Discord mention parsing.
  const cleanMessage = validation.message.replace(/@(everyone|here)/gi, '@\u200b$1');
  const lines = ['New Zaka feedback', '', cleanMessage];
  if (validation.replyTo) lines.push('', `Reply-to: ${validation.replyTo}`);
  if (validation.appVersion) {
    lines.push(`App version: ${validation.appVersion}`);
  }
  if (validation.androidVersion) {
    lines.push(`Android: ${validation.androidVersion}`);
  }
  const text = lines.join('\n');

  try {
    const response = await fetch(webhook, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      // `text` works with Slack-style webhooks; `content` with Discord-style
      // ones. `allowed_mentions` prevents Discord mention pings.
      body: JSON.stringify({
        text,
        content: text,
        allowed_mentions: { parse: [] },
      }),
    });
    if (!response.ok) {
      return json({ error: 'Could not deliver feedback' }, 502, cors);
    }
  } catch {
    return json({ error: 'Could not deliver feedback' }, 502, cors);
  }

  return json({ ok: true }, 202, cors);
}

function validateFeedback(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return { ok: false, error: 'Body must be a JSON object' };
  }

  const keys = Object.keys(value);
  if (!keys.every((key) => FEEDBACK_KEYS.has(key))) {
    return { ok: false, error: 'Unexpected feedback field' };
  }

  const message = typeof value.message === 'string' ? value.message.trim() : '';
  if (!message) {
    return { ok: false, error: 'Message is required' };
  }
  if (message.length > MAX_FEEDBACK_MESSAGE) {
    return { ok: false, error: 'Message is too long' };
  }

  const appVersion =
    typeof value.appVersion === 'string' ? value.appVersion.trim() : '';
  const androidVersion =
    typeof value.androidVersion === 'string'
      ? value.androidVersion.trim()
      : '';
  if (appVersion.length > 64 || androidVersion.length > 64) {
    return { ok: false, error: 'Version field is too long' };
  }

  const replyTo = typeof value.replyTo === 'string' ? value.replyTo.trim() : '';
  if (replyTo) {
    if (
      replyTo.length > 254 ||
      !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(replyTo)
    ) {
      return { ok: false, error: 'Reply-to email is invalid' };
    }
  }

  return {
    ok: true,
    message,
    appVersion: appVersion || null,
    androidVersion: androidVersion || null,
    replyTo: replyTo || null,
  };
}

async function checkFeedbackRateLimit(env, token) {
  const kv = env.ADVISOR_RATE_LIMIT;
  if (!kv) return { ok: true };

  const limit = Number(env.FEEDBACK_DAILY_LIMIT || 3);
  const day = new Date().toISOString().slice(0, 10);
  const key = `feedback:${token}:${day}`;
  const current = Number(await kv.get(key)) || 0;
  if (current >= limit) {
    return { ok: false, error: 'Daily feedback limit reached' };
  }
  await kv.put(key, String(current + 1), { expirationTtl: 172800 });
  return { ok: true };
}

async function checkRateLimit(env, token) {
  const kv = env.ADVISOR_RATE_LIMIT;
  if (!kv) return { ok: true };

  const limit = Number(env.DAILY_LIMIT || 20);
  const day = new Date().toISOString().slice(0, 10);
  const key = `rate:${token}:${day}`;
  const current = Number(await kv.get(key)) || 0;
  if (current >= limit) {
    return { ok: false, error: 'Daily limit reached' };
  }
  await kv.put(key, String(current + 1), { expirationTtl: 172800 });
  return { ok: true };
}

async function recordUsage(env) {
  const kv = env.ADVISOR_RATE_LIMIT;
  if (!kv) return;

  const day = new Date().toISOString().slice(0, 10);
  const key = `usage:${day}`;
  const current = Number(await kv.get(key)) || 0;
  const next = current + 1;
  await kv.put(key, String(next), { expirationTtl: 172800 });

  const threshold = Number(env.DAILY_ALERT_CALLS || 100);
  if (next === threshold && env.BUDGET_ALERT_WEBHOOK) {
    try {
      await fetch(env.BUDGET_ALERT_WEBHOOK, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          text: `Zaka advisor reached ${next} Gemini calls today.`,
        }),
      });
    } catch {
      // Alerts are best-effort and must never break a user request.
    }
  }
}

function parseTips(raw) {
  let text = String(raw || '').trim();
  if (!text) return null;

  if (text.startsWith('```')) {
    text = text.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  }

  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch {
    return null;
  }

  let values;
  if (Array.isArray(parsed)) {
    values = parsed;
  } else if (parsed && typeof parsed === 'object' && Array.isArray(parsed.tips)) {
    values = parsed.tips;
  } else if (parsed && typeof parsed === 'object' && typeof parsed.text === 'string') {
    values = [parsed.text];
  } else {
    return null;
  }

  const tips = values
    .filter((value) => typeof value === 'string')
    .map((value) => value.trim())
    .filter((value) => value.length > 0)
    .slice(0, MAX_TIPS)
    .map((value) => value.slice(0, 240));

  // Defence in depth: the app labels tips, but a model that ignores the
  // prompt must not put "financial advice", a product or a bank into the UI.
  if (tips.some((tip) => FORBIDDEN.test(tip))) return null;

  return tips.length > 0 ? tips : null;
}

function corsHeaders(request, env) {
  const allowed = env.ALLOWED_ORIGIN || '*';
  const origin = request.headers.get('origin');
  const allowOrigin = allowed === '*' ? '*' : origin === allowed ? origin : allowed;
  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Headers': 'Content-Type, X-Install-Token',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

function json(body, status, headers) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...headers,
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    },
  });
}
