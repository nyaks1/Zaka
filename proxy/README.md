# Zaka advisor proxy

The app never holds a Gemini key. It sends only this JSON to the proxy:

```json
{
  "runwayDays": 3,
  "dailyBurnRand": 90,
  "categoryPercent": { "Taxi": 48, "Food": 52 },
  "periodDays": 14
}
```

The worker rejects anything else, caps the body at 1 KB / 1,000 characters,
checks a per-install token, and calls Gemini. It never logs the summary or the
token.

## Deploy (Cloudflare Workers)

```sh
cd proxy
npx wrangler login
npx wrangler secret put GEMINI_API_KEY
npx wrangler secret put GEMINI_MODEL
# Optional alert webhook:
npx wrangler secret put BUDGET_ALERT_WEBHOOK
npx wrangler deploy
```

Set `GEMINI_MODEL` from the current list at
<https://ai.google.dev/gemini-api/docs/models>. The worker has no default model
name on purpose.

For the per-install daily limit and daily usage alert, create a KV namespace and
uncomment the binding in `wrangler.toml`:

```sh
npx wrangler kv namespace create ADVISOR_RATE_LIMIT
```

Without the KV binding the worker still enforces the allowlist, size cap and
POST-only rule; it just cannot rate-limit or alert. The install token is a
rate-limit key, not a shared secret: the worker only checks its shape, so do not
treat it as authentication. Enable KV and a budget alert before sharing the URL
widely. For the web build, set `ALLOWED_ORIGIN` in `wrangler.toml` to the
deployed web origin instead of `*`. The Android app does not send an `Origin`
header.

## Build the app against the proxy

```sh
flutter build apk --release \
  --dart-define=ADVISOR_PROXY_URL=https://zaka-advisor.<your-subdomain>.workers.dev
```

The consent switch must be on before the app makes the request. If the proxy is
missing or unreachable, the app uses its deterministic offline tip.

## Unit checks (Node 18+)

```sh
cd proxy
npm test
```

The tests cover POST-only, the exact four-field allowlist, extra fields,
unknown categories, the install token, the 1 KB cap, content type, the
"financial advice" and product/provider output filter, and the Gemini request
keeping the prompt in `systemInstruction` with only the four summary fields in
`contents`.

## curl checks

Use a token of 24–128 URL-safe characters. Generate a fresh one for the
checks; do not commit a real install token.

Valid request:

```sh
TOKEN="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
curl -i -X POST "$ADVISOR_URL" \
  -H 'content-type: application/json' \
  -H "x-install-token: $TOKEN" \
  --data '{"runwayDays":3,"dailyBurnRand":90,"categoryPercent":{"Taxi":48,"Food":52},"periodDays":14}'
```

Expected: `200` with `{"tips":[...]}`.

Extra field (must be rejected):

```sh
curl -i -X POST "$ADVISOR_URL" \
  -H 'content-type: application/json' \
  -H "x-install-token: $TOKEN" \
  --data '{"runwayDays":3,"dailyBurnRand":90,"categoryPercent":{"Taxi":48},"periodDays":14,"note":"Sipho"}'
```

Expected: `400`.

Missing token:

```sh
curl -i -X POST "$ADVISOR_URL" \
  -H 'content-type: application/json' \
  --data '{"runwayDays":3,"dailyBurnRand":90,"categoryPercent":{"Taxi":48},"periodDays":14}'
```

Expected: `401`.

GET:

```sh
curl -i "$ADVISOR_URL"
```

Expected: `405`.

Oversized body:

```sh
python3 - <<'PY' >/tmp/zaka-big.json
print('{"runwayDays":3,"dailyBurnRand":90,"categoryPercent":{"Taxi":48},"periodDays":14,"padding":"' + 'x' * 1200 + '"}')
PY
curl -i -X POST "$ADVISOR_URL" \
  -H 'content-type: application/json' \
  -H "x-install-token: $TOKEN" \
  --data-binary @/tmp/zaka-big.json
```

Expected: `413`.

## Wording boundary

The prompt and the app use “tips” and “insights”, not “financial advice”. The
prompt forbids product recommendations, and the Worker rejects a tip that names
a product, insurer, bank or provider. The app shows “Tips, not financial
advice.” This is a wording boundary, not a FAIS licence. Get South African
legal review before adding referrals, product comparisons or provider links.
