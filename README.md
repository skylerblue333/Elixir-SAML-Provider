# Sky SAML Lab

Sky SAML Lab is a dependency-free Elixir engineering component for validating SAML service-provider configuration and already-decoded assertion metadata.

## Implemented

- bounded entity ID, audience, subject and URL validation
- HTTPS-only Assertion Consumer Service URL policy
- rejection of embedded URL credentials
- issuer and audience matching
- bounded clock-skew handling
- assertion `NotBefore` / `NotOnOrAfter` policy checks
- ExUnit coverage
- formatting and warnings-as-errors compilation gates

## Critical boundary

This is **not a complete SAML Identity Provider or Service Provider**. It does not parse XML, verify XML signatures, validate certificate chains, decrypt assertions, generate AuthnRequests, issue assertions, manage signing keys, establish browser sessions, perform replay prevention, or authenticate users.

The functions in this package operate only on metadata that a separate trusted SAML/XML/signature boundary has already decoded and authenticated. Passing these checks alone must never be treated as proof of identity.

## Development

```bash
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

## SKYCOIN4444 integration

Use this package as a narrow policy-validation layer behind a separately reviewed SAML implementation. Keep XML signature verification, trust-chain validation, replay protection, request correlation, secrets, and session issuance outside this component unless they are separately implemented and tested.

Status: **engineering beta**. No production deployment, compliance certification, tenant isolation, HA, or independent security review is claimed.
