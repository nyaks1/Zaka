# Zaka — Cash Tracker + Money Across Accounts

> **Because every cent counts.**

Zaka makes cash visible. Budgeting apps see card swipes and EFTs, but the moment you withdraw at an ATM they go blind. Zaka starts exactly there: every withdrawal becomes a cash pot with a countdown, so you know when your cash will run out before it does.

It now also tracks the rest of your money. Add your FNB, Capitec, ABSA, Standard Bank, Nedbank or TymeBank accounts, import a PDF or CSV statement into each one, and see one live total without handing your banking login to an app.

Built for the **FNB App of the Year Hackathon 2026** — theme: *Financial inclusion and money confidence.*

Zaka is for people aged **18 and over**. It gives tips and insights, not
financial advice.

---

## Install it in 60 seconds

1. **Download the APK on the phone:** [zaka-0.1.0.apk](release/zaka-0.1.0.apk)
   (about 61 MB). The SHA-256 is printed next to the file and below.
2. **Check the phone:** Android **7.0 (API 24) or later**. This is a
   debug-signed hackathon build, not a Play Store release.
3. **Open the downloaded file.** Android will ask you to allow installs from
   the browser or file manager you used. Allow **that one app**, then tap
   **Install**. You do not need to enable “install unknown apps” for every app.
4. **Play Protect may warn you.** A debug-signed APK from outside the Play Store
   can trigger “Unsafe app blocked” or “App scan”. Tap **More details** (or
   **Details**) and then **Install anyway**. The exact words vary by Android
   version. Do **not** turn Play Protect off globally; if you are not happy with
   the warning, build from source or stop here.
5. **Open Zaka and tap “Try with sample data”** on the first screen. That loads
   the R900 piece-job statement, the R500 ATM transfer and the five-day runway.
   No account or bank login is needed for the demo.

If the install button is greyed out, the usual cause is that “install unknown
apps” is allowed for a different app than the one holding the APK. Open
**Settings → Apps → Special app access → Install unknown apps** and allow the
browser or file manager you actually used.

`SHA256 (zaka-0.1.0.apk)`: `4df7bcd176a578f05bb5de32983d84faf7f980ac0b80cbb2a1c605dd94ae78e2`

This public APK is built **without** a proxy URL or feedback alias. Ask Zaka
therefore shows its on-device tip, and the feedback form points at the public
GitHub Issues page instead of posting to a Worker. The online Gemini path and
the `/feedback` route ship in the source and work when a build supplies
`ADVISOR_PROXY_URL`, a deployed Worker with `FEEDBACK_WEBHOOK`, and a monitored
contact alias. Nothing in the cash tracker needs either.

