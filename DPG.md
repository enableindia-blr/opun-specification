# OPuN as a Digital Public Good

OPuN (Open Purple Network) is being prepared for submission to the [Digital Public Goods Alliance](https://digitalpublicgoods.net/) registry. This page sets out how the specification meets each indicator of the [DPG Standard](https://digitalpublicgoods.net/standard/), with links to the evidence in this repository.

OPuN is an open, consent-based network protocol that connects Persons with Disabilities to jobs, learning and financial services across any participating platform. It is published as an open, royalty-free public good: any government department, system integrator, NGO, employer, training provider, lender or startup can implement it without licence fees or vendor lock-in.

## 1. Relevance to the Sustainable Development Goals

OPuN is relevant to **SDG 8 (Decent Work and Economic Growth)** and **SDG 10 (Reduced Inequalities)**. Both goals name persons with disabilities in their targets and indicators, so OPuN's relevance is direct, not incidental.

### SDG 8: Decent Work and Economic Growth

| Target | UN target (abridged) | How OPuN advances it | Evidence |
| --- | --- | --- | --- |
| **8.5** | Full and productive employment and decent work for all, *including persons with disabilities*, and equal pay for work of equal value | An open, interoperable job network for PwDs. Any employer or job platform can publish opportunities, and any seeker app can discover and apply for them, across the whole lifecycle from discovery to joining. Salary is published openly in every job posting. | Livelihood domain (`opun:livelihood`); `schema:JobPosting` with mandatory `baseSalary` (§7.1 of the [livelihood specification](./opun_livelihood_domain_spec_2_0_0.md)); application lifecycle states (§8) |
| **8.6** | Reduce the proportion of youth not in employment, education or training | Learning and job opportunities sit on the same network, so a young PwD can move from a course to a credential to a job. | [Learning domain](./learning-domain-2.0/) (`opun:learning`); course-completion credentials (SD-JWT VC) that can be presented to employers ([VC flow](./VC/VC_Readme.md)) |
| **8.10** | Expand access to banking, insurance and financial services for all | Lenders and inclusion-focused finance providers can offer loan products to PwDs through the same open rails. | [Loan domain](./loan/) (`opun:loan`): product discovery, application and status |

UN indicator **8.5.2** (unemployment rate by sex, age and *persons with disabilities*) is the outcome metric OPuN deployments can report against.

### SDG 10: Reduced Inequalities

| Target | UN target (abridged) | How OPuN advances it | Evidence |
| --- | --- | --- | --- |
| **10.2** | Empower and promote the social, economic and political inclusion of all, *irrespective of … disability* | Removes the platform silos that keep PwDs out of mainstream job and skilling markets: any platform can join the network and serve PwD users. | Beckn 2.0 open network and DeDi participant registry; accessibility metadata on every job (`accessibilityMetadata.suitableDisabilityTypes` in the [livelihood attributes](./livelihood-domain-2.0/schema/livelihood/v1/schema-extension/attributes.yaml)) |
| **10.3** | Ensure equal opportunity and reduce inequalities of outcome, including by eliminating discriminatory practices | With selective disclosure, a candidate shares only what a job needs (a skill, an eligibility), not their full disability or medical record. Disability appears as a suitability condition the job declares, not as a property used against the candidate. Data handling is consent-based and purpose-bound. | [VC flow](./VC/VC_Readme.md) (OpenID4VC, SD-JWT selective disclosure); consent principles (§17 of the livelihood specification) |

**In one paragraph:** OPuN is an open, consent-based network protocol that connects Persons with Disabilities to jobs, skilling and finance across any participating platform. It directly advances SDG 8.5 (decent work for all, including persons with disabilities), SDG 8.6 (youth in employment, education or training) and SDG 8.10 (access to financial services). It also advances SDG 10.2 and 10.3 (inclusion irrespective of disability, and equal opportunity) through interoperable participating platforms and privacy-preserving verifiable credentials that let candidates prove their skills without revealing sensitive disability data.

## 2. Open licence

The specification, schemas, contexts, vocabularies and examples are licensed under the [Apache License 2.0](./LICENSE), an OSI-approved licence. See [NOTICE](./NOTICE).

## 3. Clear ownership

Copyright is held by Plotch.ai, which originally developed the specification. The specification is stewarded by Enable India, a disability-sector non-profit, as an open public good. See [NOTICE](./NOTICE).

## 4. Platform independence

OPuN depends only on open standards: Beckn Protocol Core v2.0.0, JSON-LD 1.1, schema.org, W3C DIDs, OpenID4VCI / OpenID4VP, SD-JWT VC, Ed25519 / X25519 and XForms. Participant discovery uses DeDi, an open registry protocol. No proprietary product or service is required to implement OPuN. Organisations named in examples are illustrative and can be replaced by any conforming implementation.

## 5. Documentation

- [README](./README.md): overview, domains, repository structure, getting started.
- [Livelihood specification](./opun_livelihood_domain_spec_2_0_0.md): normative rules, lifecycle, conformance criteria.
- Schema packs and example payloads for every API in the [livelihood](./livelihood-domain-2.0/), [learning](./learning-domain-2.0/) and [loan](./loan/) domains.
- [Verifiable credential flow](./VC/VC_Readme.md): issuance and presentation with full examples.

## 6. Mechanism for extracting non-PII data

All catalog, schema and transaction data in OPuN is exchanged in open formats: JSON, JSON-LD and YAML. Implementations can export and import non-personal data, such as job catalogs and course catalogs, in these formats without conversion.

## 7. Adherence to privacy and applicable laws

OPuN is designed for compliance with data-protection and disability law. In India these are the Digital Personal Data Protection Act 2023, the Rights of Persons with Disabilities Act 2016 and the Information Technology Act 2000; implementations in other countries must comply with their local equivalents. The specification requires:

- explicit, user-provided data only, purpose-bound to the transaction, with no secondary use without consent (§17.2);
- minimised personal data, mandatory transport security, and no sensitive data in logs (§19);
- no central identity provider (§17.1).

## 8. Adherence to standards and best practices

See [Standards used](./README.md#standards-used) in the README for the full list with links. The verifiable credential flow is aligned with OpenID4VCI and OpenID4VP; it has not yet been run through the OpenID Foundation conformance suite.

## 9. Do no harm by design

### 9a. Data privacy and security

- Every network message is signed (Ed25519 over a SHA-256 body digest), and participant keys are published in the registry, so any party can verify who sent a message and that it was not altered.
- Verifiable credentials are holder-bound and use selective disclosure: a candidate can prove one fact ("certified in X", "18+") without revealing the rest of the credential.
- Sensitive disability data is shared only with the candidate's consent, as part of the application they submit (§17.2).
- Example payloads in this repository are illustrative and must not contain real personal data.

### 9b. Inappropriate and illegal content

OPuN is a protocol and does not host user content. Each participating platform is responsible for moderating the content it publishes to the network (for example job postings, course listings and loan products) and for removing illegal or discriminatory content.

### 9c. Protection from harassment

Participating platforms must give users a way to report abuse and raise grievances; the `/support` and `/on_support` APIs carry support contact details for every transaction. The livelihood network serves adult job seekers.
