# ☁️ SaaS Automated Data Ingestion & Analytics Pipeline

An automated, cloud-native ETL architecture designed to extract, sanitize, and bulk-ingest massive unstructured third-party datasets into a centralized relational database to power real-time BI analytics.

## 📌 Project Context
The SaaS platform faced critical bottlenecks during new client onboarding. Manual data entry and row-by-row legacy CSV imports caused severe database locks, timeouts, and a high rate of corrupted records. This project re-engineered the ingestion architecture to utilize asynchronous API endpoints, an automated validation engine, and highly optimized bulk SQL insertion scripts.

### 🎯 Business Impact & Measured Results
- **99% Processing Speed Increase:** Reduced database insertion time from multi-hour row-by-row processing to sub-minute bulk execution.
- **98% Data Accuracy Improvement:** Pre-insertion sanitization rules eliminated mapping failures and duplicate primary keys.
- **90% Faster Client Onboarding:** Integration cycle reduced from 3 weeks to 48 hours.
- **100% Manual Effort Eliminated:** Replaced manual CSV-wrangling with automated API routing and Dead Letter Queues (DLQ).

## 🗂️ Repository Structure

├── 📂 01_business_requirements
│   ├── data_dictionary.md              # Target schema definitions
│   └── exception_handling_rules.md     # Rules for the Dead Letter Queue
├── 📂 02_system_architecture
│   ├── etl_pipeline_flow.md            # Mermaid: Asynchronous Ingestion Flow
│   └── api_sequence_diagram.md         # Mermaid: Webhook and Async Status
├── 📂 03_technical_specifications
│   ├── bulk_ingest_payload.json        # Standardized Array Request/Response
│   └── data_mapping_matrix.xlsx        # Source-to-Target sanitization rules
├── 📂 04_database_and_sql
│   ├── 01_schema_creation.sql          # Relational DDL with indexing
│   └── 02_bulk_insert_proc.sql         # Optimized Stored Procedure for bulk loading
└── 📂 05_validation_engine
    └── payload_validator.cs            # C#/.NET Data validation logic
