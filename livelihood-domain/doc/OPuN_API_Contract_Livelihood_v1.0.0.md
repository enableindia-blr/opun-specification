# OPuN API Contract for Livelihood Domain v1.0.0

## Version History

|---------|------------|--------------------------------------------------|
| Version |       Date | Changes                                          |
|---------|------------|--------------------------------------------------|
| 1.0.0   | 2024-12-10 | Initial version - Livelihood domain API contract |
|---------|------------|--------------------------------------------------|
---

## 1. Introduction

OPuN (A Decentralized, Consent-Based Open Network for Persons with Disabilities) establishes a unified protocol enabling structured data exchange for livelihood-related processes. This document outlines the specifications governing all interactions between Buyer Platforms (BAPs) and Seller Platforms (BPPs) in the OPuN ecosystem. In facilitating transparent, interoperable, and verifiable communications, OPuN ensures that livelihood opportunities—such as job roles, internships, and project-based assignments—can be discovered, evaluated, and pursued efficiently across decentralized digital infrastructures.

Participation in the OPuN network requires adherence to foundational principles intended to safeguard transaction integrity, transparency, and reliability. Every participant, regardless of role, must undertake responsibilities related to data accuracy, cryptographic compliance, behavioral conformance, and preservation of network trust.

The OPuN framework prioritizes autonomy and decentralized control. Each participant operates its own systems, yet collectively ensures a harmonized experience for candidates and opportunity providers. This specification defines the expectations that allow such distributed coordination to function predictably.

The livelihood domain defines a structured vocabulary of attributes required for the characterization of job roles, skills, experience criteria, compensation models, and application workflows. Attributes identified within this contract represent the authoritative definitions to be used by all participants.

Enumerated fields—such as employment type, fulfillment mode, and application state—must adhere to the exact values specified in this document. Consistent interpretation of attribute semantics ensures that candidate experiences remain uniform across diverse platforms.

This API contract document is structured as follows:

* JSON payload for each API request & response;
* Definition & enumerations of specific attribute keys, as applicable;
* Examples of usage of specific attribute keys for a business requirement, as applicable;
* Expected behaviour of APIs on the network;

Livelihood API contract includes the following APIs:

### a) Pre-order APIs

* `/search` - Buyer NP (BAP) specifies the search intent for job opportunities;
* `/on_search` - Seller NP (BPP) responds with the job catalog based on the search intent;
* `/select` - Buyer NP (BAP) specifies the job opportunity selected by the candidate;
* `/on_select` - Seller NP (BPP) responds with detailed job information, quote, and application form (XInput) with required information for selected job opportunity;
* `/init` & `/on_init` - Buyer NP (BAP) submits filled application form and Seller NP (BPP) returns submitted form data for verification;
* `/confirm` - Buyer NP (BAP) places the job application on behalf of the candidate;
* `/on_confirm` - Seller NP (BPP) responds to the application placed either through auto-acceptance or deferred acceptance or rejection;

### b) Post-order APIs

* `/status` - BAP requests for the current status of the application;
* `/on_status` - BPP provides the current status of the application;
* `/cancel` - BAP places cancellation request for the application;
* `/on_cancel` - BPP responds to the BAP cancellation request or cancels the application directly;
* `/update` - BAP initiates an update request (for application details) on behalf of the candidate;
* `/on_update` - BPP responds to the BAP update request or initiates an unsolicited update (interview schedule, notes, offer, etc.) directly;
* `/support` - BAP requests support information;
* `/on_support` - BPP responds with support information;

All attribute keys, defined in this API contract, are mandatory, unless explicitly mentioned otherwise. Participants may validate the request & response payloads, based on mandatory attribute keys, as defined in this contract and respond with "NACK" (along with appropriate error code as defined here) for invalid payloads. Any payload, without optional attribute keys, cannot be considered as invalid.

This API contract has been defined after incorporating requirements for the livelihood opportunities domain.

All participants are required to ensure full compliance with this API contract on the OPuN network.

---

## 2. Signing & Verification of requests & responses

1. Key pairs, for signing & encryption, can be generated using any standard library e.g. libsodium.

2. Creating key pairs

   * Create key pairs, for signing (ed25519) & encryption (X25519);
   * Update base64 encoded public keys in registry;

3. Auth Header Signing

   * Generate UTF-8 byte array from json payload;
   * Generate Blake2b hash from UTF-8 byte array;
   * Create base64 encoding of Blake2b hash, this becomes the digest for signing;
   * Sign the request, using your private signing key, and add the signature to the request authorization header.

4. Auth Header Verification

   * Extract the digest from the encoded signature in the request;
   * Get the signing_public_key from registry using lookup (by using the ukId in the authorization header);
   * Create (UTF-8) byte array from the raw payload and generate Blake2b hash;
   * Compare generated Blake2b hash with the decoded digest from the signature in the request;
   * In case of failure to verify, HTTP error 401 should be thrown;

---

## 3. Registry lookup

1. There are 2 possible participant types, for the livelihood domain, in the OPuN registry:

   * Buyer App Platform (BAP)

   * Seller App Platform (BPP)

2. Each participant type, defined above, will have an entry in the registry for their entity;

3. Every participant on the OPuN registry will have one or more entries in the registry, with unique identifier ("key_id") for each such entry;

4. Signing & Verification of requests and responses using auth headers is defined in section 2.

