# Loan Domain – Example Payloads

This directory contains example request/response payloads for each Beckn 2.0 flow using the loan domain schema extension (`opun:loan`).

All examples use:

- `context.domain`: `opun:loan`
- `@context` / `schema_context`: [Beckn Core v2 context, Loan v1 context]

## Application Lifecycle (BAP-originated)

1. **BAP** creates the loan application locally with `loan_application_id` and status `DRAFT`.
2. **Init** — BAP sends the application (order with `loanApplicationId`, buyer, fulfillment, orderAttributes with form data). **BPP** creates an application at their end keyed by that ID and responds with **on_init** echoing the same data; status remains `DRAFT`.
3. **Confirm** — BAP verifies the echoed data from on_init and sends **confirm** with status `APPLICATION_SUBMITTED`. **on_confirm** — BPP verifies echo and transitions status from `DRAFT` to `APPLICATION_SUBMITTED`.
4. **Status / Update** — BAP may request status via **status**; BPP returns **on_status**. The loan provider pushes **unsolicited on_update** for status changes (e.g. UNDER_REVIEW, APPROVED, REJECTED, DISBURSED) or responds to **update** with **on_update**.

## Flow-to-file mapping

| Step | Action   | Request (BAP → BPP)     | Response (BPP → BAP)     |
|------|----------|--------------------------|---------------------------|
| 1    | Search   | `search/search.json`     | `search/on_search.json`   |
| 2    | Select   | `select/select.json`     | `select/on_select.json`   |
| 3    | Init     | `init/init.json`         | `init/on_init.json`       |
| 4    | Confirm  | `confirm/confirm.json`   | `confirm/on_confirm.json` |
| 5    | Status   | `status/status.json`     | `status/on_status.json`   |
| 6    | Update   | `update/update.json`     | `update/on_update.json`   |
| 7    | Cancel   | `cancel/cancel.json`     | `cancel/on_cancel.json`   |

## Payloads

### Search Flow

- **search.json** – BAP searches for loan products (filters: amount range, tenure, purpose, segment).
- **on_search.json** – BPP returns catalog with loan product items and loan domain attributes.

### Select Flow

- **select.json** – BAP selects a loan product to view details and application form.
- **on_select.json** – BPP returns full product details, application form (XInput), and provider info.

### Init Flow

- **init.json** – BAP sends the application (created at BAP with `loanApplicationId`). Order includes buyer, fulfillment (id = application id, status DRAFT), orderAttributes (applicationForm with formData, loanApplicationId, appliedDate), orderItems (selected loan product).
- **on_init.json** – BPP creates application against the same ID and echoes the received data; fulfillmentStatus and applicationStatus remain DRAFT.

### Confirm Flow

- **confirm.json** – BAP verifies echoed data and confirms with applicationStatus `APPLICATION_SUBMITTED`.
- **on_confirm.json** – BPP verifies echo and responds; BPP changes status from DRAFT to APPLICATION_SUBMITTED.

### Status Flow

- **status.json** – BAP requests current application/loan status.
- **on_status.json** – BPP returns current order and fulfillment with loanApplicationStatus (e.g. APPLICATION_SUBMITTED, UNDER_REVIEW, APPROVED).

### Update Flow

- **update.json** – BAP-initiated update (e.g. contact or document) or request for action.
- **on_update.json** – BPP response. Loan provider may also send **unsolicited on_update** to push status changes (e.g. UNDER_REVIEW, APPROVED, REJECTED, DISBURSED).

### Cancel Flow

- **cancel.json** – BAP or BPP cancels the application.
- **on_cancel.json** – Cancellation acknowledged; applicationStatus set to CANCELLED.

## Schema Reference

For entity definitions, attribute scopes, and lifecycle details, see the [Loan schema extension](../schema-extension/README.md) in this repository.
