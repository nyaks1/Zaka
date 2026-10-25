# Zaka — Cash Tracker + Money Across Accounts

> **Because every cent counts.**

Zaka makes cash visible. Budgeting apps see card swipes and EFTs, but the moment you withdraw at an ATM they go blind. Zaka starts exactly there: every withdrawal becomes a cash pot with a countdown, so you know when your cash will run out before it does.

It now also tracks the rest of your money. Add your FNB, Capitec, ABSA, Standard Bank, Nedbank or TymeBank accounts, import a PDF or CSV statement into each one, and see one live total without handing your banking login to an app.

Built for the **FNB App of the Year Hackathon 2026** — theme: *Financial inclusion and money confidence.*

---

## The Problem

Cash accounts for **56% of all consumer payments in South Africa by volume**, with an average cash payment of about R208 (SARB payments study). Cash is concentrated in the informal economy: only 39% of informal traders and 10% of taxi drivers accept electronic payments (SARB Cost of Cash study).

Bank-feed apps like 22seven can't see any of it. People with irregular incomes — paying for taxis, street vendors and spaza shops — lose track of small, frequent spends and run out of cash before payday, with no early warning and no affordable financial advice.

The villain isn't cash. It's **invisible money**: the bank sees the withdrawal, then nothing.

## The Solution

| Feature | What it does | Status |
|---|---|---|
| Multi-account tracking | Cash wallet plus any number of bank, savings and credit accounts | ✅ |
| ATM withdrawal pots | Record a withdrawal; it becomes a pot you spend down | ✅ |
| Two-tap cash logging | Log spends fast with SA presets (taxi, vendor, airtime, electricity) | ✅ |
| Dashboard | Total across accounts, spending by category, recent activity | ✅ |
| PDF + CSV import | Import a month-end PDF (password prompt included) or CSV, categorise it, and skip rows already imported | ✅ |
| Recurring cash | A Mon–Fri taxi is logged once and posted automatically on the days you choose | ✅ |
| Cash-runway forecast | Daily burn rate × remaining money = the day your money runs out | ✅ |
| Ask Zaka tips | Optional Gemini tips from a four-field, privacy-safe summary, with an on-device fallback | ✅ |
| Consent + delete-all | Explicit consent before any AI call; wipe every table and setting in one tap | ✅ |
| Live bank sync | Connect FNB through Stitch and refresh automatically | ☐ |

*(Anything unticked at submission is roadmap, not a feature.)*

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
not financial advice**; the prompt forbids product recommendations. See
[`docs/advisor.md`](docs/advisor.md) and [`proxy/README.md`](proxy/README.md).

The **Delete everything** control removes every account, entry, recurring rule
and import key in one transaction, then clears all settings including the
consent flag. A blank Cash account is recreated so the app still opens.

### Recurring taxi, explained

A commuter who takes a taxi every weekday should not open the app five times a week. In **Log cash**, enter the fare, switch on **Repeat this spend**, and pick **Weekdays** (or any combination of days). Zaka saves the first fare immediately and stores the rule.

On the next day the app opens, any due fares are posted automatically, so the balance and forecast stay correct. The rule remembers the last day it posted, and a database uniqueness constraint stops the same fare being added twice. The **Recurring** tab shows each rule, its next due day, and lets you pause or stop it. Pausing does not back-fill the days you were away.

## Architecture

**Local-first.** All spending data lives on the device in a SQLite database. There is no central database of users' money to breach.

```
Flutter app (Riverpod)
   │
   ├── Drift / SQLite  ← accounts, withdrawals, spends, transfers,
   │        │             recurring rules (on-device)
   │        │ streams
   │        ├── per-account balances + one total
   │        ├── live category totals
   │        └── cash-runway forecast (pure Dart, unit tested)
   │
   ├── PDF / CSV importer ── on-device parsing + dedupe
   │        (pdf_document / pdf_graphics; no file upload)
   │
   ├── BankProvider seam ──► Zaka backend ──► Stitch ──► FNB
   │                          (roadmap; holds secrets and tokens)
   │
   └── Ask Zaka ──► Zaka proxy ──► Gemini API
        (consent gate; four-field summary; offline fallback)
```

