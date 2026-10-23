# Zaka — Cash Tracker + Money Across Accounts

> **Because every cent counts.**

Zaka makes cash visible. Budgeting apps see card swipes and EFTs, but the moment you withdraw at an ATM they go blind. Zaka starts exactly there: every withdrawal becomes a cash pot with a countdown, so you know when your cash will run out before it does.

It now also tracks the rest of your money. Add your FNB, Capitec, ABSA, Standard Bank, Nedbank or TymeBank accounts, import a CSV statement, move money between accounts, and see one live total without handing your banking login to an app.

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
| Transfers | Move money between accounts without counting it as spending | ✅ |
| FNB CSV import | Import a statement, categorise it, and skip rows already imported | ✅ |
| Recurring cash | A Mon–Fri taxi is logged once and posted automatically on the days you choose | ✅ |
| Cash-runway forecast | Daily burn rate × remaining money = the day your money runs out | ✅ |
| Live bank sync | Connect FNB through Stitch and refresh automatically | ☐ |
| AI advisor (Gemini) | Explains your spending pattern in plain language | ☐ |
| Consent + delete-all | Explicit consent before any AI call; wipe all data in one tap | ☐ |

*(Anything unticked at submission is roadmap, not a feature.)*

### Accounts, imports and transfers

The **Accounts** tab is the home for money that is not in your wallet. Add an
account with its bank, type and opening balance, then import a CSV exported
from FNB Online Banking. Zaka reads the usual `Date, Description, Amount,
Balance` layout and statements that use separate `Debit`/`Credit` columns.

Imports are safe to repeat: every row gets a stable key, and the database
rejects a second copy for the same account. ATM and cash-withdrawal rows become
**transfers** to the cash wallet rather than spending, so the same money is not
counted twice. Everything else is categorised from the description (taxi,
airtime, electricity, food, vendor) and can be deleted from Activity.

**Move money** records a transfer between two accounts you already track. It
changes both balances but never appears as income or spending. The dashboard
total is the sum of every account balance, including a negative credit balance
if you owe money.

Live bank sync is not switched on yet. See
[`docs/bank-sync.md`](docs/bank-sync.md) for the Stitch/backend design and why
it needs a server before it can ship.

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
   ├── CSV importer ── on-device parsing + dedupe (FNB today)
   │
   ├── BankProvider seam ──► Zaka backend ──► Stitch ──► FNB
   │                          (roadmap; holds secrets and tokens)
   │
   └── AI proxy ──► Gemini API            (roadmap — not wired yet)
        (holds the API key; receives aggregated summaries only)
```

- Works offline; only the future bank sync and advisor need a connection.
- Money is stored in **cents as integers**, never floating point.
- The forecast is a pure function (`lib/core/forecast.dart`) fed by Riverpod providers, which makes it easy to test and change.
- Account balances are computed by a pure function (`lib/core/accounting.dart`): opening balance + money in − money out + transfers.
- Statement parsing (`lib/core/statement.dart`) is pure Dart and has no network or file-system dependency, so it is easy to test.
- The Gemini key and any bank provider secret will never ship inside the app.

## Tech Stack

- **Flutter / Dart** — cross-platform app (Android, web; Windows desktop with Visual Studio)
- **Drift (SQLite)** — typed, local-first persistence
- **Riverpod** — state management and live queries
- **csv** — statement parsing
- **file_selector** — choosing a statement file on web, desktop and Android
- **Stitch** — planned bank-data provider, via a backend (roadmap)
- **Gemini API** — AI financial advisor, via proxy (roadmap)

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

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```

## Testing

```bash
flutter analyze     # no issues
flutter test        # 44 tests
```

Verified on this machine: `flutter analyze`, `flutter test`, `flutter build web --release`, and `flutter build apk --debug` (output at `build/app/outputs/flutter-apk/app-debug.apk`). The Windows desktop target still needs the Visual Studio C++ workload.

Coverage:

