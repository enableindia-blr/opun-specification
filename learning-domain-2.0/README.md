# Learning Domain Specification (Courses)

This repository contains the **Learning Domain** specification for **courses** (physical, online, hybrid), built on **Beckn Protocol v2.0.0**, in the same way the OPuN Livelihood domain extends Beckn for jobs and employment.

## Overview

The Learning Domain extends Beckn 2.0 with:

- **Course discovery & catalog** – Search and browse courses by subject, level, delivery mode, location, and price.
- **Enrollment lifecycle** – From search → select → init → confirm → progress → completion/certificate.
- **Physical, online, and hybrid delivery** – Single schema for all delivery modes (`courseType`: online, offline, hybrid, self_paced, instructor_led).
- **Credentials** – Certificates (completion, participation, achievement, professional) as fulfillment outcomes, with optional verifiable credentials.

**Implementation alignment:** The schema is aligned with **groclake_learning_manager** (intents for course, enrollment, content, progress, certificate), **groclake-frontend** (Automation → L&D: seller maintains courses, processes enrollments, issues certificates), and **opungram-frontend** (My Account → Training and courses: buyer browses, enrolls, sees progress, gets certification).

## Design and Planning

- **[LEARNING_DOMAIN_SCHEMA_DESIGN.md](./LEARNING_DOMAIN_SCHEMA_DESIGN.md)** – Full schema extension design: entity mapping, attributes, lifecycle states, API flows, directory layout, and next steps.

## Directory Structure

```
learning-domain-2.0/
├── README.md
├── LEARNING_DOMAIN_SCHEMA_DESIGN.md
└── schema/
    └── learning/
        └── v1/
            ├── schema-extension/
            │   ├── attributes.yaml
            │   ├── context.jsonld
            │   └── vocab.jsonld
            └── examples/           # (to be populated)
                ├── discover/
                ├── search/
                ├── select/
                ├── init/
                ├── confirm/
                ├── status/
                ├── update/
                ├── support/
                └── cancel/
```

## Domain Identification

- **Domain (in context):** `opun:learning`
- **Fulfillment category:** `COURSE` (or equivalent as finalized)

## Key Entities (Beckn → Learning)

| Beckn       | Learning              |
|------------|------------------------|
| Item       | Course / course offering |
| Provider   | Institution / academy / educator |
| Order      | Enrollment             |
| Fulfillment| Enrollment progress, completion, certificate |

## Status

- **Schema design:** Done (see LEARNING_DOMAIN_SCHEMA_DESIGN.md).
- **Schema extension files:** Skeleton in place (attributes, vocab, context).
- **Examples & normative spec:** To be added in follow-up work.

## References

- [Beckn Protocol v2.0.0](https://github.com/beckn/protocol-specifications)
- [OPuN Livelihood Domain 2.0](../livelihood-domain-2.0/)
- [Schema.org – Course, LearningResource](https://schema.org/Course)
