# 📡 Edge Computing & Network Disconnect Rules

Heavy machinery operating deep in the mining pit frequently experiences cellular network dropouts. To ensure zero telemetry data loss, the On-Board Computer (OBC) must adhere to the following Edge Computing rules:

## Rule 1: Store and Forward (Offline Caching)
- **Condition:** If the vehicle loses connection to the Cloud API Gateway (Ping timeout > 5 seconds).
- **Action:** The OBC must switch to `OFFLINE_MODE` and begin writing 10Hz telemetry payloads to its local encrypted flash storage.
- **Capacity constraint:** The edge device must hold up to 72 hours of telemetry data locally.

## Rule 2: Throttled Reconnection Sync
- **Condition:** When the vehicle drives back into network range.
- **Action:** The OBC must NOT dump all offline data instantly, which would cause a DDoS-like spike on the API Gateway.
- **Execution:** It must transmit the cached data chronologically at a throttled rate (max 50 payloads per second) while simultaneously streaming live data, until the backlog is cleared.

## Rule 3: Edge-Level Critical Alarms
- **Condition:** If a `CRITICAL` threshold (e.g., Brake Pressure Failure) occurs while the truck is in `OFFLINE_MODE`.
- **Action:** Since the cloud cannot trigger the ERP, the edge device must fire a physical hardware interrupt, instantly illuminating the red WARNING strobe in the driver's cabin and safely governing engine RPM down to 15%.
