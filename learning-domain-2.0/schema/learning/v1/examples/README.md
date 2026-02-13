# Learning Domain – Example Payloads

This directory contains example request/response payloads for each Beckn 2.0 flow, using the learning domain schema extension (`opun:learning`).

All examples use:
- `context.domain`: `opun:learning`
- `@context`: [Beckn Core v2 context, Learning v1 context]

## Payloads

### Search Flow

- **search.json** – Learner/BAP searches for courses by keyword, category, level, type, etc.
- **on_search.json** – BPP returns catalog with course offerings matching search criteria.

**Example search criteria:** Course category (technical), level (beginner), type (online).

### Select Flow

- **select.json** – Learner selects a specific course to view details and enrollment form.
- **on_select.json** – BPP returns detailed course information, fee quote, and XInput (enrollment form schema).

**Key elements:** Course details (schedule, prerequisites, learning objectives), enrollment form (XForms), fee structure.

### Init Flow

- **init.json** – Learner submits filled enrollment form with learner details, prerequisite verification, accessibility requirements.
- **on_init.json** – BPP acknowledges enrollment form submission, returns enrollment ID (pending confirmation).

**Key elements:** Learner profile, filled enrollment form (XInput data), prerequisite verification, accessibility metadata.

### Confirm Flow

- **confirm.json** – Learner confirms enrollment (after reviewing details).
- **on_confirm.json** – BPP confirms enrollment, enrollment status becomes `confirmed`, stage becomes `enrolled`.

**Key elements:** Enrollment confirmed, enrollment ID, enrollment status/stage updated.

### Status Flow

- **status.json** – Learner/BAP requests current enrollment status.
- **on_status.json** – BPP returns current enrollment state, progress percentage, last accessed content, completion status.

**Key elements:** Enrollment status (`pending`, `confirmed`, `in_progress`, `completed`, `cancelled`), enrollment stage (`applied`, `enrolled`, `started`, `in_progress`, `assessment`, `completed`), progress percentage, last accessed content.

### Update Flow

- **update.json** – Update enrollment (learner updates progress) or provider updates (schedule change, certificate issued).
- **on_update.json** – Update response (e.g., progress updated, certificate issued with verifiable credential).

**Update types:**
- `PROGRESS_UPDATE` – Learner progress on content items.
- `CERTIFICATE_ISSUED` – Certificate generated and issued on completion.

**Key elements:** Progress percentage, content completion status, certificate details (ID, PDF URL, verifiable credential ID, issuer/holder DID, share token).

### Cancel Flow

- **cancel.json** – Learner or provider cancels enrollment.
- **on_cancel.json** – Enrollment cancelled, status updated to `cancelled`.

**Key elements:** Cancellation reason, cancellation fee (if applicable), enrollment status updated.

## Enrollment Lifecycle

The examples demonstrate the complete enrollment lifecycle:

1. **Search** → Find courses
2. **Select** → View course details and enrollment form
3. **Init** → Submit enrollment form
4. **Confirm** → Enrollment confirmed (`pending` → `confirmed`, `applied` → `enrolled`)
5. **Status** → Track progress (`in_progress`, progress percentage)
6. **Update** → Progress updates, certificate issued (`completed`, certificate details)
7. **Cancel** → Cancel enrollment if needed (`cancelled`)

## Alignment with Implementation

These payloads align with:
- **groclake_learning_manager** – Course, enrollment, progress, certificate intents
- **groclake-frontend** (L&D) – Seller/provider course management and enrollment processing
- **opungram-frontend** (Training and courses) – Buyer/learner course browsing, enrollment, progress tracking

See [LEARNING_DOMAIN_SCHEMA_DESIGN.md](../../../LEARNING_DOMAIN_SCHEMA_DESIGN.md) for entity mapping and lifecycle details.
