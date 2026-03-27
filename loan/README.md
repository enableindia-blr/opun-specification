# Loan Domain

Schema specification for the **Loan** domain in OPuN networks. This domain covers loan product discovery, applications created at BAP and submitted via init, confirmation with echoed-data verification, and status updates (including unsolicited on_update from the loan provider) on Beckn Protocol v2.0.

## Scope

- **Loan product catalog** — Search and discovery of loan products (amount range, tenure, purpose, segment)
- **Application lifecycle** — Application is created at BAP; init sends it to BPP; BPP creates application against the same ID and echoes data in on_init; confirm verifies echo and submits (APPLICATION_SUBMITTED); on_confirm moves BPP status from DRAFT to APPLICATION_SUBMITTED
- **Status and updates** — Loan provider updates application/loan status via unsolicited on_update or in response to update

## Version

| Version | Path    | Status   |
|---------|---------|----------|
| v1      | `v1/`   | Current  |

See [v1/README.md](v1/README.md) for version layout and [v1/schema-extension/README.md](v1/schema-extension/README.md) for the schema definition.
