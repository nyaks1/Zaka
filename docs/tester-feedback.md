# Tester feedback triage

Triage date: 26 October 2026. Scope: the feedback gathered for the hackathon
demo build. “Done” means it is in this APK and covered by a test or a check in
[`docs/evidence/`](evidence/). “Roadmap” means it is not shipped and must not be
described as a feature.

| # | Feedback | Decision | Status | Where |
|---|---|---|---|---|
| 1 | “I should be able to create an account.” | Add local email/password accounts in the Account screen. | Done | `lib/features/auth/auth_screen.dart` |
| 2 | “Give new users 3 months free.” | Every new account gets a 90-day trial and falls back to the free plan, never a lockout. | Done | `AuthService.register`, `lib/features/auth/auth_service.dart` |
| 3 | “I should be able to see users.” | Creator console lists every account on the device, with plan actions. | Done, this device | `lib/features/auth/admin_users_screen.dart` |
| 4 | “How do I give myself lifetime access?” | A private build config supplies `OWNER_EMAIL`; a public checkout has no default. Optional `OWNER_ACCESS_CODE` adds a one-time claim step. | Done | `build.local.example.json`, `docs/accounts.md` |
| 5 | “Sign up with Google or email/password.” | Email/password ships. Google needs an OAuth client id and a verified ID token; the button explains that instead of faking a login. | Email: Done. Google: Roadmap | `docs/accounts.md` |
| 6 | “See users on other phones / a real admin list.” | Needs a central user service with server-side roles. The local list cannot see another device. | Roadmap | `docs/accounts.md` |
| 7 | “The sample data showed a salary; use the R900 piece-job payment.” | Sample statement now starts with a R900 piece job, R500 ATM, R35 taxi and R240 groceries; the runway is five days. | Done | `lib/data/sample_data.dart`, `test/sample_data_test.dart` |
| 8 | “Make the whole Ask Zaka card tappable.” | The card is an `InkWell` with a chevron; tapping the body opens Privacy & Ask Zaka. | Done | `lib/features/dashboard/dashboard_screen.dart`, `test/app_flow_test.dart` |
| 9 | “✅ / ☐ is unclear and over-claims.” | Feature table now uses **Done** and **Roadmap**; unsupported claims were removed or labelled. | Done | `README.md` |
| 10 | “Show me the evidence, not assertions.” | Analyze, tests, gitleaks, OSV, live curls and APK manifest/signing outputs are in `docs/evidence/`. | Done | `docs/evidence/` |
| 11 | “Charge after the trial.” | No payment provider is integrated. Nobody can be charged in this build. | Roadmap | `README.md` |
| 12 | “Email verification and password reset.” | Not possible with a local-only account table. Needs the backend. | Roadmap | `docs/accounts.md` |
| 13 | “Delete everything should really delete my account and PIN.” | Delete-all now removes every local user, the sign-in id, the PIN and advisor settings as well as the money tables. | Done | `PrivacyService`, `test/privacy_test.dart` |
| 14 | “Someone can see my balances when they pick up my phone.” | Optional 4–8 digit PIN lock, re-lock after backgrounding, and `FLAG_SECURE` hides the recents preview. PIN only; biometrics are roadmap. | Done | `lib/features/security/`, `test/app_lock_test.dart` |
| 15 | “Where do I complain, and what do you do with my data?” | About + readable privacy policy, Information Officer, retention, cross-border Google processing, complaints route and the delete path. | Done | `PRIVACY.md`, `lib/features/support/` |
| 16 | “Give me a support channel that does not expose my email.” | Copyable contact in Account and Privacy, an in-app form that posts to the Worker and stores nothing, and GitHub Issues with a “no financial data” warning. | Done | `lib/features/support/`, `proxy/src/index.js`, `test/feedback_contact_test.dart` |
| 17 | “Is it accessible and in my language?” | English-only, no Semantics coverage yet. isiZulu, Setswana and Sesotho are the first targets; the contrast check is recorded. | Roadmap | `docs/accessibility.md` |
| 18 | “What if I lose or replace my phone?” | There is no encrypted export or backup yet. This is a POPIA access gap and the top roadmap item. | Roadmap | `PRIVACY.md`, `README.md` |

## Decisions worth calling out

- **Local-first accounts.** The existing promise is that money data stays on the
  phone. Creating an account does not upload balances, transactions, notes or
  bank details. The trade-off is that the creator console is per-device until a
  central account service exists.
- **Google is not faked.** A “Continue with Google” button that trusts a typed
  email would let anyone claim the creator email. The button is a setup
  explainer until a real OAuth client and verified ID token exist.
- **Trial is honest.** The 90-day date is real, but no paid feature is gated, so
  the end of the trial does not break the app.
- **Creator access is a build-time convention.** It is fine for a demo; it is
  not a security boundary. Production owner roles must be assigned and checked
  on the server.

## Open questions for the next round

1. Which email should be the production owner? There is no default in a public
   checkout; the owner comes from the private `build.local.json`.
2. Should the app require an account before showing the dashboard, or stay
   usable offline without one? It currently stays usable.
3. Which payment provider should handle Plus after the trial (Paystack, Yoco,
   Stripe, Google Play Billing)?
4. Is a central user directory acceptable under the POPIA/privacy wording, given
   it stores an email and plan but no money data?
5. When should encrypted export/backup ship, and should it use a user passphrase
   or the Android Keystore?
6. Which feedback alias is monitored, and who answers a data request within the
   POPIA response window?