5. All requests & responses have to be signed by the sender and verified by the receiver. If any request fails verification, it should be rejected (NACK'd) with http 401 error code;

6. The identity of the sender of a request is sent, through the auth header, as follows:

   ```
   keyId="{subscriber_id}|{key_id}|{algorithm}"
   ```

7. Signing by all participants will be using their private key, for which the corresponding public key will be in the registry for their "key_id";

8. Verification of requests is using registry lookup. Participants can either use the registry lookup endpoints or cache the registry locally (with refresh at regular interval) for a local lookup;

9. Following options are available:

   * `/lookup`

     ```
     request:
     {
         "subscriber_id":"bap.opungram.com",
         "domain":"opun:livelihood",
         "key_id":"KEYID",
         "country":"IND",
         "city":"std:080",
         "type":"BAP" 
     }
     response:
     [
         {
             "subscriber_id":"bap.opungram.com",
             "status":"SUBSCRIBED",
             "key_id":"KEYID",
             "subscriber_url":"https://bap-api.opungram.com/agache/agent/network/",
             "country":"IND",
             "domain":"opun:livelihood",
             "valid_from":"2024-01-01T00:00:00.000Z",
             "valid_until":"2028-01-01T00:00:00.000Z",
             "type":"BAP",
             "signing_public_key": "<ed25519_signing_public_key>",
             "encr_public_key": "<x25519_encryption_public_key>",
             "created":"2024-01-01T00:00:00.000Z",
             "updated":"2024-01-01T00:00:00.000Z",
             "city":"std:080"
         }
     ]
     ```

**Note:** `type` - enum - "BPP", "BAP", "BG"

---

## 4. Construct of APIs & transaction trail

### 4.1. API Structure and Content

All OPuN APIs adhere to a standard construct comprising two main blocks:

**Context**: Contains essential attribute keys like transaction_id and message_id, which are used to identify the source and destination of the message in the API request or response.

**Message**: Carries the core content of the message, such as search intent, catalog details, or order details.

### 4.2. Asynchronous API Flow

All APIs are asynchronous, operating through a four-step request-response mechanism:

1. **Request**: The sender transmits the request to the recipient.

2. **Acknowledgement (Sync)**: The recipient immediately acknowledges the request by sending an "ACK" (or "NACK" if validation fails).

3. **Response (Async Callback)**: The recipient sends the full response using a corresponding callback API (e.g., `/on_search` for a `/search` request).

4. **Callback Acknowledgement (Sync)**: The recipient of the callback (usually the original sender) acknowledges the response with an "ACK" or "NACK."

### 4.3. Correlation and Identification

**Correlation**: Every request and its corresponding response are uniquely identified by a combination of transaction_id and a unique message_id, allowing the sender to correlate the response with the original request.

**Stale Message Handling**: If a stale request or response is received (i.e., its timestamp is earlier than a previously processed one identified by the same transaction_id + message_id), the recipient should send a "NACK" with the designated error codes: "20002" (for BAP) or "30022" (for BPP).

### 4.4. Error Handling

**Error Transmission**: An error block can be sent in either synchronous (with the request acknowledgement) or asynchronous (with the callback) mode.

**Required Attributes**: The error block must include the following attribute keys: error.type and error.code.

**Error Codes**: Standard OPuN error codes are detailed in a separate error codes specification document.

### 4.5 Transaction ID Management (Pre-Order Stage)

The way transaction_id is used varies during the pre-order stage:

**Full Trail**: A unique transaction_id is maintained for the entire pre-order stage (`/search`, `/select`, `/init`, `/confirm`) to track the transaction trail for a single candidate.

**Cached Catalogs**: Given that buyer applications often cache catalogs for performance, a unique transaction_id is specifically maintained for the set of APIs: `/select`, `/init`, and `/confirm`.

**Live Search**: Buyer applications implementing live search functionality have the flexibility to use the same transaction_id across the entire pre-order stage.

### 4.6. Application Identification

**Unique Application ID**: An application on the network is uniquely identified by the combination of the transaction_id and the order id.


---

## 5. API Contract

### 5.1 /search

Search API will be used to communicate the intent for discovering job opportunities.

Search request is always broadcast through the gateway so that all BPPs who have registered for the specific domain, in the search request, are notified.

#### 5.1.1 Search by Job Title

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "action":"search",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M1",
    "timestamp":"2024-01-15T08:00:00.000Z",
    "ttl":"PT30S"
  },
  "message":
  {
    "intent":
    {
      "item":
      {
        "descriptor":
        {
          "name":"Fullstack Engineer"
        }
      },
      "fulfillment":
      {
        "type":"remote"
      }
    }
  }
}
```

#### 5.1.2 Search by Skills

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "action":"search",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M1",
    "timestamp":"2024-01-15T08:00:00.000Z",
    "ttl":"PT30S"
  },
  "message":
  {
    "intent":
    {
      "item":
      {
        "descriptor":
        {
          "name":"React, Node.js, TypeScript"
        }
      }
    }
  }
}
```

#### 5.1.3 Search by Provider/Employer

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "action":"search",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M1",
    "timestamp":"2024-01-15T08:00:00.000Z",
    "ttl":"PT30S"
  },
  "message":
  {
    "intent":
    {
      "provider":
      {
        "id":"1"
      }
    }
  }
}
```

---

### 5.2 /on_search

BPP responds with job catalog based on the search intent.

#### 5.2.1 Catalog Response

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_search",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M1",
    "timestamp":"2024-01-15T08:00:30.000Z",
    "ttl":"P1M"
  },
  "message":
  {
    "catalog":
    {
      "descriptor":
      {
        "name":"Opun Seva"
      },
      "providers":
      [
        {
          "id":"1",
          "descriptor":
          {
            "name":"TechCorp Solutions",
            "short_desc":"Leading technology company specializing in software development and digital solutions",
            "images":
            [
              {
                "url":"https://example.com/techcorp-logo.png"
              }
            ]
          },
          "fulfillments":
          [
            {
              "id":"1",
              "type":"remote"
            },
            {
              "id":"2",
              "type":"hybrid"
            },
            {
              "id":"3",
              "type":"onsite"
            }
          ],
          "locations":
          [
            {
              "id":"L1",
              "city":
              {
                "name":"Pune",
                "code":"std:020"
              },
              "state":
              {
                "name":"Maharashtra",
                "code":"MH"
              }
            }
          ],
          "items":
          [
            {
              "id":"JOB_001",
              "descriptor":
              {
                "name":"Fullstack Engineer",
                "long_desc":"We're looking for a Fullstack Engineer with expertise in React, React Native, and Node.js. The ideal candidate should have experience building scalable web and mobile applications."
              },
              "price":
              {
                "currency":"INR",
                "value":"1200000"
              },
              "time":
              {
                "label":"Application Period",
                "range":
                {
                  "start":"2024-01-03T13:23:01+00:00",
                  "end":"2024-02-03T13:23:01+00:00"
                }
              },
              "location_ids":["L1"],
              "fulfillment_ids":["1", "2", "3"],
              "tags":
              [
                {
                  "display":true,
                  "descriptor":
                  {
                    "code":"min-edu-qual",
                    "name":"Minimum Educational Qualifications"
                  },
                  "list":
                  [
                    {
                      "value":"Bachelors"
                    }
                  ]
                },
                {
                  "display":true,
                  "descriptor":
                  {
                    "code":"employment-type",
                    "name":"Employment Type"
                  },
                  "list":
                  [
                    {
                      "descriptor":
                      {
                        "code":"emp-duration-type",
                        "name":"Duration Type"
                      },
                      "value":"FULL_TIME"
                    }
                  ]
                },
                {
                  "display":true,
                  "descriptor":
                  {
                    "code":"skills-reqd",
                    "name":"Skills Required"
                  },
                  "list":
                  [
                    {
                      "descriptor":
                      {
                        "code":"skill",
                        "name":"Skill"
                      },
                      "value":"React"
                    },
                    {
                      "descriptor":
                      {
                        "code":"skill",
                        "name":"Skill"
                      },
                      "value":"Node.js"
                    },
                    {
                      "descriptor":
                      {
                        "code":"skill",
                        "name":"Skill"
                      },
                      "value":"TypeScript"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
```

