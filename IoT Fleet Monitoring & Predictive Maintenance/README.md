# 🚜 IoT Fleet Monitoring & Predictive Maintenance (FMA)
**Technical Business Analysis Case Study by Lula Xaba**

An event-driven telemetry and predictive maintenance system architected to ingest real-time IoT sensor data from heavy mining machinery, automate ERP work orders, and prevent catastrophic equipment failures through condition-based monitoring.

## 📌 Project Context
Heavy industrial fleets traditionally rely on run-to-failure or manual schedule-based maintenance, resulting in severe revenue loss due to unplanned downtime. This project redesigns the maintenance workflow by utilizing onboard IoT sensors to stream high-frequency telemetry into a cloud database. An automated rules engine evaluates this data to trigger predictive maintenance workflows directly into the enterprise ERP (SAP/Oracle) before a breakdown occurs.

### 🎯 Business Impact & Measured Results
- **45% Reduction in Unplanned Downtime:** Caught critical mechanical anomalies prior to catastrophic failure.
- **100% ERP Automation:** Replaced manual dispatch tickets with zero-touch, API-driven work order generation.
- **30% Reduction in Emergency Costs:** Enabled proactive inventory checks and standard-shipping for parts.
- **20% Increased Asset Lifecycle:** Shifted fleet from reactive repairs to precision condition-based servicing.

## 🗂️ Repository Structure

├── 📂 01_business_requirements
│   └── telemetry_threshold_rules.md    # BA rules defining Warning vs. Critical states
├── 📂 02_system_architecture
│   └── hardware_to_erp_flow.md         # Mermaid: End-to-End System Integration
├── 📂 03_technical_specifications
│   └── api_contracts.json              # Inbound IoT Payload & Outbound ERP API
├── 📂 04_database_and_sql
│   └── fleet_telemetry_schema.sql      # DDL and Anomaly Detection Stored Procedure
└── 📂 05_analytics_and_reporting
    └── power_bi_semantic_model.md      # BI Star Schema and DAX KPIs
    
"https://iot-fleetpredictivemaintenance.ai.studio"          
