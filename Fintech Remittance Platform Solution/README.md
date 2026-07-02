# 🌍 Remittance Platform: Technical BA Case Study

A structured end-to-end digital remittance system designed to improve cross-border payments through API-driven automation, FIC-aligned compliance workflows, and real-time transaction visibility.

## 📌 Project Context
Traditional remittance flows suffer from fragmented processing, multi-day bank settlements, and opaque tracking, resulting in low customer trust and high operational overhead. This project redesigns the architecture to introduce automated risk-based KYC, event-driven payment processing, and comprehensive BI tracking.

### 🎯 Expected Business Impact
*   **85% Faster Onboarding:** Automated risk-scoring engine for low-risk users.
*   **100% Transparency:** Real-time event tracking across the transaction lifecycle.
*   **+60% Compliance Efficiency:** Automated FIC-aligned AML screening reducing manual queues.
*   **50% Support Reduction:** Proactive status webhooks eliminating "Where is my money?" queries.

## 🗂️ Repository Structure

This repository contains the complete suite of Technical Business Analysis artifacts, structured as they would be handed off to an enterprise development team.

```
├── 📂 01_business_requirements
│   ├── business_rules_catalogue.md     # FIC-aligned compliance and routing rules (18 rules)
│   ├── user_stories_backlog.md         # Epics, Stories, and Acceptance Criteria (Agile/BDD)
│   └── risk_scoring_algo.md            # ML-informed KYC risk scoring algorithm + pseudocode
├── 📂 02_system_architecture
│   ├── context_diagram.md              # Level 0 System Boundaries (Mermaid)
│   └── process_flows.md                # Event-driven Transaction Lifecycle (BPMN)
├── 📂 03_technical_specifications
│   ├── api_contracts.json              # OpenAPI 3.0 REST API specifications
│   └── data_mapping_matrix.md          # Source-to-Target system field mappings
├── 📂 04_database_and_sql
│   ├── 01_schema_creation.sql          # Core relational DDL (Users, KYC, Transactions, Events)
│   ├── 02_mock_data_inserts.sql        # Sample data for UAT (6 users, realistic scenarios)
│   └── erd_visual.md                   # Entity-Relationship Diagram (Mermaid) + validation
├── 📂 05_analytics_and_reporting
│   ├── power_bi_dataset_model.md       # Star schema design (Fact & Dimension tables)
│   └── cloud_cost_analysis.md          # TCO & infrastructure cost breakdown (AWS)
└── README.md                           # This file (project overview & quick start)
```

## 🛠️ Tech Stack & Tools
`SQL` | `REST APIs (JSON)` | `Mermaid.js` | `Power BI` | `Jira/Confluence` | `Excel`

---

## 🚀 Quick Start

1. **Review Business Requirements:** Start with [`01_business_requirements/`](01_business_requirements/) to understand the FIC compliance rules and user story backlog.
2. **Understand Architecture:** Navigate to [`02_system_architecture/`](02_system_architecture/) to see the system boundaries and transaction workflows.
3. **Review Technical Specs:** Check [`03_technical_specifications/`](03_technical_specifications/) for API contracts and data mappings.
4. **Database Design:** Review [`04_database_and_sql/`](04_database_and_sql/) for the relational schema and seed data.
5. **Analytics:** Explore [`05_analytics_and_reporting/`](05_analytics_and_reporting/) for BI reporting requirements.

---

## 📊 Key Artifacts Summary

| Artifact | Purpose | Audience |
| :--- | :--- | :--- |
| **Business Rules Catalogue** | 18 FIC-aligned compliance rules, routing logic, hold procedures | Compliance Officers, Product Managers |
| **Risk Scoring Algorithm** | ML pseudocode for automated KYC approval decisions | Data Scientists, Backend Engineers |
| **User Stories** | 8 Agile stories with BDD acceptance criteria (Gherkin format) | Development Team, QA, Product Owner |
| **Context Diagram** | System integration touchpoints (Level 0 DFD) | Lead Architects, IT Stakeholders |
| **Process Flows** | Event-driven transaction lifecycle with state machine | Developers, Solutions Architects |
| **API Contracts** | OpenAPI 3.0 spec; Swagger-compatible for auto-generated SDKs | Backend Developers, Integration Partners |
| **Data Mapping Matrix** | Field-level transformations & validation rules (front-end → DB) | Database Engineers, ETL Developers |
| **Database Schema** | Relational DDL, constraints, indexing strategy | DBA, Data Engineers |
| **ERD Diagram** | Visual ER diagram with relationships, cardinality, sample queries | Architects, Data Modelers |
| **Mock Data** | 6 users with realistic transaction scenarios for UAT | QA, Testing Team |
| **Power BI Model** | Star schema with fact/dimension tables, DAX measures, RLS | BI Analysts, Finance Team |
| **Cloud Cost Analysis** | OPEX breakdown, profitability model, scaling roadmap | Finance, Operations, Executive Leadership |