- **Forecast** — burn-rate averaging, lookback window, recurring commitments, horizon cap, empty data, zero balance.
- **Recurrence** — Mon–Fri expansion across weekends, exclusive “after”, end dates, next occurrence, weekday encoding.
- **Money** — parsing `R 1,234.50` / `35,50`, signed opening balances, formatting cents.
- **Accounting** — opening balances, money in/out, transfers, per-account and total balances.
- **Statement parsing** — FNB-style signed amounts, debit/credit columns, quoted descriptions, preamble rows, SA date formats, Rand/thousands/parentheses, repeatable row keys.
- **Importing** — salary, spend and ATM-to-cash classification; category guesses; re-import skips every row; duplicate safety.
- **Database** — withdrawal + spend persistence, recurring taxi posting once per weekday, no duplicates on re-sync, paused rules, last-account protection.
- **Migration** — a v1 cash-only database upgrades to v2 and keeps its entries attached to the cash account.
- **UI flows** — add money, log a preset spend, see the live balance, add a bank account and see the combined total, set up a weekday taxi and find it under Recurring.

## Project Structure

Feature-first layout:

```
lib/
  core/            # theme, money, dates, forecast, recurrence,
                   # accounting, statement parsing
  data/            # Drift database, repository, recurring service,
                   # statement importer, BankProvider seam
  features/
    accounts/      # add account, import statement, move money
    withdrawals/   # add money / ATM withdrawal pots
    spending/      # quick logging, presets, repeat setup
    recurring/     # manage repeating spends
    dashboard/     # total balance, runway, category breakdown
    activity/      # full timeline, delete an entry
    shell/         # bottom navigation
  widgets/         # shared UI pieces
docs/
  bank-sync.md     # Stitch/backend design for live bank sync
tool/              # Windows/WSL Flutter wrappers
```

## Security & POPIA

- **Data minimisation:** cash and imported bank records stay on-device; no backend receives them. Statement files are parsed in the app and never uploaded. Only aggregates will go to the AI once the advisor ships.
- **No banking credentials:** Zaka never asks for an internet-banking username, password or OTP. Live sync, when it ships, will use a provider consent screen and a backend that holds tokens.
- **No PII in logs:** the app does not log amounts, notes, statement rows or free text; database errors are logged without record contents.
- **Secrets:** no API keys or secrets in the repo. Secret scanning (gitleaks) is intended before pushes.
- **Deletion:** individual spends and withdrawals can be deleted from Activity. One-tap delete-all is roadmap.
- **Hardening roadmap:** encryption at rest (SQLCipher), `allowBackup=false`, minimum Android permissions, obfuscated release build, MobSF and OSV-Scanner checks, certificate pinning and root detection.

## Known Limitations

- **Live bank sync is not implemented.** CSV import is manual and FNB is the verified format. Other banks may work if their CSV has a date and amount (or debit/credit) column, but they have not been tested. OFX, PDF and direct bank APIs are roadmap.
- Only ATM/cash-withdrawal descriptions are auto-classified as transfers. Other transfers between your own accounts should be recorded with **Move money**.
- Accounts cannot be edited yet; remove an empty account and add it again. An account with entries cannot be removed, and the last account is protected.
- Credit accounts use a signed balance only; credit limits, minimum payments and interest are not modelled.
- The AI advisor and its consent screen are not implemented yet; the app is fully usable offline without them.
- The local database is plain SQLite, not encrypted at rest yet.
- Windows desktop builds require Visual Studio C++ tooling, which is not installed on this machine. The `file_selector` plugin also needs Windows Developer Mode for plugin symlinks; web and Android builds are unaffected.
- The web build stores data in the browser's origin storage; it is a demo target, not the shipping target.

## Roadmap & Business Model

No ads, ever.

- **Free:** cash tracking and CSV import forever, plus a monthly allowance of advisor questions.
- **Zaka Plus (about R29/month):** live bank sync, unlimited advisor, goals and alerts, PDF reports.
- **Zaka Ultra (about R50/month):** shared stokvel and household pots, proactive cash-runway alerts, voice logging in SA languages, consented income and spending statement.
- **Later:** stokvel group features, opt-in product referrals with explicit consent, anonymised aggregate insights, and the categorisation engine as an SDK for other SA fintechs.

Prices are hypotheses to be validated with pilot users.

## Author

**Nyakallo Masiu** — [github.com/nyaks1](https://github.com/nyaks1)

Built for the FNB App of the Year Hackathon 2026.
