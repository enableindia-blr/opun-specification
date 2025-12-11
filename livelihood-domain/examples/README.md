# OPuN Livelihood Usecase


## Overview

OPuN (A Decentralized, Consent-Based Open Network for Persons with Disabilities) establishes a unified protocol enabling structured data exchange for livelihood-related processes. This document outlines the specifications governing all interactions between Buyer Platforms (BAPs) and Seller Platforms (BPPs) in the OPuN ecosystem. In facilitating transparent, interoperable, and verifiable communications, OPuN ensures that livelihood opportunities—such as job roles, internships, and project-based assignments—can be discovered, evaluated, and pursued efficiently across decentralized digital infrastructures.

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


## Application Flow

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

14. **support/on_support API**: Retrieves support contact information and assistance resources.



## Domain

All examples use the domain: `opun:livelihood`

## Version

All examples use version: `1.0.0`
