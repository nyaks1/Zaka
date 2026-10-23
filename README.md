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
| ATM withdrawal pots | Record a withdrawal; it becomes a pot you spend down | ☐ |
| Two-tap cash logging | Log spends fast with SA presets (taxi, vendor, airtime, electricity) | ☐ |
| Dashboard | Live balance, spending by category | ☐ |
| Cash-runway forecast | Daily burn rate × remaining cash = the day your cash runs out | ☐ |
| AI advisor (Gemini) | Explains your spending pattern in plain language | ☐ |
| Consent + delete-all | Explicit consent before any AI call; wipe all data in one tap | ☐ |

*(Tick each box as it ships. Anything unticked at submission is roadmap, not a feature.)*

## Architecture

**Local-first.** All spending data lives on the device in an encrypted database. There is no central database of users' money to breach.

```
Flutter app (Riverpod)
   │
   ├── Drift / SQLite  ← all cash data, on-device
   │
   └── AI proxy ──► Gemini API
        (holds the API key; receives aggregated summaries only)
```

- Works offline and on low data; only the advisor needs a connection.
- The Gemini key never ships inside the app. Requests go through a small proxy.
- Only **aggregated summaries** are sent to the AI, never raw entries or free-text notes.

## Tech Stack

- **Flutter / Dart** — cross-platform mobile app
- **Drift (SQLite)** — typed, local-first persistence
- **Riverpod** — state management
- **Gemini API** — AI financial advisor, via proxy

## Security & POPIA

Developed with a Secure System Development Cycle mindset:

- **Data minimisation:** cash records stay on-device; only aggregates go to the AI.
- **Consent:** explicit, informed consent screen before any AI call, disclosing that processing by the AI provider may occur outside South Africa.
- **Deletion:** one-tap delete-all wipes the local database.
- **No PII in logs:** verified with `adb logcat` during testing.
- **Secrets:** no keys in the repo or the APK; secret scanning (gitleaks) before pushes.
- **Hardening:** minimum Android permissions, `allowBackup=false`, obfuscated release build.
- **Testing:** `flutter analyze`, MobSF scan of the APK, dependency audit (OSV-Scanner), manual abuse-case tests.

Threat model summary (STRIDE across device ↔ local DB, app ↔ proxy, proxy ↔ Gemini) is in the submission document.

**Known limitations:** certificate pinning and root detection are roadmap items.

## Getting Started

**Prerequisites:** Flutter SDK, Android Studio or a physical Android device with USB debugging.

```bash
git clone <this-repo-url>
cd zaka
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates Drift code
flutter run --dart-define=ZAKA_AI_PROXY_URL=<your-proxy-url>
```

Build a release APK:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols \
  --dart-define=ZAKA_AI_PROXY_URL=<your-proxy-url>
```

## Project Structure

Feature-first layout:

```
lib/
  core/            # theme, utils, shared widgets
  data/            # Drift database, DAOs
  features/
    withdrawals/   # ATM withdrawal pots
    spending/      # quick logging, categories
    dashboard/     # balance, forecast
    advisor/       # AI advisor, consent
    settings/      # privacy, delete-all
```

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