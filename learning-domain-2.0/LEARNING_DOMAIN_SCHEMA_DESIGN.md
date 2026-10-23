# Learning Domain – Schema Extension Design (Beckn 2.0)

**Status:** Design / Planning (schema aligned with implementation)  
**Base:** Beckn Protocol Core v2.0.0  
**Domain:** Learning (Courses – Physical / Online / Hybrid)

**Implementation reference:** `groclake_learning_manager`, groclake-frontend (Automation → L&D), opungram-frontend (My Account → Training and courses).

---

## 1. Purpose and Scope

This document plans and designs the **schema extension** for a **Learning Domain** (courses) built on top of Beckn 2.0, analogous to the OPuN Livelihood Domain.

- **In scope:** Course discovery, enrollment lifecycle, delivery (physical, online, hybrid), assessments, and credentials.
- **Out of scope:** Modifications to Beckn Core; UI/UX or platform-specific policies.

---

## 2. Design Principles (Aligned with Livelihood)

| Principle | Application |
|-----------|-------------|
| **Beckn Core unchanged** | All transactions use Beckn 2.0 actions, context, and envelope. |
| **Domain semantics in extension** | Learning-specific meaning lives in attributes, vocab, and context only. |
| **JSON-LD + schema.org** | Reuse and extend schema.org learning/education terms where applicable. |
| **Core + Schema Packs** | Learning domain = one schema pack composable with Beckn Core. |

---

## 3. Domain Identification

- **Domain code (in context):** `opun:learning`
- **Namespace:** `https://opun.network/schema/learning/v1/`
- **Fulfillment category:** `COURSE` (or equivalent as finalized)

All learning transactions **must** declare the learning domain in `context.domain` as `opun:learning` and use the learning JSON-LD context.

---

## 4. Beckn Entity Mapping (Learning Interpretation)

| Beckn Core Entity | Learning Domain Interpretation |
|-------------------|---------------------------------|
| **Catalog / Item** | Course or course offering (with schedule, delivery mode, price). |
| **Provider** | Learning provider: institution, training center, academy, or individual educator. |
| **Category** | Course category / subject / level (e.g. "Programming", "Certification", "Language"). |
| **Order** | Enrollment (one enrollment per learner per course offering). |
| **Fulfillment** | Enrollment fulfillment: progress, attendance, assessments, completion, certificate. |
| **Quote** | Course fee (one-time or instalments). |
| **XInput** | Enrollment form, prerequisites declaration, preferences. |
| **Payment** | Course fee payment (if applicable; can be informational like Livelihood salary). |

---

## 5. Key Domain Entities and Attributes (Schema Extension)

### 5.1 Course (Item) – `LearningCourseAttributes` / `CourseOffering`

Attributes to define in **attributes.yaml** (scope: **Item** or **Category** as appropriate):

| Attribute | Type | Scope | Description |
|-----------|------|--------|-------------|
| `courseCode` | string | Item | Unique identifier/code for the course or offering. |
| `courseName` | string | Item | Title of the course (may align with `descriptor.name`). |
| `description` | string | Item | Long description (may align with `descriptor.longDesc`). |
| `deliveryMode` | enum | Item | `PHYSICAL`, `ONLINE`, `HYBRID`. |
| `duration` | duration (ISO 8601) or object | Item | Total course duration (e.g. "PT40H" or 8 weeks). |
| `schedule` | object/array | Item | Start date, end date, session timings, timezone. |
| `language` | string (e.g. BCP 47) | Item | Medium of instruction. |
| `level` | enum | Item | e.g. `BEGINNER`, `INTERMEDIATE`, `ADVANCED`, `ALL`. |
| `prerequisites` | array | Item | Required prior knowledge, courses, or qualifications. |
| `learningOutcomes` | array | Item | What the learner will be able to do after completion. |
| `syllabus` / `curriculum` | array or URL | Item | Topics, modules, or link to syllabus. |
| `maxParticipants` | integer | Item | Seat capacity (for physical/hybrid). |
| `credentialType` | enum | Item | e.g. `CERTIFICATE`, `DIPLOMA`, `BADGE`, `NONE`. |
| `accreditation` | array/object | Item | Recognitions, accrediting bodies. |
| `location` | object | Item | Venue (for physical/hybrid): address, city, pincode, etc. |
| `onlineMeetingInfo` | object | Item | For online/hybrid: platform, meeting link template, etc. |
| `accessibilityMetadata` | object | Item | Optional: accessibility accommodations (similar to Livelihood). |

