# Zaka privacy policy

**Effective 26 October 2026 · version 1.0 · hackathon build 0.1.0+1**

Zaka is a local-first cash tracker. This notice explains what it does with
personal information, who is responsible, how long information is kept, and how
to ask a question, ask for deletion or complain.

This is a plain-language notice for a pre-release build, not legal advice. The
project will get South African privacy review before a public launch.

## 1. Responsible party and Information Officer

- **Responsible party:** Nyakallo Masiu, a solo developer, South Africa.
- **Information Officer:** Nyakallo Masiu. Under POPIA the head of a private
  body is its Information Officer.
- **Contact:** use the contact shown in the app under **Account → Send feedback
  or a complaint**, or at the top of the Privacy & Ask Zaka screen. If the build
  has no email alias configured, that contact is the public GitHub Issues page:
  <https://github.com/nyaks1/Zaka/issues>.
- **Information Regulator registration:** registration with the Information
  Regulator is a pre-launch compliance step. This hackathon build is a
  pre-release and has not yet been registered. Check the current requirements
  and complaint process at <https://inforegulator.org.za/>.

Please do not put bank details, card numbers, ID numbers, account numbers or
statements in a first message. If a private channel is needed, ask for one in
the public issue without including the sensitive information.

## 2. What Zaka processes

### On your phone (not uploaded)

- Money records you enter or import: amounts, dates, categories, notes and
  account names.
- Your local Zaka account: display name, email address and a salted
  PBKDF2-HMAC-SHA256 password hash. There is no central user directory.
- If you turn on app lock: a salted PBKDF2 hash of your 4–8 digit PIN. The PIN
  itself is never stored.
- Settings, including the Ask Zaka consent flag, a random per-install token
  used for rate limiting, and the app-lock setting.

This data lives in a SQLite database in Zaka's private app storage. Android
backup is disabled in this build (`android:allowBackup="false"`). Signing in
does not upload money data.

### Ask Zaka (optional, off by default)

When you turn Ask Zaka on and tap for tips, the app sends only these four fields
to a Zaka Cloudflare Worker:

```json
{
  "runwayDays": 3,
  "dailyBurnRand": 90,
  "categoryPercent": { "Taxi": 48, "Food": 52 },
  "periodDays": 14
}
```

The Worker sends those four fields to **Google Gemini**. Google may process
them **outside South Africa**. By turning Ask Zaka on, you consent to that
cross-border processing for the purpose of generating tips. The summary has no
name, note, bank, account number, import key or exact timestamp. The Worker does
not log the summary or the install token. If the proxy is unavailable, the app
shows a tip generated on the phone.

### Feedback (optional)

If you use the in-app feedback form in a build with a Worker URL, the message you
type is sent to the Zaka Worker and forwarded to the project webhook (a third-party
destination such as Discord or Slack). The Worker does not store the message and
defangs broadcast mentions (such as `@everyone` and `@here`). An optional reply email
and the optional app version and Android version pass through to the webhook only
when you provide or tick them to allow follow-up. Do not include money data, bank
details, card numbers, ID numbers or statements.

The public hackathon APK is built without a Worker URL, so its form points at
the public GitHub Issues page instead of posting the message. That page is
public: never paste financial or identity information there.

### Technical data

- The Worker receives the request body, the `X-Install-Token` header and normal
  HTTP metadata (such as IP address and user agent) needed to deliver the
  request. Cloudflare processes that metadata as the hosting provider.
- If the optional Cloudflare KV binding is enabled, rate-limit and usage keys
  expire after **2 days**. The Worker stores no summary, feedback message or
  account data.

Zaka does **not** use ads, analytics, behavioural tracking or crash reporting.
That is a deliberate privacy choice. There is no advertising identifier and no
third-party tracking SDK.

## 3. Why we process it

