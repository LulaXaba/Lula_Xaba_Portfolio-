-- ==============================================================================
-- SCRIPT: 01_schema_creation.sql
-- PURPOSE: Create the relational schema for the ingestion pipeline and analytics layer.
-- ==============================================================================

CREATE TABLE FITNESS_EXERCISE (
    ExerciseID VARCHAR(50) PRIMARY KEY,
    ExerciseName VARCHAR(200) NOT NULL,
    EquipmentCategory VARCHAR(50) NOT NULL,
    DifficultyLevel VARCHAR(30) NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IX_FITNESS_EXERCISE_CATEGORY ON FITNESS_EXERCISE(EquipmentCategory);
CREATE INDEX IX_FITNESS_EXERCISE_DIFFICULTY ON FITNESS_EXERCISE(DifficultyLevel);

CREATE TABLE EXCEPTION_LOG (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    BatchID VARCHAR(100) NULL,
    ErrorNumber INT NOT NULL,
    ErrorMessage VARCHAR(4000) NOT NULL,
    ErrorProcedure VARCHAR(200) NULL,
    ErrorTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
