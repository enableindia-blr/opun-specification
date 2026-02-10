# Learning Domain – Example Payloads

This directory will contain example request/response payloads for each Beckn 2.0 flow, using the learning domain schema extension.

Planned structure (to be populated):

- **discover/** – discover.json, on_discover.json, catalog_publish.json
- **search/** – search intent, on_search.json (catalog with courses)
- **select/** – select.json, on_select.json (course details + XInput for enrollment)
- **init/** – init.json, on_init.json (enrollment form submission)
- **confirm/** – confirm.json, on_confirm.json (enrollment confirmed)
- **status/** – status.json, on_status.json (enrollment state, progress)
- **update/** – update.json, on_update*.json (progress, certificate, cancellation)
- **support/** – support.json, on_support.json
- **cancel/** – cancel.json, on_cancel.json

All examples must use:

- `context.domain`: `opun:learning`
- `@context`: [Beckn Core v2 context, Learning v1 context]

See [LEARNING_DOMAIN_SCHEMA_DESIGN.md](../../../LEARNING_DOMAIN_SCHEMA_DESIGN.md) for entity mapping and lifecycle.