**N.B.**
1. `/on_search` responses may be paginated by provider, i.e. separate `/on_search` response per provider with the same transaction_id and message_id as `/search`;
2. Job opportunities must include all required fields as specified in the schema;
3. Skills, qualifications, and employment type must be clearly specified in tags;

---

### 5.3 /select

BAP specifies the job opportunity selected by the candidate.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"select",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M2",
    "timestamp":"2024-01-15T09:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "items":
      [
        {
          "id":"JOB_001"
        }
      ],
      "fulfillments":
      [
        {
          "id":"1"
        }
      ]
    }
  }
}
```

---

### 5.4 /on_select

BPP responds with detailed job information, quote, and application form (XInput).

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_select",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M2",
    "timestamp":"2024-01-15T09:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "provider":
      {
        "id":"1",
        "descriptor":
        {
          "name":"TechCorp Solutions",
          "short_desc":"Leading technology company specializing in digital identity solutions",
          "images":
          [
            {
              "url":"https://example.com/techcorp-logo.png"
            }
          ]
        },
        "rateable":false
      },
      "items":
      [
        {
          "id":"JOB_001",
          "descriptor":
          {
            "name":"Fullstack Engineer",
            "long_desc":"We're looking for a Fullstack Engineer with expertise in React, React Native, and Node.js. The ideal candidate should have experience building scalable web and mobile applications."
          },
          "price":
          {
            "currency":"INR",
            "value":"1200000"
          },
          "time":
          {
            "label":"Application Period",
            "range":
            {
              "start":"2024-01-03T13:23:01+00:00",
              "end":"2024-02-03T13:23:01+00:00"
            }
          },
          "xinput":
          {
            "required":true,
            "head":
            {
              "descriptor":
              {
                "name":"Job Application Form"
              },
              "index":
              {
                "min":0,
                "cur":0,
                "max":3
              },
              "headings":
              [
                "Personal Information",
                "Professional Experience",
                "Skills & Qualifications",
                "Review & Submit"
              ]
            },
            "form":
            {
              "mime_type":"application/xml",
              "data":"<?xml version=\"1.0\" encoding=\"UTF-8\"?><xf:model xmlns:xf=\"http://www.w3.org/2002/xforms\"><xf:instance><data><personal_info><full_name/><date_of_birth/><gender/><address/><phone/><email/></personal_info><professional_experience><current_company/><current_position/><years_of_experience/><previous_companies/></professional_experience><skills_qualifications><education><degree/><field/><university/><year/></education><skills/><certifications><name/><issuer/><year/></certifications></skills_qualifications><documents><resume/><cover_letter/><portfolio/></documents><role_questionnaire><question1/><question2/><question3/></role_questionnaire></data></xf:instance></xf:model>",
              "resubmit":false
            }
          },
          "fulfillment_ids":["1"],
          "tags":
          [
            {
              "display":true,
              "descriptor":
              {
                "code":"employment-type",
                "name":"Employment Type"
              },
              "list":
              [
                {
                  "descriptor":
                  {
                    "code":"emp-duration-type",
                    "name":"Duration Type"
                  },
                  "value":"FULL_TIME"
                }
              ]
            },
            {
              "display":true,
              "descriptor":
              {
                "code":"docs-reqd",
                "name":"Documents Required"
              },
              "list":
              [
                {
                  "value":"Resume/CV"
                },
                {
                  "value":"Cover Letter"
                },
                {
                  "value":"Portfolio Link (if applicable)"
                }
              ]
            }
          ]
        }
      ],
      "quote":
      {
        "price":
        {
          "currency":"INR",
          "value":"1500000"
        },
        "breakup":
        [
          {
            "title":"Base Salary",
            "price":
            {
              "currency":"INR",
              "value":"1200000"
            }
          },
          {
            "title":"Variable Pay",
            "price":
            {
              "currency":"INR",
              "value":"300000"
            }
          }
        ]
      }
    }
  }
}
```

**N.B.**
1. The `xinput` block contains the application form structure in XForms 2.0 XML format (NO URL);
2. Form fields are sent inline via `form.data` in XForms 2.0 XML;
3. The form structure includes: Personal info, Professional experience, Skills & qualifications, Documents, Role-specific questionnaire;
4. Buyer app renders the XForm structure and candidate fills the form;
5. No form-submit endpoint is used - form is rendered and filled at buyer app;

---

### 5.5 /init

