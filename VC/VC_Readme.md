

## Flow overview

1. **Issuer** — OpenID4VCI Credential Issuer: publishes metadata, creates credential offers, issues VC-JWT.
2. **Holder wallet** — OpenID4VCI wallet,  key holder, consent manager: requests credential, stores VC, builds VP-JWT for verifier.
3. **Verifier (Rang De)** — OpenID4VP Relying Party: sends authorization request with presentation_definition; verifies VP and embedded VC.
4. **DID Resolver** — Resolves DID documents for signature verification (holder and issuer).
5. **Identity Manager (Plotch)** — DID registry / trust anchor: stores and serves DID documents.


## 1. Issuer — (OpenID4VCI Credential Issuer)

**Role:** Exposes OpenID4VCI metadata, issues credential offers (e.g. via QR/API), and returns signed VC-JWT in response to a valid credential request.

### 1.1 Issuer metadata (OpenID4VCI)

**schema:**

```json
{
  "display": {
    "name": "Course Certificate",
    "locale": "en-IN",
    "description": "Course certificate issued via Dhiway",
    "background_color": "#0b8043"
  },
  "nonce_endpoint": "/cred/nonce",
  "credential_issuer": "https://issuer-plotch.opun.network",
  "credential_endpoint": "/cred/credential",
  "authorization_servers": [],
  "notification_endpoint": "/cred/notification",
  "deferred_credential_endpoint": "/cred/deferred_credential",
  "credential_request_encryption": {
    "jwks": [],
    "encryption_required": false,
    "enc_values_supported": [
      "A128GCM"
    ],
    "zip_values_supported": [
      "DEF"
    ]
  },
  "credential_response_encryption": {
    "encryption_required": false,
    "alg_values_supported": [
      "ECDH-ES"
    ],
    "enc_values_supported": [
      "A128GCM"
    ],
    "zip_values_supported": [
      "DEF"
    ]
  },
  "credential_configurations_supported": {
    "65b25749-8312-4023-85bf-ddb509478f95": {
      "vct": "https://opun.network/vct/course-certificate",
      "scope": "CourseCertificate",
      "format": "dc+sd-jwt",
      "credential_metadata": {
        "claims": {
          "usn": {
            "display": [
              {
                "name": "USN",
                "locale": "en-IN"
              }
            ]
          },
          "name": {
            "display": [
              {
                "name": "Participant Name",
                "locale": "en-IN"
              }
            ]
          },
          "email": {
            "display": [
              {
                "name": "Email",
                "locale": "en-IN"
              }
            ]
          },
          "event": {
            "display": [
              {
                "name": "Course name",
                "locale": "en-IN"
              }
            ]
          },
          "grade": {
            "display": [
              {
                "name": "Grade or Rank",
                "locale": "en-IN"
              }
            ]
          },
          "cert_id": {
            "display": [
              {
                "name": "Certificate ID",
                "locale": "en-IN"
              }
            ]
          },
          "duration": {
            "display": [
              {
                "name": "Duration of the course",
                "locale": "en-IN"
              }
            ]
          },
          "end_date": {
            "display": [
              {
                "name": "End date",
                "locale": "en-IN"
              }
            ]
          },
          "cert_name": {
            "display": [
              {
                "name": "Certification name",
                "locale": "en-IN"
              }
            ]
          },
          "issue_date": {
            "display": [
              {
                "name": "Issue date",
                "locale": "en-IN"
              }
            ]
          },
          "start_date": {
            "display": [
              {
                "name": "Start date",
                "locale": "en-IN"
              }
            ]
          }
        },
        "display": {
          "name": "Course Certificate",
          "locale": "en-IN",
          "description": "Course certificate issued via Dhiway",
          "background_color": "#0b8043"
        }
      },
      "proof_types_supported": {
        "jwt": {
          "proof_signing_alg_values_supported": [
            "ES256"
          ]
        }
      },
      "credential_signing_alg_values_supported": [
        "ES256"
      ],
      "cryptographic_binding_methods_supported": [
        "jwk"
      ]
    }
  }
}

```

