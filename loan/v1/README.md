# Loan Domain — v1

Version 1 of the Loan domain schema and examples for OPuN (Beckn Protocol v2.0 extension).

## Contents

| Directory           | Description |
|---------------------|-------------|
| **schema-extension/** | JSON-LD context, vocabulary, and attribute definitions for the loan domain (products, applications, fulfillment). |
| **examples/**         | Example request/response payloads for each Beckn flow (search, select, init, confirm, status, update, cancel). |

## Domain Context

- **Context domain:** `opun:loan`
- **Schema base:** Use `schema-extension/context.jsonld` and `vocab.jsonld` for `@context` and type/term resolution.

See [schema-extension/README.md](schema-extension/README.md) for entity and attribute details, and [examples/README.md](examples/README.md) for flow-wise payload descriptions.
