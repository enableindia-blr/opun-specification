# OPuN Verifiable Credential Flow — Pre-Authorized Code 

**Document purpose:** Schema and flow reference for OpenID4VCI credential issuance and OpenID4VP presentation using **pre-authorized code only**. 

**Scope:** Issuer (GroclakeVC), Holder (Opungram Wallet), Verifier (Rang De). Credential format: **dc+sd-jwt** only.

---

## 1. Actors and Roles

| Actor | Role | Responsibility |
|-------|------|-----------------|
| **Issuer** | OpenID4VCI Credential Issuer | Publishes metadata, creates credential offers with pre-authorized code, issues signed VC (dc+sd-jwt). |
| **Holder / Wallet** | OpenID4VCI + OpenID4VP wallet | Receives offer, gets nonce, sends credential request with proof, stores VC, builds VP for verifier. |
| **Verifier** | OpenID4VP Relying Party (e.g. Rang De) | Sends presentation request with `presentation_definition`; verifies VP and embedded VC. |
| **Identity Manager** | DID registry / trust anchor | Stores and serves DID documents (e.g. `did:web`) for signature verification. |
| **DID Resolver** | — | Resolves DID documents for issuer and holder (used by Issuer/Verifier). |

---

## 2. Pre-Authorized Code Flow (High-Level)

We use **only** the pre-authorized code flow. No authorization code or user PIN.

Two ways credential issuance can start:
- **Flow A — Issuer-initiated:** Issuer creates a credential offer (e.g. QR or deep link) and the Holder receives it via the Wallet.
- **Flow B — Holder-initiated:** Holder (via Wallet) requests a credential from a known Issuer and configuration (e.g. from a catalog or deep link); no offer is pushed first.

In both cases, the Wallet then fetches issuer metadata, obtains a nonce, and sends a credential request with proof to receive the credential.

---

### Flow A — Issuer-Initiated (Offer → Wallet → Credential)

Issuer creates and delivers the credential offer; Holder opens it in the Wallet, which then runs the pre-auth issuance steps.

```mermaid
sequenceDiagram
    participant Issuer
    participant Wallet as Holder Wallet
    participant Verifier

    Note over Issuer,Wallet: Issuer creates offer and delivers to Holder (QR / link / API)
    Issuer->>Wallet: 1. Credential Offer (pre-authorized_code, credential_configuration_ids)
    Wallet->>Issuer: 2. GET /.well-known/openid-credential-issuer
    Issuer->>Wallet: 3. Issuer Metadata
    Wallet->>Issuer: 4. POST /cred/nonce
    Issuer->>Wallet: 5. c_nonce
    Wallet->>Issuer: 6. POST /cred/credential (proof with c_nonce)
    Issuer->>Wallet: 7. Credential Response (credential + disclosures)

    Note over Wallet,Verifier: Presentation (OpenID4VP)
    Verifier->>Wallet: 8. Presentation Request
    Wallet->>Verifier: 9. VP Token (VP response)
```

---

### Flow B — Holder-Initiated (Wallet Requests Credential)

Holder (via Wallet) starts the flow: Wallet already has or obtains `credential_issuer` and `credential_configuration_id` (e.g. from app context or user choice). No offer from Issuer is required to begin.

```mermaid
sequenceDiagram
    participant Holder
    participant Wallet as Holder Wallet
    participant Issuer
    participant Verifier

    Note over Holder,Wallet: Holder chooses to request a credential (e.g. from catalog / issuer list)
    Holder->>Wallet: Request credential (issuer + configuration_id)
    Wallet->>Issuer: 1. GET /.well-known/openid-credential-issuer
    Issuer->>Wallet: 2. Issuer Metadata
    Wallet->>Issuer: 3. POST /cred/nonce
    Issuer->>Wallet: 4. c_nonce
    Wallet->>Issuer: 5. POST /cred/credential (proof with c_nonce, pre-auth if required)
    Issuer->>Wallet: 6. Credential Response (credential + disclosures)
    Wallet->>Holder: Credential stored

    Note over Wallet,Verifier: Presentation (OpenID4VP)
    Verifier->>Wallet: 7. Presentation Request
    Wallet->>Verifier: 8. VP Token (VP response)
```

---