### 1.2 Credential offer (QR/API)


**schema**

```json
{
  "grants": {
    "urn:ietf:params:oauth:grant-type:pre-authorized_code": {
      "user_pin_required": false,
      "pre-authorized_code": "mx_zA35A34Lfb3k4sw69V1fC925hO8vTyZdyeB2VCy8"
    }
  },
  "issuer_did": "did:key:z6Mkc2e03b619db940c1",
  "credential_issuer": "https://issuer-plotch.opun.network",
  "credential_configuration_ids": [
    "65b25749-8312-4023-85bf-ddb509478f95"
  ]
}
```

grant type -> pre-authorized_code

format -> dc+sd-jwt

configuration id -> "65b25749-8312-4023-85bf-ddb509478f95"

For pre-auth, the wallet will call:

```json
/cred/nonce
/cred/credential
/cred/notification
```


### 1.3 Issued credential (VC-JWT)
for dc+sd-jwt, the payload must be flat claims + iss + sub + vct

**schema:**



Credential Response:
```json
{
  "format": "dc+sd-jwt",
  "credential": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkaWQ6d2ViOmRpZC1wbG90Y2gub3B1bi5uZXR3b3JrOmFnYWNoZTphZ2VudDppZGVudGl0eTppZDoyMzUzYzZiNCIsInN1YiI6ImRpZDprZXk6ejZNa2IzODU1M2IxMTRmMTRhYzYiLCJpYXQiOjE3NzI0MTY2OTQsImV4cCI6MTgwMzk1MjY5NCwidmN0IjoiIiwiY3JlZGVudGlhbFN1YmplY3QiOnsic2tpbGxfbmFtZSI6IkxlYWRlcnNoaXAiLCJwcm9maWNpZW5jeSI6IkV4Y2VsbGVudCIsIl9zZCI6WyJCdnRVVTdteXBCWUIyb29rTjlLOG5zMDBDdnBQclc1Wl8wWFItVEhMTTl3IiwiUjFBYmNSRm1JemJ0bU84eFBrUE04R20xeGRPUkRWUkxnQ3hMSUMtY0VaRSJdfX0.JFizHPmBhO2WVoH968gU7rvfyVE9pc8h5BeT6WZNChBbO5FGZRTa6PBTWkyQSEpDe8pzKizKzPSunsRmkpCiOQ",
  "disclosures": [
      "WyI1UG00WkZqOUxGT2VhWkY1RGlrMmh3Iiwic2tpbGxfbmFtZSIsIkxlYWRlcnNoaXAiXQ",
      "WyJRTDRQQ1gxTlZSR3ZFNWhBaTIxZkNnIiwicHJvZmljaWVuY3kiLCJFeGNlbGxlbnQiXQ"
    ]
}
```
Decoded
```json
{
  "exp": 1803809277,
  "iat": 1772273277,
  "iss": "did:web:did-plotch.opun.network:agache:agent:identity:id:2353c6b4",
  "sub": "did:key:z6Mkb38553b114f14ac6",
  "vct": "",
  "credentialSubject": {
    "skill_name": "Leadership",
    "proficiency": "Excellent"
  }
}
```
Decode disclosure 
```json
WyI1UG00WkZqOUxGT2VhWkY1RGlrMmh3Iiwic2tpbGxfbmFtZSIsIkxlYWRlcnNoaXAiXQ
[
  "5Pm4ZFj9LFOeaZF5Dik2hw",
  "skill_name",
  "Leadership"
]

[salt, name, value]
```

Problem:
This should be 
```json

"vct": "https://opun.network/vct/skill-certificate"

```


