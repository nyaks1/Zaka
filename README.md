# Zaka — Cash Tracker + AI Financial Advisor

> **Because every cent counts.**

Zaka makes cash visible. Budgeting apps see card swipes and EFTs, but the moment you withdraw at an ATM they go blind. Zaka starts exactly there: every withdrawal becomes a cash pot with a countdown, so you know when your cash will run out before it does.

Built for the **FNB App of the Year Hackathon 2026** — theme: *Financial inclusion and money confidence.*

---

## The Problem

Cash accounts for **56% of all consumer payments in South Africa by volume**, with an average cash payment of about R208 (SARB payments study). Cash is concentrated in the informal economy: only 39% of informal traders and 10% of taxi drivers accept electronic payments (SARB Cost of Cash study).

Bank-feed apps like 22seven can't see any of it. People with irregular incomes — paying for taxis, street vendors and spaza shops — lose track of small, frequent spends and run out of cash before payday, with no early warning and no affordable financial advice.

The villain isn't cash. It's **invisible money**: the bank sees the withdrawal, then nothing.

## The Solution

| Feature | What it does | Status |
|---|---|---|
| ATM withdrawal pots | Record a withdrawal; it becomes a pot you spend down | ✅ |
| Two-tap cash logging | Log spends fast with SA presets (taxi, vendor, airtime, electricity) | ✅ |
| Dashboard | Live balance, spending by category, recent activity | ✅ |
| Recurring cash | A Mon–Fri taxi is logged once and posted automatically on the days you choose | ✅ |
| Cash-runway forecast | Daily burn rate × remaining cash = the day your cash runs out | ✅ |
| AI advisor (Gemini) | Explains your spending pattern in plain language | ☐ |
| Consent + delete-all | Explicit consent before any AI call; wipe all data in one tap | ☐ |

*(Anything unticked at submission is roadmap, not a feature.)*

### Recurring taxi, explained

A commuter who takes a taxi every weekday should not open the app five times a week. In **Log cash**, enter the fare, switch on **Repeat this spend**, and pick **Weekdays** (or any combination of days). Zaka saves the first fare immediately and stores the rule.

On the next day the app opens, any due fares are posted automatically, so the balance and forecast stay correct. The rule remembers the last day it posted, and a database uniqueness constraint stops the same fare being added twice. The **Recurring** tab shows each rule, its next due day, and lets you pause or stop it. Pausing does not back-fill the days you were away.

## Architecture

**Local-first.** All spending data lives on the device in a SQLite database. There is no central database of users' money to breach.

```
Flutter app (Riverpod)
   │
   ├── Drift / SQLite  ← withdrawals, spends, recurring rules (on-device)
   │        │ streams
   │        ├── live balance + category totals
   │        └── cash-runway forecast (pure Dart, unit tested)
   │
   └── AI proxy ──► Gemini API            (roadmap — not wired yet)
        (holds the API key; receives aggregated summaries only)
```

- Works offline; only the future advisor will need a connection.
- Money is stored in **cents as integers**, never floating point.
- The forecast is a pure function (`lib/core/forecast.dart`) fed by Riverpod providers, which makes it easy to test and change.
- The Gemini key will never ship inside the app. Requests will go through a small proxy.

## Tech Stack

- **Flutter / Dart** — cross-platform app (Android, web; Windows desktop with Visual Studio)
- **Drift (SQLite)** — typed, local-first persistence
- **Riverpod** — state management and live queries
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
flutter test        # 29 tests
```

Verified on this machine: `flutter analyze`, `flutter test`, `flutter build web --release`, and `flutter build apk --debug` (output at `build/app/outputs/flutter-apk/app-debug.apk`). The Windows desktop target still needs the Visual Studio C++ workload.

Coverage:

- **Forecast** — burn-rate averaging, lookback window, recurring commitments, horizon cap, empty data, zero balance.
- **Recurrence** — Mon–Fri expansion across weekends, exclusive “after”, end dates, next occurrence, weekday encoding.
- **Money** — parsing `R 1,234.50` / `35,50`, formatting cents.
- **Database** — withdrawal + spend persistence, recurring taxi posting once per weekday, no duplicates on re-sync, paused rules.
- **UI flows** — add a withdrawal, log a preset spend, see the live balance, set up a weekday taxi and find it under Recurring.

## Project Structure

Feature-first layout:

```
lib/
  core/            # theme, money, dates, forecast, recurrence rules
  data/            # Drift database, repository, recurring posting service
  features/
    withdrawals/   # ATM withdrawal pots
    spending/      # quick logging, presets, repeat setup
    recurring/     # manage repeating spends
    dashboard/     # balance, runway, category breakdown
    activity/      # full timeline, delete an entry
    shell/         # bottom navigation
  widgets/         # shared UI pieces
tool/              # Windows/WSL Flutter wrappers
```

## Security & POPIA

- **Data minimisation:** cash records stay on-device; no backend receives them. Only aggregates will go to the AI once the advisor ships.
- **No PII in logs:** the app does not log amounts, notes or free text; database errors are logged without record contents.
- **Secrets:** no API keys or secrets in the repo. Secret scanning (gitleaks) is intended before pushes.
- **Deletion:** individual spends and withdrawals can be deleted from Activity. One-tap delete-all is roadmap.
- **Hardening roadmap:** encryption at rest (SQLCipher), `allowBackup=false`, minimum Android permissions, obfuscated release build, MobSF and OSV-Scanner checks, certificate pinning and root detection.

## Known Limitations

- The AI advisor and its consent screen are not implemented yet; the app is fully usable offline without them.
- The local database is plain SQLite, not encrypted at rest yet.
- Windows desktop builds require Visual Studio C++ tooling, which is not installed on this machine.
- The web build stores data in the browser's origin storage; it is a demo target, not the shipping target.

## Roadmap & Business Model

No ads, ever.

- **Free:** cash tracking forever, plus a monthly allowance of advisor questions.
- **Zaka Plus (about R29/month):** unlimited advisor, goals and alerts, PDF reports.
- **Zaka Ultra (about R50/month):** shared stokvel and household pots, proactive cash-runway alerts, voice logging in SA languages, consented income and spending statement.
- **Later:** stokvel group features, opt-in product referrals with explicit consent, anonymised aggregate insights, and the categorisation engine as an SDK for other SA fintechs.

Prices are hypotheses to be validated with pilot users.

## Author

**Nyakallo Masiu** — [github.com/nyaks1](https://github.com/nyaks1)

Built for the FNB App of the Year Hackathon 2026.
