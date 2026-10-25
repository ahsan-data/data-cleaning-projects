# Employee Records Data

## Project Overview

This project focuses on cleaning and standardizing a synthetic employee dataset using SQL. The goal was to improve data consistency, identify missing and invalid values and prepare the records for further analysis.

The original dataset was preserved, and all cleaning operations were performed on a separate staging table. The cleaned results were saved in `employee_records_cleaned`.

## Data Source

The dataset was generated with the help of ChatGPT for this data cleaning practice project. The Python script used to generate the dataset is available in the `scripts/` folder.

This dataset contains synthetic employee information and does not represent real individuals.

## Tools Used

- PostgreSQL
- SQL
- pgAdmin / SQL editor

## Cleaning Process

### 1. Initial Data Review

Reviewed the staging table and checked the initial row count. Examined distinct values in each column to identify inconsistent formats, missing values, duplicates, and other data quality issues.

### 2. Employee ID Cleaning

Standardized employee IDs into the `EMP-00000` format where the original value could be interpreted reliably.

- Standardized numeric IDs and supported variations in employee ID formats.
- Identified missing values and common placeholders.
- Checked for duplicate IDs and values that did not match the expected format.

Values that could not be reliably standardized were retained for further review.

### 3. Employee Name Cleaning

Reviewed employee names and corrected common formatting issues.

- Standardized capitalization and removed leading or trailing spaces.
- Removed unnecessary spaces between words.
- Removed commas from names stored in a `Last, First` format.
- Used email usernames to fill missing names where a reasonable name could be derived.

The resulting names were checked for missing values.

### 4. Email Cleaning

Standardized email formatting and reviewed invalid or missing values.

- Converted email addresses to lowercase.
- Removed leading and trailing spaces.
- Replaced common missing-value placeholders with `NULL`.
- Identified email addresses containing consecutive dots for further review.

Email format validation remained part of the final data quality checks.

### 5. Phone Number Cleaning

Standardized recognizable US phone numbers into a consistent format.

- Removed unnecessary formatting characters when interpreting phone numbers.
- Standardized 10-digit numbers and supported 11-digit numbers beginning with `1`.
- Added the `+1` country code to recognized US numbers.
- Converted common missing-value placeholders to `NULL`.
- Retained incomplete or unrecognized values for review rather than guessing the correct number.

### 6. Department Standardization

Standardized department names to make grouping and reporting easier.

- Corrected capitalization and spacing.
- Mapped recognized abbreviations and variations to consistent department names.
- Standardized examples such as IT, Finance, Marketing, Operations, and HR-related entries.
- Replaced selected missing-value placeholders with `NULL`.

Reviewed the distinct department values after cleaning.

### 7. Job Title Standardization

Cleaned job titles to improve consistency.

- Standardized capitalization and spacing.
- Expanded abbreviations such as `Mgr` and `Asst`.
- Standardized selected abbreviations, including IT, SEO, and HR.
- Reviewed distinct job titles to identify remaining inconsistencies.

### 8. Hire Date Cleaning

Reviewed hire dates stored in different formats and converted recognized values to PostgreSQL's `DATE` data type.

- Identified missing values and invalid date entries.
- Converted supported formats, including `MM-DD-YYYY`, `DD/MM/YYYY`, and `DD-Mon-YY`.
- Reviewed specific invalid dates and corrected selected values where a replacement was explicitly determined.
- Converted unsupported or unrecognized formats to `NULL` during conversion.

Date values were reviewed before and after conversion.

### 9. Salary Cleaning

Converted salary values to a numeric data type for easier analysis.

- Removed currency symbols, commas, and other non-numeric formatting characters.
- Converted common missing-value placeholders to `NULL`.
- Rounded salary values to whole numbers.
- Replaced zero salaries with `NULL` as part of the project's data quality rules.

Salary values were checked after conversion.

### 10. Employment Status Standardization

Standardized employment status values into consistent categories.

- Corrected capitalization and spacing.
- Mapped recognized variations to `Active`, `Leave`, `Terminated`, or `Resigned`.
- Replaced selected missing-value placeholders with `NULL`.
- Reviewed the distinct values remaining after standardization.

### 11. Work Location Standardization

Standardized work locations to make location-based analysis more consistent.

- Corrected capitalization and spacing.
- Mapped recognized abbreviations and variations to locations such as New York, San Francisco, Seattle, Austin, and Chicago.
- Standardized recognized remote-work labels to `Remote`.
- Replaced selected missing-value placeholders and `True`/`False` entries with `NULL`.

Reviewed the final distinct location values.

### 12. Duplicate Record Review

Checked for duplicate employee IDs, identical records, and records sharing the same employee name, email, and hire date.

Used `ROW_NUMBER()` and PostgreSQL's `ctid` to identify and remove repeated records based on the combination of `full_name`, `email`, and `hire_date`, keeping one record from each matching group.

This rule was applied only when all three fields were present.

### 13. Final Data Quality Checks

Reviewed the staging table for remaining missing values, invalid employee ID formats, and common missing-value placeholders.

Compared the row counts of the original and staging tables to check how the record count changed during cleaning.

The final results were saved to `employee_records_cleaned` for further analysis.

## SQL Techniques Used

- `SELECT`, `DISTINCT`, and `COUNT()` for data profiling
- `UPDATE` and `CASE` for data correction and standardization
- `TRIM()`, `BTRIM()`, `INITCAP()`, and `LOWER()` for text cleaning
- `REGEXP_REPLACE()` and regular expressions for pattern-based cleaning
- `SPLIT_PART()` and `SUBSTRING()` for extracting values
- `ALTER TABLE` for changing column data types
- `TO_DATE()` for date conversion
- `ROW_NUMBER()` and `ctid` for duplicate removal
- `NULL` handling and validation queries

## Project Outcome

The project produced a cleaned employee records table with more consistent employee IDs, names, contact details, department names, job titles, hire dates, salary values, employment statuses, and work locations.

Duplicate records were removed according to the selected matching rule. Missing, invalid, and unrecognized values were reviewed through validation queries.

The original raw table remains unchanged, allowing the cleaning results to be checked against the source data.

## Limitations

- The dataset is synthetic and intended for SQL practice.
- Some invalid values may remain where the correct value could not be determined reliably.
- Names derived from email usernames may not always match an employee's actual name.
- Phone numbers were standardized using US number formats. This does not confirm that a number is valid or belongs to a particular employee.
- Duplicate removal was based on the selected combination of name, email, and hire date. Records with shared values may require further investigation before being treated as duplicates.

## Final Tables

| Table | Purpose |
|---|---|
| `employee_records_raw` | Original dataset, preserved unchanged |
| `employee_records_staging` | Working table used for cleaning and validation |
| `employee_records_cleaned` | Final cleaned dataset |

