# Loan Domain — Schema Extension (v1)

This directory contains the **Loan** domain schema extension for OPuN networks on Beckn Protocol v2.0. It defines the JSON-LD context, vocabulary, and domain-specific attributes for loan products, applications (created at BAP, echoed in on_init, confirmed with APPLICATION_SUBMITTED), and status/update flows.

## Files

| File             | Description |
|------------------|-------------|
| **context.jsonld** | JSON-LD `@context`: term definitions, prefixes (`opun`, `beckn`, `schema`), and property/type mappings for the loan domain. |
| **vocab.jsonld**   | RDF vocabulary: types and terms used in loan payloads. |
| **attributes.yaml** | Domain-specific attributes with types, scopes (Item, Order, Fulfillment), and examples. |

## Domain Context

- **Base IRI:** `https://opun.network/schema/loan/v1/`
- **Domain in messages:** `opun:loan`

## Key Types and Entities

- **LoanProduct (Item)** — `LoanProduct`, `LoanPurpose`, `LoanType`, `RepaymentFrequency`; attributes such as `loanProductCode`, `loanProductName`, `principalMin`, `principalMax`, `interestRateAnnual`, `tenureMinMonths`, `tenureMaxMonths`, `repaymentFrequency`, `currency`, `targetSegments`.
- **Loan application (Order)** — `LoanApplicationAttributes`: `loanApplicationId`, `loanProductId`, `appliedPrincipal`, `appliedTenureMonths`, `applicationForm` (formData), `applicationStatus` (DRAFT, APPLICATION_SUBMITTED, etc.), `appliedDate`.
- **Fulfillment** — `LoanFulfillmentAttributes`: `loanApplicationStatus`, `loanAccountId` (post-disbursement), `sanctionedPrincipal`, `repaymentSchedule`, status updates from provider.

## Application Lifecycle (BAP-originated)

1. **BAP** creates the application locally with `loan_application_id` and status `DRAFT`.
2. **Init** — BAP sends application payload (order with `loanApplicationId`, buyer, fulfillment, orderAttributes with form data). BPP creates application at their end keyed by that ID and responds with **on_init** echoing the same data; status remains `DRAFT`.
3. **Confirm** — BAP verifies echoed data from on_init and sends **confirm** with status `APPLICATION_SUBMITTED`. **on_confirm** — BPP verifies echo, transitions status from `DRAFT` to `APPLICATION_SUBMITTED`.
4. **Status / Update** — BAP may request status via **status**; BPP returns **on_status**. Loan provider pushes **unsolicited on_update** for status changes (e.g. UNDER_REVIEW, APPROVED, REJECTED, DISBURSED) or responds to **update** with **on_update**.

## Attribute Scopes

- **Item** — Loan product catalog (e.g. `loanProductCode`, `loanProductName`, `principalMin`, `principalMax`, `interestRateAnnual`, `tenureMinMonths`, `tenureMaxMonths`, `repaymentFrequency`).
- **Order** — Application attributes (e.g. `loanApplicationId`, `loanProductId`, `appliedPrincipal`, `applicationForm`, `applicationStatus`, `appliedDate`).
- **Fulfillment** — Loan/account status and disbursement (e.g. `loanApplicationStatus`, `loanAccountId`, `sanctionedPrincipal`, `repaymentSchedule`).

## Usage

1. **In request/response payloads:** Include this extension’s context in `@context` or `schema_context`, e.g. the published URL for `context.jsonld`.
2. **Validation:** Validate payloads against the terms and structures defined in `context.jsonld` and `vocab.jsonld`, and attribute rules in `attributes.yaml`.

See the [examples/](../examples/README.md) directory for flow-wise sample payloads (search, select, init, confirm, status, update, cancel).