BAP sends filled form data in the init request after candidate fills the form.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"init",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M3",
    "timestamp":"2024-01-15T10:00:00.000Z",
    "ttl":"P1M"
  },
  "message":
  {
    "order":
    {
      "provider":
      {
        "id":"1"
      },
      "items":
      [
        {
          "id":"JOB_001",
          "xinput":
          {
            "form":
            {
              "mime_type":"application/xml",
              "data":"<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><personal_info><full_name>Sanjay Kumar</full_name><date_of_birth>1988-05-15</date_of_birth><gender>Male</gender><address>123 Main Street, Bangalore</address><phone>+91-9999999999</phone><email>sanjay.kumar@example.com</email></personal_info><professional_experience><current_company>ABC Tech</current_company><current_position>Senior Developer</current_position><years_of_experience>4.5</years_of_experience><previous_companies><company><name>XYZ Corp</name><position>Developer</position><duration>2 years</duration></company></previous_companies></professional_experience><skills_qualifications><education><degree>Bachelors</degree><field>Computer Science</field><university>ABC University</university><year>2010</year></education><skills>React, Node.js, TypeScript, AWS</skills><certifications><cert><name>AWS Certified Developer</name><issuer>Amazon</issuer><year>2022</year></cert></certifications></skills_qualifications><documents><resume>https://example.com/resume/sanjay-kumar.pdf</resume><cover_letter>https://example.com/cover-letter/sanjay-kumar.pdf</cover_letter><portfolio>https://sanjaykumar.dev</portfolio></documents><role_questionnaire><question1>I am interested in this position because it aligns with my expertise in full-stack development and offers opportunities to work on cutting-edge technologies.</question1><question2>I have 4+ years of experience with React, including building complex SPAs and mobile apps with React Native.</question2><question3>Yes, I am available to start immediately and can join within 2 weeks notice period.</question3></role_questionnaire></data>"
            }
          }
        }
      ],
      "fulfillments":
      [
        {
          "id":"1",
          "customer":
          {
            "id":"aadhaar:798677675565",
            "person":
            {
              "name":"Sanjay Kumar",
              "gender":"Male",
              "age":"35",
              "skills":
              [
                {
                  "name":"React",
                  "code":"react"
                },
                {
                  "name":"Node.js",
                  "code":"nodejs"
                },
                {
                  "name":"TypeScript",
                  "code":"typescript"
                }
              ],
              "languages":
              [
                {
                  "code":"en",
                  "name":"English"
                },
                {
                  "code":"hi",
                  "name":"Hindi"
                }
              ]
            },
            "contact":
            {
              "phone":"+91-9999999999",
              "email":"sanjay.kumar@example.com"
            }
          }
        }
      ],
      "billing":
      {
        "name":"Sanjay Kumar",
        "organization":
        {
          "descriptor":
          {
            "name":"OpunGram",
            "code":"opungram.com"
          },
          "contact":
          {
            "phone":"+91-8888888888",
            "email":"support@opungram.com"
          }
        },
        "address":"123 Main Street, Bangalore",
        "phone":"+91-9999999999"
      },
      "payments":
      [
        {
          "params":
          {
            "bank_code":"IFSC_CODE_OF_THE_BANK",
            "bank_account_number":"121212121212",
            "bank_account_name":"Sanjay Kumar"
          }
        }
      ]
    }
  }
}
```

**N.B.**
1. BAP sends filled form data in `xinput.form.data` after candidate fills the form at buyer app;
2. Form data is in XML format matching the XForms structure received in `on_select`;
3. BPP stores this form data for later verification;

---

### 5.6 /on_init

BPP stores the form data and returns it back for review by candidate along with other information.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_init",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M3",
    "timestamp":"2024-01-15T10:00:30.000Z",
    "ttl":"P1M"
  },
  "message":
  {
    "order":
    {
      "provider":
      {
        "id":"1",
        "descriptor":
        {
          "name":"TechCorp Solutions",
          "short_desc":"Leading technology company specializing in digital identity solutions",
          "images":
          [
            {
              "url":"https://example.com/techcorp-logo.png"
            }
          ]
        },
        "rateable":false
      },
      "items":
      [
        {
          "id":"JOB_001",
          "descriptor":
          {
            "name":"Fullstack Engineer",
            "long_desc":"We're looking for a Fullstack Engineer with expertise in React, React Native, and Node.js. The ideal candidate should have experience building scalable web and mobile applications."
          },
          "price":
          {
            "currency":"INR",
            "value":"1200000"
          },
          "time":
          {
            "label":"Application Period",
            "range":
            {
              "start":"2024-01-03T13:23:01+00:00",
              "end":"2024-02-03T13:23:01+00:00"
            }
          },
                    "xinput":
                    {
                        "required":true,
                        "head":
                        {
                            "descriptor":
                            {
                                "name":"Job Application Form"
                            },
                            "index":
                            {
                                "min":0,
                                "cur":0,
                                "max":3
                            },
                            "headings":
                            [
                                "Personal Information",
                                "Professional Experience",
                                "Skills & Qualifications",
                                "Review & Submit"
                            ]
                        },
                        "form":
                        {
                            "mime_type":"application/xml",
                            "data":"<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><personal_info><full_name>Sanjay Kumar</full_name><date_of_birth>1988-05-15</date_of_birth><gender>Male</gender><address>123 Main Street, Bangalore</address><phone>+91-9999999999</phone><email>sanjay.kumar@example.com</email></personal_info><professional_experience><current_company>ABC Tech</current_company><current_position>Senior Developer</current_position><years_of_experience>4.5</years_of_experience><previous_companies><company><name>XYZ Corp</name><position>Developer</position><duration>2 years</duration></company></previous_companies></professional_experience><skills_qualifications><education><degree>Bachelors</degree><field>Computer Science</field><university>ABC University</university><year>2010</year></education><skills>React, Node.js, TypeScript, AWS</skills><certifications><cert><name>AWS Certified Developer</name><issuer>Amazon</issuer><year>2022</year></cert></certifications></skills_qualifications><documents><resume>https://example.com/resume/sanjay-kumar.pdf</resume><cover_letter>https://example.com/cover-letter/sanjay-kumar.pdf</cover_letter><portfolio>https://sanjaykumar.dev</portfolio></documents><role_questionnaire><question1>I am interested in this position because it aligns with my expertise in full-stack development and offers opportunities to work on cutting-edge technologies.</question1><question2>I have 4+ years of experience with React, including building complex SPAs and mobile apps with React Native.</question2><question3>Yes, I am available to start immediately and can join within 2 weeks notice period.</question3></role_questionnaire></data>"
                        }
                    },
          "fulfillment_ids":["1"]
        }
      ],
      "fulfillments":
      [
        {
          "state":
          {
            "descriptor":
            {
              "code":"APPLICATION-FORM-SUBMITTED",
              "name":"Application Form Submitted - Pending Verification"
            },
            "updated_at":"2024-01-15T10:00:30.000Z"
          },
          "id":"1",
          "type":"JOB",
          "tracking":false,
          "agent":
          {
            "person":
            {
              "name":"HR Team"
            },
            "contact":
            {
              "email":"hr@techcorp.com"
            }
          },
          "customer":
          {
            "id":"aadhaar:798677675565",
            "person":
            {
              "name":"Sanjay Kumar",
              "gender":"Male",
              "age":"35",
              "skills":
              [
                {
                  "name":"React",
                  "code":"react"
                },
                {
                  "name":"Node.js",
                  "code":"nodejs"
                }
              ],
              "languages":
              [
                {
                  "code":"en",
                  "name":"English"
                }
              ]
            },
            "contact":
            {
              "phone":"+91-9999999999",
              "email":"sanjay.kumar@example.com"
            }
          }
        }
      ],
      "billing":
      {
        "name":"Sanjay Kumar",
        "organization":
        {
          "descriptor":
          {
            "name":"OpunGram",
            "code":"opungram.com"
          },
          "contact":
          {
            "phone":"+91-8888888888",
            "email":"support@opungram.com"
          }
        },
        "address":"123 Main Street, Bangalore",
        "phone":"+91-9999999999"
      },
      "payments":
      [
        {
          "params":
          {
            "bank_code":"IFSC_CODE_OF_THE_BANK",
            "bank_account_number":"121212121212",
            "bank_account_name":"Sanjay Kumar"
          }
        }
      ],
      "quote":
      {
        "price":
        {
          "currency":"INR",
          "value":"1500000"
        },
        "breakup":
        [
          {
            "title":"Base Salary",
            "price":
            {
              "currency":"INR",
              "value":"1200000"
            }
          },
          {
            "title":"Variable Pay",
            "price":
            {
              "currency":"INR",
              "value":"300000"
            }
          }
        ]
      }
    }
  }
}
```

