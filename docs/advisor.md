# Ask Zaka: privacy, consent and proxy

Ask Zaka is optional. It is off by default. The app is fully usable without it,
and the offline tip is generated on the phone with no network.

## The only data that can leave the phone

`AdvisorSummary` in `lib/features/advisor/advisor_summary.dart` is a closed
allowlist:

```json
{
  "runwayDays": 3,
  "dailyBurnRand": 90,
  "categoryPercent": { "Taxi": 48, "Food": 52 },
  "periodDays": 14
}
```

- `runwayDays`: days until cash runs out, or `null` if it lasts beyond the
  forecast window.
- `dailyBurnRand`: average variable spend per day, in rand.
- `categoryPercent`: share of spending by category over `periodDays`. The keys
  are the fixed Zaka category labels.
- `periodDays`: the lookback window used for the category percentages.

The object has no fields for, and the code never adds:

- `Spend.note` or transaction descriptions;
- account names, bank names or institutions;
- import keys;
- exact timestamps;
- individual transactions, balances or account numbers.

The widget test `never includes a spend note, import key, or account name`
asserts that a note such as `Sipho's tuckshop` is absent from
`jsonEncode(summary.toJson())`.

## Consent gate

`AdvisorService.askAdvisor` checks `consentAdvisor` in
`shared_preferences` as its first statement:

```dart
if (!await _preferences.hasConsent()) {
  throw StateError('No consent');
}
```

Only after that check can it create the install token or call the proxy. The
test `throws before any HTTP call when consent is off` uses a client that would
record a call and asserts it is never reached.

The consent screen (`lib/features/advisor/advisor_screen.dart`) shows:

- the live summary, verbatim, as pretty-printed JSON;
- the never-sent list;
- that a Zaka proxy calls Google Gemini and Google may process the summary
  outside South Africa;
- the purpose: short cash-flow tips and insights;
- an on/off switch;
- a delete-everything button;
- “Tips, not financial advice.”

## Offline fallback

`offlineTip(summary)` is deterministic and network-free. It uses the same
summary:

> At R90 a day, your cash runs out Thursday. Taxi is 48% of your spend.

The dashboard “Ask Zaka” card always shows this tip. If the proxy is not
configured, unreachable, rate-limited, or returns an error, the app shows the
same fallback and labels it “Offline tip”.

## Proxy controls

The Cloudflare Worker in `proxy/src/index.js` is the only component with the
Gemini key. It enforces:

- `POST` only; `GET` gets `405`;
- `Content-Type: application/json`;
- a 1 KB byte cap and a 1,000-character cap;
- exactly the four top-level keys, with no extras and no missing keys;
- `runwayDays` null or 0–365;
- `dailyBurnRand` finite and 0–1,000,000;
- `periodDays` 1–365;
- `categoryPercent` limited to the six known Zaka category labels and integer
  percentages;
- an `X-Install-Token` header (24–128 URL-safe characters);
- an optional per-install daily rate limit in Cloudflare KV;
- an optional daily usage webhook for the budget alert.

The worker does not log the summary or the token. The Gemini key and model are
Wrangler secrets. `GEMINI_MODEL` has no default in the repo: set it from the
current list at <https://ai.google.dev/gemini-api/docs/models>.

Deployment and curl checks are in [`proxy/README.md`](../proxy/README.md).

## App configuration

Build with the proxy URL:

```sh
flutter build apk --release \
  --dart-define=ADVISOR_PROXY_URL=https://zaka-advisor.<subdomain>.workers.dev
```

If the define is absent, the app never calls the network for Ask Zaka and uses
the offline tip. The app refuses a non-HTTPS proxy (except `localhost` for
`wrangler dev`) before creating an install token.

## FAIS / FSCA boundary

The app and the prompt use “tips” and “insights”, not “financial advice”. The
prompt forbids loans, credit, insurance, investments, product recommendations
and provider recommendations. The app shows “Tips, not financial advice.”

This is a wording and product-design boundary, not a FAIS licence. Do not add
referrals, product comparisons, provider links, or personalised investment
recommendations without South African legal review and the appropriate
licence/representative arrangements.

## Delete everything

`PrivacyService.deleteEverything()` calls `AppDatabase.deleteEverything()`,
which deletes every table in one transaction, then runs a best-effort `VACUUM`
so SQLite does not keep old rows in free pages, then clears all
`shared_preferences`. The UI recreates a blank Cash account afterwards so the
app remains usable. The test `deleteEverything empties every table and clears
preferences` checks every table and the preference clear.
