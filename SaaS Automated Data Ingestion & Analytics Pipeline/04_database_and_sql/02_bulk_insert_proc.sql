-- ==============================================================================
-- SCRIPT: 02_bulk_insert_proc.sql
-- PURPOSE: Stored procedure to handle bulk inserts into FITNESS_EXERCISE
--          minimizing transaction log overhead and preventing table locks.
-- ==============================================================================

CREATE PROCEDURE sp_BulkIngestExercises
    @ExerciseData dbo.ExerciseTableType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        MERGE INTO FITNESS_EXERCISE AS Target
        USING @ExerciseData AS Source
        ON Target.ExerciseID = Source.ExerciseID

        WHEN MATCHED THEN
            UPDATE SET
                ExerciseName = Source.ExerciseName,
                EquipmentCategory = Source.EquipmentCategory,
                DifficultyLevel = Source.DifficultyLevel,
                LastUpdated = CURRENT_TIMESTAMP

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ExerciseID, ExerciseName, EquipmentCategory, DifficultyLevel)
            VALUES (Source.ExerciseID, Source.ExerciseName, Source.EquipmentCategory, Source.DifficultyLevel);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        INSERT INTO EXCEPTION_LOG (ErrorNumber, ErrorMessage, ErrorProcedure)
        VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_PROCEDURE());

        THROW;
    END CATCH
END;
