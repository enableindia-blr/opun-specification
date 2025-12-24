#OPuN Livelihood Domain — Beckn Protocol 2.0.0 Examples

## Overview

Overview

This directory contains Beckn Protocol 2.0.0–compliant example payloads for the OPuN Livelihood Domain (A Decentralized, Consent-Based Open Network for Persons with Disabilities).

The examples demonstrate correct Beckn 2.0 modeling, including:

#JSON-LD semantics
#Stable identifiers
#Livelihood-specific application lifecycle
#Canonical placement of job, fulfillment, and form (xinput) data

These examples are intended to be reference-grade for implementers.


## Beckn Protocol 2.0.0 — Key Characteristics

### JSON-LD Structure
All payloads follow JSON-LD conventions: (JavaScript Object Notation for Linked Data) 
- `@context` array referencing Beckn protocol contexts
- `@type` annotations for semantic typing
- `@id` for globally unique identifiers (URNs)
- Schema.org vocabulary for domain objects

```
"@context": [
  "https://becknprotocol.io/context/core.jsonld",
  "https://becknprotocol.io/context/livelihood.jsonld"
]
```

### Protocol Metadata
- **Domain**: `beckn:livelihood` (Beckn protocol namespace)
- **Core Version**: `2.0.0`
- **Identifier Type**: URN (urn:job:*, urn:order:*, etc.)
- **State Modeling**: Fulfillment-scoped
- **Forms**: beckn:XInput

### Semantic Typing

All business objects are explicitly typed.

- **Object** -  Type
- **Order** -	`beckn:Order`
- **Search Intent** -	`beckn:Intent`
- **Job** -	`schema:JobPosting`
- **Provider** -	`schema:Organization`
- **Candidate** -	`schema:Person`
- **Fulfillment** -`beckn:Fulfillment`
- **Quote** -	`beckn:Quote`
- **State** -	`beckn:State`
- **Location** -	`schema:Place` and `schema:PostalAddress`
- **Salary** -	`schema:MonetaryAmount`

- **Intent Structure**: Uses `beckn:Intent` with `@typeHint` for search queries


## Directory Structure

```
examples-2.0.0/
├── README.md (this file)
├── search/
│   ├── search-by-job-title.json
│   ├── search-by-skills.json
│   ├── search-by-provider.json
│   └── on_search.json
├── select/
│   ├── select.json
│   └── on_select.json
├── init/
│   ├── init.json
│   └── on_init.json
├── confirm/
│   ├── confirm.json
│   └── on_confirm.json
├── status/
│   ├── status.json
│   └── on_status.json
├── update/
│   ├── update.json
│   ├── on_update.json
│   ├── on_update_confirmation.json
│   └── on_update_job_offer.json
├── cancel/
│   ├── cancel.json
│   └── on_cancel.json
└── support/
    ├── support.json
    └── on_support.json
```

## API Endpoints

### Search APIs
- **`/search`** - Search for job opportunities
  - `search-by-job-title.json` - Search by job title using `@typeHint: "schema:JobPosting"` and `title` property
  - `search-by-skills.json` - Search by candidate skills
  - `search-by-provider.json` - Search by employer/provider
- **`/on_search`** - Search response with job catalog containing semantically typed items

### Select APIs
- **`/select`** - Candidate selects a job opportunity
- **`/on_select`** - Response with detailed job information, quote, and form structure via XInput

### Init APIs
- **`/init`** - Submit filled application form with form data
- **`/on_init`** - Response with submitted form data stored and returned for verification

### Confirm APIs
- **`/confirm`** - Confirm job application submission with same form data received in on_init
- **`/on_confirm`** - Confirmation response after BPP verifies form data and application is submitted

### Status APIs
- **`/status`** - Check application status
- **`/on_status`** - Status response with current application state

### Update APIs
- **`/update`** - Update application details (solicited update from BAP to BPP)
- **`/on_update`** - Update confirmation response (for solicited updates) or unsolicited update sent from BPP to BAP
  - `on_update.json` - Interview scheduling example (unsolicited)
  - `on_update_confirmation.json` - Update confirmation (solicited)
  - `on_update_job_offer.json` - Job offer extension example (unsolicited)

### Cancel APIs
- **`/cancel`** - Cancel job application
- **`/on_cancel`** - Cancellation confirmation

### Support APIs
- **`/support`** - Request support information
- **`/on_support`** - Support contact details

## Beckn 2.0.0 Compliance Requirements

### 1. Context Structure
```json
{
  "@context": [
    "https://becknprotocol.io/context/core.jsonld",
    "https://becknprotocol.io/context/livelihood.jsonld"
  ],
  "context": {
    "domain": "beckn:livelihood",
    "core_version": "2.0.0",
    ...
  }
}
```

### 2. Semantic Typing
All business objects must include `@type` annotations:
- `beckn:Order` for order objects
- `beckn:Intent` for search intents
- `beckn:Fulfillment` for fulfillment objects
- `beckn:Quote` for quote objects
- `beckn:Payment` for payment objects
- `beckn:State` for state objects
- `schema:JobPosting` for job postings
- `schema:Organization` for providers/organizations
- `schema:Person` for customers/persons
- `schema:Place` for locations
- `schema:MonetaryAmount` for price/salary information

### 3. Identifiers
- Use URN format for `@id`: `urn:job:JOB_001`, `urn:provider:1`, `urn:order:JOB_APP_001`
- Remove invalid characters from `message_id` (no `$` prefix)

### 4. Location Structure
```json
"location": {
  "@type": "schema:Place",
  "address": {
    "@type": "schema:PostalAddress",
    "addressLocality": "Bangalore",
    "addressCountry": "IND"
  }
}
```

### 5. Intent Structure (Search)
```json
"intent": {
  "@type": "beckn:Intent",
  "@typeHint": "schema:JobPosting",
  "title": "Fullstack Engineer"
}
```

### 6. Fulfillment Structure
```json
{
  "@type": "beckn:Fulfillment",
  "id": "1",
  "fulfillmentCategory": "JOB",
  ...
}
```

## Application Flow

1. **search** → **on_search**: Candidate searches for jobs, receives catalog
2. **select** → **on_select**: Candidate selects job, receives detailed info and form
3. **init** → **on_init**: Candidate submits form, receives confirmation for review
4. **confirm** → **on_confirm**: Candidate confirms, application is submitted
5. **status** → **on_status**: Check application status at any time
6. **update** / **on_update**: Update application or receive unsolicited updates (interviews, offers)
7. **cancel** → **on_cancel**: Cancel application if needed
8. **support** → **on_support**: Get support contact information

## Domain

All examples use the domain: `beckn:livelihood`

## Version

All examples use core version: `2.0.0`

## Differences from Beckn 1.0.0

1. **JSON-LD Structure**: Added `@context`, `@type`, and `@id` annotations
2. **Domain Namespace**: Changed from `opun:livelihood` to `beckn:livelihood`
3. **Core Version Field**: Changed from `version` to `core_version`
4. **Semantic Typing**: All objects must be semantically typed
5. **Intent Structure**: Search intents use `@typeHint` and flat properties
6. **Location Structure**: Uses schema.org Place and PostalAddress
7. **Fulfillment Category**: Added `fulfillmentCategory` field
8. **Message IDs**: Must be valid UUIDs without special prefixes

## References

- [Beckn Protocol Core Specification 2.0.0](https://github.com/beckn/protocol-specifications)
- [OPuN Protocol Specification](../)
- [Schema.org Vocabulary](https://schema.org/)
- [JSON-LD Specification](https://www.w3.org/TR/json-ld/)
