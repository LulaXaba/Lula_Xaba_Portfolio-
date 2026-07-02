# 📝 Agile Requirements: ERP Integration Epic

**Epic:** Automate SAP Work Order Generation from IoT Telemetry Alerts
**Epic Owner:** Technical BA (Lula Xaba)

## User Story: Critical Engine Overheat Auto-Dispatch
**As a** Maintenance Dispatcher  
**I want** the system to automatically generate an SAP Work Order when a vehicle's engine temperature reaches a critical threshold  
**So that** parts can be staged and mechanics dispatched without manual data entry delays.

### Acceptance Criteria (BDD / Gherkin)

**Scenario 1: Successful Work Order Creation**
- **Given** a CAT-797F Dump Truck is in an "Operational" state
- **And** the `sp_EvaluateEngineOverheat` procedure detects a sustained temperature > 115°C for 5 minutes
- **When** the system triggers the outbound API `POST /api/erp/plant-maintenance/work-order`
- **Then** SAP must return a `201 Created` response with a valid Work Order ID
- **And** the UI Dashboard must update the truck's status to "CRITICAL - WO Generated"
- **And** the truck's GPS beacon must change to RED on the Dispatcher Map.

**Scenario 2: ERP API Timeout (Exception Handling)**
- **Given** the rules engine identifies a critical threshold breach
- **When** the POST request to SAP times out after 10,000ms
- **Then** the middleware must queue the payload in a Dead Letter Queue (DLQ)
- **And** execute an exponential backoff retry (3 attempts max)
- **And** send a high-priority WebSocket alert to the Dispatcher UI reading: "MANUAL DISPATCH REQUIRED: ERP Offline."
