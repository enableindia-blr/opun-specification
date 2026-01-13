# OpuN Network Specification

This repository contains the OpuN Network Specification, which builds upon Beckn Protocol v2.0.0 to enable open protocol-based unemployment (OpuN) services for job opportunities and employment.

## Overview

The OpuN Network Specification extends Beckn Protocol v2.0.0 with comprehensive domain-specific schemas and APIs for the complete job market ecosystem:

- **Job Discovery & Catalog Management**: Advanced search, filtering, and catalog publication of job opportunities across multiple platforms
- **Application Lifecycle Management**: Complete application workflow from submission to offer acceptance including form validation, document management, and status tracking
- **Interview & Assessment Process**: Structured interview scheduling, process management, and assessment tracking
- **Employment Services**: End-to-end hiring workflow management including job offers, candidate profiles, and fulfillment tracking
- **Candidate Experience**: Seamless experience for job seekers with profile management, application tracking, and communication

## Architecture

This specification extends Beckn v2.0.0 with livelihood domain-specific capabilities:

- **Comprehensive Schema Pack**: 8 domain-specific attribute schemas covering jobs, applications, interviews, offers, and fulfillment
- **JSON-LD + schema.org alignment** for global semantic interoperability in HR and recruitment contexts
- **Core + Schema Packs** for design-time composability with standardized livelihood domain extensions
- **CDS-centric discovery** with asynchronous catalog publication for job opportunity marketplaces
- **DeDi-compliant registry** for decentralized identity management of employers and job seekers
- **Complete API Flows**: 8 comprehensive API flows covering the entire recruitment lifecycle from discovery to joining

## Directory Structure

```
livelihood-domain-2.0/
├── README.md                          # This file
└── schema/
    └── livelihood/
        └── v1/
            ├── attributes.yaml         # Domain-specific attributes
            ├── context.jsonld          # JSON-LD context
            ├── vocab.jsonld           # RDF vocabulary
            └── examples/
                ├── cancel/
                │   ├── cancel.json
                │   └── on_cancel.json
                ├── confirm/
                │   ├── confirm.json
                │   └── on_confirm.json
                ├── discover/
                │   ├── catalog_publish.json
                │   ├── discover.json
                │   └── on_discover.json
                ├── init/
                │   ├── init.json
                │   └── on_init.json
                ├── select/
                │   ├── on_select.json
                │   └── select.json
                ├── status/
                │   ├── on_status.json
                │   └── status.json
                ├── support/
                │   ├── on_support.json
                │   └── support.json
                └── update/
                    ├── on_update_confirmation.json
                    ├── on_update_job_offer_accepted.json
                    ├── on_update_job_offer.json
                    ├── on_update_joining_confirmed.json
                    ├── on_update.json
                    ├── update_job_offer_accepted.json
                    └── update.json
```

## Domain: Livelihood

The Livelihood domain provides schemas for job opportunities, employment services, and related workflows.

### Key Entities

- **JobOpportunityAttributes**: Comprehensive job posting details including salary, skills, benefits, and application requirements
- **ApplicationFormAttributes**: Structured application forms with required fields and submission URLs
- **InterviewProcessAttributes**: Interview scheduling and process management including stages, types, and modes
- **ApplicationStatusAttributes**: Complete application tracking with status codes from submission to joining
- **CandidateProfileAttributes**: Job seeker profiles with resume, portfolio, experience, and preferences
- **LivelihoodJobOfferAttributes**: Detailed job offers with salary breakdowns, benefits, and employment terms
- **LivelihoodApplicationAttributes**: Application management with forms, documents, and submission tracking
- **LivelihoodFulfillmentAttributes**: End-to-end fulfillment tracking including verification, interviews, and status updates

### Core Flows

1. **Discovery**: Search and browse job opportunities using Beckn v2.0.0 discovery APIs with catalog publication
2. **Selection**: Select specific job opportunities and view detailed requirements
3. **Initialization**: Initialize the application process with candidate information
4. **Confirmation**: Confirm job applications and process submissions
5. **Status Tracking**: Monitor application status, interview schedules, and progress updates
6. **Updates**: Handle job offer responses, confirmation updates, and status changes
7. **Support**: Access customer support and assistance throughout the process
8. **Cancellation**: Cancel applications or withdraw from processes when needed

## Getting Started

### Prerequisites

- Beckn Protocol v2.0.0 compatible implementation
- JSON-LD processing capabilities
- DeDi-compliant registry integration

### Implementation Guide

1. **Schema Adoption**: Use the provided livelihood schema pack
2. **Context Integration**: Include livelihood context in your JSON-LD documents
3. **API Compliance**: Implement Beckn v2.0.0 APIs with livelihood extensions

## Examples

See the `examples/` directory for complete request/response examples in JSON-LD format.

## Contributing

Contributions are welcome! Please refer to the Beckn Protocol contribution guidelines.

## License

This specification is licensed under the MIT License.

## Related Specifications

- [Beckn Protocol v2.0.0](https://github.com/beckn/protocol-specifications)
- [DeDi Protocol](https://dedi.global)
- [Schema.org](https://schema.org)