**N.B.**
1. BPP stores the form data received in `init` and returns it back for candidate review;
2. Form data is returned in XML format matching what was sent in `init`;
3. Candidate can review all submitted information before confirming the application;
4. If candidate finds any discrepancy, they can drop the transaction at buyer app and start again;
5. State indicates "APPLICATION-FORM-SUBMITTED - Pending Verification";

---

### 5.7 /confirm

BAP places the job application on behalf of the candidate.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"confirm",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M4",
    "timestamp":"2024-01-15T11:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "provider":
      {
        "id":"1"
      },
      "items":
      [
        {
          "id":"JOB_001",
          "fulfillment_ids":["1"],
          "xinput":
          {
            "form":
            {
              "mime_type":"application/xml",
              "data":"<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><personal_info><full_name>Sanjay Kumar</full_name><date_of_birth>1988-05-15</date_of_birth><gender>Male</gender><address>123 Main Street, Bangalore</address><phone>+91-9999999999</phone><email>sanjay.kumar@example.com</email></personal_info><professional_experience><current_company>ABC Tech</current_company><current_position>Senior Developer</current_position><years_of_experience>4.5</years_of_experience><previous_companies><company><name>XYZ Corp</name><position>Developer</position><duration>2 years</duration></company></previous_companies></professional_experience><skills_qualifications><education><degree>Bachelors</degree><field>Computer Science</field><university>ABC University</university><year>2010</year></education><skills>React, Node.js, TypeScript, AWS</skills><certifications><cert><name>AWS Certified Developer</name><issuer>Amazon</issuer><year>2022</year></cert></certifications></skills_qualifications><documents><resume>https://example.com/resume/sanjay-kumar.pdf</resume><cover_letter>https://example.com/cover-letter/sanjay-kumar.pdf</cover_letter><portfolio>https://sanjaykumar.dev</portfolio></documents><role_questionnaire><question1>I am interested in this position because it aligns with my expertise in full-stack development and offers opportunities to work on cutting-edge technologies.</question1><question2>I have 4+ years of experience with React, including building complex SPAs and mobile apps with React Native.</question2><question3>Yes, I am available to start immediately and can join within 2 weeks notice period.</question3></role_questionnaire></data>"
            }
          }
        }
      ],
      "fulfillments":
      [
        {
          "id":"1",
          "customer":
          {
            "id":"aadhaar:798677675565",
            "person":
            {
              "name":"Sanjay Kumar",
              "gender":"Male",
              "age":"35",
              "skills":
              [
                {
                  "name":"React",
                  "code":"react"
                },
                {
                  "name":"Node.js",
                  "code":"nodejs"
                }
              ],
              "languages":
              [
                {
                  "code":"en",
                  "name":"English"
                }
              ]
            },
            "contact":
            {
              "phone":"+91-9999999999",
              "email":"sanjay.kumar@example.com"
            }
          }
        }
      ],
      "billing":
      {
        "name":"Sanjay Kumar",
        "organization":
        {
          "descriptor":
          {
            "name":"OpunGram",
            "code":"opungram.com"
          },
          "contact":
          {
            "phone":"+91-8888888888",
            "email":"support@opungram.com"
          }
        },
        "address":"123 Main Street, Bangalore",
        "phone":"+91-9999999999"
      },
      "payments":
      [
        {
          "params":
          {
            "bank_code":"IFSC_CODE_OF_THE_BANK",
            "bank_account_number":"121212121212",
            "bank_account_name":"Sanjay Kumar"
          }
        }
      ]
    }
  }
}
```

**N.B.**
1. BAP generates `order.id` for tracking purposes;
2. BAP sends the same filled form data that was received in `on_init`;
3. This is the final confirmation step where candidate confirms the application after reviewing the data;
4. All order details must match what was verified in `/on_init`;

---

### 5.8 /on_confirm

BPP responds to the application placed either through auto-acceptance or deferred acceptance or rejection.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_confirm",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M4",
    "timestamp":"2024-01-15T11:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "provider":
      {
        "id":"1",
        "descriptor":
        {
          "name":"TechCorp Solutions",
          "short_desc":"Leading technology company specializing in digital identity solutions",
          "images":
          [
            {
              "url":"https://example.com/techcorp-logo.png"
            }
          ]
        },
        "rateable":false
      },
      "items":
      [
        {
          "id":"JOB_001",
          "descriptor":
          {
            "name":"Fullstack Engineer",
            "long_desc":"We're looking for a Fullstack Engineer with expertise in React, React Native, and Node.js."
          },
          "price":
          {
            "currency":"INR",
            "value":"1200000"
          },
          "fulfillment_ids":["1"]
        }
      ],
      "fulfillments":
      [
        {
          "state":
          {
            "descriptor":
            {
              "code":"APPLICATION-CONFIRMED",
              "name":"Application Confirmed"
            },
            "updated_at":"2024-01-15T11:00:30.000Z"
          },
          "id":"1",
          "type":"JOB",
          "tracking":true,
          "agent":
          {
            "person":
            {
              "name":"HR Team"
            },
            "contact":
            {
              "email":"hr@techcorp.com"
            }
          },
          "customer":
          {
            "id":"aadhaar:798677675565",
            "person":
            {
              "name":"Sanjay Kumar",
              "gender":"Male",
              "age":"35"
            },
            "contact":
            {
              "phone":"+91-9999999999",
              "email":"sanjay.kumar@example.com"
            }
          }
        }
      ],
      "billing":
      {
        "name":"Sanjay Kumar",
        "organization":
        {
          "descriptor":
          {
            "name":"OpunGram",
            "code":"opungram.com"
          },
          "contact":
          {
            "phone":"+91-8888888888",
            "email":"support@opungram.com"
          }
        },
        "address":"123 Main Street, Bangalore",
        "phone":"+91-9999999999"
      },
      "payments":
      [
        {
          "params":
          {
            "bank_code":"IFSC_CODE_OF_THE_BANK",
            "bank_account_number":"121212121212",
            "bank_account_name":"Sanjay Kumar"
          }
        }
      ],
      "quote":
      {
        "price":
        {
          "currency":"INR",
          "value":"1500000"
        },
        "breakup":
        [
          {
            "title":"Base Salary",
            "price":
            {
              "currency":"INR",
              "value":"1200000"
            }
          },
          {
            "title":"Variable Pay",
            "price":
            {
              "currency":"INR",
              "value":"300000"
            }
          }
        ]
      }
    }
  }
}
```

