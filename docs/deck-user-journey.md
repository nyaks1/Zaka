# Deck user journey (source copy)

The pitch deck itself is an external file and was not in this checkout. This is
the journey to paste into it so the deck, README and SSDLC form describe the same
product path. Use these six beats, in this order.

## Slide: one user, six taps

1. **Install and open.** Download the APK from `release/zaka-0.1.0.apk`
   in the repository, sideload it on Android 7.0+, and open Zaka. On the first
   screen tap **Try with sample data**.
2. **See the runway.** The sample creates an FNB cheque account and shows **R125
   in the bank + R500 cash = R625**, with a **5-day** runway. The ATM row became
   a cash transfer, not a spend.
3. **Log a real spend.** Tap **Log cash**, choose a taxi preset, and optionally
   turn on **Repeat this spend → Weekdays**. The forecast updates on the phone.
4. **Import a statement.** Accounts → a bank account → **Import statement** →
   CSV/PDF. The preview classifies ATM rows as cash transfers and skips rows
   already imported.
5. **Ask Zaka (optional).** Tap the Ask Zaka card. The exact four-field JSON is
   shown before consent. Turning it on sends only `runwayDays`,
   `dailyBurnRand`, `categoryPercent` and `periodDays` to the Worker; Google may
   process them outside South Africa. The card always has an on-device tip if
   the network or proxy fails (in this public build without baked-in secret proxy
   credentials, it runs the privacy-first on-device tip; the live Gemini demo is
   the screen recording).
6. **Account, privacy and support.** Create a local account, turn on **App
   lock** (PIN), open **Privacy policy**, and use **Send feedback or a
   complaint**. Tapping the contact copies it; the in-app form posts to the
   Worker; the warning says **Please don't send bank details or statements.**
   **Delete everything** removes the money data, local account and sign-in, the
   PIN and Ask Zaka settings.

## Slide: what the judge should remember

- Cash-first, not bank-feed-first: the ATM withdrawal is the product's starting
  point.
- Four fields leave the phone, with consent, and only for optional tips.
- The public build runs the privacy-first on-device tip; the live Gemini demo is
  the screen recording.
- No central money database, no bank login, no ads, no tracking.
- The honest gaps are on the slide: no encrypted export yet, English-only UI,
  PIN-only lock, local accounts, debug-signed hackathon APK.
- The support path is visible in two screens and is the same path in the README
  and the SSDLC form.

## Slide: 18+ and scope

Zaka is for people aged 18 and over. It gives tips and insights, not financial
advice. Payments, live bank sync and a central account directory are roadmap,
not current features.
