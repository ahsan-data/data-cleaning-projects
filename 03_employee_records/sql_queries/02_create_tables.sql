DROP TABLE IF EXISTS employee_records_raw;

CREATE TABLE employee_records_raw (
    employee_id TEXT,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    department TEXT,
    job_title TEXT,
    hire_date TEXT,
    salary TEXT,
    employment_status TEXT,
    work_location TEXT
);

SELECT * FROM employee_records_raw;

--Create a staging table to hold the data from the raw table

CREATE TABLE employee_records_staging AS
SELECT *
FROM employee_records_raw;

SELECT * FROM employee_records_staging;