### 5.2 Provider – Learning Provider

| Attribute | Type | Scope | Description |
|-----------|------|--------|-------------|
| `providerType` | enum | Provider | e.g. `INSTITUTION`, `TRAINING_CENTER`, `ACADEMY`, `INDIVIDUAL_EDUCATOR`. |
| `accreditation` | array | Provider | Institutional accreditations. |
| `website` | uri | Provider | Provider website. |
| `learnerSupport` | object | Provider | Support channels (email, chat, hours). |

### 5.3 Enrollment (Order) – `LearningEnrollmentAttributes`

| Attribute | Type | Scope | Description |
|-----------|------|--------|-------------|
| `enrollmentId` | string | Order | Unique enrollment reference. |
| `enrolledAt` | date-time | Order | When the learner enrolled. |
| `preferences` | object | Order | Preferred batch, language, etc. (if captured in XInput). |

### 5.4 Fulfillment – `LearningFulfillmentAttributes`

| Attribute | Type | Scope | Description |
|-----------|------|--------|-------------|
| `enrollmentStatus` | enum | Fulfillment.state | See §6. |
| `progressPercentage` | number | Fulfillment | 0–100. |
| `attendanceSummary` | object | Fulfillment | Sessions attended / total (if applicable). |
| `assessmentResults` | array | Fulfillment | Grades/scores per assessment (if shared). |
| `completedAt` | date-time | Fulfillment | When course was completed. |
| `certificate` | object | Fulfillment | Certificate ID, URL, issuer, credential type. |
| `nextSession` | object | Fulfillment | Next class/session info (for status updates). |

### 5.5 Price (Quote) – Course Fee

| Attribute | Type | Scope | Description |
|-----------|------|--------|-------------|
| `feeType` | enum | Price | e.g. `ONE_TIME`, `INSTALMENT`, `SUBSCRIPTION`. |
| `currency` / `minimum` / `maximum` | (existing) | Price | As in Beckn Core. |
| `paymentDeadline` | date-time | Price | Last date to pay (if applicable). |

---

## 6. Enrollment Lifecycle (Fulfillment States)

**Aligned with implementation** (`groclake_learning_manager_schema`: `EnrollmentStatus`, `EnrollmentStage`).

### 6.1 Enrollment status (`enrollmentStatus`)

| Value | Description |
|-------|-------------|
| `pending` | Enrollment submitted; awaiting provider confirmation. |
| `confirmed` | Provider confirmed enrollment. |
| `in_progress` | Learner is actively taking the course. |
| `completed` | Course completed. |
| `cancelled` | Enrollment cancelled. |
| `failed` | Enrollment failed (e.g. prerequisite not met). |

### 6.2 Enrollment stage (`enrollmentStage`)

| Value | Description |
|-------|-------------|
| `applied` | Learner has applied (form submitted). |
| `enrolled` | Enrolled and confirmed. |
| `started` | Course has started for this learner. |
| `in_progress` | In progress. |
| `assessment` | In assessment phase. |
| `completed` | Completed. |

States should be **monotonic** where applicable. Use `enrollmentStatus` for high-level state and `enrollmentStage` for finer-grained lifecycle (e.g. applied → enrolled → started → in_progress → assessment → completed).

---

## 7. Tag Groups (Extensibility)

Following the Livelihood pattern, define **tagGroups** in **attributes.yaml** for flexible extension:

- **course-details:** duration, level, language, credential type, syllabus link.
- **delivery:** delivery mode, location, online platform, schedule.
- **enrollment:** enrollment ID, batch, preferences.
- **progress:** progress percentage, last accessed, next session.
- **assessment:** assessment type, score, passed/failed, feedback.
- **certificate:** credential ID, issuer, verification URL.

---

## 8. Vocabulary (vocab.jsonld)

Define RDF classes and properties for:

- **Classes:** `LearningCourse`, `CourseOffering`, `DeliveryMode`, `EnrollmentStatus`, `LearningProvider`, `LearningEnrollmentAttributes`, `LearningFulfillmentAttributes`, `Credential`, `Schedule`, `Prerequisite`, `LearningOutcome`.
- **Enums (as classes or enumeration):** `DeliveryMode` (PHYSICAL, ONLINE, HYBRID), `EnrollmentStatus` (values as above), `CredentialType`, `CourseLevel`.
- **Properties:** All attributes in §5 as RDF properties with `schema:domainIncludes` and `schema:rangeIncludes` where appropriate; align with schema.org (e.g. `Course`, `EducationalOccupationalProgram`, `LearningResource`) where it fits.

