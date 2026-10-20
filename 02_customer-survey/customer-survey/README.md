# Customer Survey Data Cleaning

## Overview

This project focuses on cleaning and preparing customer survey data for analysis using PostgreSQL. The work includes checking data quality, standardizing text values, converting data types, splitting address fields, cleaning contact information and identifying potential duplicate records.

## Data Source

The dataset was obtained from [Data Analytics Lab](https://github.com/data-analytics-labs/tutorials/blob/main/survey_dataset_messy_txt.txt).

## Tools Used

- PostgreSQL
- SQL
- pgAdmin 4

## Project Structure

```text
customer-survey-data-cleaning/
│
├── data/
│   ├── raw_data/
│   │   └── customer_survey_raw.csv
│   │
│   └── cleaned_data/
│       └── customer_survey_cleaned.csv
│
├── sql_queries/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_survey_dataset_raw.sql
│   ├── 04_customer_survey_staging.sql
│   └── 05_customer_survey_cleaned.sql
│
├── documentation/
│   └── data_cleaning_log.md
│
├── results/
│   └── screenshots/
│       ├── address_separate.png
│       ├── contact_clean.png
│       ├── Date_cleaning.png
│       ├── duplicate_count.png
│       └── text_standardization.png
│
└── README.md
```

## Data Cleaning Process

1. Checked the initial row count and number of unique customers.
2. Removed extra spaces and standardized membership values.
3. Standardized service feedback categories.
4. Converted survey dates to the `DATE` data type.
5. Split addresses into street, city, and state.
6. Cleaned email and phone values and created a preferred contact column.
7. Identified potential duplicate records and reviewed repeated submissions.
8. Validated the cleaned data and checked the final record count.

## Files and Folders

- **`data/raw_data/`**: Contains the original survey dataset.
- **`data/cleaned_data/`**: Contains the cleaned survey dataset.
- **`sql_queries/`**: Contains the SQL scripts in execution order.
- **`documentation/`**: Contains the data cleaning log.
- **`results/screenshots/`**: Contains screenshots of selected cleaning and validation steps.

## Results

The project produces a cleaned customer survey dataset with standardized values and structured fields, ready for further analysis.

Final record counts and duplicate-removal results should be confirmed using the SQL validation queries.

## Notes

The original raw dataset is kept separate from the staging table to preserve the source data during cleaning.