**Pre-auth–specific points:**
- **Flow A:** Offer contains `grants.urn:ietf:params:oauth:grant-type:pre-authorized_code` with `pre-authorized_code` and `user_pin_required: false`. No separate auth server or login.
- **Flow B:** Wallet may use a pre-authorized code obtained out-of-band (e.g. from a prior link or API) or an issuer-specific mechanism; no authorization server token exchange.
- **Endpoints used:** `/.well-known/openid-credential-issuer`, `/cred/nonce`, `/cred/credential`, and optionally `/cred/notification`.

---

## 3. Schema Reference 

Each subsection gives: **purpose**, **key descriptions**, and **full schema/example**.

---

### 3.1 Issuer Metadata (Discovery)

**Purpose:** Describes issuer capabilities and credential configurations. Wallet fetches this from `GET {credential_issuer}/.well-known/openid-credential-issuer` (or equivalent path).

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `credential_issuer` | Yes | Base URL of the credential issuer (no trailing slash). |
| `credential_endpoint` | Yes | Path or URL for POST credential requests (e.g. `/cred/credential`). |
| `nonce_endpoint` | Yes (for proof) | Path or URL for GET/POST to obtain `c_nonce` (e.g. `/cred/nonce`). |
| `authorization_servers` | No | Empty for pre-auth-only; no separate AS. |
| `credential_configurations_supported` | Yes | Map of configuration_id → configuration object. |
| `credential_configurations_supported.<id>.format` | Yes | `"dc+sd-jwt"` for SD-JWT VC. |
| `credential_configurations_supported.<id>.scope` | No | Scope name (e.g. `CourseCertificate`) for display/identification. |
| `credential_configurations_supported.<id>.vct` | Yes | Credential type URI (e.g. `https://opun.network/vct/course-certificate`). Must not be empty. |
| `credential_configurations_supported.<id>.proof_types_supported` | Yes | Proof type for credential request; we use `jwt` with `proof_signing_alg_values_supported: ["ES256"]`. |
| `credential_configurations_supported.<id>.credential_signing_alg_values_supported` | No | Issuer signing alg; we use `["ES256"]`. |
| `credential_configurations_supported.<id>.cryptographic_binding_methods_supported` | No | e.g. `["jwk"]`. |
| `credential_configurations_supported.<id>.credential_metadata` | No | `claims` and `display` for wallet UI. |
| `display` | No | Issuer-level display (name, locale, description, background_color). |
| `notification_endpoint` | No | Optional status/notification endpoint (e.g. `/cred/notification`). |
| `deferred_credential_endpoint` | No | Optional deferred issuance. |
| `credential_request_encryption` / `credential_response_encryption` | No | Optional; we use `encryption_required: false`. |

**Schema (example):**

```json
{
  "credential_issuer": "https://issuer-plotch.opun.network",
  "credential_endpoint": "/cred/credential",
  "nonce_endpoint": "/cred/nonce",
  "authorization_servers": [],
  "notification_endpoint": "/cred/notification",
  "deferred_credential_endpoint": "/cred/deferred_credential",
  "display": {
    "name": "Course Certificate",
    "locale": "en-IN",
    "description": "Course certificate issued via Dhiway",
    "background_color": "#0b8043"
  },
  "credential_request_encryption": {
    "jwks": [],
    "encryption_required": false,
    "enc_values_supported": ["A128GCM"],
    "zip_values_supported": ["DEF"]
  },
  "credential_response_encryption": {
    "encryption_required": false,
    "alg_values_supported": ["ECDH-ES"],
    "enc_values_supported": ["A128GCM"],
    "zip_values_supported": ["DEF"]
  },
  "credential_configurations_supported": {
    "65b25749-8312-4023-85bf-ddb509478f95": {
      "format": "dc+sd-jwt",
      "scope": "CourseCertificate",
      "vct": "https://opun.network/vct/course-certificate",
      "credential_signing_alg_values_supported": ["ES256"],
      "cryptographic_binding_methods_supported": ["jwk"],
      "proof_types_supported": {
        "jwt": {
          "proof_signing_alg_values_supported": ["ES256"]
        }
      },
      "credential_metadata": {
        "claims": {
          "usn": { "display": [{ "name": "USN", "locale": "en-IN" }] },
          "name": { "display": [{ "name": "Participant Name", "locale": "en-IN" }] },
          "email": { "display": [{ "name": "Email", "locale": "en-IN" }] },
          "event": { "display": [{ "name": "Course name", "locale": "en-IN" }] },
          "grade": { "display": [{ "name": "Grade or Rank", "locale": "en-IN" }] },
          "cert_id": { "display": [{ "name": "Certificate ID", "locale": "en-IN" }] },
          "duration": { "display": [{ "name": "Duration of the course", "locale": "en-IN" }] },
          "end_date": { "display": [{ "name": "End date", "locale": "en-IN" }] },
          "cert_name": { "display": [{ "name": "Certification name", "locale": "en-IN" }] },
          "issue_date": { "display": [{ "name": "Issue date", "locale": "en-IN" }] },
          "start_date": { "display": [{ "name": "Start date", "locale": "en-IN" }] }
        },
        "display": {
          "name": "Course Certificate",
          "locale": "en-IN",
          "description": "Course certificate issued via Dhiway",
          "background_color": "#0b8043"
        }
      }
    }
  }
}
```