Namespace: e.g. `learning:` → `https://opun.network/schema/learning/v1/`.

---

## 9. Context (context.jsonld)

- **@context:** Merge Beckn Core context and learning vocab so that:
  - Beckn core terms remain under `beckn:`.
  - Learning terms use `opun:` or `learning:` prefix and point to the learning vocab IRI.
- Include all classes and properties used in examples and in the attribute schemas so that JSON payloads can be compact (short names without full IRIs).

---

## 10. API Flows (Same as Beckn 2.0)

| Flow | Learning semantics |
|------|--------------------|
| **Discover** | Provider publishes course catalog (on_discover / catalog). |
| **Search** | Learner/BAP searches by keyword, category, delivery mode, location, level, price. |
| **Select** | Get course details, fee quote, and XInput (enrollment form). |
| **Init** | Learner submits filled enrollment form (and optionally preferences). |
| **Confirm** | Confirm enrollment; provider accepts and returns enrollment ID. |
| **Status** | Current enrollment state, progress, next session. |
| **Update** | Batch change, schedule change, progress update, certificate issued, cancellation by provider. |
| **Support** | Learner or provider requests support. |
| **Cancel** | Learner or provider cancels enrollment (policy on refunds is domain/business rule). |

---

## 11. XInput (Enrollment / Registration Form)

- **Governance:** Same as Livelihood – form schema immutable after `/on_select`; filled data echoed in init/confirm/on_init/on_confirm.
- **Typical fields:** Name, contact, email, prerequisites declaration, preferred batch/language, special requirements (e.g. accessibility), consent for communications.

---

## 12. Directory Structure (Proposed)

```
learning-domain-2.0/
├── README.md
├── LEARNING_DOMAIN_SCHEMA_DESIGN.md   # This document
└── schema/
    └── learning/
        └── v1/
            ├── schema-extension/
            │   ├── attributes.yaml    # All attributes + tagGroups
            │   ├── context.jsonld     # @context for payloads
            │   └── vocab.jsonld      # RDF vocabulary
            └── examples/
                ├── discover/
                │   ├── discover.json
                │   ├── on_discover.json
                │   └── catalog_publish.json
                ├── search/
                │   └── on_search.json
                ├── select/
                │   ├── select.json
                │   └── on_select.json
                ├── init/
                │   ├── init.json
                │   └── on_init.json
                ├── confirm/
                │   ├── confirm.json
                │   └── on_confirm.json
                ├── status/
                │   ├── status.json
                │   └── on_status.json
                ├── update/
                │   ├── update.json
                │   └── on_update*.json
                ├── support/
                │   ├── support.json
                │   └── on_support.json
                └── cancel/
                    ├── cancel.json
                    └── on_cancel.json
```

---

## 13. Next Steps

1. **Domain code finalized:** `opun:learning`
2. **Implement schema-extension:**  
   - **attributes.yaml** – full attribute definitions and tag groups.  
   - **vocab.jsonld** – classes and properties.  
   - **context.jsonld** – compact context for use in payloads.
3. **Add example payloads** for search, select, init, confirm, status, update, cancel (at least one per flow).
4. **Write normative spec** (e.g. `opun_learning_domain_spec_2_0_0.md`) covering lifecycle, states, XInput, and conformance.
5. **Align with schema.org** – map learning classes to `Course`, `EducationalOccupationalProgram`, `LearningResource`, `CourseInstance` where it improves interoperability.

---

## 14. Implementation Alignment

The schema extension is aligned with the following implementations so that Beckn payloads can map directly to/from existing APIs and UIs.

### 14.1 Backend: groclake_learning_manager

**Location:** `groclake/agent/agache/groclake/groclake_learning_manager/groclake_learning_manager.py`  
**Schema:** `groclake/lib/groclake/schemas/groclake_learning_manager_schema.py`

**Human learning intents (lifecycle):**

