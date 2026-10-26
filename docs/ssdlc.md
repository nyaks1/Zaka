# SSDLC / security and privacy questionnaire (repo copy)

This is the repository copy of the SSDLC answers for the FNB App of the Year
Hackathon 2026 build. The external submission form was not present in this
checkout, so this file is the source of truth to copy into that form. It matches
the README, the in-app privacy policy and `docs/evidence/`.

## Project

| Field | Answer |
|---|---|
| Project | Zaka — cash tracker and cash-runway forecast |
| Version | 0.1.0+1 (hackathon build) |
| Package | `za.co.zaka.zaka` |
| Minimum Android | 7.0 (API 24) |
| Target Android | API 36 |
| Backend | Optional Cloudflare Worker for Ask Zaka tips and feedback only |
| Data store | On-device SQLite (Drift); no money database server |
| Repository | <https://github.com/nyaks1/Zaka> |

## Contact and complaints

- **Responsible party / Information Officer:** Nyakallo Masiu, solo developer.
- **Contact path:** Account → **Send feedback or a complaint**, and the same row
  on Privacy & Ask Zaka. Tapping copies the configured contact.
- **If no email alias is configured:** the contact is the public GitHub Issues
  page, <https://github.com/nyaks1/Zaka/issues>. Never paste financial data
  there.
- **In-app form:** in a build with a Worker URL, posts a message to the Worker
  `/feedback` route, which forwards it to a webhook and stores nothing. The
  public hackathon APK has no Worker URL, so it points at GitHub Issues.
- **Deletion:** Privacy & Ask Zaka → **Delete everything** removes money tables,
  the local account and sign-in, the app-lock PIN, and Ask Zaka settings.
- **Regulator:** Information Regulator (South Africa),
  <https://inforegulator.org.za/>. Registration is a pre-launch task; this
  hackathon build is not yet registered.

## Data map

| Data | Where | Purpose | Leaves the phone? | Retention |
|---|---|---|---|---|
| Amounts, dates, categories, notes, account names | SQLite on phone | Cash tracking and forecast | No | Until delete-all or uninstall |
| Local account name, email, password hash | SQLite on phone | Sign-in and trial | No | Until delete-all |
| App-lock PIN hash | SharedPreferences | Unlock the app | No | Until turned off, delete-all or uninstall |
| Ask Zaka four-field summary | Worker → Google Gemini | Tips | Yes, only with consent | Not stored by the Worker; Google policy applies |
| Install token | SharedPreferences; Worker KV rate-limit key | Rate limiting | Yes, header only | KV key expires after 2 days |
| Feedback message | Worker → webhook | Support | Yes, only when sent | Worker stores nothing; webhook policy applies |
| Optional reply email, app version, Android version | Worker → webhook | Reply and triage | Only if provided/ticked | Webhook policy applies |

## Cross-border processing

The Ask Zaka consent text says Google may process the four fields **outside
South Africa**. The in-app privacy policy repeats it, and `README.md` states it.
The four fields are `runwayDays`, `dailyBurnRand`, `categoryPercent` and
`periodDays`; no names, notes, banks, account numbers, import keys or exact
timestamps have a field. Cloudflare may process request metadata outside South
Africa as the hosting provider.

## Security controls in this build

- Consent gate before any Ask Zaka network call; off by default.
- Closed allowlist for the summary; extra fields rejected.
- 1 KB / 1,000-character cap on tips, 4 KB / 4,000-character cap on feedback.
- POST-only, JSON content type, install-token shape check, optional KV rate
  limits (tips 20/day default; feedback 3/day default).
- Output denylist for “financial advice”, products, insurers, banks and
  providers; a blocked tip becomes `502` and the app shows the offline tip.
- Gemini prompt in `systemInstruction`; only the summary in `contents`.
- Gemini key and feedback webhook are Wrangler secrets, never in the APK.
- PBKDF2-HMAC-SHA256 for local passwords and the app-lock PIN.
- Android `allowBackup=false`; `FLAG_SECURE` hides balances from recents and
  screenshots.
- No analytics, ads, crash reporting or tracking SDK.
- No bank credentials, card numbers or OTPs are requested.
- PDF/CSV parsing happens on the phone; files are not uploaded.
- `gitleaks` and `osv-scanner` evidence is in `docs/evidence/`.

## Verification

| Check | Result | Evidence |
|---|---|---|
| `flutter analyze` | No issues | `docs/evidence/flutter_analyze.txt` |
| `flutter test` | 81 tests pass | `docs/evidence/flutter_test.txt` |
| Worker `npm test` | 22 tests pass | `docs/evidence/proxy_tests.txt` |
| Release APK builds | Yes, debug-signed demo | `docs/evidence/apk_build.txt` |
| Secrets scan | gitleaks, no leaks | `docs/evidence/gitleaks.txt` |
| Dependency scan | OSV, no known vulnerabilities | `docs/evidence/osv_scanner.txt` |
| Live Worker curls | 405/401/400/415/413/500 as expected | `docs/evidence/curl_checks.txt` |
| Device smoke test | Android 16, sample data, add, spend, consent | `docs/evidence/logcat_clean.txt`, screenshots |

## Known gaps and roadmap

1. **No encrypted export or backup.** This is the largest POPIA access gap. A
   lost phone loses the data. Roadmap: encrypted JSON/CSV export with a user
   passphrase, plus opt-in encrypted backup.
2. **Plain SQLite at rest.** No SQLCipher yet. App lock and `FLAG_SECURE` hide
   the UI, not the database file.
3. **No biometric unlock.** PIN only; biometrics need a native plugin and
   permission.
4. **English-only UI, no Semantics coverage.** Targets are isiZulu, Setswana and
   Sesotho. A monochrome contrast check is in `docs/accessibility.md`.
5. **No crash reporting.** Deliberate privacy choice, not an omission.
6. **Local accounts only.** No email verification, password reset, session
   expiry, central directory or server-side roles.
7. **Debug-signed APK.** Not a Play Store build; production keystore signing is
   roadmap.
8. **No payments.** Refund route is not implemented because nobody can be
   charged. When payments ship, the refund and complaint path must be published
   before taking money.
9. **Live bank sync is roadmap.** No Stitch integration or bank credentials.
10. **18+ only.** POPIA children's-data rules are not implemented because the
    product is not directed at children.

## Incident response

1. Take the Worker or APK link down if a secret or data leak is suspected.
2. Rotate the Gemini key, webhook URL and any Cloudflare token.
3. Check `docs/evidence/` and git history with gitleaks; do not paste secrets in
   issues.
4. Tell affected users what happened and what they can do; do not include their
   money data in the message.
5. Record the incident, the fix and the follow-up test.
6. If personal information was compromised, assess the POPIA notification
   duties and the Information Regulator's current process.

## Sign-off

This is a hackathon pre-release. It is not a claim of POPIA certification, FAIS
licensing, or production security. Get South African legal and security review
before a public launch, payments, live bank sync or a central account service.
