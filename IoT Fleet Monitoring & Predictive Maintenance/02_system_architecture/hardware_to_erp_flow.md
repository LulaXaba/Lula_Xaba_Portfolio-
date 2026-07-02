# 🏗️ End-to-End System Architecture: Hardware to ERP

This flow maps how high-frequency physical sensor data is ingested, processed, and routed to trigger automated business logic in the enterprise ERP.

```mermaid
flowchart TD
    %% Hardware & Edge Layer
    subgraph Edge [Edge / Heavy Machinery]
        Sensors([IoT Sensors: Temp, Pressure])
        OBC[On-Board Computer / Telemetry Unit]
        Sensors -- 10Hz Data --> OBC
    end

    %% Cloud Ingestion Layer
    subgraph Cloud [Cloud Ingestion & Processing]
        Gateway[IoT API Gateway]
        Queue[Message Broker / Kafka]
        RulesEngine{Stream Analytics / Rules Engine}
        
        OBC -- HTTPS / MQTT Payload --> Gateway
        Gateway --> Queue
        Queue --> RulesEngine
    end

    %% Data Storage Layer
    subgraph Data [Data & Persistence]
        TSDB[(Time-Series DB: Raw Telemetry)]
        SQL[(Relational DB: Active Alerts)]
        
        RulesEngine -- "All Data (Historical)" --> TSDB
        RulesEngine -- "Threshold Breaches" --> SQL
    end

    %% Enterprise Integration
    subgraph Enterprise [Enterprise Systems]
        SAP[SAP / Oracle ERP PM Module]
        DispatchUI[Dispatch Web Dashboard]
        
        SQL -- "API: Trigger Work Order" --> SAP
        SQL -- "WebSockets: Live Alert" --> DispatchUI
        SAP -- "WO Status Updates" --> SQL
    end
```
