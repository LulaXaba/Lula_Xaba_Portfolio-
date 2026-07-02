# 📘 Data Dictionary

This document defines the canonical target schema for the ingestion pipeline and the business meaning of each field.

## Core Entity: FITNESS_EXERCISE

| Column | Type | Nullable | Description | Business Rule |
| :--- | :--- | :--- | :--- | :--- |
| ExerciseID | VARCHAR(50) | No | Unique identifier for the exercise record | Must be unique and non-empty |
| ExerciseName | VARCHAR(200) | No | Official exercise name | Trim whitespace and uppercase before load |
| EquipmentCategory | VARCHAR(50) | No | Category of equipment required | Must match allowed enumeration |
| DifficultyLevel | VARCHAR(30) | No | Difficulty classification | Must be one of BEGINNER, INTERMEDIATE, ADVANCED |
| LastUpdated | DATETIME | No | Timestamp of the last ingest/update event | Default to current timestamp |

## Allowed Values

- EquipmentCategory: BARBELL, DUMBBELL, MACHINE, BODYWEIGHT, CABLE, NONE
- DifficultyLevel: BEGINNER, INTERMEDIATE, ADVANCED

## Validation Expectations

- Missing ExerciseID or ExerciseName must be rejected.
- Null or malformed enum values must be quarantined.
- Duplicate ExerciseID values will trigger an update/merge strategy in the database layer.