| Intent | Description |
|--------|-------------|
| `groclake_human_learning_course_create` | Create course/training offering. |
| `groclake_human_learning_course_update` | Update course. |
| `groclake_human_learning_course_delete` | Delete (soft/hard) course. |
| `groclake_human_learning_course_list` | List courses (filter by category, level, type, status). |
| `groclake_human_learning_course_fetch` | Fetch single course. |
| `groclake_human_learning_enrollment_create` | Create enrollment (learner enrolls in course). |
| `groclake_human_learning_enrollment_update` | Update enrollment (status, stage, progress). |
| `groclake_human_learning_enrollment_list` | List enrollments. |
| `groclake_human_learning_enrollment_fetch` | Fetch single enrollment. |
| `groclake_human_learning_course_content_*` | Create/update/delete/list/fetch course content (modules, lessons, etc.). |
| `groclake_human_learning_progress_update` | Update learner progress per content item. |
| `groclake_human_learning_progress_list` | List progress records. |
| `groclake_human_learning_certificate_generate` | Generate certificate from completed enrollment. |
| `groclake_human_learning_certificate_create` / `update` / `list` / `fetch` / `delete` | Certificate CRUD. |
| `groclake_human_learning_certificate_to_vc` | Convert certificate to verifiable credential. |

**Enums (aligned with attributes.yaml / vocab.jsonld):**

- **Course:** `CourseCategory` (technical, soft_skills, certification, degree, workshop, other), `CourseLevel` (beginner, intermediate, advanced, expert), `CourseType` (online, offline, hybrid, self_paced, instructor_led), `CourseStatus` (draft, open, closed, archived).
- **Enrollment:** `EnrollmentStatus` (pending, confirmed, in_progress, completed, cancelled, failed), `EnrollmentStage` (applied, enrolled, started, in_progress, assessment, completed).
- **Certificate:** `CertificateType` (completion, participation, achievement, professional), `CertificateStatus` (issued, revoked, expired).
- **Content/Progress:** `ContentType` (module, lesson, video, reading, assignment, quiz, project, other), `CompletionStatus` (not_started, in_progress, completed, skipped).

### 14.2 Seller app: groclake-frontend (L&D)

**Location:** Automation → **L&D (Courses, enrollment, certificate)**  
**Components:** `learning-course-management`, `learning-enrollment-management`, `learning-course-content-management`, `learning-certificate-management`  
**Services:** `learning-course-service`, `learning-enrollment-service`, `learning-content-service`, `learning-progress-service`, `learning-certificate-service`

**Provider/seller flow:** Create and maintain courses → manage course content (modules, lessons, etc.) → review and process enrollments → update progress → on completion issue certificate (generate/create, optional VC).

### 14.3 Buyer app: opungram-frontend (Training and courses)

**Location:** My Account → **Training and courses**  
**Routes:** `/training`, `/training/[id]`, `/training/[id]/enroll`, `/training/[id]/enroll/success`  
**Components:** `training-courses-section`, `training-courses-courses-subsection`, `training-courses-enrollments-subsection`, `training-courses-certificates-subsection`, `learning-enrollment-detail-view`, `learning-enrollment-card`, `learning-learner-dashboard`

**Learner/buyer flow:** Browse courses → view course details → enroll (with form if `form_id` / XInput) → see enrollments and progress → on completion view and share certificates.

### 14.4 Mapping summary

| Beckn / Schema | Implementation |
|----------------|----------------|
| Item (course) | `HumanLearningCourse*` / `LearningCourse` (course_id, course_name, course_category, course_level, course_type, course_status, provider_id, instructor_*, duration_*, start_date, end_date, enrollment_deadline, max_enrollments, fee_amount, prerequisites, learning_objectives, course_outline, certificate_template_id, form_id, etc.) |
| Order (enrollment) | `HumanLearningEnrollment*` / `LearningEnrollment` (enrollment_id, course_id, learner_id, enrollment_status, enrollment_stage, progress_percentage, form_response_id, etc.) |
| Fulfillment (progress + certificate) | `HumanLearningProgress*`, `HumanLearningCertificate*` / `LearningProgress`, `LearningCertificate` (progress_percentage, completion_date, certificate_id, certificate_type, certificate_status, verifiable_credential_id, etc.) |
| XInput | Enrollment form (form_id, form_response_id). |

---

## 15. References

- Beckn Protocol Core v2.0.0  
- OPuN Livelihood Domain 2.0 (livelihood-domain-2.0, opun_livelihood_domain_spec_2_0_0.md)  
- Schema.org: [Course](https://schema.org/Course), [EducationalOccupationalProgram](https://schema.org/EducationalOccupationalProgram), [LearningResource](https://schema.org/LearningResource)  
- Implementation: groclake `groclake_learning_manager`, `groclake_learning_manager_schema`; groclake-frontend L&D services; opungram-frontend Training and courses.
