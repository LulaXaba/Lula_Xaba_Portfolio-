# ⚙️ Telemetry Threshold & Business Rules Engine

To prevent false positives and alarm fatigue for the dispatch team, the Validation Engine evaluates incoming IoT data against these strict temporal and threshold-based rules.

## Sensor Threshold Matrix (Dump Trucks: CAT-797F)

| Sensor Metric | Operational Range | WARNING State Trigger | CRITICAL State Trigger | Required Action (System) |
| :--- | :--- | :--- | :--- | :--- |
| **Engine Oil Temp** | 80°C - 105°C | > 110°C (Sustained 2 mins) | > 115°C (Sustained 5 mins) | Generate ERP Ticket: Engine Diagnostics |
| **Hydraulic Pressure**| 190 - 230 bar | < 185 bar (Instant drop) | < 170 bar (Sustained 1 min) | Generate ERP Ticket: Hydraulics Leak Check |
| **Tire Pressure** | 115 - 125 psi | < 110 psi (Slow leak) | < 100 psi (Instant drop) | Alert Pit Dispatch; Route to Bay |

**Rule 1: The Temporal Buffer**
A single anomaly spike (e.g., Oil Temp hits 116°C for 5 seconds) must NOT trigger a state change. The system requires the anomaly to be sustained for the defined temporal window (e.g., 5 minutes) to filter out sensor noise.

**Rule 2: Automated Escalation**
If a vehicle remains in a `WARNING` state for longer than 60 minutes without normalizing, the system automatically escalates the status to `CRITICAL` and dispatches a work order.
