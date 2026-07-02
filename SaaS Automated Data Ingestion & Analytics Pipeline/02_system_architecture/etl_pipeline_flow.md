# 🔄 Asynchronous ETL Pipeline Flow

This diagram illustrates how data passes from client endpoints through the validation engine, highlighting asynchronous branching logic and Dead Letter Queue routing.

```mermaid
flowchart TD
    Start([Client Submits Dataset Array]) --> Ingest[API Gateway Ingests Payload]
    Ingest --> Queue[Push Batch to Ingestion Queue]
    Queue --> Ack([Return 202 Accepted to Client])

    Queue --> Process[Worker Service Pulls Batch]
    Process --> Loop[Iterate Through Records]

    Loop --> Check{Schema & Constraint Valid?}

    Check -- No --> DLQ[Route Record to Dead Letter Queue]
    DLQ --> ErrorLog[(Log Exception Table)]

    Check -- Yes --> Sanitize[Sanitize Text & Normalize Fields]
    Sanitize --> Staging[Append to Staging Table Collection]

    ErrorLog --> BatchCheck
    Staging --> BatchCheck

    BatchCheck{All Records Evaluated?}
    BatchCheck -- No --> Loop

    BatchCheck -- Yes --> ExecuteBulk[Execute sp_BulkIngestExercises Stored Proc]
    ExecuteBulk --> Commit[(Target Database Upsert)]
    Commit --> Finish[Trigger BI Dataset Refresh Webhook]
    Finish --> Webhook([Dispatched Ingestion Summary Webhook to Client])
```
