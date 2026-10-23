# OPuN Livelihood Domain Specification
**Built on Beckn Protocol Core v2.0.0**  
**Version: 1.0.0**  
**Status: Normative**

---

## 1. Introduction

The **OPuN Livelihood Domain** defines a decentralized, consent-based, interoperable protocol for **employment, livelihood discovery, job application, and hiring lifecycle management**.

This domain is implemented as a **domain extension** on top of the **Beckn Protocol Core (v2.0.0)**.

- **Beckn Core** provides the transaction grammar and interoperability guarantees.
- **OPuN** governs all **business semantics, lifecycle rules, state machines, and domain evolution** for Livelihood.

This document is the **authoritative specification** for OPuN Livelihood implementations.

---

## 2. Design Philosophy

### 2.1 Separation of Concerns

| Layer | Owner | Responsibility |
|------|-------|----------------|
| Protocol Core | Beckn | Actions, envelopes, routing, interoperability |
| Domain Semantics | OPuN | Jobs, applications, interviews, offers |
| Implementations | Network Participants | UX, policies, compliance |

### 2.2 Non-Goals

- OPuN does **not** modify Beckn Core
- OPuN does **not** mandate UI/UX
- OPuN does **not** prescribe employer policies

---

## 3. Domain Identification

### 3.1 Domain Code

All transactions **must declare**:

```json
"domain": "opun:livelihood"
```

### 3.2 Namespace

```json
"opun": "https://opun.network/schema/livelihood/v1/"
```

OPuN is the **namespace authority** for all livelihood semantics.

---

## 4. Protocol Contexts

All payloads **must include exactly two contexts**:

```json
"@context": [
  "https://schema.nfh.global/core/v2.0/context.jsonld",
  "https://opun.network/schema/livelihood/v1/context.jsonld"
]
```

The OPuN context is also published, unchanged, at the tagged repository copy:
`https://raw.githubusercontent.com/enableindia-blr/opun-specification/v2.0.0/livelihood-domain-2.0/schema/livelihood/v1/schema-extension/context.jsonld`.
Implementations should resolve both contexts through a document loader with a local or cached copy, as recommended by Beckn, rather than fetching them on every message.

- Beckn core context → Beckn-governed, immutable within v2
- OPuN livelihood context → OPuN-governed, versioned (`v1` in the path is the major version)

---

## 5. Versioning Strategy

### 5.1 Independent Versioning

| Component | Version |
|----------|---------|
| Beckn Core | 2.0.0 |
| OPuN Livelihood Domain | 1.0.0 |

Domain evolution **must not** be tied to Beckn releases.

### 5.2 Semantic Versioning Rules

- **Major**: Breaking lifecycle or semantic changes
- **Minor**: Additive, backward-compatible changes
- **Patch**: Clarifications, documentation, constraints

---

## 6. Core Beckn Objects (Inherited)

The following Beckn objects are **used as-is** and **must not be redefined**:

- `beckn:Intent`
- `beckn:Order`
- `beckn:Fulfillment`
- `beckn:Quote`
- `beckn:State`
- `beckn:XInput`
- `beckn:Payment`

OPuN defines **interpretation**, not structure.

---

## 7. Domain Object Model

### 7.1 Job Representation

Jobs are represented using:

```json
"@type": "schema:JobPosting"
```

Mandatory properties:

- `title`
- `description`
- `employmentType`
- `jobLocationType`
- `baseSalary`
- `validThrough`

---

### 7.2 Fulfillment Category

All livelihood transactions **must use exactly**:

```json
"fulfillmentCategory": "JOB"
```

No additional categories are valid in this domain.

---

## 8. Application Lifecycle

### 8.1 Canonical Application States

Application state is expressed via:

```json
fulfillment.state.descriptor.code
```

| Code | Description |
|------|-------------|
| APPLICATION-SUBMITTED | Application successfully submitted |
| APPLICATION-UNDER-REVIEW | Employer review in progress |
| INTERVIEW-SCHEDULED | Interview planned |
| INTERVIEW-COMPLETED | Interview completed |
| JOB-OFFER-EXTENDED | Offer issued |
| OFFER-ACCEPTED | Candidate accepted offer |
| OFFER-DECLINED | Candidate declined offer |
| APPLICATION-REJECTED | Employer rejection |
| APPLICATION-CANCELLED | Candidate cancellation |

State transitions **must be monotonic**.

---

## 9. Search Semantics

### 9.1 Intent Model

Search requests **must use**:

```json
{
  "@type": "beckn:Intent",
  "@typeHint": "schema:JobPosting"
}
```

Allowed filters:
- Job title
- Skills
- Provider
- Location

---

## 10. Selection & Form Discovery

### 10.1 `/on_select`

The `/on_select` response **must include**:

- Complete job description
- Salary quote (informational)
- `beckn:XInput` describing application form

---

## 11. XInput (Application Forms)

### 11.1 Governance Rules

- Form schema is **immutable** after `/on_select`
- Form structure must not change mid-transaction
- Filled data must be echoed verbatim

### 11.2 Mandatory Echo Points

Filled form data **must appear in**:
- `/init`
- `/on_init`
- `/confirm`
- `/on_confirm`

---

## 12. Init & Confirm Semantics

### 12.1 `/init`

- Candidate submits filled application form
- No irreversible action is taken

### 12.2 `/confirm`

- Candidate confirms submission
- Employer accepts application into workflow

---

## 13. Updates

### 13.1 Solicited Updates

Triggered by candidate:
- Contact corrections
- Document updates

### 13.2 Unsolicited Updates

Triggered by employer:
- Interview scheduling
- Offer extension
- Status changes

All updates are delivered via:

```
/on_update
```

---

## 14. Status

The `/status` API provides **current application state** and must always reflect the latest fulfillment state.

---

## 15. Cancellation

### 15.1 Candidate Cancellation

- Performed via `/cancel`
- Results in `APPLICATION-CANCELLED`

### 15.2 Employer Rejection

- Delivered via `/on_update`
- Results in `APPLICATION-REJECTED`

No cancellation fees are allowed.

---

## 16. Financial Semantics

- Salary is informational
- Represented using `schema:MonetaryAmount`
- Communicated via `beckn:Quote`
- No payments are executed in this domain

---

## 17. Identity & Consent

### 17.1 Identity

- Use URN identifiers
- No central identity provider mandated

Example:
```
urn:person:aadhaar:xxxxxxxxxxxx
```

### 17.2 Consent Principles

- Explicit user-provided data only
- Purpose-bound to job application
- No secondary usage without consent

---

## 18. Support

Support discovery is handled via:

- `/support`
- `/on_support`

Support information is informational only.

---

## 19. Security & Privacy

- Transport-level security is mandatory
- Personal data must be minimized
- Logs must avoid sensitive data storage

---

## 20. Conformance Criteria

An implementation is **OPuN Livelihood Compliant** if it:

- Uses Beckn Core 2.0 unchanged
- Declares `opun:livelihood`
- Follows lifecycle states strictly
- Preserves XInput integrity
- Honors consent and privacy rules

---

## 21. Governance & Evolution

This specification is governed by **OPuN**.

All changes:
- Must be versioned
- Must be documented
- Must preserve backward compatibility unless a major version is released

---

## 22. References

- Beckn Protocol Core Specification v2.0.0  
- JSON-LD 1.1 Specification  
- Schema.org Vocabulary  
- OPuN Governance Charter  

---

**End of Specifica