---

## 📝 How to Use This Repository

This repository serves as a **reference implementation** for enterprise-grade Technical Business Analysis. Each artifact is production-ready and demonstrates:

- ✅ Clear compliance requirements aligned with FIC regulations
- ✅ Event-driven microservices architecture
- ✅ Real-time transaction tracking and audit trails
- ✅ Automated risk-scoring and exception handling
- ✅ RESTful API standards for third-party integration

## 🔐 Compliance Framework

All rules and workflows are designed to align with:
- **FIC (Financial Intelligence Centre) AML Requirements**
- **POPIA (Protection of Personal Information Act) - South Africa**
- **Cross-Border Payment Regulations (ISO 20022)**

---

## � Deployment & API Documentation

### **Interactive API Docs (Swagger UI)**
The payload models defined in [`03_technical_specifications/api_contracts.json`](03_technical_specifications/api_contracts.json) are fully compatible with **Swagger/OpenAPI** tooling:

1. **View in Swagger Editor:** Copy the JSON file contents and paste into [Swagger Editor](https://editor.swagger.io/)
2. **Generate Client SDKs:** Use OpenAPI generators to auto-generate TypeScript, Python, Java client libraries
3. **API Testing:** Swagger UI provides an interactive interface to test all endpoints

**Why This Matters:** Developers can start coding immediately from the API contract without ambiguity about payloads, error codes, or authentication.

---

### **Docker Containerization (Local Testing)**
The SQL scripts in [`04_database_and_sql/`](04_database_and_sql/) are designed to run in containerized environments:

**Quick Start (Docker Compose):**

```bash
# Spin up a local PostgreSQL database
docker-compose up -d

# Run schema creation
docker exec remittance-db psql -U postgres -d remittance_db -f /scripts/01_schema_creation.sql

# Seed mock data
docker exec remittance-db psql -U postgres -d remittance_db -f /scripts/02_mock_data_inserts.sql

# Verify data insertion
docker exec remittance-db psql -U postgres -d remittance_db -c "SELECT COUNT(*) FROM Users;"
```

**Example docker-compose.yml:**
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: remittance_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - ./04_database_and_sql:/scripts
      - postgres_data:/var/lib/postgresql/data
      
volumes:
  postgres_data:
```

This allows developers to:
- ✅ Test the data model locally without cloud infrastructure
- ✅ Validate SQL syntax and indexes
- ✅ Run integration tests against mock data
- ✅ Prototype backend APIs

---

### **Cloud Deployment (AWS)**
For production deployment, see [`05_analytics_and_reporting/cloud_cost_analysis.md`](05_analytics_and_reporting/cloud_cost_analysis.md) for:
- Infrastructure cost breakdown (OPEX model)
- Scaling roadmap (50k → 500k transactions/month)
- Security & compliance checklist

---

### **Additional Implementation Resources**

| Resource | Purpose | Link |
| :--- | :--- | :--- |
| Risk Scoring Algorithm | ML-informed KYC automation logic | [`01_business_requirements/risk_scoring_algo.md`](01_business_requirements/risk_scoring_algo.md) |
| Entity-Relationship Diagram | Visual database schema & relationships | [`04_database_and_sql/erd_visual.md`](04_database_and_sql/erd_visual.md) |
| Database ERD | Mermaid diagram showing all FK relationships | Same file as above |
| Cost Projections | TCO & profitability model | [`05_analytics_and_reporting/cloud_cost_analysis.md`](05_analytics_and_reporting/cloud_cost_analysis.md) |

---


---

**Status:** Complete Case Study | **Version:** 1.0 | **Last Updated:** July 2026