**N.B.**
1. BPP verifies the form data received in `confirm` against what was stored in `init`;
2. If verification passes, BPP returns `order.id` (can be same as BAP's or BPP-generated) and application is submitted;
3. State indicates "APPLICATION-CONFIRMED";
4. Tracking is enabled (`tracking: true`) for post-order APIs;
5. This `order.id` will be used for all subsequent API calls (`status`, `update`, `cancel`, etc.);

---

### 5.9 /status

BAP requests for the current status of the application.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"status",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M5",
    "timestamp":"2024-01-20T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order_id":"JOB_APP_001"
  }
}
```

---

### 5.10 /on_status

BPP provides the current status of the application.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_status",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M5",
    "timestamp":"2024-01-20T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "state":"ACTIVE",
      "fulfillments":
      [
        {
          "id":"1",
          "state":
          {
            "descriptor":
            {
              "code":"UNDER-REVIEW",
              "name":"Application Under Review"
            },
            "updated_at":"2024-01-20T10:00:30.000Z"
          }
        }
      ]
    }
  }
}
```

**N.B.**
1. Status codes can include: "APPLICATION-RECEIVED", "UNDER-REVIEW", "SHORTLISTED", "INTERVIEW-SCHEDULED", "OFFER-EXTENDED", "REJECTED", "WITHDRAWN", etc.;
2. Status updates can also be sent via unsolicited `/on_update`;

---

### 5.11 /update

BAP initiates an update request (for application details) on behalf of the candidate.

#### 5.11.1 Solicited Update - Update Application Details

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"update",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M6",
    "timestamp":"2024-01-25T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "fulfillments":
      [
        {
          "id":"1",
          "customer":
          {
            "person":
            {
              "name":"Sanjay Kumar",
              "contact":
              {
                "phone":"+91-9999999999",
                "email":"sanjay.kumar.new@example.com"
              }
            }
          }
        }
      ],
      "update_target":"fulfillments"
    }
  }
}
```

---

### 5.12 /on_update

BPP responds to the BAP update request or initiates an unsolicited update (interview schedule, notes, offer, etc.) directly.

#### 5.12.1 Solicited Update - Update Confirmation

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_update",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M6",
    "timestamp":"2024-01-25T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "state":"UPDATED",
      "fulfillments":
      [
        {
          "id":"1",
          "state":
          {
            "descriptor":
            {
              "code":"APPLICATION-UPDATED",
              "name":"Application Updated"
            },
            "updated_at":"2024-01-25T10:00:30.000Z"
          },
          "customer":
          {
            "person":
            {
              "name":"Sanjay Kumar",
              "contact":
              {
                "phone":"+91-9999999999",
                "email":"sanjay.kumar.new@example.com"
              }
            }
          }
        }
      ],
      "update_target":"fulfillments"
    }
  }
}
```

