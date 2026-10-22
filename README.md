# OPuN Specification

**OPuN (Open Purple Network)** is an open, decentralised, consent-based network protocol that connects Persons with Disabilities (PwDs) to jobs, learning and financial services across any participating platform.

OPuN is a **domain extension of [Beckn Protocol Core v2.0.0](https://github.com/beckn/protocol-specifications)**. It adds domain meaning (jobs, courses, loans, credentials) without changing Beckn Core, so any Beckn-compatible platform can join the network without bespoke integration.

This repository holds the normative specification, schema packs (JSON-LD contexts, vocabularies, attributes) and example payloads for every API.

## Domains

| Domain | Code | Scope | Version | Status | Folder |
| --- | --- | --- | --- | --- | --- |
| Livelihood | `opun:livelihood` | Jobs, internships and project work: discovery, application, interview, offer, joining, cancellation, support | 1.0.0 | Normative | [`livelihood-domain-2.0/`](./livelihood-domain-2.0/) and [specification](./opun_livelihood_domain_spec_2_0_0.md) |
| Learning | `opun:learning` | Courses (online, offline, hybrid): discovery, enrolment, progress, certificates | v1 | Draft | [`learning-domain-2.0/`](./learning-domain-2.0/) |
| Loan | `opun:loan` | Loan product discovery, application, status updates | v1 | Current | [`loan/`](./loan/) |
| Verifiable Credentials | — | Credential issuance and presentation (OpenID4VCI / OpenID4VP, SD-JWT VC) | — | Draft | [`VC/`](./VC/VC_Readme.md) |

All domains are built on Beckn Protocol Core **v2.0.0**. Domain versions evolve independently of Beckn releases (see §5 of the livelihood specification).

## Repository structure

```
OPuN-Specification/
├── README.md                              # This file
├── LICENSE                                # Apache License 2.0
├── NOTICE                                 # Copyright and stewardship
├── DPG.md                                 # SDG alignment and DPG Standard evidence
├── opun_livelihood_domain_spec_2_0_0.md   # Normative livelihood specification
├── livelihood-domain-2.0/
│   └── schema/livelihood/v1/
│       ├── schema-extension/              # attributes.yaml, context.jsonld, vocab.jsonld
│       └── examples/                      # discover, select, init, confirm, status,
│                                          # update, cancel, support
├── learning-domain-2.0/
│   ├── LEARNING_DOMAIN_SCHEMA_DESIGN.md
│   └── schema/learning/v1/
│       ├── schema-extension/
│       └── examples/                      # search, select, init, confirm, status,
│                                          # update, cancel
├── loan/
│   ├── flow.md
│   └── v1/
│       ├── schema-extension/
│       └── examples/                      # search, select, init, confirm, status,
│                                          # update, cancel
└── VC/
    └── VC_Readme.md                       # Verifiable credential flow and schemas
```

## Livelihood flow

Livelihood discovery follows Beckn v2.0 catalog-centric discovery: provider platforms (BPPs) publish catalogs, and seeker platforms (BAPs) discover them. The transaction APIs that follow are exchanged directly between BAP and BPP.

```mermaid
sequenceDiagram
    autonumber
    participant C as Candidate
    participant BAP as Seeker app (BAP)
    participant CDS as Catalog discovery
    participant BPP as Provider app (BPP)

    BPP->>CDS: catalog_publish (job catalog)
    C->>BAP: Enter search criteria
    BAP->>CDS: discover
    CDS-->>BAP: on_discover (matching jobs)
    BAP-->>C: Display job listings

    C->>BAP: Select job
    BAP->>BPP: select
    BPP-->>BAP: on_select (job details and application form)
    C->>BAP: Fill and submit form
    BAP->>BPP: init (filled form data)
    BPP-->>BAP: on_init (echo for review)
    C->>BAP: Confirm application
    BAP->>BPP: confirm
    BPP-->>BAP: on_confirm (application id)

    BPP-->>BAP: on_update (interview, offer, joining; unsolicited)
    BAP->>BPP: status / update / cancel / support
    BPP-->>BAP: on_status / on_update / on_cancel / on_support
```

### Livelihood APIs

| Stage | APIs |
| --- | --- |
| Discovery | `catalog_publish`, `discover`, `on_discover` |
| Selection and application | `select`, `on_select`, `init`, `on_init`, `confirm`, `on_confirm` |
| Post-application | `status`, `on_status`, `update`, `on_update`, `cancel`, `on_cancel`, `support`, `on_support` |

The learning and loan domains use the `search` / `on_search` discovery pair, followed by the same select → init → confirm → status/update/cancel lifecycle. See each domain's README and examples.

## Getting started

### For readers and implementers

1. Read the [livelihood specification](./opun_livelihood_domain_spec_2_0_0.md): domain identification, lifecycle states, form (XInput) rules, identity and consent, security, conformance.
2. Review the schema pack for your domain: `attributes.yaml`, `context.jsonld` and `vocab.jsonld` under `schema-extension/`.
3. Use the example payloads under `examples/` as reference requests and responses for every API.

### For platforms joining a network

1. **Choose your role:** seeker platform (BAP) or provider platform (BPP).
2. **Register** as a network participant in a DeDi-compliant registry, with your participant type and public keys.
3. **Generate keys:** Ed25519 for message signing (HTTP signature over a SHA-256 body digest) and X25519 for encryption.
4. **Implement the APIs** for your domain, including all mandatory fields and lifecycle rules.
5. **Test** your requests and responses against the example payloads.

## Standards used

| Standard | Used for |
| --- | --- |
| [Beckn Protocol Core v2.0.0](https://github.com/beckn/protocol-specifications) | Transaction grammar, envelopes, routing |
| [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/) | Linked-data contexts for every schema pack |
| [schema.org](https://schema.org/) | Shared vocabulary (`JobPosting`, `Course`, `MonetaryAmount`, …) |
| [DeDi](https://dedi.global/) | Decentralised directory of network participants and keys |
| [W3C Decentralized Identifiers (DID) v1.0](https://www.w3.org/TR/did-core/) | Issuer (`did:web`) and holder (`did:key`) identifiers |
| [OpenID for Verifiable Credential Issuance](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html) | Credential issuance (pre-authorised code flow) |
| [OpenID for Verifiable Presentations](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) | Credential presentation to verifiers |
| [SD-JWT-based Verifiable Credentials](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/) | Credential format with selective disclosure |
| [Ed25519 (RFC 8032)](https://www.rfc-editor.org/rfc/rfc8032) and X25519 (RFC 7748) | Message signing and encryption |
| [XForms](https://www.w3.org/TR/xforms/) | Application forms exchanged in `on_select` |

The VC flow is aligned with OpenID4VCI and OpenID4VP; it has not yet been run through the OpenID Foundation conformance suite.

## Relevance to the Sustainable Development Goals

OPuN directly advances **SDG 8** (Decent Work and Economic Growth: targets 8.5, 8.6, 8.10) and **SDG 10** (Reduced Inequalities: targets 10.2, 10.3), both of which name persons with disabilities in their targets.

OPuN is being prepared for submission as a Digital Public Good. See [DPG.md](./DPG.md) for the full SDG alignment and how the specification meets each indicator of the DPG Standard.

## Privacy and data protection

- Disability and identity data is sensitive. Implementations must collect and share only what a transaction needs, with the user's consent (see §17 and §19 of the livelihood specification).
- Verifiable credentials use selective disclosure, so a holder can prove one fact without revealing the whole record.
- Implementations operating in India must comply with the Digital Personal Data Protection Act 2023 and the Rights of Persons with Disabilities Act 2016; implementations elsewhere must comply with their local equivalents.
- Example payloads are illustrative only and must not contain real personal data.
- Hosting user content, moderation and grievance redressal are the responsibility of each participating platform.

## Versioning

Each domain follows semantic versioning, independently of Beckn Core:

- **Major:** breaking lifecycle or semantic changes
- **Minor:** additive, backward-compatible changes
- **Patch:** clarifications, documentation, constraints

### Current versions

- Beckn Protocol Core: 2.0.0
- Livelihood domain: 1.0.0 (normative)
- Learning and loan domains: v1
- Verifiable credential flow: draft

Tagged releases and a changelog start with the first public release.

## Contributing

Contributions are welcome through issues and pull requests.

1. Open an issue describing the change and the domain it affects.
2. Keep changes backward-compatible unless a major version is proposed.
3. Make sure every example payload is valid JSON and uses synthetic data.
4. Update the domain README and the changelog.
5. Sign off each commit (`git commit -s`) to certify the [Developer Certificate of Origin](https://developercertificate.org/). Contributions are accepted under the Apache License 2.0.

## License

Copyright 2025–2026 Plotch.ai. Licensed under the [Apache License, Version 2.0](./LICENSE). See [NOTICE](./NOTICE).

## Stewardship

The OPuN specification was originally developed by Plotch.ai and is stewarded by Enable India as an open, royalty-free public good. Any government, employer, training provider, lender, NGO or platform may implement it without licence fees.
