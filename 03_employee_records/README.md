# Employee Records Data Cleaning with PostgreSQL

## Project Overview

This project focuses on cleaning an employee dataset using PostgreSQL. The dataset contains common data quality issues, including inconsistent employee IDs, missing values, different text formats, invalid dates, salary formatting problems, and duplicate records.

I used SQL to review the data, standardize values where possible, and prepare a cleaned table for further analysis.

The original data was preserved in its raw table. All cleaning operations were performed on a separate staging table.

## Tools Used

- PostgreSQL
- SQL
- pgAdmin

## Dataset

The dataset contains 10 columns covering employee information, including:

- Employee ID and full name
- Email and phone number
- Department and job title
- Hire date and salary
- Employment status and work location

The dataset was generated with the help of ChatGPT for this practice project. The Python script used to generate the data is available in the `scripts/` folder.

All records are synthetic and do not represent real employees.

## Data Cleaning Steps

The main cleaning tasks included:

1. **Data review:** Checked row counts, distinct values, missing fields, and inconsistent formats.
2. **Employee IDs:** Standardized recognizable ID formats and reviewed missing or invalid IDs.
3. **Employee names:** Corrected capitalization and spacing, removed unwanted commas, and derived some missing names from email usernames.
4. **Email addresses:** Standardized capitalization, removed extra spaces, and identified formatting issues.
5. **Phone numbers:** Standardized recognizable US phone numbers and flagged incomplete or unrecognized values for review.
6. **Departments:** Standardized department names and common abbreviations.
7. **Job titles:** Corrected capitalization and standardized selected abbreviations.
8. **Hire dates:** Reviewed date formats, handled selected invalid values, and converted supported dates to the `DATE` data type.
9. **Salary:** Removed formatting characters, converted values to a numeric type, rounded salaries, and treated zero salaries as missing.
10. **Employment status:** Standardized recognized values such as Active, Leave, Terminated, and Resigned.
11. **Work locations:** Standardized recognized location names and remote-work labels.
12. **Duplicate records:** Identified and removed repeated records based on employee name, email, and hire date.
13. **Final validation:** Reviewed remaining missing values, checked employee ID formats, and compared row counts.

## Project Structure

```text
employee-records/
│
├── data/
│   ├── raw_data/
│   │   └── employees_raw.csv
│   └── cleaned_data/
│       └── employees_cleaned.csv
│
├── sql_queries/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_employee_records_raw.sql
│   ├── 04_employee_records_staging.sql
│   └── 05_employee_records_cleaned.sql
│
├── scripts/
│   └── generate_dataset.py
│
├── documentation/
│   └── data_cleaning_log.md
│
├── results/
│   └── screenshots/
│
└── README.md
```


## Database Tables

| Table | Purpose |
|---|---|
| [employee_records_raw](sql_queries/03_employees_raw.sql) | Stores the original dataset without cleaning changes |
| [employee_records_staging](sql_queries/04_employees_staging.sql) | Holds the working copy used for cleaning |
| [employee_records_cleaned](sql_queries/05_employees_cleaned.sql) | Stores the final results |

## Validation

After cleaning, I reviewed the data to check:

- Remaining missing and placeholder values
- Employee IDs that did not match the standard format
- Duplicate employee records under the selected matching rule
- Distinct values in standardized columns
- Row counts before and after cleaning

The cleaned table is intended for further analysis. Values that could not be determined reliably were not automatically corrected.

## Results and Documentation


For a more detailed explanation of the changes made, see the [Data Cleaning Log](documentation/data_cleaning_log.md).

## Notes

This is a practice project built with synthetic data. Some values may remain incomplete or require further review. Standardizing a value does not guarantee that the underlying information is correct.

The project demonstrates my use of PostgreSQL to inspect, clean, standardize and validate data while keeping the original dataset unchanged.