This is correct:
```json

{
  "iss": "did:key:z6Mkc2e03b619db940c1",
  "sub": "did:key:z6Mkb38553b114f14ac6",
  "vct": "https://opun.network/vct/course-certificate",
  "usn": "13",
  "name": "Vikram Tarniprasad Acharya",
  "email": "vikram@plotch.ai",
  "event": "CC",
  "grade": "A",
  "cert_id": "CERT-2026-52375",
  "cert_name": "Web Development Fundamentals",
  "duration": "40",
  "start_date": "2026-02-10",
  "end_date": "2026-02-10",
  "issue_date": "2026-02-17"
}

```

For SD-JWT VC, spec requires:
vct = credential type identifier




## 2. Holder —  VC Wallet (Plotch VC App + Wallet Server)

**Role:** OpenID4VCI wallet (receives offers, requests credentials), OpenID4VP wallet (builds presentations), key holder (signs proof and VP), consent manager (stores consent context).

### 2.1 Credential request


**schema**

```json
{
  "credential_configuration_id": "65b25749-8312-4023-85bf-ddb509478f95",
  "format": "dc+sd-jwt",
  "proof": {
    "proof_type": "jwt",
    "jwt": "eyJhbGciOiJFUzI1NiJ9..."
  }
}

```

### 2.2 Credential response

**schema**

```json

{
  "format": "dc+sd-jwt",
  "credential": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...",
  "c_nonce": "-7iiFfBzJj5pxeEZJKW4ow",
  "c_nonce_expires_in": 3600
}

```

```json

{
    "credential": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkaWQ6d2ViOmRpZC1wbG90Y2gub3B1bi5uZXR3b3JrOmFnYWNoZTphZ2VudDppZGVudGl0eTppZDoyMzUzYzZiNCIsInN1YiI6ImRpZDprZXk6ejZNa2IzODU1M2IxMTRmMTRhYzYiLCJpYXQiOjE3NzI0MTY2OTQsImV4cCI6MTgwMzk1MjY5NCwidmN0IjoiIiwiY3JlZGVudGlhbFN1YmplY3QiOnsic2tpbGxfbmFtZSI6IkxlYWRlcnNoaXAiLCJwcm9maWNpZW5jeSI6IkV4Y2VsbGVudCIsIl9zZCI6WyJCdnRVVTdteXBCWUIyb29rTjlLOG5zMDBDdnBQclc1Wl8wWFItVEhMTTl3IiwiUjFBYmNSRm1JemJ0bU84eFBrUE04R20xeGRPUkRWUkxnQ3hMSUMtY0VaRSJdfX0.JFizHPmBhO2WVoH968gU7rvfyVE9pc8h5BeT6WZNChBbO5FGZRTa6PBTWkyQSEpDe8pzKizKzPSunsRmkpCiOQ",
    "disclosures": [
        "WyI1UG00WkZqOUxGT2VhWkY1RGlrMmh3Iiwic2tpbGxfbmFtZSIsIkxlYWRlcnNoaXAiXQ",
        "WyJRTDRQQ1gxTlZSR3ZFNWhBaTIxZkNnIiwicHJvZmljaWVuY3kiLCJFeGNlbGxlbnQiXQ"
    ],
    "format": "dc+sd-jwt"
}
```

### 2.3 Verifiable presentation Request

**schema**

```json


Presentation request:

{"client_id":"did:key:z6Mkf3c44dbeade64f58",
"holder_did":"did:key:z6Mkb38553b114f14ac6",
"nonce":"nonce_1772425475262_vfjuy2m8ce",
"purpose_statement":"Verify cred",
"response_type":"vp_token"}


{
  "nonce": "nonce_1772425324671_t8sn0w8ebu9",
  "client_id": "did:key:z6Mkf3c44dbeade64f58",
  "holder_did": "did:key:z6Mkb38553b114f14ac6", 
  "response_type": "vp_token", 
  "purpose_statement": "Skill verification"
}

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
  }
}

```

### Verifiable presentation 

This JSON is a VP Token response containing an SD-JWT credential + key binding proof + presentation submission mapping.

**schema**


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

"format": "dc+sd-jwt" (Selective Disclosure Verifiable Credential)
Meaning:
dc = digital credential
sd-jwt = selective disclosure JWT


