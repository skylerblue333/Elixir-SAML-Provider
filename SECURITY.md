# Security Boundary

Sky SAML Lab is an engineering-beta validation library. It accepts already-decoded metadata maps from a trusted XML/signature-processing boundary.

It does **not** parse SAML XML, expand XML entities, verify XML Digital Signatures, validate certificate chains, decrypt encrypted assertions, manage IdP/SP keys, implement browser bindings, generate AuthnRequests, issue assertions, perform user authentication, or provide a production identity provider/service provider.

Callers must perform standards-compliant XML parsing, signature validation, certificate trust, replay protection, request/response correlation, destination/recipient checks, and secure session creation before treating SAML data as authenticated identity.

Report suspected implementation vulnerabilities through the repository's private security-reporting channel rather than publishing secrets or exploit details in public issues.
