# Data Cleaning Projects

This repository contains data cleaning projects focused on improving data quality, consistency, and reliability. Each project uses a different dataset to practice data cleaning techniques and document the steps taken.

The projects currently focus on SQL, with plans to add Excel and Python projects in the future.

## Projects

| No. | Project | Tool | Description |
|---|---|---|---|
| 01 | [Data Science Job Postings](./01_DS_job_posting_on_glassdoor/) | PostgreSQL | Clean and standardize job posting data from Glassdoor. |
| 02 | [Customer Survey](./02_customer-survey/) | PostgreSQL | Clean customer survey data, standardize responses, and handle duplicate records. |
| 03 | [Employee Records](./03_employee_records/) | PostgreSQL | Clean and standardize employee records, including names, contact details, dates, and salary values. |

## Tools

- PostgreSQL
- Git and GitHub

## Project Approach

Each project follows a practical data cleaning workflow:

- Review the original dataset and identify data quality issues.
- Keep the original data unchanged.
- Create a staging table for cleaning and transformation.
- Standardize inconsistent values and data formats.
- Handle missing values, invalid entries, and duplicate records where appropriate.
- Validate the cleaned data and document the results.

The cleaning rules depend on the dataset and are documented within each project.

## Repository Structure

```text
data-cleaning-projects/
│
├── 01_DS_job_posting_on_glassdoor/
├── 02_customer-survey/
├── 03_employee_records/
└── README.md
```

Each project folder contains its own SQL scripts, documentation, and supporting files where applicable.

## Purpose

This repository serves as a practical portfolio of data cleaning work, demonstrating how I identify data quality issues, apply appropriate cleaning rules, and validate the results.

More projects using Power Query and Python will be added over time.
