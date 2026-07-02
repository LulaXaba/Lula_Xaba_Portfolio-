// ==============================================================================
// FILE: payload_validator.cs
// PURPOSE: Rule-based sanitization to prevent database corruption.
//          Routes malformed records to the Dead Letter Queue (DLQ).
// ==============================================================================

public class IngestionValidator
{
    public ValidationResult ValidateBatch(List<ExerciseRecord> records)
    {
        var validRecords = new List<ExerciseRecord>();
        var deadLetterQueue = new List<ExceptionRecord>();

        foreach (var record in records)
        {
            if (string.IsNullOrWhiteSpace(record.ExerciseId) || string.IsNullOrWhiteSpace(record.Name))
            {
                deadLetterQueue.Add(new ExceptionRecord(record, "Missing Primary Key or Name"));
                continue;
            }

            record.Name = record.Name.Trim().ToUpperInvariant();

            if (!IsValidEquipmentCategory(record.Equipment))
            {
                deadLetterQueue.Add(new ExceptionRecord(record, $"Invalid Equipment Enum: {record.Equipment}"));
                continue;
            }

            validRecords.Add(record);
        }

        return new ValidationResult(validRecords, deadLetterQueue);
    }

    private bool IsValidEquipmentCategory(string equipment)
    {
        return new[] { "BARBELL", "DUMBBELL", "MACHINE", "BODYWEIGHT", "CABLE", "NONE" }
            .Contains(equipment?.Trim().ToUpperInvariant());
    }
}
