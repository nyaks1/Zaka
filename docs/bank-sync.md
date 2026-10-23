# Bank sync design

Zaka is **import-first** today. You can add multiple accounts, move money
between them, and import an FNB CSV statement. Live bank sync is deliberately
not wired up yet: it needs a provider agreement and a backend, and shipping a
half-configured OAuth flow would put users' banking data at risk.

This document is the implementation plan for the next phase.

## Why a backend is required

A bank-data provider such as Stitch uses OAuth-style consent. The app opens the
provider's consent screen, the user approves access, and the provider redirects
back with a code. Exchanging that code for an access token requires the
provider's **client secret**.

That secret must never ship inside a Flutter app, and neither should long-lived
bank tokens. The app should only talk to your backend, which:

- holds the provider secret and encrypts tokens at rest;
- exchanges the consent code for tokens;
- receives provider webhooks for new transactions;
- normalises accounts and transactions into the model in
  `lib/data/bank/bank_provider.dart`;
- exposes a small authenticated API to the app.

```
Flutter app ──HTTPS──> Zaka backend ──GraphQL/OAuth──> Stitch ──> FNB
     │                      │
     │                 secrets, tokens,
     │                 webhooks, sync log
     └── Drift/SQLite <── normalised accounts + transactions
```

## What is available in South Africa

- **Stitch** is the most SA-focused option. It provides account data and
  payment initiation through a GraphQL API and has direct integrations with
  South African banks. Access is commercial and partner-based.
- **Salt Edge** and **Yodlee** are global aggregators; SA coverage varies by
  bank and product.
- **Nedbank's API Marketplace**, ABSA/FNB/Standard Bank partner APIs, and
  **Capitec Pay** are partner-gated. Capitec Pay initiates payments; it is not
  a statement-data API.
- **Plaid does not cover South African banks.**
- There is no mandated open-banking regime in South Africa yet, so there is no
  public "connect any bank" API. Coverage and pricing come from the provider
  contract.

For a personal build, start with Stitch's sandbox or stay on CSV import until a
production agreement is justified. For a product, expect company onboarding,
a security review, POPIA obligations, and per-account or per-call pricing.

## Target data model

The local schema already has the pieces a feed needs:

| Bank provider | Zaka |
|---|---|
| linked account | `accounts` row (`institution`, `name`, `kind`, opening balance) |
| credit transaction | `withdrawals` row (`source = 'sync'`) |
| debit transaction | `spends` row (`source = 'sync'`) |
| transfer between own accounts | `transfers` row |
| provider transaction id | `import_key` (unique per account) |

A sync adapter should:

1. Match each provider account to a local account, creating one on first sight.
2. Insert new transactions with `source = 'sync'` and a stable
   `import_key` derived from the provider transaction id.
3. Skip rows already present (`UNIQUE (account_id, import_key)`).
4. Classify obvious own-account transfers (ATM withdrawals, transfers between
   linked accounts) as `transfers`, not spending.
5. Leave ambiguous rows for the user to recategorise rather than guessing.

`statementImportKey` and the `StatementImporter` already implement the same
deduplication and ATM-to-cash behaviour for CSV files. A live feed should reuse
that logic rather than growing a second ledger.

## Consent and security

- Ask for consent per institution, in plain language, before opening the
  provider screen.
- Show what is shared, why, and when the consent expires.
- Store tokens encrypted at rest on the backend; never in Drift, logs, or
  analytics.
- Keep the app's local database as the source of truth for display. A backend
  compromise should not expose the full local ledger.
- Provide revoke and delete-all. Revoking must stop sync and delete tokens.
- POPIA: purpose limitation, data minimisation, retention limits, a deletion
  path, and an audit trail of consent.
- Do not log amounts, descriptions, account numbers, or tokens.
- Do not screen-scrape bank credentials. It breaks on 2FA, violates bank terms,
  and creates a serious liability.

## Rollout

1. **Now:** accounts, transfers, CSV import, dedupe, ATM-to-cash classification.
2. **Sandbox:** backend skeleton, Stitch adapter, link flow, one FNB test
   account, pull-to-refresh.
3. **Private beta:** webhooks, scheduled refresh, consent expiry, revoke,
   reconciliation UI, error states.
4. **Production:** onboarding, POPIA review, monitoring, incident response,
   provider go-live.

The interface in `lib/data/bank/bank_provider.dart` is the contract to
implement. No provider secret or live endpoint belongs in this repository.
