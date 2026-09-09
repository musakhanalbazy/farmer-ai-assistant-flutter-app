# Business Profile Setup — Changes & Testing

This README documents the edits I made to wire the Business Profile Setup form to the backend API, fix validation issues that caused HTTP 422 responses, and improve error visibility in the UI.

## Overview

- Wired the app to POST business profile data to your FastAPI endpoint at `http://192.168.1.17:8000/business/setup`.
- Aligned the JSON payload shape with the backend schema (snake_case keys, `services_offered` list, optional `business_website`).
- Surface backend validation errors in the UI so you can see server responses instead of a generic message.
- Handled `422 Unprocessable Entity` responses so the server validation details are available to the ViewModel and views.

## Files changed

- `lib/services/app_url.dart`
  - Added `AppUrls.businessSetup = 'http://192.168.1.17:8000/business/setup'`.
- `lib/repository/repository.dart`
  - `submitBusinessProfile(...)` now posts to `AppUrls.businessSetup` and allows network exceptions from the API layer to bubble up (so the ViewModel can show the server message).
- `lib/model/business_profile_model.dart`
  - Added `toApiJson()` which returns the API payload in snake_case.
  - `services_offered` is produced from the model's boolean flags (e.g. `visitVisa` -> `visit_visa`).
  - `business_website` is only included in the payload when non-empty (the field is optional).
  - Added `region` / `country` / qualification fields mapping from the model.
- `lib/data/network/network_api_service.dart`
  - Treat `422` responses as `BadRequestException` so the response body (validation details) is passed up to the repository/ViewModel.
  - Central response handling still parses JSON bodies for 200/201 responses.
- `lib/ui/business_profile_setup/business_profile_viewmodel.dart`
  - `submitProfile()` now catches `AppExceptions` and stores the exception text in `submitError` so the UI displays the server error message.
- `lib/ui/business_profile_setup/business_profile_form_view.dart`
  - The website validator was adjusted during debugging; final state: `business_website` is optional in the UI and validated only when provided.

## Expected API payload

The backend expects a JSON body like the example below (snake_case keys):

```json
{
  "organization_name": "string",
  "business_type": "string",
  "city": "string",
  "operating_countries": ["string"],
  "business_email": "user@example.com",
  "business_phone_no": "string",
  "services_offered": ["string"],
  "region": "string",
  "country": "string",
  "mandatory_qualification_question": "string",
  "consent_accepted": true,
  "business_website": "https://example.com/",   // optional — omitted if empty
  "registration_id": "string",
  "optional_qualification_question": "string"
}
```

Notes:
- `services_offered` is a list of identifiers derived from the booleans in the UI. Current mapping used in `toApiJson()`:
  - `visitVisa` -> `visit_visa`
  - `workVisa` -> `work_visa`
  - `studyVisa` -> `study_visa`
  - `prApplication` -> `pr_application`
  - `businessVisa` -> `business_visa`
  - `familySponsor` -> `family_sponsor`
  - `investmentMigration` -> `investment_migration`
  - `refugeeAdvisory` -> `refugee_advisory`

## How to test locally

1. Start the Flutter app as you normally do (e.g. `flutter run` or using your dev tools) and navigate to the Business Profile Setup flow.
2. Fill the form fields. `business_website` is optional — leave it blank to omit it from the payload.
3. Complete the wizard and press the final **Submit** button on Step 4.
   - If the backend returns validation errors, the exact server message will be shown at the top of Step 4 (above the consent card).

### Example curl test (worked during verification)
Create a UTF-8 encoded JSON file `payload.json` containing the payload, then run:

```powershell
curl.exe -i -X POST "http://192.168.1.17:8000/business/setup" -H "Content-Type: application/json" --data-binary "@payload.json"
```

Example `payload.json` used during testing:

```json
{
  "organization_name":"Test Org",
  "business_type":"Immigration",
  "city":"Karachi",
  "operating_countries":["Pakistan"],
  "business_email":"user@example.com",
  "business_phone_no":"03123456789",
  "services_offered":["visit_visa"],
  "region":"Asia",
  "country":"Pakistan",
  "mandatory_qualification_question":"Do you meet X?",
  "consent_accepted":true,
  "business_website":"https://example.com/",
  "registration_id":"REG123",
  "optional_qualification_question":"Have you done Y?"
}
```

Response observed during test:

```json
{"status":"success","message":"Business profile complete"}
```

## Troubleshooting

- If you get `422` or `400` errors: copy the full JSON shown in the app (it will appear above the consent card in Step 4) and paste it here — it contains the backend validation details (e.g. missing fields, format errors).
- If you want to see *exactly* what the app sends, I can add temporary logging to `lib/data/network/network_api_service.dart` to print request URL + JSON body and the raw response body. Tell me if you'd like that; I'll add it and show how to remove it later.

## Next steps I can do for you

- Add temporary request/response logging for debugging network payloads.
- Map backend field names to friendlier UI labels if you want to make the UX clearer.
- Implement a consent checkbox in the UI (currently `consent_accepted` is always set to `true` in the payload because the UI mock had no checkbox).

---

If you want the README in a different filename or want me to commit these changes to git with a commit message, tell me the message and I'll apply it.