- Works offline; only live bank sync and optional Ask Zaka need a connection.
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
- **shared_preferences** — the `consentAdvisor` flag and per-install advisor token
- **http** — the POST to the advisor proxy
- **Cloudflare Workers + KV** — the advisor proxy, allowlist, rate limit and budget alert
- **Stitch** — planned bank-data provider, via a backend (roadmap)

## Running it (Windows + WSL)

This project is deliberately kept on the **Windows** filesystem:

```
Windows:  C:\src\projects\Zaka
WSL:      /mnt/c/src/projects/Zaka
          /home/nyaks/src/github/Zaka  → symlink to the same folder
```

Flutter is installed on Windows (`C:\src\flutter_windows_3.47.0-stable`). Windows Flutter cannot reliably build a project stored on the WSL filesystem because it fails to create plugin symlinks there, so keep the project on the Windows drive.

### From Windows (PowerShell or cmd)

```powershell
cd C:\src\projects\Zaka
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates Drift code
flutter run -d chrome                                     # fastest way to see it
```

- `flutter run -d windows` needs the **“Desktop development with C++”** workload in Visual Studio. It is not installed on this machine yet.
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

The release manifest now declares `android.permission.INTERNET` and sets
`android:allowBackup="false"`. Build with the advisor proxy URL if you want the
optional Gemini tips; without it the app uses the on-device fallback:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols \
  --dart-define=ADVISOR_PROXY_URL=https://zaka-advisor.<subdomain>.workers.dev
```

Deploy the proxy with [`proxy/README.md`](proxy/README.md). Set
`GEMINI_MODEL` from the current list at
<https://ai.google.dev/gemini-api/docs/models>; the repo deliberately has no
default model name.

## Testing

```bash
flutter analyze     # no issues
flutter test        # 64 tests
```

Verified on this machine: `flutter analyze`, `flutter test`, `flutter build web
--release`, and `flutter build apk --release` (output at
`build/app/outputs/flutter-apk/app-release.apk`). The release APK manifest was
checked for `INTERNET` and `allowBackup=false`. The proxy has 10 Node tests
(`cd proxy && npm test`): POST-only, the four-field allowlist, extra fields,
unknown categories, install token, 1 KB cap, content type, per-install daily
limit, the “financial advice” output filter, and the Gemini prompt. The Windows
desktop target still needs the Visual Studio C++ workload.

Coverage:

- **Forecast** — burn-rate averaging, lookback window, recurring commitments, horizon cap, empty data, zero balance.
- **Recurrence** — Mon–Fri expansion across weekends, exclusive “after”, end dates, next occurrence, weekday encoding.
- **Money** — parsing `R 1,234.50` / `35,50`, signed opening balances, formatting cents.
- **Accounting** — opening balances, money in/out, transfers, per-account and total balances.
- **Statement parsing** — FNB-style signed amounts, debit/credit columns, quoted descriptions, preamble rows, SA date formats, Rand/thousands/parentheses, trailing-minus amounts, repeatable row keys.
- **PDF statements** — text extraction from a generated text PDF, date-led row reconstruction, debit/credit columns, running-balance direction, no-text PDF rejection.
- **Importing** — salary, spend and ATM-to-cash classification; category guesses; re-import skips every row; duplicate safety.
- **Database** — withdrawal + spend persistence, recurring taxi posting once per weekday, no duplicates on re-sync, paused rules, last-account protection.
- **Migration** — a v1 cash-only database upgrades to v2 and keeps its entries attached to the cash account.
- **Advisor privacy** — exactly four JSON fields; a `Sipho's tuckshop` note, import key and account name never appear; period filtering; missing-runway handling.
- **Consent gate** — no consent throws `StateError('No consent')` before any HTTP call; the request body is exactly `summary.toJson()`; no proxy or network failure falls back to the deterministic tip.
- **Delete-all** — every table is emptied in one transaction and preferences are cleared; a blank Cash account can be recreated.
- **UI flows** — add money, log a preset spend, see the live balance, add a bank account and see the combined total, set up a weekday taxi and find it under Recurring.

## Project Structure

Feature-first layout:

