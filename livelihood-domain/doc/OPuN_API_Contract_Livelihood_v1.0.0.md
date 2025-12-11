# OPuN API Contract for Livelihood Domain v1.0.0

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-12-XX | Initial version - Livelihood domain API contract |

---

## 1. Introduction

OPuN (OPuN Networks) API contracts map business requirements for livelihood opportunities (job opportunities, internships, work assignments) to a set of attribute keys in different APIs and ensures interoperability, between a Buyer App Platform (BAP) & Seller App Platform (BPP), as follows:

* by defining the set of attribute keys that need to be exchanged to establish a handshake between the BAP & BPP;
* clearly defining the single source of truth for each attribute key and thereby establishing mutability & immutability of these keys on behalf of the participants at each end of the transaction;

This API contract document is structured as follows:

* JSON payload for each API request & response;
* Definition & enumerations of specific attribute keys, as applicable;
* Examples of usage of specific attribute keys for a business requirement, as applicable;
* Expected behaviour of APIs on the network;

Livelihood API contract includes the following APIs:

### 1.1 Pre-order APIs

* `/search` - BAP specifies the search intent for job opportunities;
* `/on_search` - BPP responds with the job catalog based on the search intent;
* `/select` - BAP specifies the job opportunity selected by the candidate;
* `/on_select` - BPP responds with detailed job information, quote, and application form (XInput);
* `/init` & `/on_init` - BAP submits filled application form and BPP returns submitted form data for verification;
* `/confirm` - BAP places the job application on behalf of the candidate;
* `/on_confirm` - BPP responds to the application placed either through auto-acceptance or deferred acceptance or rejection;

### 1.2 Post-order APIs

* `/status` - BAP requests for the current status of the application;
* `/on_status` - BPP provides the current status of the application;
* `/cancel` - BAP places cancellation request for the application;
* `/on_cancel` - BPP responds to the BAP cancellation request or cancels the application directly;
* `/update` - BAP initiates an update request (for application details) on behalf of the candidate;
* `/on_update` - BPP responds to the BAP update request or initiates an unsolicited update (interview schedule, notes, offer, etc.) directly;
* `/track` - BAP requests for tracking of application progress;
* `/on_track` - BPP responds with tracking details for application;
* `/support` - BAP requests support information;
* `/on_support` - BPP responds with support information;
* `/rating` - BAP submits rating for the application experience;
* `/on_rating` - BPP acknowledges the rating;

All attribute keys, defined in this API contract, are mandatory, unless explicitly mentioned otherwise. Participants may validate the request & response payloads, based on mandatory attribute keys, as defined in this contract and respond with "NACK" (along with appropriate error code as defined here) for invalid payloads. Any payload, without optional attribute keys, cannot be considered as invalid.

This API contract has been defined after incorporating requirements for livelihood opportunities domain.

All participants are required to ensure full compliance with this API contract on the OPuN network.

---

## 2. Signing & Verification of requests & responses

1. Key pairs, for signing & encryption, can be generated using any standard library e.g. libsodium, Bouncy Castle, etc.
2. Creating key pairs
   * Create key pairs, for signing (ed25519) & encryption (X25519);
   * Update base64 encoded public keys in registry;
   * Utility to generate signing key pairs and test signing & verification is available in the OPuN registry documentation;
