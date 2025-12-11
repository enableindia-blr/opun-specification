# OPuN Livelihood Usecsae

This section contains sample request and response payloads for the OPuN (OPuN Networks) livelihood domain. 

## Overview

The opun:livelihood domain enables discovery and application for job opportunities through a standardized protocol. this implementation uses structured fields for better clarity and interoperability.

## Key Differences from Tag-Based Approach

1. **Structured Fields**: Uses explicit fields like `billing`, `payments`, `quote`, `docs`, and `xinput` for form handling
2. **Form Handling**: Implements `xinput` schema for job application forms with GET API calls
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
- `select/on_select.json` - Response with detailed job information, quote, and form fields via XInput (XForms 2.0 XML)
- `select/form-submit-response.json` - Form submission response with submission_id

### Init
- `init/init.json` - Submit filled application form
- `init/on_init.json` - Response with submitted form data returned for verification by candidate along with other information

### Confirm
- `confirm/confirm.json` - Confirm job application submission
- `confirm/on_confirm.json` - Confirmation response with application details

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
2. **on_select API**: BPP responds with detailed job information, quote, and form (xinput) containing:
   - Form URL with transaction_id parameter
   - Authorization token (JWT)
   - Form metadata (headings, steps)
3. **Form Submission**: 
   - Form fields are provided inline via XForms 2.0 XML in `xinput.form.data`
   - Form captures: Candidate personal details (if not already known), Resume/certifications, Role-specific questionnaire responses
   - XForms engine POSTs to `xf:submission/@action` URL (form-submit endpoint)
   - BPP validates the payload, generates `submission_id`, and returns it to BAP via form-submit response
4. **init API**: BAP sends `submission_id` in the init request
5. **on_init API**: BPP returns submitted form data (from submission_id) for verification by candidate along with other information
6. **confirm API**: Candidate confirms and submits job application
7. **on_confirm API**: BPP responds with confirmation and application details
8. **update/on_update API**: Can be used in two ways:
   - **Solicited Update**: BAP requests to update application details → BPP responds with confirmation
   - **Unsolicited Update**: BPP sends updates to BAP such as:
     - Interview schedule
     - Application notes
     - Job offer details
     - Status changes
9. **status/on_status API**: Used to check the current status of application

## Domain

All examples use the domain: `opun:livelihood`

## Version

All examples use version: `1.1.0`