#### 5.12.2 Unsolicited Update - Interview Schedule

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_update",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M7",
    "timestamp":"2024-01-28T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "fulfillments":
      [
        {
          "id":"1",
          "state":
          {
            "descriptor":
            {
              "code":"INTERVIEW-SCHEDULED",
              "name":"Interview Scheduled"
            },
            "updated_at":"2024-01-28T10:00:00.000Z"
          },
          "tags":
          [
            {
              "code":"interview-details",
              "list":
              [
                {
                  "descriptor":
                  {
                    "code":"interview-date",
                    "name":"Interview Date"
                  },
                  "value":"2024-02-05T10:00:00.000Z"
                },
                {
                  "descriptor":
                  {
                    "code":"interview-time",
                    "name":"Interview Time"
                  },
                  "value":"10:00 AM IST"
                },
                {
                  "descriptor":
                  {
                    "code":"interview-type",
                    "name":"Interview Type"
                  },
                  "value":"Technical Round"
                },
                {
                  "descriptor":
                  {
                    "code":"interview-location",
                    "name":"Interview Location"
                  },
                  "value":"TechCorp Solutions, Pune Office"
                },
                {
                  "descriptor":
                  {
                    "code":"interviewer-name",
                    "name":"Interviewer Name"
                  },
                  "value":"John Doe"
                },
                {
                  "descriptor":
                  {
                    "code":"interviewer-contact",
                    "name":"Interviewer Contact"
                  },
                  "value":"john.doe@techcorp.com"
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
```

#### 5.12.3 Unsolicited Update - Job Offer

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_update",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M8",
    "timestamp":"2024-02-10T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "fulfillments":
      [
        {
          "id":"1",
          "state":
          {
            "descriptor":
            {
              "code":"OFFER-EXTENDED",
              "name":"Job Offer Extended"
            },
            "updated_at":"2024-02-10T10:00:00.000Z"
          },
          "tags":
          [
            {
              "code":"offer-details",
              "list":
              [
                {
                  "descriptor":
                  {
                    "code":"offer-letter-url",
                    "name":"Offer Letter URL"
                  },
                  "value":"https://techcorp.com/offers/JOB_APP_001.pdf"
                },
                {
                  "descriptor":
                  {
                    "code":"offer-validity",
                    "name":"Offer Validity"
                  },
                  "value":"2024-02-25T23:59:59.000Z"
                },
                {
                  "descriptor":
                  {
                    "code":"joining-date",
                    "name":"Joining Date"
                  },
                  "value":"2024-03-01T00:00:00.000Z"
                }
              ]
            }
          ]
        }
      ],
      "quote":
      {
        "price":
        {
          "currency":"INR",
          "value":"1500000"
        },
        "breakup":
        [
          {
            "title":"Base Salary",
            "price":
            {
              "currency":"INR",
              "value":"1200000"
            }
          },
          {
            "title":"Variable Pay",
            "price":
            {
              "currency":"INR",
              "value":"300000"
            }
          }
        ]
      }
    }
  }
}
```

**N.B.**
1. `/update` can be used for solicited updates (BAP-initiated);
2. `/on_update` can be used for both solicited (response to `/update`) and unsolicited (BPP-initiated) updates;
3. Unsolicited updates include: interview schedule, application notes, job offer details, status changes;
4. Update target specifies which part of the order is being updated;

---

### 5.13 /cancel

BAP places cancellation request for the application.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"cancel",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M9",
    "timestamp":"2024-02-15T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order_id":"JOB_APP_001",
    "cancellation_reason_id":"001",
    "descriptor":
    {
      "name":"Candidate withdrew application",
      "short_desc":"Candidate decided to withdraw the application"
    }
  }
}
```

---

### 5.14 /on_cancel

BPP responds to the BAP cancellation request or cancels the application directly.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_cancel",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M9",
    "timestamp":"2024-02-15T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order":
    {
      "id":"JOB_APP_001",
      "state":"CANCELLED",
      "fulfillments":
      [
        {
          "id":"1",
          "state":
          {
            "descriptor":
            {
              "code":"APPLICATION-CANCELLED",
              "name":"Application Cancelled"
            },
            "updated_at":"2024-02-15T10:00:30.000Z"
          }
        }
      ]
    }
  }
}
```

---

### 5.15 /track

BAP requests for tracking of application progress.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"track",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M10",
    "timestamp":"2024-02-20T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "order_id":"JOB_APP_001"
  }
}
```

---

### 5.16 /on_track

BPP responds with tracking details for application.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_track",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M10",
    "timestamp":"2024-02-20T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "tracking":
    {
      "url":"https://techcorp.com/track/JOB_APP_001",
      "status":"active"
    }
  }
}
```

---

### 5.17 /support

BAP requests support information.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"support",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M11",
    "timestamp":"2024-02-25T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "ref_id":"JOB_APP_001"
  }
}
```

---

### 5.18 /on_support

BPP responds with support information.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_support",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M11",
    "timestamp":"2024-02-25T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "phone":"+91-8888888888",
    "email":"support@techcorp.com",
    "uri":"https://techcorp.com/support"
  }
}
```

---

### 5.19 /rating