---

### 3.2 Credential Offer (Pre-Authorized Code)

**Purpose:** Invitation from Issuer to Wallet to start issuance. Conveyed via QR, deep link, or API. Contains the pre-authorized code and which credential configuration(s) are offered.

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `credential_issuer` | Yes | Same as in issuer metadata; base URL of issuer. |
| `credential_configuration_ids` | Yes | Array of configuration IDs the wallet may request (from `credential_configurations_supported`). |
| `grants` | Yes | Must include pre-authorized code grant. |
| `grants.urn:ietf:params:oauth:grant-type:pre-authorized_code` | Yes | Object containing the pre-authorized code. |
| `grants....pre-authorized_code` | Yes | Single-use code issued by the Issuer for this offer. |
| `grants....user_pin_required` | No | We use `false` (no user PIN). |
| `issuer_did` | No (recommended) | Issuer DID for the credential `iss` claim (e.g. `did:key:...` or `did:web:...`). |

**Schema (example):**

```json
{
  "credential_issuer": "https://issuer-plotch.opun.network",
  "credential_configuration_ids": [
    "65b25749-8312-4023-85bf-ddb509478f95"
  ],
  "grants": {
    "urn:ietf:params:oauth:grant-type:pre-authorized_code": {
      "pre-authorized_code": "mx_zA35A34Lfb3k4sw69V1fC925hO8vTyZdyeB2VCy8",
      "user_pin_required": false
    }
  },
  "issuer_did": "did:key:z6Mkc2e03b619db940c1"
}
```

**Pre-auth flow:** Wallet does **not** call an authorization server. It uses this offer to learn `credential_issuer` and `credential_configuration_ids`, then calls `/cred/nonce` and `/cred/credential` (and optionally `/cred/notification`).

---

### 3.3 Nonce Request and Response

**Purpose:** Wallet obtains a short-lived `c_nonce` from the Issuer to include in the proof of possession when requesting the credential.

**Request:** `GET` or `POST` to `{credential_issuer}{nonce_endpoint}` (e.g. `GET /cred/nonce`). No body required for GET.

**Response keys:**

| Key | Required | Description |
|-----|----------|-------------|
| `c_nonce` | Yes | Fresh nonce for the credential request proof. |
| `c_nonce_expires_in` | No | Lifetime of the nonce in seconds (e.g. 3600). |

**Example response:**

```json
{
  "c_nonce": "-7iiFfBzJj5pxeEZJKW4ow",
  "c_nonce_expires_in": 3600
}
```

---

### 3.4 Credential Request (POST /cred/credential)

**Purpose:** Wallet requests issuance of a credential. Must include a proof JWT bound to the holder’s key and the Issuer’s `c_nonce`.

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `credential_configuration_id` | Yes | One of the IDs from the offer’s `credential_configuration_ids`. |
| `format` | Yes | `"dc+sd-jwt"`. |
| `proof` | Yes | Proof of possession of the key that will hold the credential. |
| `proof.proof_type` | Yes | `"jwt"`. |
| `proof.jwt` | Yes | JWT containing at least `iss` (holder DID), `aud` (issuer or credential_issuer), `nonce` (c_nonce), `iat`, optional `exp`. Signed with holder’s private key (ES256). |

**Schema (example):**

```json
{
  "credential_configuration_id": "65b25749-8312-4023-85bf-ddb509478f95",
  "format": "dc+sd-jwt",
  "proof": {
    "proof_type": "jwt",
    "jwt": "eyJhbGciOiJFUzI1NiJ9.<payload>.<signature>"
  }
}
```