3. Auth Header Signing
   * Generate UTF-8 byte array from json payload;
   * Generate Blake2b hash from UTF-8 byte array;
   * Create base64 encoding of Blake2b hash, this becomes the digest for signing;
   * Sign the request, using your private signing key, and add the signature to the request authorization header;
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
3. Every participant on the OPuN registry will have one or more entries in the registry, with unique identifier ("ukid") for each such entry;
4. Signing & Verification of requests and responses using auth headers is defined in section 2;
5. All requests & responses have to be signed by the sender and verified by the receiver. If any request fails verification, it should be rejected (NACK'd) with http 401 error code;
6. The identity of the sender of a request is sent, through the auth header, as follows:
   ```
   keyId="{subscriber_id}|{unique_key_id}|{algorithm}"
   ```
7. Signing by all participants will be using their private key, for which the corresponding public key will be in the registry for their "ukid";
8. Verification of requests is using registry lookup. Participants can either use the registry lookup endpoints or cache the registry locally (with refresh at regular interval) for a local lookup;
9. Following options are available:
   * `/lookup`
     ```
     request:
     {
         "subscriber_id":"bap.opungram.com",
         "domain":"opun:livelihood",
         "ukId":"UKID1",
         "country":"IND",
         "city":"std:080",
         "type":"BAP"
     }
     response:
     [
         {
             "subscriber_id":"bap.opungram.com",
             "status":"SUBSCRIBED",
             "ukId":"UKID1",
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

---

## 4. Construct of APIs & transaction trail

1. All APIs follow the same construct and include:
   * Context - includes transaction_id, message_id and other attribute keys that identify the source & destination of the message being sent through the API request or response;
   * Message - identifies the content of the message e.g. the search intent, catalog details, order details, etc.;
2. All APIs are asynchronous, i.e.:
   * request is sent from sender to recipient;
   * recipient acknowledges the request by sending an "ACK" (or "NACK" if they cannot validate the request);
   * recipient sends response through the callback for the corresponding request API e.g. `/on_search` callback for `/search` request;
   * recipient of callback (could be the original sender) acknowledges the response by sending an "ACK" (or "NACK" if they cannot validate the request);
3. Every request & response pair is identified by a transaction_id + unique message_id & the sender of a request is able to correlate the response to the request using the above;
4. If a stale request or response is received, i.e. with timestamp earlier than similar request or response (identified by the transaction_id + message_id) that has already been processed, the recipient can send "NACK" with the error code "20002" (BAP) and "30022" (BPP);
5. Error block can be sent in sync (in response to request) or async (along with callback) mode and should have the following attribute keys: error.type, error.code;
6. OPuN standard error codes are defined in the error codes specification document;
7. Transaction trail for a candidate is maintained through a unique transaction_id for the pre-order stage, i.e. `/search`, `/select`, `/init`, `/confirm`. However, considering that most buyer apps cache catalogs that are reused by multiple candidates, for providing a good candidate experience, a unique transaction_id is maintained for `/select`, `/init` & `/confirm`.
8. Buyer apps with live search functionality can use the same transaction_id across the entire pre-order stage;
9. Unique id for an application on a network will be identified by the transaction_id & order id;


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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
              "url":"https://bpp-api.opunseva.com/agache/agent/network/application/form-submit",
              "data":"<?xml version=\"1.0\" encoding=\"UTF-8\"?><xf:model xmlns:xf=\"http://www.w3.org/2002/xforms\"><xf:instance><data><personal_info><full_name/><date_of_birth/><gender/><address/><phone/><email/></personal_info><professional_experience><current_company/><current_position/><years_of_experience/><previous_companies/></professional_experience><skills_qualifications><education><degree/><field/><university/><year/></education><skills/><certifications><name/><issuer/><year/></certifications></skills_qualifications><documents><resume/><cover_letter/><portfolio/></documents><role_questionnaire><question1/><question2/><question3/></role_questionnaire></data></xf:instance><xf:submission id=\"submit\" method=\"post\" action=\"https://bpp-api.opunseva.com/agache/agent/network/application/form-submit\" replace=\"instance\"/></xf:model>",
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
1. The `xinput` block contains the application form fields in XForms 2.0 XML format;
2. Form fields are sent inline via `form.data` in XForms 2.0 XML;
3. The form captures: Candidate personal details (if not already known), Resume/certifications, Role-specific questionnaire responses;
4. On form submission, the XForms engine will POST to `xf:submission/@action` URL;
5. BPP validates the payload, generates `submission_id`, and returns it to BAP via form-submit response;

---

### 5.5 /init

BAP sends `submission_id` in the init request after form submission.

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
    "version":"1.1.0",
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
              "submission_id":"8203501c-8934-468c-b947-1d5317847e9a"
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
1. The `submission_id` is obtained from the form-submit response after candidate fills and submits the application form;
2. BAP sends only the `submission_id` in the init request;
3. BPP retrieves the form data using the `submission_id`;

---

### 5.6 /on_init

BPP returns submitted form data (from submission_id) for verification by candidate along with other information.

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
    "version":"1.1.0",
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
            "form":
            {
              "mime_type":"application/xml",
              "submission_id":"8203501c-8934-468c-b947-1d5317847e9a",
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
1. BPP returns the submitted form data retrieved using `submission_id` for candidate verification;
2. Form data is returned in XML format matching the XForms structure;
3. Candidate can review all submitted information before confirming the application;
4. State indicates "APPLICATION-FORM-SUBMITTED - Pending Verification";

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
    "version":"1.1.0",
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
          "fulfillment_ids":["1"]
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
2. This is the final confirmation step where candidate confirms the application;
3. All order details must match what was verified in `/on_init`;

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
    "version":"1.1.0",
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
1. BPP returns `order.id` (can be same as BAP's or BPP-generated);
2. State indicates "APPLICATION-CONFIRMED";
3. Tracking is enabled (`tracking: true`) for post-order APIs;
4. This `order.id` will be used for all subsequent API calls (`status`, `update`, `cancel`, etc.);

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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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
    "version":"1.1.0",
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

**Version**: `1.1.0`

All APIs use version `1.1.0` unless specified otherwise.

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
  * `url` - Form submission URL
  * `data` - XForms 2.0 XML data (inline)
  * `submission_id` - Unique ID returned after form submission
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

1. **search API**: Candidate searches for job opportunities
2. **on_search API**: BPP responds with job catalog
3. **select API**: Candidate selects a job opportunity
4. **on_select API**: BPP responds with detailed job information, quote, and form fields via XInput (XForms 2.0 XML)
5. **Form Submission**: 
   - Form fields are provided inline via XForms 2.0 XML in `xinput.form.data`
   - Form captures: Candidate personal details (if not already known), Resume/certifications, Role-specific questionnaire responses
   - XForms engine POSTs to `xf:submission/@action` URL (form-submit endpoint)
   - BPP validates the payload, generates `submission_id`, and returns it to BAP via form-submit response
6. **init API**: BAP sends `submission_id` in the init request
7. **on_init API**: BPP returns submitted form data (from submission_id) for verification by candidate along with other information
8. **confirm API**: Candidate confirms and submits job application (BAP generates `order.id`)
9. **on_confirm API**: BPP responds with confirmation and application details (BPP returns `order.id`)
10. **update/on_update API**: Can be used in two ways:
    - **Solicited Update**: BAP requests to update application details → BPP responds with confirmation
    - **Unsolicited Update**: BPP sends updates to BAP such as:
      - Interview schedule
      - Application notes
      - Job offer details
      - Status changes
11. **status/on_status API**: Used to check the current status of application
12. **cancel/on_cancel API**: Used to cancel the application
13. **track/on_track API**: Used to track application progress
14. **support/on_support API**: Used to get support information
15. **rating/on_rating API**: Used to rate the application experience

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

1. BPP provides form fields in XForms 2.0 XML format in `/on_select`
2. Candidate fills the form using XForms engine
3. Form is submitted to BPP's form-submit endpoint
4. BPP validates and generates `submission_id`
5. BAP sends `submission_id` in `/init`
6. BPP returns form data for verification in `/on_init`
7. Candidate confirms application in `/confirm`

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

Complete example payloads for all APIs are available in the `/examples/work-opportunities/` directory of the OPuN specification repository.

---

## Appendix B: References

* OPuN Protocol Specification
* Beckn Protocol Core Specification
* XForms 2.0 Specification
* OPuN Registry Documentation
* OPuN Error Codes Specification

---

**Document Version**: 1.0.0  
**Last Updated**: 2024-12-XX  
**Domain**: opun:livelihood  
**API Version**: 1.1.0