The APK is also reproducible from source; see
[Build a release APK](#build-a-release-apk). The public repository is
<https://github.com/nyaks1/Zaka>.

---

## The Problem

Cash accounts for **56% of all consumer payments in South Africa by volume**, with an average cash payment of about R208 (SARB payments study). Cash is concentrated in the informal economy: only 39% of informal traders and 10% of taxi drivers accept electronic payments (SARB Cost of Cash study). These are external published figures, not measurements from this build.

Bank-feed apps like 22seven can't see any of it. People with irregular incomes — paying for taxis, street vendors and spaza shops — lose track of small, frequent spends and run out of cash before payday, with no early warning and no affordable financial advice.

The villain isn't cash. It's **invisible money**: the bank sees the withdrawal, then nothing.

## The Solution

| Feature | What it does | Status |
|---|---|---|
| Multi-account tracking | Cash wallet plus any number of bank, savings and credit accounts | Done |
| ATM withdrawal pots | Record a withdrawal; it becomes a pot you spend down | Done |
| Two-tap cash logging | Log spends fast with SA presets (taxi, vendor, airtime, electricity) | Done |
| Dashboard | Total across accounts, spending by category, recent activity | Done |
| PDF + CSV import | Import a month-end PDF (password prompt included) or CSV, categorise it, and skip rows already imported | Done |
| Recurring cash | A Mon–Fri taxi is logged once and posted automatically on the days you choose | Done |
| Cash-runway forecast | Daily burn rate × remaining money = the day your money runs out | Done |
| Ask Zaka tips | Optional Gemini tips from a four-field, privacy-safe summary, with an on-device fallback | Done |
| Consent + delete-all | Explicit consent before any AI call; one tap wipes every money table, the local account and sign-in, the app-lock PIN and advisor settings | Done |
| App lock | Optional 4–8 digit PIN, re-lock after backgrounding, Android recents preview hidden | Done |
| Privacy policy + About | Readable in-app policy, Information Officer/contact, version, licences | Done |
| Feedback + complaints | Copyable contact in Privacy and Account, in-app form, Worker route, GitHub Issues warning | Done |
| Email/password accounts | Local account, PBKDF2 password hash, 3-month trial on sign-up | Done |
| Creator console | Owner sees accounts on this device and can grant lifetime access | Done (this device) |
| Google sign-in | Continue with a Google account | Roadmap |
| Central user directory | See every user across phones; server-side roles and plans | Roadmap |
| Live bank sync | Connect FNB through Stitch and refresh automatically | Roadmap |
| Payments / card checkout | Charge for Plus after the trial | Roadmap |

**Done** means the feature is in this build and is covered by the evidence in
[`docs/evidence/`](docs/evidence/). **Roadmap** is not a feature: it has no
shipped screen or working backend, and the README says so below.

**What happens on day 91:** the account label changes from “Trial” to “Free
plan”. The cash tracker, imports and on-device Ask Zaka tip keep working. No paid
feature is switched on yet, so nothing is locked and nothing is charged. The
90-day date is real, but the trial is not a paywall in this build.

### Sample data

The first-run dashboard has a **Try with sample data** button. It creates an
FNB cheque account and imports one small statement:

| Day | Description | Amount | Running balance |
|---|---|---:|---:|
| −3 | PIECE JOB PAYMENT | +R900.00 | R900.00 |
| −2 | ATM CASH WITHDRAWAL | −R500.00 | R400.00 |
| −1 | TAXI – BREE | −R35.00 | R365.00 |
| Today | PICK N PAY GROCERIES | −R240.00 | R125.00 |

The ATM row becomes a transfer to the Cash wallet, so the dashboard shows
**R125 in the bank + R500 cash = R625**. The two spends over two observed days
give a R137.50 daily burn, which puts the runway at **5 days**. The statement is
generated by `buildSampleStatementCsv` in
[`lib/data/sample_data.dart`](lib/data/sample_data.dart), and
`test/sample_data_test.dart` asserts the R900 piece-job row (no salary) and the
five-day forecast.

### Zaka accounts, trial and creator access

The person icon on the dashboard opens **Account**. From there you can create an
email/password account or sign in. A new account gets **3 months free**; when the
trial ends the cash tracker keeps working on the free plan because no paid
feature is switched on yet.

The account layer is local-first: the user row lives in the same on-device
SQLite database, the password is stored as a salted PBKDF2-HMAC-SHA256 hash, and
money data is never uploaded by signing in. A public checkout has **no default
creator email**: `OWNER_EMAIL` is empty unless a private build config supplies
it. To create a creator build, copy `build.local.example.json` to
`build.local.json`, set `ownerEmail` and an optional `ownerAccessCode`, and run
`tool/build-release.ps1`. The file is gitignored, so the real address and code
never appear in the public README or APK build command. With an owner email
configured, signing up with it creates an **owner + lifetime** account; the
**Users** console then lists every account on that device and can grant lifetime
access, reset a trial or move someone to free. If `ownerAccessCode` is set, the
account must also enter that code once.

Google sign-in and a central user directory are **Roadmap**, not features. A
real Google button needs an OAuth client for the Android package and signing
key; without it the button explains the gap rather than faking a login. The full
setup, the local security limits (no email verification, no password reset, no
cross-device users) and the server-side plan are in
[`docs/accounts.md`](docs/accounts.md).

### Accounts, imports and transfers

The **Accounts** tab is the home for money that is not in your wallet. Add an
account with its bank, type and opening balance, then import a month-end PDF
from your bank, or a CSV exported from Online Banking. PDF text is extracted
on the phone; a password-protected PDF asks for the password and never saves
it. Zaka reads the usual `Date, Description, Amount, Balance` layout and
statements that use separate `Debit`/`Credit` columns. The preview is the
safety net: check it before importing.

Imports are safe to repeat: every row gets a stable key, and the database
rejects a second copy for the same account. ATM and cash-withdrawal rows become
**transfers** to the cash wallet rather than spending, so the same money is not
counted twice. Everything else is categorised from the description (taxi,
airtime, electricity, food, vendor) and can be deleted from Activity. Import
each bank into its own account; a single bank statement only sees that bank's
rows, never your cash or another bank.

Zaka does not offer manual account-to-account transfers. The only movement
between accounts is the automatic classification of an ATM or cash-withdrawal
row from a statement, so that withdrawal is not counted twice. The dashboard
total is the sum of every account balance, including a negative credit balance
if you owe money.

Live bank sync is not switched on yet. See
[`docs/bank-sync.md`](docs/bank-sync.md) for the Stitch/backend design and why
it needs a server before it can ship.

### Ask Zaka, privacy first

The dashboard has an **Ask Zaka** card. It always shows a deterministic tip
computed on the phone, for example:

> At R90 a day, your cash runs out Thursday. Taxi is 48% of your spend.

Optional Gemini tips are **off by default**. The privacy screen shows the exact
JSON that may be sent, what is never sent, and an on/off switch. Only four
fields can leave the phone: `runwayDays`, `dailyBurnRand`, `categoryPercent`
and `periodDays`. Spend notes, account names, bank names, import keys and exact
timestamps have no field in `AdvisorSummary` at all.

`AdvisorService.askAdvisor` throws `StateError('No consent')` before it can
create a token or make an HTTP call. The proxy holds the Gemini key, accepts
POST only, caps the body at 1 KB / 1,000 characters, rejects extra fields and
can rate-limit per install. If the network or proxy is unavailable, the card
falls back to the same on-device tip. Output is labelled **tips and insights,
not financial advice**; the prompt forbids product recommendations, and the
proxy rejects a tip that names a product, provider or bank before it reaches
the card. See
[`docs/advisor.md`](docs/advisor.md) and [`proxy/README.md`](proxy/README.md).

**Cross-border processing:** when you turn Ask Zaka on and request tips, the
Worker sends those four fields to **Google Gemini**, and **Google may process
them outside South Africa**. The consent switch is the consent point for that
transfer. This is also stated on the in-app privacy screen and in the SSDLC
form. Cloudflare may process request metadata outside South Africa as the
hosting provider. If you leave Ask Zaka off, nothing is sent.

The **Delete everything** control removes every money table — accounts, entries,
recurring rules and import keys — in one transaction. It also deletes every
local Zaka account, the signed-in user id, the app-lock PIN and the Ask Zaka
consent and install token. A blank Cash account is recreated so the app still
opens. The control now really does remove the local account and sign-in; it
does not leave your email behind.

### Recurring taxi, explained

A commuter who takes a taxi every weekday should not open the app five times a week. In **Log cash**, enter the fare, switch on **Repeat this spend**, and pick **Weekdays** (or any combination of days). Zaka saves the first fare immediately and stores the rule.

On the next day the app opens, any due fares are posted automatically, so the balance and forecast stay correct. The rule remembers the last day it posted, and a database uniqueness constraint stops the same fare being added twice. The **Recurring** tab shows each rule, its next due day, and lets you pause or stop it. Pausing does not back-fill the days you were away.

## Architecture

**Local-first.** All spending data lives on the device in a SQLite database.
There is no central database of users' money to breach. Accounts are local rows
too in this build, so there is no central user directory to query yet.

```
Flutter app (Riverpod)
   │
   ├── Drift / SQLite  ← accounts, withdrawals, spends, transfers,
   │        │             recurring rules, local users (on-device)
   │        │ streams
   │        ├── per-account balances + one total
   │        ├── live category totals
   │        └── cash-runway forecast (pure Dart, unit tested)
   │
   ├── PDF / CSV importer ── on-device parsing + dedupe
   │        (pdf_document / pdf_graphics; no file upload)
   │
   ├── Account layer ── local PBKDF2 hash + 3-month trial
   │        └── creator role + local user list
   │
   ├── BankProvider seam ──► Zaka backend ──► Stitch ──► FNB
   │                          (roadmap; holds secrets and tokens)
   │
   └── Ask Zaka ──► Zaka proxy ──► Gemini API
        (consent gate; four-field summary; offline fallback)
```

- Works offline; only live bank sync, optional Ask Zaka and the roadmap
  central accounts need a connection.
- Money is stored in **cents as integers**, never floating point.
- The forecast is a pure function (`lib/core/forecast.dart`) fed by Riverpod providers, which makes it easy to test and change.
- Account balances are computed by a pure function (`lib/core/accounting.dart`): opening balance + money in − money out + transfers.
- Statement parsing (`lib/core/statement.dart`) and PDF text extraction (`lib/data/pdf_statement.dart`) are pure Dart, with no network dependency, so they are easy to test.
- The Gemini key and any bank provider secret never ship inside the app; the proxy is the only component that holds the Gemini key.

## Tech Stack

- **Flutter / Dart** — cross-platform app (Android, web; Windows desktop with Visual Studio)
- **Drift (SQLite)** — typed, local-first persistence
- **Riverpod** — state management and live queries
- **csv** — CSV statement parsing
- **pdf_document / pdf_graphics** — pure-Dart PDF text extraction on the phone
- **file_selector** — choosing a PDF or CSV on web, desktop and Android
- **shared_preferences** — the `consentAdvisor` flag, per-install advisor token and signed-in user id
- **crypto** — PBKDF2-HMAC-SHA256 password hashing for local accounts
- **flutter_boxicons** — the icon set used across the minimalist UI
- **http** — the POST to the advisor proxy
- **Cloudflare Workers + KV** — the advisor proxy, allowlist, rate limit and budget alert
- **Stitch** — planned bank-data provider, via a backend (roadmap)

## Running it (Windows + WSL)

The examples assume the checkout is on the **Windows** filesystem and that
Flutter is installed on Windows. Windows Flutter cannot reliably build a
project stored on the WSL filesystem because it fails to create plugin symlinks
there, so keep the project on a Windows drive. Your own paths will differ from
the examples below.

### From Windows (PowerShell or cmd)

```powershell
cd <path-to-Zaka>
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates Drift code
flutter run -d chrome                                     # fastest way to see it
```

- `flutter run -d windows` needs the **“Desktop development with C++”** workload in Visual Studio.
- The `file_selector` plugin needs Windows **Developer Mode** for plugin symlinks (`start ms-settings:developers`). Web and Android builds do not need it.
- Android: accept the SDK licences with `flutter doctor --android-licenses`, plug in a device, then `flutter run -d <device>`.

### From WSL

Use the wrapper so commands run through the Windows SDK:

```bash
tool/flutter-win.sh pub get
tool/flutter-win.sh test
tool/flutter-win.sh run -d chrome
tool/flutter-win.sh build web --release
```

A Windows equivalent is `tool\flutter-win.cmd`.

### Web prerequisites

`web/sqlite3.wasm` and `web/drift_worker.js` are checked in so Drift can open SQLite in the browser. They come from the drift `2.35.3` release. If you upgrade drift, replace both files from the matching release.

### Build a release APK

The release manifest declares `android.permission.INTERNET` and sets
`android:allowBackup="false"`. Real values stay out of public build commands:
copy `build.local.example.json` to `build.local.json`, fill in the proxy URL,
owner email, creator code and feedback alias, then run the PowerShell helper:

```powershell
powershell -ExecutionPolicy Bypass -File tool/build-release.ps1
```

`build.local.json` is gitignored, so the real owner address and code never
appear in this README or in a shell history. The helper runs:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols \
  --dart-define=ADVISOR_PROXY_URL=... \
  --dart-define=OWNER_EMAIL=... \
  --dart-define=OWNER_ACCESS_CODE=... \
  --dart-define=FEEDBACK_EMAIL=...
```

Omit `ADVISOR_PROXY_URL` to ship the on-device Ask Zaka tip only. Omit
`OWNER_ACCESS_CODE` if the creator email alone should unlock lifetime access.
A public checkout has an empty `OWNER_EMAIL`, so no one is the creator until a
private build config supplies an address. If `FEEDBACK_EMAIL` is unset, the app
points people at the public GitHub Issues page instead of shipping a dead or
personal address. See [`docs/accounts.md`](docs/accounts.md) and
[`build.local.example.json`](build.local.example.json).

Deploy the proxy with [`proxy/README.md`](proxy/README.md). Set
`GEMINI_MODEL` from the current list at
<https://ai.google.dev/gemini-api/docs/models>; the repo deliberately has no
default model name.

## Testing

```bash
flutter analyze     # no issues
flutter test        # 80 tests
cd proxy && npm test  # 22 tests
```

Verified for this revision:

- `flutter analyze` — no issues.
- `flutter test` — 80 tests passed.
- `flutter build apk --release` — output at
  `build/app/outputs/flutter-apk/app-release.apk`; the manifest was checked for
  `INTERNET` and `allowBackup=false`.
- `gitleaks detect` — no leaks.
- `osv-scanner scan source -L pubspec.lock` — no known vulnerabilities.
- `cd proxy && npm test` — 22 Node tests, including the feedback route.
- Live advisor proxy curls against a temporary Cloudflare Worker: `405` for GET,
  `401` without an install token, `400` for an extra field or unknown category,
  `415` for the wrong content type, `413` for an oversized body, and `500` for a
  valid request on the keyless temporary build. The host is redacted in
  `docs/evidence/curl_checks.txt`.
- On-device smoke test on a 1220×2712 Android 16 phone: cleared data, loaded the
  sample statement, added R100, logged a R35 taxi, opened the Ask Zaka card,
  created the creator account and saw it in the Users console. The app-lock and
  feedback screens were added after that device run and are covered by widget
  tests, not by this log. The flow is in `docs/evidence/logcat_clean.txt`.
  `device_screenshot.png` is the R625, five-day-runway portrait;
  `device_light.png` and `device_dark.png` show the same build after the add and
  spend in both themes.

The web build is not re-verified in this revision; the Windows desktop target
still needs the Visual Studio C++ workload. Raw outputs are indexed in
[`docs/evidence/README.md`](docs/evidence/README.md). A claim that is not in that
folder is not claimed as verified. Tester feedback and its disposition are in
[`docs/tester-feedback.md`](docs/tester-feedback.md).

Coverage:

- **Forecast** — burn-rate averaging, lookback window, recurring commitments, horizon cap, empty data, zero balance.
- **Recurrence** — Mon–Fri expansion across weekends, exclusive “after”, end dates, next occurrence, weekday encoding.
- **Money** — parsing `R 1,234.50` / `35,50`, signed opening balances, formatting cents.
- **Accounting** — opening balances, money in/out, transfers, per-account and total balances.
- **Statement parsing** — FNB-style signed amounts, debit/credit columns, quoted descriptions, preamble rows, SA date formats, Rand/thousands/parentheses, trailing-minus amounts, repeatable row keys.
- **PDF statements** — text extraction from a generated text PDF, date-led row reconstruction, debit/credit columns, running-balance direction, no-text PDF rejection.
- **Importing** — salary, spend and ATM-to-cash classification; category guesses; re-import skips every row; duplicate safety.
- **Database** — withdrawal + spend persistence, recurring taxi posting once per weekday, no duplicates on re-sync, paused rules, last-account protection.
- **Migration** — a v1 cash-only database upgrades through v2 to v3, keeps its entries attached to the cash account, and creates the local user table.
- **Advisor privacy** — exactly four JSON fields; a `Sipho's tuckshop` note, import key and account name never appear; period filtering; missing-runway handling.
- **Consent gate** — no consent throws `StateError('No consent')` before any HTTP call; the request body is exactly `summary.toJson()`; no proxy or network failure falls back to the deterministic tip.
- **Delete-all** — every money table is emptied in one transaction, every local account and the sign-in are removed, the app-lock PIN and advisor preferences are cleared, and a blank Cash account can be recreated.
- **App lock** — PINs are validated, hashed, verified and cleared; the lock gate shows the PIN screen and opens only on the right PIN.
- **Feedback** — the feedback row exists, shows the warning and copies the configured contact; the Worker forwards a valid message and rejects extra fields, a missing token, an invalid reply-to, an oversized body, a missing webhook and a rate-limited caller.
- **Accounts** — 90-day trial, normalised unique emails, PBKDF2 hashes, wrong-password rejection, owner-by-email lifetime, optional creator code, owner-only plan changes, expired trial falling back to free.
- **Sample data** — the R900 piece-job statement (no salary) imports one ATM transfer, leaves a R625 total, and forecasts five days.
- **UI flows** — add money, log a preset spend, see the live balance, add a bank account and see the combined total, set up a weekday taxi and find it under Recurring, tap anywhere on the Ask Zaka card, create the creator account and open the user console.

## Project Structure

Feature-first layout:

```
lib/
  core/            # theme, money, dates, forecast, recurrence,
                   # accounting, statement parsing, PBKDF2 helpers
  data/            # Drift database, repository, recurring service,
                   # statement importer, PDF extraction, BankProvider seam
  features/
    accounts/      # add account, import PDF/CSV
    withdrawals/   # add money / ATM withdrawal pots
    spending/      # quick logging, presets, repeat setup
    recurring/     # manage repeating spends
    dashboard/     # total balance, runway, category breakdown, Ask Zaka card
    advisor/       # summary allowlist, consent gate, offline tip, privacy screen
    auth/          # local accounts, 90-day trial, creator user console
    security/      # PIN app lock and the launch/background lock gate
    support/       # About, privacy policy, feedback form and shared contact
    activity/      # full timeline, delete an entry
    shell/         # bottom navigation
  widgets/         # shared UI pieces
docs/
  accounts.md      # local accounts, trial, creator access, Google/backend plan
  advisor.md       # data allowlist, consent gate, proxy, FAIS boundary
  bank-sync.md     # Stitch/backend design for live bank sync
  accessibility.md # language status, Semantics gap, contrast check
  ssdlc.md         # SSDLC answers, data map, complaints and known gaps
  deck-user-journey.md # the six-beat journey mirrored in the pitch deck
  evidence/        # analyze, tests, gitleaks, OSV, logcat, screenshots
proxy/             # Cloudflare Worker: Gemini key, tips and feedback routes
tool/              # Windows/WSL Flutter wrappers and the private release build
```

## Security & POPIA

- **Data minimisation:** cash and imported bank records stay on-device; no backend receives them. PDF and CSV files are parsed in the app and never uploaded. Ask Zaka can send only `runwayDays`, `dailyBurnRand`, `categoryPercent` and `periodDays`. A local account stores a name, email, salted password hash and plan on the phone; it does not upload them.
- **Consent and cross-border processing:** Ask Zaka is off by default. `askAdvisor` checks the stored `consentAdvisor` flag before any token creation or HTTP call. Turning it off stops all sends. When it is on, the four fields go to the Worker and then to **Google Gemini, which may process them outside South Africa**. The switch is the consent point for that transfer. Cloudflare may process request metadata outside South Africa as the host.
- **Feedback:** in a build with a Worker URL compiled in, the in-app form posts one message to the Worker `/feedback` route, which forwards it to the project webhook and stores nothing. Diagnostics are opt-in and limited to the Zaka version and Android version. The form and the privacy screen say **Please don’t send bank details or statements**. GitHub Issues is a public channel with the same warning. The Worker enforces a 4 KB cap, a 2,000-character message, a token shape check and a 3-per-day default limit; KV keys expire after 2 days. The public APK has no Worker URL, so its feedback row copies the GitHub Issues link.
- **No banking credentials:** Zaka never asks for an internet-banking username, password or OTP. A PDF password is used in memory for extraction and is not saved. Live sync, when it ships, will use a provider consent screen and a backend that holds tokens.
- **No PII in logs:** the app does not log amounts, notes, statement rows or free text; database errors are logged without record contents. The proxy does not log the summary, feedback message or install token.
- **Secrets:** no API keys or secrets in the repo. The Gemini key, feedback webhook and `GEMINI_MODEL` are Wrangler secrets. The owner email, creator code and feedback alias come from the gitignored `build.local.json`. `gitleaks detect` is run for each revision (see `docs/evidence/gitleaks.json`), but it is not yet a CI gate.
- **Deletion:** individual spends and withdrawals can be deleted from Activity. **Delete everything** removes every money table in one transaction, every local Zaka account and the signed-in user id, the app-lock PIN, and the advisor consent and install token. It runs a best-effort SQLite `VACUUM`. **There is no encrypted export or backup yet**; that is a known POPIA access gap and a roadmap item, because a lost or replaced phone loses the data.
- **Local account limits:** passwords and PINs are PBKDF2-HMAC-SHA256 hashed, but there is no email verification, password reset, session expiry, server-side owner role or encrypted-at-rest database. A local owner flag is a demo convenience, not a security boundary. See [`docs/accounts.md`](docs/accounts.md).
- **No crash reporting, ads or analytics.** This is a deliberate privacy choice, not an omission.
- **Age:** Zaka is for people aged **18 and over**; it is not directed at children.
- **Android hardening:** the release manifest declares `INTERNET` and sets `allowBackup=false`. `FLAG_SECURE` hides balances from the recents preview and screenshots. The optional app lock is PIN-only; biometric unlock is roadmap. Release APKs currently use the debug signing key (debug-signed demo build). Production keystore signing, SQLCipher encryption at rest, automated gitleaks/OSV/MobSF CI, certificate pinning and root detection remain on the hardening roadmap.

The readable policy is [`PRIVACY.md`](PRIVACY.md) and the in-app **Privacy policy**
screen. It names the responsible party and Information Officer, retention,
cross-border processing and the complaints route to the Information Regulator.
The SSDLC answers and data map are in [`docs/ssdlc.md`](docs/ssdlc.md).

## Known Limitations

- **Accounts are local to one phone.** There is no central user directory, so the creator console cannot see users on another device. There is no email verification, password reset or session expiry. The creator role is a local build-time convention; production roles must be server-side. Google sign-in is not implemented; the button explains the missing OAuth client instead of faking a login.
- **The trial is a label, not a paywall.** Every account gets 90 days of trial status and then falls back to the free plan. No paid feature is switched on and no payment provider is integrated, so nothing stops working at the end of the trial.
- **No encrypted export or backup.** This is the largest POPIA access gap: a lost or replaced phone loses the data, and we cannot hand you a portable file. Encrypted JSON/CSV export with a user passphrase, plus opt-in encrypted backup, is on the roadmap.
- **The local database is plain SQLite, not encrypted at rest yet.** The PIN lock and `FLAG_SECURE` hide the screen and the recents preview, but they do not encrypt the database file.
- **App lock is PIN-only.** Biometric unlock needs a native plugin and permission, so it is roadmap. If you forget the PIN, clearing Android app data also removes the money data.
- **English-only UI, no Semantics coverage.** The UI is not localised and the custom cards, charts and icon buttons do not have reliable screen-reader labels. The first targets are **isiZulu, Setswana and Sesotho**, with first-language review. A monochrome contrast check is recorded in [`docs/accessibility.md`](docs/accessibility.md), but it is not a full accessibility audit.
- **Live bank sync is not implemented.** PDF and CSV import are manual. The PDF parser is heuristic: it needs a text layer, and bank-specific layouts may need the preview checked or a CSV fallback. Scanned/image-only PDFs need OCR (roadmap), and other banks' CSV/PDF layouts are not verified. OFX and direct bank APIs remain roadmap.
- Only ATM/cash-withdrawal descriptions are auto-classified as transfers. Zaka does not offer manual account-to-account transfers; import each bank's statement into its own account.
- Accounts cannot be edited yet; remove an empty account and add it again. An account with entries cannot be removed, and the last account is protected.
- Credit accounts use a signed balance only; credit limits, minimum payments and interest are not modelled.
- Ask Zaka needs the proxy deployed and `ADVISOR_PROXY_URL` set at build time for online tips. Without it, the app is fully usable and shows the on-device tip. The proxy's rate limits and budget alert need the optional Cloudflare KV binding. The Worker stores no summaries or feedback, but the Gemini and webhook providers may process or keep data under their own policies.
- There is **no crash reporting**. That is deliberate: no analytics, ads, tracking SDK or crash upload is included, so a crash gives you no automatic diagnostic and us no stack trace.
- Windows desktop builds require Visual Studio C++ tooling. The `file_selector` plugin also needs Windows Developer Mode for plugin symlinks; web and Android builds are unaffected.
- The web build stores data in the browser's origin storage; it is a demo target, not the shipping target.
- The APK is debug-signed and distributed from this repository, so Android Play Protect may warn. It is not a Play Store release and production signing is roadmap.

## Roadmap & Business Model

No ads, ever.

- **Free:** cash tracking, PDF/CSV import and the on-device Ask Zaka tip. The
  app keeps working after the trial.
- **3-month trial:** every new account starts here. It is a real 90-day date,
  but no Plus feature is gated yet.
- **Zaka Plus (about R29/month, hypothesis):** live bank sync, unlimited
  advisor, goals and alerts, PDF reports.
- **Zaka Ultra (about R50/month, hypothesis):** shared stokvel and household
  pots, proactive cash-runway alerts, voice logging in SA languages, consented
  income and spending statement.
- **Creator lifetime:** `OWNER_EMAIL` accounts get lifetime access with no
  payment. The local user console can grant it to another account on the same
  phone.
- **Later:** a central account service with email verification and server-side
  roles, payments, stokvel group features, opt-in product referrals with
  explicit consent, anonymised aggregate insights, and the categorisation
  engine as an SDK for other SA fintechs.
- **Privacy and access roadmap:** encrypted export/backup with a user
  passphrase, biometric unlock, SQLCipher at rest, localisation (isiZulu,
  Setswana, Sesotho) and a full accessibility audit.

Prices are hypotheses to be validated with pilot users. Payments are not
implemented; nobody can be charged in this build.

## Licence

Zaka's source code is released under the [MIT licence](LICENSE). The **Zaka**
name, the **Z logo** and the launcher icon are product marks of the project
author and are **not** covered by the MIT licence. Third-party packages,
including `flutter_boxicons` (MIT), are credited in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md); the app also shows their
licence texts under **About → Licences** (`showLicensePage`). No trademark
registration is claimed, so confirm ownership or assignment of the artwork
before a commercial launch.

## Author

**Nyakallo Masiu** — [github.com/nyaks1](https://github.com/nyaks1)

Built for the FNB App of the Year Hackathon 2026.