**Pre-auth:** Request is authorized by the Issuer’s acceptance of the pre-authorized code (e.g. sent in a header or validated out-of-band). No access token from an authorization server is required in this document’s flow.

---

### 3.5 Credential Response (Issued VC)

**Purpose:** Issuer returns the issued SD-JWT credential and disclosures. Used as the credential response body for successful issuance.

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `format` | Yes | `"dc+sd-jwt"`. |
| `credential` | Yes | Compact serialization: SD-JWT (JWT + optional disclosure strings joined by `~`). |
| `disclosures` | Yes (for dc+sd-jwt) | Array of base64url-encoded disclosure strings, each `[salt, claim_name, claim_value]`. |
| `c_nonce` | No | New nonce for a subsequent credential request. |
| `c_nonce_expires_in` | No | Lifetime of the new c_nonce. |

**Schema (example):**

```json
{
  "format": "dc+sd-jwt", 
  "credential": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkaWQ6d2ViOmRpZC1wbG90Y2gub3B1bi5uZXR3b3JrOmFnYWNoZTphZ2VudDppZGVudGl0eTppZDoyMzUzYzZiNCIsInN1YiI6ImRpZDprZXk6ejZNa2IzODU1M2IxMTRmMTRhYzYiLCJpYXQiOjE3NzI0MzUyNTQsImV4cCI6MTgwMzk3MTI1NCwidmN0IjoiaHR0cHM6Ly9vcHVuLm5ldHdvcmsvdmN0L2lkZW50aXR5LWNhcmQiLCJjcmVkZW50aWFsU3ViamVjdCI6eyJwaG9uZSI6Ijk4MzM5MzMzNDUiLCJmdWxsX25hbWUiOiJWaWtyYW0iLCJpc19vdmVyXzE4IjoiMTgrIiwiX3NkIjpbIld6NXhwTzFCMktyck54M3NiNUJBUlRWZ0VTRkZVcE15TENkV1p0MEp3RWciLCJsVS1TQlV1OUJ0cHhVS0lHdVpvZzhFZXpVX3JGS0x4TTNYcHZFX01nellZIiwiNDNhb2RVc21NNjBRX2RtYWxtODM0eFpsaEJpdUpuVGUtMlVzMkt5bHJLYyJdfX0.PoY5_j6A6w9GKi4Tkbc4cSv8MoaRpZngE5QTv-NxnPuE0lDW6NVYWEOWbPCd_gjVePtsiUm6XvNSGgsnJ-ufFQ",
  "disclosures": [
    "WyI2a3lyWnh2dlppaGE0ZU45aFVvRjFRIiwicGhvbmUiLCI5ODMzOTMzMzQ1Il0",
    "WyJrakV1UUQ4WFRZU01CM2hJVkJwS1JnIiwiZnVsbF9uYW1lIiwiVmlrcmFtIl0",
    "WyJCTWRKcmFOMklaMHRBdDhrYWRnQ2NRIiwiaXNfb3Zlcl8xOCIsIjE4KyJd"
  ],
  "c_nonce": "-7iiFfBzJj5pxeEZJKW4ow",
  "c_nonce_expires_in": 3600
}
```

---

### 3.6 Issued VC (SD-JWT) — Decoded Payload and Disclosures

**Purpose:** Defines the structure of the SD-JWT payload (before disclosure hashes) and the format of each disclosure for schema review.

**VC JWT payload (decoded) — key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `iss` | Yes | Issuer DID (e.g. `did:web:...` or `did:key:...`). |
| `sub` | Yes | Holder (subject) DID (e.g. `did:key:...`). |
| `iat` | Yes | Issued-at time (Unix). |
| `exp` | Yes | Expiration time (Unix). |
| `vct` | Yes | Credential type URI; MUST be non-empty (e.g. `https://opun.network/vct/course-certificate`). |
| `credentialSubject` | Yes | Object. For selective disclosure, contains disclosed claims and/or `_sd` array of disclosure hashes. |

**Disclosure format:** Each disclosure is base64url(JSON array of three elements):
- `[0]` — salt (string)
- `[1]` — claim name (string)
- `[2]` — claim value (any JSON type)

**Example — decoded VC payload:**

