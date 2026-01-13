# OpuN Network Specification

This repository contains the OpuN Network Specification, which builds upon Beckn Protocol v2.0.0 to enable open protocol-based unemployment (OpuN) services for job opportunities and employment.

## Overview

The OpuN Network Specification extends Beckn Protocol v2.0.0 with domain-specific schemas and APIs for:

- **Job Discovery**: Search and discover job opportunities across multiple platforms
- **Application Management**: Streamlined job application processes
- **Employment Services**: End-to-end hiring workflow management

## Architecture

This specification follows Beckn v2.0.0 principles:

- **JSON-LD + schema.org alignment** for global semantic interoperability
- **Core + Schema Packs** for design-time composability
- **CDS-centric discovery** with asynchronous catalog publication
- **DeDi-compliant registry** for decentralized identity management

## Directory Structure

```
opunnetwork-specification/
├── README.md                          # This file
├── schema/
│   └── livelihood/
│       └── v1/
│           ├── attributes.yaml         # Domain-specific attributes
│           ├── context.jsonld          # JSON-LD context
│           ├── vocab.jsonld           # RDF vocabulary
│           └── examples/
│               └── select/
│                   ├── select.json     # Select request example
│                   └── on_select.json  # On select response example
```

## Domain: Livelihood

The Livelihood domain provides schemas for job opportunities, employment services, and related workflows.

### Key Entities

- **JobOpportunity**: Represents a job opening with detailed requirements
- **EmploymentType**: Type of employment contract (FULL_TIME, PART_TIME, etc.)
- **WorkMode**: Work arrangement (REMOTE, ONSITE, HYBRID)
- **ApplicationStatus**: Status of job application in recruitment process

### Core Flows

1. **Discovery**: Search for job opportunities using Beckn v2.0.0 discovery APIs
2. **Selection**: Select job opportunities and view detailed requirements
3. **Application**: Submit applications through standardized forms
4. **Tracking**: Monitor application status and interview schedules

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