- To show your balances, spending breakdown and cash-runway forecast.
- To run the local account and trial you create.
- To generate Ask Zaka tips when you opt in.
- To answer feedback, support requests and complaints.
- To keep the service available and prevent abuse (rate limiting).
- To meet legal obligations and respond to a lawful request.

## 4. Who receives it

- **Google Gemini** receives the four Ask Zaka fields when you turn Ask Zaka on
  and request tips. Google may process them outside South Africa.
- **Cloudflare** hosts the Worker and may process request metadata outside South
  Africa as the infrastructure provider.
- **The project webhook** (a third-party service such as Discord or Slack)
  receives a feedback message and any optional reply-to email you choose to
  send. The webhook provider may process and store it under its own privacy
  policy.
- **GitHub** hosts the public issue tracker and this repository.
- **No one else.** We do not sell personal information or share it for
  advertising.

## 5. Cross-border processing

Google and Cloudflare may process data outside South Africa. POPIA section 72
allows a transfer if the recipient is subject to a law, binding agreement or
corporate rules that provide an adequate level of protection, or if you consent.
The Ask Zaka switch is the consent point for the four-field summary. The
feedback form is the consent point for a message you choose to send. If you do
not want cross-border processing, leave Ask Zaka off and do not use the feedback
form; the cash tracker works entirely on the phone.

## 6. How long we keep it

- **On-device money data, local account and PIN hash:** until you use **Delete
  everything** or uninstall Zaka. There is no server copy.
- **Cloudflare KV rate-limit and usage keys:** 2 days.
- **Feedback:** the Worker forwards the message and stores nothing. The
  receiving webhook or email service may keep it under its own policy. Ask us to
  delete it and we will pass the request on.
- **GitHub Issues:** public until the project or you delete the post.
- **Email:** if you use an email alias, the mailbox provider's retention applies.

## 7. Your rights

Under POPIA you may ask:

- what personal information we hold and for a copy;
- for a correction;
- for deletion;
- to object to processing;
- for an explanation of how we process it.

The fastest access and deletion path is in the app. Every entry is visible, and
**Delete everything** (Privacy & Ask Zaka) removes the money tables, the local
Zaka account and sign-in, the app-lock PIN, and the Ask Zaka settings. The
control now really does remove the local account; it does not leave your email
behind.

**Access gap:** there is no encrypted export or backup yet. A lost or replaced
phone loses the data, and we cannot hand you a portable file. Encrypted export
is on the roadmap. Until it ships, contact us and we will help you read or
capture what is on the phone.

## 8. Security

- Passwords and PINs are stored as salted PBKDF2-HMAC-SHA256 hashes, never in
  plain text.
- The local database is plain SQLite, not encrypted at rest yet. The app-lock
  PIN and Android `FLAG_SECURE` hide the screen and the recents preview, but
  they do not encrypt the database file.
- The Worker enforces HTTPS, POST-only, an allowlist, size caps, an install
  token and optional per-install rate limits.
- No API key ships in the app. The Gemini key and webhook URL are Wrangler
  secrets.
- If you believe your data was compromised, contact us and change any reused
  password.

## 9. Children

Zaka is for people aged **18 and over**. It is not directed at children, and we
do not knowingly collect a child's personal information. If you believe a child
has used Zaka, contact us so we can help remove the local data.

## 10. Complaints

If we do not resolve a complaint, you may complain to the **Information
Regulator (South Africa)** at <https://inforegulator.org.za/>. The Regulator
publishes the current complaint form, email address and postal address. You can
also complain to us first using the contact in the app.

## 11. Changes

We will update this notice and the in-app Privacy policy screen when the data
flows change, for example when payments, live bank sync or a central account
service ships. The version and effective date at the top will change.

## 12. Contact

Use **Account → Send feedback or a complaint**, or the same row on the Privacy &
Ask Zaka screen. Tapping the row copies the configured contact. If no email
alias is configured in the build, it copies
<https://github.com/nyaks1/Zaka/issues>.

Please don't send bank details or statements.
