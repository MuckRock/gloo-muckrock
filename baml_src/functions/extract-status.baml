class FOIARequestData {
  trackingNumber string? @description("The government agency's assigned tracking, case, or reference number for this specific FOIA/public records request — for example 'A-2023-01089', 'FOIA-2022-002-00322', 'Case Number 116392', 'RD 77093'. Only extract the agency-assigned reference for this request. Do not extract internal file numbers, court case numbers, or other unrelated identifiers mentioned incidentally.")
  dateEstimate string? @description("An ISO8601 string of the date by which the agency estimates it will complete processing the request or provide the next installment of records. Extract any stated or estimated completion date, including phrases like 'on or before', 'by approximately', 'we expect to respond by'. Use null if not present.")
  price float? @description("The total balance remaining to pay for this request, as a float. Use null if not present.")
  priceDetails string? @description("A sentence describing what the price is for (e.g. per page or record delivered, etc). null if not present.")
  reasoning string
  requestStatus RequestStatus
  recordsStatus RecordsStatus
}

enum RecordsStatus {
  NOT_APPLICABLE @description("The request is still being processed, or records status is not yet determined. Use this as the default for in-progress, payment, fix, and indeterminate situations.")
  RECORDS_FOUND @description("The agency has explicitly confirmed or already provided records for this specific request. Do NOT use if records are merely implied or inferred from context — only use when the agency has actually attached/provided records or explicitly stated 'records were found/exist for your request'.")
  NO_RECORDS_FOUND @description("The agency has affirmatively confirmed that no responsive records exist for this request. Use only when the agency explicitly states there are no records — not when they are simply not the custodian or are redirecting to another agency.")
  MORE_RECORDS_PENDING @description("The agency has released some records but explicitly states additional records are still forthcoming for this same request.")
}

enum RequestStatus {
  IN_PROGRESS @description("The agency accepted the request and is actively processing it. Use this for: acknowledgment letters with case numbers, extension notifications, fee waiver grants, responses directing the requester to an agency portal or system to track their request, portal account registration confirmations from the FOIA agency, and any status update indicating work is underway. Does NOT include one-time passcode or login authentication emails.")
  FIX_REQUIRED @description("The agency requires a response or action from the requestor before processing can continue. This includes: requests for clarification or additional information; requests to narrow the scope; asking the requestor to confirm receipt of records; offering a choice of next steps (e.g. 'do you want a formal no-records letter or a new request?'); test or verification emails from the agency confirming the requestor's email address before sending the actual response; or any other situation where the requestor must respond. Does NOT include simply forwarding to another agency. Does NOT include asking the requester to choose a delivery method (mail, in-person pickup, etc.) for records that are already being prepared — that is IN_PROGRESS.")
  PAYMENT_REQUIRED @description("The requestor must pay a fee for the agency to continue processing or release records.")
  REQUEST_REJECTED @description("The request was denied or closed without fulfillment, with clear non-fulfillment indicators such as: explicit denial citing legal exemptions or inability to process; a final disposition of 'Other'; an expired appeal deadline; a statement that the agency's responsibility to respond has ended; the agency stating they are not the custodian and cannot or will not help (even if they say they have no responsive documents); a Glomar response ('we can neither confirm nor deny'); or a request that was administratively closed (even if the agency offers to process a revised version). Do NOT use for a simple 'closed' or 'completed' status notification without additional context. Do NOT use when a FOIA appeal is denied solely because the original agency's 'no records found' determination was upheld — in that case use REQUEST_COMPLETED with NO_RECORDS_FOUND.")
  REQUEST_COMPLETED @description("The agency has completed processing and fulfilled the request. Use this for normal completions — when records are provided (possibly redacted, even with some exemptions applied), when no records are confirmed to exist, or when a simple 'closed'/'completed' notification is received without denial context.")
  INDETERMINATE @description("The status cannot be determined, or the communication is not substantively related to this FOIA request. Use for emails from third-party systems completely unrelated to the FOIA (email encryption services, cloud storage notifications, login alerts), one-time passcode/OTP/authentication code emails for portal login (even from a FOIA agency portal), email recall requests, or any message with no FOIA-relevant content. Do NOT use for substantive emails from the FOIA agency itself — prefer IN_PROGRESS for brief agency acknowledgments.")
}

function ExtractRequestData(request_text: string) -> FOIARequestData {
  client GPT5Client
  prompt #"
    You are analyzing public records correspondence to figure out what the status of the request for public records is. Your job is to extract the information from the government's response and classify the status of the request.

    Important distinctions:
    - Simple "closed" or "completed" notifications without denial context → REQUEST_COMPLETED.
    - Explicit denial indicators (exemptions cited, "Other" disposition, deadline expired, agency cannot respond, administratively closed) → REQUEST_REJECTED.
    - Agency is not the custodian / has no documents but refers elsewhere → REQUEST_REJECTED (not NO_RECORDS_FOUND).
    - Agency says no records exist BUT asks requester to choose a next step → FIX_REQUIRED (not REQUEST_COMPLETED).
    - FOIA appeal denied solely because the original 'no records found' determination was upheld (not because of exemptions) → REQUEST_COMPLETED + NO_RECORDS_FOUND (not REQUEST_REJECTED).
    - Portal account registration / access link from the FOIA agency → IN_PROGRESS (not INDETERMINATE).
    - One-time passcode / OTP / login authentication code for a FOIA portal → INDETERMINATE (not IN_PROGRESS).
    - Test/verification email from agency asking requester to confirm email address → FIX_REQUIRED.
    - Third-party system emails (Cisco, Dropbox, ZixCorp, etc.) not from the FOIA agency → INDETERMINATE.
    - RECORDS_FOUND only when records are explicitly provided or confirmed — not inferred from discussing a case file or estimating fees.
    - Records explicitly provided/attached, even if the agency also cites exemptions for some items → REQUEST_COMPLETED + RECORDS_FOUND (not REQUEST_REJECTED). REJECTED requires all records to have been denied.
    - Records provided for the primary request scope → REQUEST_COMPLETED + RECORDS_FOUND, even if the agency separately asks about extending or expanding the scope in the same letter.
    - Asking requester to choose delivery method (mail vs. in-person pickup) for records already being prepared → IN_PROGRESS (not FIX_REQUIRED).
    - Request administratively closed for insufficient description, even if agency offers to reopen with more detail → REQUEST_REJECTED.

    Agency's response to user:
    ###
    {{ request_text }}
    ###

    {{ ctx.output_format }}
  "#
}