```
lib/
  core/            # theme, money, dates, forecast, recurrence,
                   # accounting, statement parsing
  data/            # Drift database, repository, recurring service,
                   # statement importer, PDF extraction, BankProvider seam
  features/
    accounts/      # add account, import PDF/CSV
    withdrawals/   # add money / ATM withdrawal pots
    spending/      # quick logging, presets, repeat setup
    recurring/     # manage repeating spends
    dashboard/     # total balance, runway, category breakdown, Ask Zaka card
    advisor/       # summary allowlist, consent gate, offline tip, privacy screen
    activity/      # full timeline, delete an entry
    shell/         # bottom navigation
  widgets/         # shared UI pieces
docs/
  advisor.md       # data allowlist, consent gate, proxy, FAIS boundary
  bank-sync.md     # Stitch/backend design for live bank sync
proxy/             # Cloudflare Worker: Gemini key, allowlist, rate limit
tool/              # Windows/WSL Flutter wrappers
```

## Security & POPIA

- **Data minimisation:** cash and imported bank records stay on-device; no backend receives them. PDF and CSV files are parsed in the app and never uploaded. Ask Zaka can send only `runwayDays`, `dailyBurnRand`, `categoryPercent` and `periodDays`.
- **Consent:** Ask Zaka is off by default. `askAdvisor` checks the stored `consentAdvisor` flag before any token creation or HTTP call. Turning it off stops all sends.
- **No banking credentials:** Zaka never asks for an internet-banking username, password or OTP. A PDF password is used in memory for extraction and is not saved. Live sync, when it ships, will use a provider consent screen and a backend that holds tokens.
- **No PII in logs:** the app does not log amounts, notes, statement rows or free text; database errors are logged without record contents. The proxy does not log the summary or install token.
- **Secrets:** no API keys or secrets in the repo. The Gemini key and `GEMINI_MODEL` are Wrangler secrets. Secret scanning (gitleaks) is intended before pushes.
- **Deletion:** individual spends and withdrawals can be deleted from Activity. **Delete everything** removes every table in one transaction, runs a best-effort SQLite `VACUUM`, then clears all settings including consent.
- **Android hardening:** the release manifest declares `INTERNET` and sets `allowBackup=false`; statement backups are disabled. Release APKs currently use the debug signing key (debug-signed demo build). Production keystore signing, SQLCipher encryption at rest, automated MobSF and OSV-Scanner CI pipelines, certificate pinning and root detection remain on the hardening roadmap.

## Known Limitations

- **Live bank sync is not implemented.** PDF and CSV import are manual. The PDF parser is heuristic: it needs a text layer, and bank-specific layouts may need the preview checked or a CSV fallback. Scanned/image-only PDFs need OCR (roadmap), and other banks' CSV/PDF layouts are not verified. OFX and direct bank APIs remain roadmap.
- Only ATM/cash-withdrawal descriptions are auto-classified as transfers. Zaka does not offer manual account-to-account transfers; import each bank's statement into its own account.
- Accounts cannot be edited yet; remove an empty account and add it again. An account with entries cannot be removed, and the last account is protected.
- Credit accounts use a signed balance only; credit limits, minimum payments and interest are not modelled.
- Ask Zaka needs the proxy deployed and `ADVISOR_PROXY_URL` set at build time for online tips. Without it, the app is fully usable and shows the on-device tip. The proxy's rate limit and budget alert need the optional Cloudflare KV binding.
- The local database is plain SQLite, not encrypted at rest yet.
- Windows desktop builds require Visual Studio C++ tooling, which is not installed on this machine. The `file_selector` plugin also needs Windows Developer Mode for plugin symlinks; web and Android builds are unaffected.
- The web build stores data in the browser's origin storage; it is a demo target, not the shipping target.

## Roadmap & Business Model

No ads, ever.

- **Free:** cash tracking, PDF/CSV import and the on-device Ask Zaka tip forever, plus a monthly allowance of online advisor questions.
- **Zaka Plus (about R29/month):** live bank sync, unlimited advisor, goals and alerts, PDF reports.
- **Zaka Ultra (about R50/month):** shared stokvel and household pots, proactive cash-runway alerts, voice logging in SA languages, consented income and spending statement.
- **Later:** stokvel group features, opt-in product referrals with explicit consent, anonymised aggregate insights, and the categorisation engine as an SDK for other SA fintechs.

Prices are hypotheses to be validated with pilot users.

## Author

**Nyakallo Masiu** — [github.com/nyaks1](https://github.com/nyaks1)

Built for the FNB App of the Year Hackathon 2026.
