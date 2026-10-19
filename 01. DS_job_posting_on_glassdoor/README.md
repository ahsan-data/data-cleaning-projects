# Glassdoor Data Science Job Postings. Data Cleaning with SQL

## About the Project

In this project, I cleaned a Glassdoor job postings dataset using PostgreSQL.

The dataset contains information about job titles, salary estimates, company names, locations, ratings and other job-related details. Before using this data for analysis, I worked on fixing common data quality issues and making the values more consistent.

I used SQL to clean text, separate location fields, extract salary ranges, handle missing values and remove duplicate records. I kept the original data unchanged and used a separate staging table for the cleaning work.

## Dataset

- **Source:** [Data Science Job Posting on Glassdoor. Kaggle](https://www.kaggle.com/datasets/rashikrahmanpritom/data-science-job-posting-on-glassdoor)
- **Database:** PostgreSQL
- **Language:** SQL
- **Project:** Data Cleaning

## Problems I Worked On

- Removed an unnecessary index column.
- Renamed columns to make them consistent and easier to work with.
- Cleaned salary estimates and extracted minimum and maximum salary values.
- Removed rating values from company names where the format was recognizable.
- Separated job locations and company headquarters into city and state fields.
- Handled missing and unknown values, including `-1` in the `Founded` column.
- Removed extra spaces and converted empty text values to `NULL`.
- Found and removed duplicate records.

## What I Did

### 1. Set Up the Database

Created the database and tables needed for the project.

### 2. Loaded the Raw Data

Imported the original dataset into PostgreSQL and checked the records before making changes.

### 3. Created a Staging Table

Made a copy of the raw table so I could clean the data without changing the original records.

### 4. Cleaned Salary Estimates

Removed additional text in parentheses and extracted minimum and maximum salary values into separate numeric columns when the values followed the expected format.

### 5. Cleaned Company Names and Job Titles

Removed trailing rating values from company names where possible, trimmed extra spaces, and standardized job title capitalization.

### 6. Separated Location Fields

Split job locations and company headquarters into city and state columns. I also checked values that did not follow the expected format.

### 7. Handled Missing Values

Converted `-1` to `NULL` in the `Founded` column because it represented an unknown founding year. I also cleaned empty text values in selected columns.

### 8. Removed Duplicates

Used `ROW_NUMBER()` and a CTE to find duplicate records and remove extra copies while keeping one record from each duplicate group.

### 9. Checked the Results

Ran SQL queries to check missing values, salary ranges, duplicate records, and location fields.

### 10. Created the Final Table

Created the `job_postings_cleaned` table from the staging table after the cleaning steps.

## SQL Skills Practiced

- `CREATE TABLE` and `ALTER TABLE`
- `UPDATE` and `DELETE`
- `BTRIM()` and `INITCAP()`
- `SPLIT_PART()` and `REGEXP_REPLACE()`
- `NULLIF()` and `NULL` handling
- Common Table Expressions (CTEs)
- Window functions with `ROW_NUMBER()`
- Duplicate detection and removal
- Data validation

## Repository Structure

```text
glassdoor-job-postings-cleaning/
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_job_postings_raw.sql
│   ├── 04_job_postings_staging.sql
│   └── 05_job_postings_cleaned.sql
│
├── documentation/
│   └── data_cleaning_log.md
│
├── screenshots/
├── data/
│   ├── raw/
│   └── cleaned/
│
├── .gitignore
└── README.md
```

## How to Run

1. Install PostgreSQL and open your SQL client.
2. Download the dataset from Kaggle using the link above.
3. Run `01_create_database.sql`.
4. Connect to the new database.
5. Run the remaining SQL files in numerical order.
6. Check the validation queries and review the final `job_postings_cleaned` table.

The file paths and table names may need to be adjusted to match your PostgreSQL setup.

## Documentation

The `documentation/` folder contains `data_cleaning_log.md`, where I record the cleaning steps, important SQL queries, screenshots, and validation results.

## Project Status

The cleaning workflow and validation queries are included in the project. The final results should be checked to make sure the cleaning steps worked as expected.

## Acknowledgment

Thanks to the dataset creator for sharing the Glassdoor job postings dataset on Kaggle.

**Dataset:** [Data Science Job Posting on Glassdoor](https://www.kaggle.com/datasets/rashikrahmanpritom/data-science-job-posting-on-glassdoor)