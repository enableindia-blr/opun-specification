# opun:loan — Complete Journey (Search → Update)

```mermaid
sequenceDiagram
    participant C as Customer
    participant BAP as Buyer App
    participant BPP as Lender (BPP)
    participant LOS as Lender Core (LOS)

    
    C->>BAP: Search loans (amount, tenure, purpose)
    BAP->>BPP: /search (criteria/filters)
    BPP->>BAP: /on_search (catalog of loan products)
    BAP->>C: Show loan offers

    
    C->>BAP: Selects loan offer
    BAP->>BPP: /select (Item_ID)
    BPP->>BAP: /on_select (product details, XInput Form Index 1/2 - KYC)
    BAP->>C: Renders KYC form (PAN, DOB, etc.)
    Note right of BAP: BAP creates application (DRAFT, loan_application_id) when user starts apply

      
    C->>BAP: Submits KYC data
    BAP->>BPP: /init (order with loan_application_id, form data step 1)
    BPP->>LOS: Validate KYC and fetch credit score
    LOS-->>BPP: Success (next: income proof)
    BPP->>BAP: /on_init (XInput Form Index 2/2 - doc upload, status DRAFT)
    BAP->>C: Renders file upload (salary slips)
    C->>BAP: Uploads files
    BAP->>BPP: /init (XInput submission step 2)
    BPP->>LOS: Underwriting engine
    LOS-->>BPP: Approval and sanction terms
    BPP->>BAP: /on_init (quote: ROI, EMI, terms, status DRAFT)

    
    C->>BAP: Accept and submit application
    BAP->>BPP: /confirm (applicationStatus APPLICATION_SUBMITTED, signed terms)
    BPP->>BAP: /on_confirm (orderStatus ACTIVE, loanApplicationStatus APPLICATION_SUBMITTED)
    BAP->>C: Application submitted successfully

    
    BPP->>BAP: /on_update (loanApplicationStatus ADDITIONAL_INFO_REQUESTED, e.g. bank account)
    BAP->>C: Please provide account for disbursement
    C->>BAP: Enters bank details
    BAP->>BPP: /update (disbursement info)
    BPP->>BAP: /on_update (loanApplicationStatus DISBURSED)
    BAP->>C: Money credited
```

## Protocol alignment

- **Domain:** `opun:loan` (Beckn v2.0 extension).
- **Application:** BAP creates application (DRAFT, `loan_application_id`) before first /init; init sends order; BPP echoes in on_init; confirm sets APPLICATION_SUBMITTED; on_confirm moves BPP from DRAFT to APPLICATION_SUBMITTED.
- **Status values:** Use schema terms (e.g. APPLICATION_SUBMITTED, ADDITIONAL_INFO_REQUESTED, DISBURSED). Multi-step init (XInput form index) is optional; minimum flow is one init → on_init (echo) → confirm → on_confirm.

---

```mermaid
sequenceDiagram
    participant C as Customer
    participant BAP as Buyer App (Wallet)
    participant BPP as Lender (Verifier)
    participant LOS as Lender Core (LOS)

    Note over C, LOS: Phase 2: Selection & VC Request
    C->>BAP: Selects loan offer
    BAP->>BPP: /select (Item_ID)
    BPP->>BAP: /on_select (XInput: @type: VerifiableCredential, credentialVerification rules)
    
    Note right of BAP: BAP identifies VC request for "IdentityCredential"
    BAP->>C: Consent: "Share your Verified PAN & Identity with Lender?"
    C->>BAP: User authorizes (Consent & Share)

    Note over C, LOS: Phase 3: The 'init' Loop with VC Submission
    BAP->>BPP: /init (data: { verifiedCredentials: [signed_vp_jwt] })
    BPP->>BPP: Cryptographic Validation of VC Signature
    BPP->>LOS: Sync Verified Data (PAN, DOB) to LOS
    LOS-->>BPP: Success (next: Income Proof)
    
    BPP->>BAP: /on_init (XInput: Request Income VC OR Doc Upload)
    Note over BAP, BPP: Flow continues as per original flow...

```