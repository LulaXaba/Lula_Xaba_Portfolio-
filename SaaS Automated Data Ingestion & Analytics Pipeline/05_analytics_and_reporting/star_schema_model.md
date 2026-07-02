# 📊 Power BI Analytics Star Schema Model

To optimize report rendering and eliminate complex relational queries, the ingested FitnessExerciseDB data is transformed into a highly efficient Star Schema within the analytics presentation layer.

## Architectural Design

```mermaid
erDiagram
    FACT_EXERCISE_LOGS {
        UUID LogID PK
        UUID DateKey FK
        UUID ClientKey FK
        UUID ExerciseKey FK
        INT TotalCompletions
        DECIMAL AvgIntensityScore
    }
    DIM_DATE {
        UUID DateKey PK
        DATE FullDate
        INT CalendarYear
        VARCHAR MonthName
        INT Quarter
    }
    DIM_CLIENTS {
        UUID ClientKey PK
        VARCHAR ClientName
        VARCHAR TierLevel
        VARCHAR Region
    }
    DIM_EXERCISES {
        UUID ExerciseKey PK
        VARCHAR ExerciseName
        VARCHAR EquipmentCategory
        VARCHAR DifficultyLevel
    }

    DIM_DATE ||--o{ FACT_EXERCISE_LOGS : "filters"
    DIM_CLIENTS ||--o{ FACT_EXERCISE_LOGS : "segments"
    DIM_EXERCISES ||--o{ FACT_EXERCISE_LOGS : "categorizes"
```

## Data Model Best Practices Applied

- **De-normalization:** Avoided snowflake schemas by embedding equipment categories directly into the DIM_EXERCISES table, drastically minimizing SQL join overhead during dashboard refreshes.
- **Time-Intelligence:** Integrated a dedicated DIM_DATE table to allow enterprise users to perform seamless Month-over-Month (MoM) usage velocity analytics.
