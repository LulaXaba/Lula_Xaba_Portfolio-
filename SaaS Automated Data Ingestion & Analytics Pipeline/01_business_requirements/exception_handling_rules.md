# 🚨 Exception Handling & Dead Letter Queue (DLQ) Rules

To achieve a 0% critical failure rate during bulk database inserts, malformed API payloads must be trapped by the validation engine and routed to the Dead Letter Queue.

## Business Rules for DLQ Routing

| Error Scenario | Action Triggered | Client Notification | Retry Logic |
| :--- | :--- | :--- | :--- |
| Missing Primary Key | Route record to DLQ and continue processing the remainder of the batch | Include record in batch completion webhook under failed_records | Manual correction required by client |
| Invalid Data Type | Route record to DLQ and continue processing the remainder of the batch | Include record in batch completion webhook under failed_records | Manual correction required by client |
| Database Connection Timeout | Pause batch processing immediately and stop further writes | Send 503 Service Unavailable alert via webhook | Auto-retry with exponential backoff for up to 3 attempts |
| Payload Size Exceeds 100MB | Reject the entire payload at the API gateway | Send 413 Payload Too Large response | Client must split the payload into smaller batches |
| Duplicate Business Key | Route duplicate record to DLQ or merge based on business rule | Include duplicate in failed_records if configured | Manual review or automated deduplication rule |

## Operational Notes

- All DLQ events must be logged with timestamp, batch ID, record ID, and failure reason.
- Webhook notifications must contain both success and failed record counts.
- Failed records should never block the processing of the remaining valid payload entries.
