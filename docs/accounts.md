# Accounts, trials and creator access

This document describes the account layer that ships in this build and the
backend version that does not.

## What ships now

| Capability | Status | Where |
|---|---|---|
| Create an account with email + password | Done | Account → Create free account |
| Sign in / sign out | Done | Account |
| 3-month trial on every new account | Done | `AuthService`, 90 days |
| Creator lifetime access | Done, local build | `OWNER_EMAIL`, optional `OWNER_ACCESS_CODE` |
| Creator user list | Done, this device only | Account → Users |
| Grant lifetime / reset trial / move to free | Done, this device only | Account → Users |
| App-lock PIN | Done | Account → App lock |
| Delete every local account | Done | Privacy & Ask Zaka → Delete everything |
| Google sign-in | Roadmap | Button explains the missing OAuth client |
| Central user directory (all phones) | Roadmap | Needs the backend below |
| Email verification, password reset | Roadmap | Needs the backend below |
| Payments / card checkout | Roadmap | No payment provider is wired |

The account layer is **local-first**. A Zaka account is a row in the on-device
SQLite database. The password is stored as
`pbkdf2_sha256$iterations$salt$hash` (PBKDF2-HMAC-SHA256, 60,000 iterations,
16-byte random salt). The signed-in user id is kept in shared preferences.
Money data is still only in the local database and is never uploaded by
signing in.

**Delete everything** on the Privacy & Ask Zaka screen now deletes every local
account, the sign-in id and the app-lock PIN as well as the money data. An
individual account cannot be deleted on its own yet; deleting everything is the
current path.

That also means:

- **No email verification.** Anyone who can type an email can create a local
  account with it.
- **No password reset.** A forgotten password cannot be recovered; the money
  data is still readable without signing in.
- **No cross-device sync.** Accounts on another phone do not appear in the
  creator console.
- **A local role is not a security boundary.** A rooted phone or a database
  edit can change `role` or `plan`. Do not treat the local owner flag as
  protection for money or secrets.

## The 3-month trial

`AuthService.register` sets `trial_ends_at = now + 90 days` and `plan = trial`.
The Account screen shows the days left. When the trial ends, the effective label
becomes **Free plan**; Zaka does **not** lock the cash tracker. Paid Plus
features do not exist yet, so there is nothing to gate.

The creator account gets `plan = lifetime` and no trial end.

## How the creator gives themselves lifetime access

A public checkout has **no default creator email**. The owner is whatever
private build config supplies; the value is empty unless you set it. Keep it
out of public files:

1. Copy `build.local.example.json` to `build.local.json` (gitignored).
2. Set `ownerEmail` and, if you want a second factor, `ownerAccessCode`.
3. Run `tool/build-release.ps1`, or pass the same values as
   `--dart-define=OWNER_EMAIL=...` and `--dart-define=OWNER_ACCESS_CODE=...` to
   your own private build command.

Do not put the real address or code in `README.md`, an issue or a screenshot.

Sign up with the configured email and the account is created with `role =
owner`, `plan = lifetime`, and the **Users** console appears under **Account**.

With a code configured, signing up with the creator email starts as a normal
trial. Open **Account → Unlock creator access**, enter the code once, and the
account becomes owner + lifetime. The code is compared locally. It is not a
server secret and can be extracted from a determined attacker's APK; it exists
to stop a curious tester, not a reverse engineer.

The creator console lists every account on that phone. Use the menu on a user
to **Give lifetime access**, **Reset 3-month trial**, or **Move to free plan**.
All three actions invalidate the current-user provider, so the UI updates
immediately. You cannot lose access by demoting yourself in the UI, but a
database edit can; production roles must be server-side.

## Why Google is not switched on

A real "Continue with Google" flow needs a Google Cloud OAuth client for the
Android package `za.co.zaka.zaka` and the signing certificate's SHA-1. Without a
client id, Google will not issue a verifiable ID token, and trusting an email
typed into a fake popup would let anyone claim any account, including the
creator email.

The button in this build opens an explanation instead of a fake login. To wire
it up:

1. Create a Google Cloud project and an OAuth consent screen.
2. Create an **Android** OAuth client id:
   - package name `za.co.zaka.zaka`
   - SHA-1 of the debug or release keystore (`keytool -list -v`)
3. Add `google_sign_in` and complete the native sign-in.
4. Send the returned **ID token** to a backend and verify it against Google's
   JWKS. Never trust the email or subject from the client.
5. On success, call:

```dart
await authService.signInWithVerifiedGoogle(
  email: verifiedEmail,
  displayName: verifiedName,
);
```

`signInWithVerifiedGoogle` creates a `google` provider row or signs in the
existing email. It is the only Google entry point, and it assumes the token was
already verified somewhere trustworthy.

## Central accounts and a real user directory

The local version cannot show users on other phones. That needs a small
backend. The existing advisor proxy is a Cloudflare Worker; the same deployment
can host an auth API, or a separate Worker can.

Minimum schema:

```sql
-- D1 / Postgres
users (
  id            TEXT PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  display_name  TEXT NOT NULL,
  password_hash TEXT,              -- Argon2id on the server
  provider      TEXT NOT NULL,     -- email | google
  role          TEXT NOT NULL,     -- user | owner
  plan          TEXT NOT NULL,     -- trial | lifetime | free
  trial_ends_at INTEGER,
  created_at    INTEGER NOT NULL,
  last_seen_at  INTEGER
);

sessions (
  token_hash TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL,
  expires_at INTEGER NOT NULL
);

plan_audit (
  id         TEXT PRIMARY KEY,
  actor_id   TEXT NOT NULL,
  subject_id TEXT NOT NULL,
  from_plan  TEXT,
  to_plan    TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
```

Endpoints:

| Method | Path | Notes |
|---|---|---|
| POST | `/auth/register` | Email + password; rate-limited; email verification |
| POST | `/auth/login` | Argon2id verify; short-lived session token |
| POST | `/auth/google` | Verify Google ID token via JWKS |
| GET | `/me` | Session → user + effective plan |
| POST | `/me/logout` | Revoke session |
| GET | `/admin/users` | Owner only; paginated |
| POST | `/admin/users/:id/plan` | Owner only; write `plan_audit` |

Server rules:

- Owner role is seeded by a server secret, never by an email match in the app.
- Verify email before granting a trial, or a script can farm trials.
- Hash passwords with Argon2id (or scrypt) and a per-user salt.
- Keep session tokens hashed at rest; rotate on sign-in.
- Rate-limit register, login and Google verification per IP and per email.
- Do not store money data. The server needs identity + plan only.
- POPIA: purpose limitation, deletion path, audit trail, and a privacy notice
  that says what account data leaves the phone.

Until that exists, the README labels the central directory, Google sign-in and
payments as **Roadmap**, not features.
