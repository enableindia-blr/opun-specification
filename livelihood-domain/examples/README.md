# OPuN Livelihood Usecase

This section contains sample request and response payloads for the OPuN (OPuN Networks) livelihood domain. 

## Overview

The opun:livelihood domain enables discovery and application for job opportunities through a standardized protocol. this implementation uses structured fields for better clarity and interoperability.

## Key Differences from Tag-Based Approach

1. **Structured Fields**: Uses explicit fields like `billing`, `payments`, `quote`, `docs`, and `xinput` for form handling
2. **Form Handling**: Implements `xinput` schema for job application forms with inline XForms 2.0 XML
3. **Billing Information**: Includes billing details for application tracking
4. **Payment Details**: Includes payment/bank account information for salary processing
5. **Quote Structure**: Provides detailed salary breakdown in `quote` field
6. **Document Management**: Uses `docs` array for application-related documents

## API Endpoints

The following endpoints are covered in these examples:

- `/search` - Search for job opportunities
- `/select` - Candidate selects a job opportunity
- `/init` - Submit filled application form
- `/confirm` - Confirm and submit job application
- `/status` - Check application status
- `/update` - Update application details (solicited) or unsolicited updates from BPP to BAP (interview schedule, notes, offer, etc.)
- `/cancel` - Cancel job application
- `/support` - Get support information
- `/track` - Track application progress
- `/rating` - Rate job application experience

## Example Files

### Search
- `search/search-by-job-title.json` - Search by job title
- `search/search-by-skills.json` - Search by required skills
- `search/search-by-provider.json` - Search by employer/provider
- `search/on_search.json` - Search response with job catalog

### Select
- `select/select.json` - Candidate selects a job opportunity
- `select/on_select.json` - Response with detailed job information, quote, and form structure via XInput (XForms 2.0 XML)

### Init
- `init/init.json` - Submit filled application form with form data
- `init/on_init.json` - Response with submitted form data stored and returned for verification by candidate along with other information

### Confirm
- `confirm/confirm.json` - Confirm job application submission with same form data received in on_init
- `confirm/on_confirm.json` - Confirmation response after BPP verifies form data and application is submitted

### Update
- `update/update.json` - Update application details (solicited update from BAP to BPP)
- `update/on_update.json` - Update confirmation response (for solicited updates) or unsolicited update sent from BPP to BAP (interview schedule example)
- `update/on_update_confirmation.json` - Update confirmation response for solicited updates
- `update/on_update_job_offer.json` - Unsolicited update sent from BPP to BAP (job offer example)

### Status
- `status/status.json` - Check application status
- `status/on_status.json` - Status response with current application state

### Cancel
- `cancel/cancel.json` - Cancel job application
- `cancel/on_cancel.json` - Cancellation confirmation

### Support
- `support/support.json` - Request support information
- `support/on_support.json` - Support contact details

### Track
- `track/track.json` - Track application progress
- `track/on_track.json` - Tracking URL and status

### Rating
- `rating/rating.json` - Rate job application experience
- `rating/on_rating.json` - Rating acknowledgment

## Application Flow

The job application flow follows this sequence:

1. **select API**: Candidate selects a job opportunity
2. **on_select API**: BPP responds with detailed job information, quote, and form structure via XInput:
   - Form fields are provided inline via XForms 2.0 XML in `xinput.form.data` (NO URL)
   - Form structure includes: Personal info, Professional experience, Skills & qualifications, Documents, Role-specific questionnaire
   - Form metadata (headings, steps) in `xinput.head`
3. **Form Rendering**: 
   - Buyer app renders the XForm structure received in `on_select`
   - Candidate fills the form: Personal details (if not already known), Resume/certifications, Role-specific questionnaire responses
4. **init API**: BAP sends filled form data in `xinput.form.data` to BPP
5. **on_init API**: BPP stores the form data and returns it back for review by candidate along with other information
6. **Review & Confirm**: 
   - Candidate reviews the form data returned in `on_init`
   - If candidate finds any discrepancy, they can drop the transaction at buyer app and start again
   - If all is fine, candidate proceeds to confirm
7. **confirm API**: BAP sends the same filled form data (received in on_init) in the confirm request
8. **on_confirm API**: BPP verifies the form data against what was stored in init, and if verified, application is submitted
9. **update/on_update API**: Can be used in two ways:
   - **Solicited Update**: BAP requests to update application details → BPP responds with confirmation
   - **Unsolicited Update**: BPP sends updates to BAP such as:
     - Interview schedule
     - Application notes
     - Job offer details
     - Status changes
10. **status/on_status API**: Used to check the status of application

## Domain

All examples use the domain: `opun:livelihood`

## Version

All examples use version: `1.1.0`
