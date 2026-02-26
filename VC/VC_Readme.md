

## Flow overview

1. **Issuer (Garv SE)** — OpenID4VCI Credential Issuer: publishes metadata, creates credential offers, issues VC-JWT.
2. **Holder (Salma’s wallet)** — OpenID4VCI wallet, OpenID4VP wallet, key holder, consent manager: requests credential, stores VC, builds VP-JWT for verifier.
3. **Verifier (Rang De)** — OpenID4VP Relying Party: sends authorization request with presentation_definition; verifies VP and embedded VC.
4. **DID Resolver** — Resolves DID documents for signature verification (holder and issuer).
5. **Identity Manager (Plotch)** — DID registry / trust anchor: stores and serves DID documents.


## 1. Issuer — Garv SE (OpenID4VCI Credential Issuer)

**Role:** Exposes OpenID4VCI metadata, issues credential offers (e.g. via QR/API), and returns signed VC-JWT in response to a valid credential request.

### 1.1 Issuer metadata (OpenID4VCI)

**Example (schema):**

```json
{
  "credential_issuer": "https://garvse.example.com",
  "authorization_server": "https://garvse.example.com",
  "credential_endpoint": "https://garvse.example.com/credential",
  "grant_types_supported": [
    "urn:ietf:params:oauth:grant-type:pre-authorized_code"
  ],
  "credential_configurations_supported": {
    "CourseCompletionCredential": {
      "format": "jwt_vc_json",
      "cryptographic_binding_methods_supported": ["jwk"],
      "credential_signing_alg_values_supported": ["ES256"]
    },
    "DisabilityCredential": {
      "format": "jwt_vc_json",
      "cryptographic_binding_methods_supported": ["jwk"],
      "credential_signing_alg_values_supported": ["ES256"]
    }
  }
}
```

### 1.2 Credential offer (QR/API)


**schema**

```json
{
  "credential_issuer": "https://garvse.example.com",
  "credential_configuration_ids": [
    "CourseCompletionCredential"
  ],
  "grants": {
    "urn:ietf:params:oauth:grant-type:pre-authorized_code": {
      "pre-authorized_code": "offer-code-123"
    }
  }
}
```
### 1.3 Issued credential (VC-JWT)


**schema:**

```json
{
  "iss": "https://garvse.example.com",
  "sub": "did:plotch:salma",
  "iat": 1700000000,
  "nbf": 1700000000,
  "jti": "urn:uuid:course-vc-id",
  "vc": {
    "@context": ["https://www.w3.org/2018/credentials/v1"],
    "type": [
      "VerifiableCredential",
      "CourseCompletionCredential"
    ],
    "credentialSubject": {
      "id": "did:plotch:salma",
      "name": "Salma",
      "course": "Digital Literacy",
      "grade": "A"
    }
  }
}
```

## 2. Holder — Salma’s VC Wallet (Plotch VC App + Wallet Server)

**Role:** OpenID4VCI wallet (receives offers, requests credentials), OpenID4VP wallet (builds presentations), key holder (signs proof and VP), consent manager (stores consent context).

### 2.1 Credential request

**schema**

```json
{
  "format": "jwt_vc_json",
  "credential_configuration_id": "CourseCompletionCredential",
  "proof": {
    "proof_type": "jwt",
    "jwt": "wallet-signed-proof-jwt"
  }
}
```

**Example – proof JWT payload (schema):**

```json
{
  "iss": "did:plotch:salma",
  "aud": "https://garvse.example.com/credential",
  "iat": 1700000000,
  "nonce": "issuer-nonce"
}
```

### 2.2 Stored VC object (internal storage)

### 2.3 Verifiable presentation (VP-JWT)


**schema**

```json
{
  "iss": "did:plotch:salma",
  "sub": "did:plotch:salma",
  "aud": "https://rangde.example.com",
  "iat": 1700000000,
  "nonce": "nonce-123",
  "vp": {
    "@context": ["https://www.w3.org/2018/credentials/v1"],
    "type": ["VerifiablePresentation"],
    "verifiableCredential": [
      "signed-course-vc-jwt"
    ]
  }
}
```

VP is a signed JWT (e.g. typ `vp+jwt`, alg ES256); payload includes iss, sub, aud, nonce, and vp.verifiableCredential as array of VC JWT strings. 


## 3. Verifier — Rang De (OpenID4VP Relying Party)

**Role:** Sends OpenID4VP authorization request with presentation_definition; receives vp_token; verifies VP and embedded VC(s).

### 3.1 Authorization request

**schema**

```json
{
  "response_type": "vp_token",
  "client_id": "https://rangde.example.com",
  "redirect_uri": "https://rangde.example.com/callback",
  "scope": "openid",
  "nonce": "nonce-123",
  "presentation_definition": {
    "id": "request-1",
    "input_descriptors": [
      {
        "format": {
          "jwt_vc_json": {
            "alg": ["ES256"]
          }
        }
      }
    ]
  }
}
```
