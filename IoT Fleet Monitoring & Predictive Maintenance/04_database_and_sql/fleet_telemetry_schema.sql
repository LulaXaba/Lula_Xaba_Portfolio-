-- ==============================================================================
-- SCRIPT: fleet_telemetry_schema.sql
-- PURPOSE: Define time-series tables and anomaly detection logic.
-- ============================================================================== 

-- 1. HIGH-FREQUENCY TELEMETRY TABLE
CREATE TABLE VehicleTelemetry (
    LogID UUID NOT NULL,
    AssetID VARCHAR(50) NOT NULL,
    LogTimestamp TIMESTAMP NOT NULL,
    EngineOilTemp DECIMAL(5, 2),
    HydraulicPressure DECIMAL(5, 2),
    PRIMARY KEY (AssetID, LogTimestamp)
);

-- 2. ACTIVE ALERT & ERP ROUTING TABLE
CREATE TABLE ActiveAlerts (
    AlertID UUID PRIMARY KEY,
    AssetID VARCHAR(50) NOT NULL,
    FaultCode VARCHAR(25) NOT NULL,
    TriggerValue DECIMAL(8, 2),
    SeverityLevel VARCHAR(15) CHECK (SeverityLevel IN ('WARNING', 'CRITICAL')),
    ERPWorkOrderRef VARCHAR(50) DEFAULT NULL,
    IsResolved BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ANOMALY DETECTION STORED PROCEDURE (Temporal Logic)
CREATE PROCEDURE sp_EvaluateEngineOverheat
    @AssetID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AverageTemp DECIMAL(5, 2);
    
    -- Calculate average temp over the last 5 minutes to filter noise
    SELECT @AverageTemp = AVG(EngineOilTemp)
    FROM VehicleTelemetry
    WHERE AssetID = @AssetID
      AND LogTimestamp >= DATEADD(MINUTE, -5, CURRENT_TIMESTAMP);
      
    -- Trigger logic based on BA Threshold Matrix (115 C)
    IF @AverageTemp >= 115.00
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM ActiveAlerts WHERE AssetID = @AssetID AND IsResolved = FALSE)
        BEGIN
            INSERT INTO ActiveAlerts (AlertID, AssetID, FaultCode, TriggerValue, SeverityLevel)
            VALUES (NEWID(), @AssetID, 'ERR-ENG-OIL-OVERHEAT', @AverageTemp, 'CRITICAL');
        END
    END
END;