```json
{
  "iss": "did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4",
  "sub": "did:key:z6Mkb38553b114f14ac6",
  "iat": 1772435254,
  "exp": 1803971254,
  "vct": "https://opun.network/vct/identity-card",
  "credentialSubject": {
    "_sd": [
      "Wz5xpO1B2KrrNx3sb5BARTVgESFFUpMyLCdWZt0JwEg",
      "lU-SBUu9BtpxUKIGuZog8EezU_rFKLxM3XpvE_MgzYY",
      "43aodUsmM60Q_dmalm834xZlhBiuJnTe-2Us2KylrKc"
    ]
  }
}
```

**Example — decoded disclosures (array of [salt, name, value]):**

```json
[
  ["6kyrZxvvZiha4eN9hUoF1Q", "phone", "9833933345"],
  ["kjEuQD8XTYSMB3hIVBpKRg", "full_name", "Vikram"],
  ["BMdJraN2IZ0tAt8kadgCcQ", "is_over_18", "18+"]
]
```

**Guidelines for issuers:**
- `vct` MUST be a non-empty credential type URI.
- Sign with ES256; use `jwk` cryptographic binding for the holder.
- Disclosures MUST use unique salts and match the claims in `credentialSubject` (or flat claims, depending on encoding).

---

### 3.7 Presentation Request (Verifier → Wallet)

**Purpose:** Verifier (OpenID4VP) asks the Wallet for a verifiable presentation that satisfies a `presentation_definition`.

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `response_type` | Yes | `"vp_token"`. |
| `client_id` | Yes | Verifier’s DID (e.g. `did:key:...`). |
| `nonce` | Yes | Fresh nonce for the VP response (replay protection). |
| `state` | No | Opaque state for correlation. |
| `presentation_definition` | Yes | DIF Presentation Definition. |
| `presentation_definition.id` | No | Identifier for the definition. |
| `presentation_definition.input_descriptors` | Yes | Array of input descriptors; each may specify `format.dc+sd-jwt`. |
| `holder_did` | No | Hint of expected holder DID. |
| `purpose_statement` | No | Human-readable purpose (e.g. "Skill verification"). |

**Schema (example):**

```json
{
  "response_type": "vp_token",
  "client_id": "did:key:z6Mkf3c44dbeade64f58",
  "nonce": "nonce_1772274004939_uadszym924",
  "state": "PREQ_950E8A24",
  "presentation_definition": {
    "id": "verify_skill",
    "input_descriptors": [
      {
        "id": "skill",
        "format": {
          "dc+sd-jwt": {}
        }
      }
    ]
  },
  "purpose_statement": "Skill verification"
}
```

---

### 3.8 Verifiable Presentation (VP) Response (Wallet → Verifier)

**Purpose:** Wallet returns a VP token (SD-JWT credential + key binding) and a presentation submission that maps to the presentation definition.

**Key explanations:**

| Key | Required | Description |
|-----|----------|-------------|
| `vp_token` | Yes | Object containing the VP payload. |
| `vp_token.format` | Yes | `"dc+sd-jwt"`. |
| `vp_token.credentials` | Yes | Array of one or more SD-JWT credential strings (JWT + `~` + optional disclosures). |
| `vp_token.key_binding` | Yes | JWT proving the holder’s control of the key; contains `iss` (holder), `aud` (verifier), `nonce` (from request), `iat`, `exp`. |
| `presentation_submission` | Yes | Links submitted VCs to the request. |
| `presentation_submission.id` | Yes | Unique submission id. |
| `presentation_submission.definition_id` | No | Id of the presentation_definition satisfied. |
| `presentation_submission.descriptor_map` | Yes | Array of descriptor maps; each has `id`, `path` (e.g. `$.vp_token.credentials[0]`), `format` (`dc+sd-jwt`). |

**Schema (example):**