BAP submits rating for the application experience.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"rating",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M12",
    "timestamp":"2024-03-01T10:00:00.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "rating":
    {
      "rating_category":"Application Experience",
      "id":"JOB_APP_001",
      "value":"4",
      "feedback":"Great communication throughout the process"
    }
  }
}
```

---

### 5.20 /on_rating

BPP acknowledges the rating.

```
{
  "context":
  {
    "domain":"opun:livelihood",
    "location": {
      "country": {
        "name":"India",
        "code":"IND"
      },
      "city": {
        "name":"Bangalore",
        "code":"std:080"
      }
    },
    "action":"on_rating",
    "version":"1.0.0",
    "bap_id":"bap.opungram.com",
    "bap_uri":"https://bap-api.opungram.com/agache/agent/network/",
    "bpp_id":"bpp.opunseva.com",
    "bpp_uri":"https://bpp-api.opunseva.com/agache/agent/network/",
    "transaction_id":"T1",
    "message_id":"M12",
    "timestamp":"2024-03-01T10:00:30.000Z",
    "ttl":"PT10M"
  },
  "message":
  {
    "ack":
    {
      "status":"ACK"
    }
  }
}
```

---

## 6. Attribute Key Definitions

### 6.1 Domain

**Domain**: `opun:livelihood`

This domain is used for all livelihood-related opportunities including job opportunities, internships, and work assignments.

### 6.2 Version

**Version**: `1.0.0`

All APIs use version `1.0.0` unless specified otherwise.

### 6.3 Fulfillment Types

* `remote` - Remote work opportunity
* `hybrid` - Hybrid work opportunity (combination of remote and onsite)
* `onsite` - Onsite work opportunity

### 6.4 Employment Types

* `FULL_TIME` - Full-time employment
* `PART_TIME` - Part-time employment
* `CONTRACT` - Contract-based employment
* `INTERNSHIP` - Internship opportunity
* `FREELANCE` - Freelance work opportunity

### 6.5 Application States

* `APPLICATION-FORM-SUBMITTED` - Application form has been submitted
* `APPLICATION-CONFIRMED` - Application has been confirmed
* `APPLICATION-RECEIVED` - Application received by employer
* `UNDER-REVIEW` - Application is under review
* `SHORTLISTED` - Candidate has been shortlisted
* `INTERVIEW-SCHEDULED` - Interview has been scheduled
* `INTERVIEW-COMPLETED` - Interview has been completed
* `OFFER-EXTENDED` - Job offer has been extended
* `OFFER-ACCEPTED` - Job offer has been accepted
* `OFFER-DECLINED` - Job offer has been declined
* `REJECTED` - Application has been rejected
* `WITHDRAWN` - Application has been withdrawn
* `APPLICATION-CANCELLED` - Application has been cancelled
* `APPLICATION-UPDATED` - Application details have been updated

### 6.6 XInput Form Structure

The `xinput` block is used for job application forms:

* `required` - Boolean indicating if form is required
* `head` - Form metadata including:
  * `descriptor.name` - Form name
  * `index` - Form step information (min, cur, max)
  * `headings` - Array of section headings
* `form` - Form data structure:
  * `mime_type` - MIME type of form data (`application/xml` for XForms 2.0)
  * `data` - XForms 2.0 XML data (inline) - form structure in `on_select`, filled form data in `init`, `on_init`, and `confirm`
  * `resubmit` - Boolean indicating if form can be resubmitted

### 6.7 Quote Structure

The `quote` block provides salary/compensation breakdown:

* `price` - Total compensation:
  * `currency` - Currency code (e.g., "INR")
  * `value` - Total value as string
* `breakup` - Array of compensation components:
  * `title` - Component name (e.g., "Base Salary", "Variable Pay")
  * `price` - Component value:
    * `currency` - Currency code
    * `value` - Component value as string

---

## 7. Application Flow

The job application flow follows this sequence:

1. **search API**: The candidate initiates a search for job opportunities through the BAP, which broadcasts the search intent across the network.

2. **on_search API**: The BPP responds with a comprehensive job catalog containing available opportunities that match the search criteria.

3. **select API**: The candidate selects a specific job opportunity of interest through the BAP.

4. **on_select API**: The BPP provides detailed job information, compensation quote, and the application form structure via XInput using XForms 2.0 XML format (without URL).

5. **Form Rendering and Completion**: 
   - The buyer app renders the XForm structure received in the `on_select` response
   - The candidate completes the form by providing personal details (if not already available), resume/certifications, and responses to role-specific questionnaire items

6. **init API**: The BAP transmits the completed form data in `xinput.form.data` to the BPP for processing.

7. **on_init API**: The BPP stores the submitted form data and returns it to the candidate for review, along with additional order-related information.

8. **Review and Verification**: 
   - The candidate reviews the form data returned in the `on_init` response
   - If any discrepancies are identified, the candidate may abort the transaction at the buyer app and restart the process
   - Upon verification of all information, the candidate proceeds to confirmation

9. **confirm API**: The BAP transmits the verified form data (identical to that received in `on_init`) in the confirm request, and generates an `order.id` for tracking purposes.

10. **on_confirm API**: The BPP validates the form data against the stored information from the `init` request. Upon successful verification, the application is submitted, and the BPP returns the `order.id`.

11. **update/on_update API**: This API supports two operational modes:
    - **Solicited Update**: The BAP initiates a request to modify application details, and the BPP responds with a confirmation of the update
    - **Unsolicited Update**: The BPP proactively sends updates to the BAP, including:
      - Interview scheduling information
      - Application review notes
      - Job offer details
      - Application status changes

12. **status/on_status API**: Enables querying the current status of the application at any point in the process.

13. **cancel/on_cancel API**: Facilitates cancellation of the application by either the candidate (via BAP) or the employer (via BPP).

14. **track/on_track API**: Provides real-time tracking capabilities for monitoring application progress.

15. **support/on_support API**: Retrieves support contact information and assistance resources.

16. **rating/on_rating API**: Allows the candidate to submit feedback and ratings regarding their application experience.

---

## 8. Error Codes

Standard error codes for OPuN Livelihood domain:

* `20001` - Invalid request format
* `20002` - Stale request (BAP)
* `20003` - Invalid domain
* `30001` - Provider not found
* `30002` - Job opportunity not found
* `30003` - Application not found
* `30004` - Invalid form submission
* `30005` - Application already confirmed
* `30006` - Application already cancelled
* `30022` - Stale request (BPP)
* `30023` - Invalid order state for operation

---

## 9. Expected Behavior

### 9.1 Form Submission Flow

1. BPP provides form structure in XForms 2.0 XML format in `/on_select` (NO URL)
2. Buyer app renders the XForm structure
3. Candidate fills the form at buyer app
4. BAP sends filled form data in `/init`
5. BPP stores the form data and returns it back in `/on_init` for candidate review
6. Candidate reviews the form data in `/on_init`
7. If candidate finds discrepancy, they can drop transaction and start again
8. If all is fine, BAP sends same form data in `/confirm`
9. BPP verifies form data in `/confirm` against what was stored in `/init`
10. If verified, BPP confirms application in `/on_confirm`

### 9.2 Order ID Generation

1. BAP generates `order.id` in `/confirm` request for tracking
2. BPP returns `order.id` in `/on_confirm` response (can be same or BPP-generated)
3. All subsequent API calls use this `order.id`

### 9.3 Update Mechanisms

1. **Solicited Updates**: BAP initiates via `/update`, BPP responds via `/on_update`
2. **Unsolicited Updates**: BPP initiates directly via `/on_update` (no `/update` request)
3. Update target specifies which part of order is being updated

### 9.4 Status Tracking

1. Application status is tracked through `fulfillment.state.descriptor.code`
2. Status can be queried via `/status` or received via unsolicited `/on_update`
3. Status history can be maintained by BPP for audit purposes

---

## 10. Compliance

All participants are required to ensure full compliance with this API contract on the OPuN network. Non-compliance may result in rejection of requests/responses with appropriate error codes.

---

## Appendix A: Complete Example Payloads

Complete example payloads for all APIs are available in the `/livelihood-domain/examples/` directory of the OPuN specification repository.


---

**Document Version**: 1.0.0  
**Last Updated**: 2024-12-11  
**Domain**: opun:livelihood  
**API Version**: 1.0.0