```json
{
  "vp_token": {
    "format": "dc+sd-jwt",
    "credentials": [
      "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkaWQ6d2ViOmRpZC1wbG90Y2gub3B1bi5uZXR3b3JrOmFnYWNoZTphZ2VudDppZGVudGl0eTppZDoyMzUzYzZiNCIsInN1YiI6ImRpZDprZXk6ejZNazZiOWZiNTEzODg0ZjQ5MjAiLCJpYXQiOjE3NjkxMzI0NTksImV4cCI6MTgwMDY2ODQ1OSwidmN0IjoiIiwiY3JlZGVudGlhbFN1YmplY3QiOnsic2tpbGxfbmFtZSI6InB5dGhvbiIsInByb2ZpY2llbmN5IjoiRW5nbGlzaCIsIl9zZCI6WyJfVjNwSm5xNzNzSmZ4bmk2S3NyY2pDMy1VZ3ZzQzRwUUd0dHVqdmE1cWRrIiwiUmJiblNrbE9KaTQ2R2poMFlhbWVWb1RPYS1YMlN3R1BjUldmUkwtdkltWSJdfX0.tK3J77ck-pFQoTmRWDCDeKjtdkLcTlZOmfTzpVXC-xhJV6MqbanNoyxaEWV7FtH-JrKrPOBcI3zeFAg8IXrF7Q~WyIyVWJHeXJDNmtsenFjVlZIN0dzTG1nIiwic2tpbGxfbmFtZSIsInB5dGhvbiJd"
    ],
    "key_binding": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkaWQ6a2V5Ono2TWs2YjlmYjUxMzg4NGY0OTIwIiwiYXVkIjoiZGlkOmtleTp6Nk1rZjNjNDRkYmVhZGU2NGY1OCIsIm5vbmNlIjoibm9uY2VfMTc2OTE1MjQ4MzczMl9qOXhibzNkb21xIiwiaWF0IjoxNzY5MTMzMjI5LCJleHAiOjE3NjkxMzY4Mjl9.OTGQ5aJlA_rUaKpX25D_Riy9Y9cuB1iPUBIx1wIWreKG_y_gNrp4GFeoe-F05x4S2FE2J5CMnQieXWWy0W9Caw"
  },
  "presentation_submission": {
    "id": "PRES_1769133229_816b9b73",
    "definition_id": null,
    "descriptor_map": [
      {
        "id": "desc_0",
        "path": "$.vp_token.credentials[0]",
        "format": "dc+sd-jwt"
      }
    ]
  }
}
```

---

## 4. Credential Format: dc+sd-jwt

We use **only** the **dc+sd-jwt** format (Selective Disclosure JWT Verifiable Credential).

- **dc** = digital credential  
- **sd-jwt** = selective disclosure JWT (IETF SD-JWT VC)

**Payload rules:**
- **vct** MUST be a non-empty credential type URI (e.g. `https://opun.network/vct/course-certificate`).
- **iss** = Issuer DID; **sub** = Holder DID.
- Claims may be in `credentialSubject` with `_sd` for selective disclosure, or flat at top level depending on encoding.
- Signing: **ES256**; cryptographic binding: **jwk**.

---

## 5. DID Methods and Resolution

**Issuer (e.g. Plotch):** `did:web`

- Example: `did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4`
- Resolution: `https://did-plotch.opun.network/agache/agent/identity/id/2353c6b4/did.json`
- Use: Stable, web-resolvable DID for issuers and trust anchors.

**Holder / subject:** `did:key`

- Example: `did:key:z6Mkb38553b114f14ac6`
- Resolution: Public key is embedded in the DID string; no HTTP resolution required.
- Use: Holder-controlled key material without a required web endpoint.

**DID document example (issuer, did:web):**

```json
{
  "@context": ["https://www.w3.org/ns/did/v1"],
  "id": "did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4",
  "verificationMethod": [
    {
      "controller": "did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4",
      "id": "did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4#keys-1",
      "publicKeyJwk": {
        "alg": "ES256",
        "crv": "P-256",
        "kty": "EC",
        "use": "sig",
        "x": "dqTx2uRvRL52ZCjQB1Pxasj-HMt3LGPc1nfbTrb3H-w",
        "y": "bIeDTMNErcT68uQgCWzZB0sP3undT2VZJNIgN0Sl5jg"
      },
      "type": "JsonWebKey2020"
    }
  ]
}
```

---

## 6. Pre-Auth Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/.well-known/openid-credential-issuer` | GET | Issuer metadata (discovery). |
| `/cred/nonce` | GET or POST | Obtain `c_nonce` for credential request proof. |
| `/cred/credential` | POST | Request credential (with proof); response = Credential Response (3.5). |
| `/cred/notification` | POST | Optional status/notification. |

No authorization server or token endpoint is used in the pre-authorized code flow described here.

---

## 7. Document History

- Reorganized for schema reviewers; pre-authorized code flow only; dc+sd-jwt only.
- Key-level explanations and full schemas added for all issuance and presentation messages.
