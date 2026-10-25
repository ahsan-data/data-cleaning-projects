/*
Project: Employee Records
Database: PostgreSQL

Purpose:
Clean and standardize employee records to improve data quality,
consistency and reliability.

Data Source:
The dataset was generated with the help of ChatGPT for this
data cleaning practice project. The Python script used to
generate the dataset is available in the scripts/ folder.

The original raw table is kept unchanged. All cleaning operations
are performed on a separate staging table.

Note:
This dataset is intended for practice and portfolio demonstration.
Values are corrected only when the intended value can be determined
reliably. Unclear or invalid values are flagged for review rather
than changed based on assumptions.
*/

-- Cleaning Process
-- =======================================================

---1. Review the dataset and check the initial row count.---

SELECT COUNT(*) AS initial_row_count
FROM employee_records_staging;

---2. Inspect column values and identify data quality issues.---

SELECT DISTINCT employee_id
FROM employee_records_staging
ORDER BY employee_id;

SELECT DISTINCT full_name
FROM employee_records_staging
ORDER BY full_name;

SELECT DISTINCT email
FROM employee_records_staging
ORDER BY email;

SELECT DISTINCT phone
FROM employee_records_staging
ORDER BY phone;

SELECT DISTINCT department
FROM employee_records_staging
ORDER BY department;

SELECT DISTINCT job_title
FROM employee_records_staging
ORDER BY job_title;

SELECT DISTINCT hire_date
FROM employee_records_staging
ORDER BY hire_date;

SELECT DISTINCT salary
FROM employee_records_staging
ORDER BY salary;

SELECT DISTINCT employment_status
FROM employee_records_staging
ORDER BY employment_status;

SELECT DISTINCT work_location
FROM employee_records_staging
ORDER BY work_location;

SELECT *
FROM employee_records_staging
WHERE employee_id IS NULL
   OR BTRIM(employee_id) IN ('', 'NULL', 'null', 'N/A', '-', 'None', 'unknown')
   OR full_name IS NULL
   OR BTRIM(full_name) IN ('', 'NULL', 'null', 'N/A', '-', 'None', 'unknown');

---3. Check employee IDs for missing values, duplicates, and inconsistent formats.---
-- Change data type
ALTER TABLE employee_records_staging
ALTER COLUMN employee_id TYPE VARCHAR (50);

SELECT employee_id, COUNT(*) AS occurrence_count
FROM employee_records_staging
GROUP BY employee_id
ORDER BY employee_id;

--NULL define --36
SELECT employee_id
FROM employee_records_staging
ORDER BY employee_id;

UPDATE employee_records_staging
SET employee_id = NULL
WHERE employee_id IN ('-');

---standardize employee id ----
SELECT
    employee_id AS old_employee_id,
    CASE
        WHEN BTRIM(employee_id) ~ '^[0-9]{1,5}$'
            THEN 'EMP-' || LPAD(BTRIM(employee_id), 5, '0')

        WHEN BTRIM(employee_id) ~ '^E[0-9]{5}$'
            THEN 'EMP-' || SUBSTRING(BTRIM(employee_id) FROM 2)

        WHEN BTRIM(employee_id) ~ '^EMP-[0-9]{5}$'
            THEN BTRIM(employee_id)

        ELSE employee_id
    END AS standardized_employee_id
FROM employee_records_staging
ORDER BY employee_id;

UPDATE employee_records_staging
SET
	employee_id = CASE
        WHEN BTRIM(employee_id) ~ '^[0-9]{1,5}$'
            THEN 'EMP-' || LPAD(BTRIM(employee_id), 5, '0')

        WHEN BTRIM(employee_id) ~ '^E[0-9]{5}$'
            THEN 'EMP-' || SUBSTRING(BTRIM(employee_id) FROM 2)

        WHEN BTRIM(employee_id) ~ '^EMP-[0-9]{5}$'
            THEN BTRIM(employee_id)

        ELSE employee_id
    END;

--define null -------

SELECT employee_id, COUNT(*) AS employee_count
FROM employee_records_staging
WHERE employee_id IS NULL;
	OR employee_id IN ('null','n/a','None','N/A', 'unknown')
GROUP BY employee_id;

UPDATE employee_records_staging
SET employee_id = NULL
WHERE BTRIM(employee_id) IN ('null','n/a','None','N/A', 'unknown');

SELECT employee_id, COUNT(*) AS employee_count
FROM employee_records_staging
WHERE employee_id IS NULL
GROUP BY employee_id;

---4. Clean and standardize employee names.---

-- Check missing or invalid full names.---

SELECT COUNT(*) AS name_null_count
FROM employee_records_staging
WHERE full_name IS NULL
   OR TRIM(full_name) = ''
   OR TRIM(full_name) IN (',', '-', 'N/A', 'n/a', 'None'' ');


SELECT full_name, 
	   BTRIM(INITCAP(full_name)) AS first_name_cleaned
FROM employee_records_staging;


----Update existing employee full name ---

UPDATE employee_records_staging
SET full_name = BTRIM(INITCAP(full_name));

UPDATE employee_records_staging
SET full_name = NULL
WHERE TRIM(full_name)IN ('-', 'N/A', 'n/a', 'None');
	
SELECT COUNT(*)
FROM employee_records_staging
WHERE full_name IS NULL;
 
-- Remove extra spaces between words.

UPDATE employee_records_staging
SET full_name = REGEXP_REPLACE(TRIM(full_name), '\s+', ' ', 'g')
WHERE full_name ~ '\s{2,}';

-- Remove commas from full names.

UPDATE employee_records_staging
SET full_name = REPLACE(full_name, ',', '')
WHERE full_name LIKE '%,%';


-- Extract full names from email addresses for missing records.

SELECT
    full_name,
    email,
    INITCAP(
        REPLACE(
            SPLIT_PART(email, '@', 1),
            '.',
            ' '
        )
    ) AS extracted_full_name
FROM employee_records_staging
WHERE full_name IS NULL
  AND email IS NOT NULL
  AND email LIKE '%@%';

-- Restore missing full names using email addresses.

UPDATE employee_records_staging
SET 
	full_name = INITCAP(
        REPLACE(
            SPLIT_PART(email, '@', 1),
            '.',
            ' '
        )
    );
	
---Validate full name --

SELECT full_name
FROM employee_records_staging
WHERE full_name IS NOT NULL;

---5. Validate and standardize email addresses.---

-- Change data type

ALTER TABLE employee_records_staging
ALTER COLUMN email TYPE VARCHAR(150);

-- Remove extra spaces AND standardize----

SELECT email, 
	   BTRIM(LOWER("email")) AS cleaned_email
FROM employee_records_staging;

UPDATE employee_records_staging
SET email =BTRIM(LOWER("email"));

SELECT email
FROM employee_records_staging
WHERE email IN ('-','n/a','N/A','None','none','null');

--- standardize email address --
UPDATE employee_records_staging
SET email = NULL
WHERE BTRIM(email) IN ('-','n/a','N/A','None','none','null');

-- Replace consecutive dots in email addresses with a single dot.---

SELECT
    email,
    REGEXP_REPLACE(email, '\.{2,}', '.', 'g') AS corrected_email
FROM employee_records_staging
WHERE email ~ '\.{2,}';

----Validate email
SELECT email
FROM employee_records_staging;


---6. Review phone numbers and standardize their formats where possible.---

SELECT phone
FROM employee_records_staging;

SELECT
    phone AS original_phone,
    CASE
        -- US number with country code +1
        WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g') ~ '^1[0-9]{10}$'
            THEN '+1 ' || SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 2 FOR 3
            ) || '-' || SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 5 FOR 3
            ) || '-' || SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 8 FOR 4
            )

        -- US number with 10 digits
        WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g') ~ '^[0-9]{10}$'
            THEN SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 1 FOR 3
            ) || '-' || SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 4 FOR 3
            ) || '-' || SUBSTRING(
                REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 7 FOR 4
            )

        ELSE phone
    END AS standardized_phone
FROM employee_records_staging;

UPDATE employee_records_staging
SET phone = CASE
    -- US number with country code +1
    WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g') ~ '^1[0-9]{10}$'
        THEN '+1 ' || SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 2 FOR 3
        ) || '-' || SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 5 FOR 3
        ) || '-' || SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 8 FOR 4
        )

    -- US number with 10 digits
    WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g') ~ '^[0-9]{10}$'
        THEN SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 1 FOR 3
        ) || '-' || SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 4 FOR 3
        ) || '-' || SUBSTRING(
            REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 7 FOR 4
        )

    ELSE phone
END
WHERE phone IS NOT NULL;

SELECT phone
FROM employee_records_staging
WHERE phone IS NOT NULL
  AND REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
      !~ '^(1)?[0-9]{10}$';

SELECT
    phone AS original_phone,
    CASE
        WHEN phone IS NULL
          OR LOWER(TRIM(phone)) IN (
              '', '-', 'n/a', 'na', 'none',
              'null', 'unknown', 'abc-defg'
          )
            THEN NULL

        ELSE
            CASE
                WHEN REGEXP_REPLACE(
                    REGEXP_REPLACE(phone, '\s*ext\.?\s*\d+$', '', 'i'),
                    '[^0-9]', '', 'g'
                ) ~ '^[0-9]{10}$'
                THEN
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(phone, '\s*ext\.?\s*\d+$', '', 'i'),
                            '[^0-9]', '', 'g'
                        ),
                        '([0-9]{3})([0-9]{3})([0-9]{4})',
                        '\1-\2-\3'
                    )
                ELSE TRIM(phone)
            END
    END AS standardized_phone
FROM employee_records_staging;

UPDATE employee_records_staging
SET phone =
    CASE
        WHEN phone IS NULL
          OR LOWER(TRIM(phone)) IN (
              '', '-', 'n/a', 'na', 'none',
              'null', 'unknown', 'abc-defg'
          )
            THEN NULL

        WHEN REGEXP_REPLACE(
            REGEXP_REPLACE(phone, '\s*ext\.?\s*\d+$', '', 'i'),
            '[^0-9]', '', 'g'
        ) ~ '^[0-9]{10}$'
            THEN REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        phone,
                        '\s*ext\.?\s*\d+$',
                        '',
                        'i'
                    ),
                    '[^0-9]', '', 'g'
                ),
                '([0-9]{3})([0-9]{3})([0-9]{4})',
                '\1-\2-\3'
            )

        ELSE TRIM(phone)
    END;

SELECT phone
FROM employee_records_staging
WHERE phone IS NOT NULL
  AND phone !~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$';

UPDATE employee_records_staging
SET phone =
    CASE
        -- Missing or placeholder values
        WHEN phone IS NULL
          OR LOWER(TRIM(phone)) IN (
              '', '-', 'n/a', 'na', 'none',
              'null', 'unknown', 'abc-defg'
          )
            THEN NULL

        -- 10-digit phone number, with or without separators
        WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
             ~ '^[0-9]{10}$'
            THEN '+1 ' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 1 FOR 3
                 ) || '-' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 4 FOR 3
                 ) || '-' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 7 FOR 4
                 )

        -- 11-digit number beginning with 1 (country code)
        WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
             ~ '^1[0-9]{10}$'
            THEN '+1 ' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 2 FOR 3
                 ) || '-' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 5 FOR 3
                 ) || '-' ||
                 SUBSTRING(
                     REGEXP_REPLACE(phone, '[^0-9]', '', 'g')
                     FROM 8 FOR 4
                 )

        -- Keep incomplete or unrecognized values for review
        ELSE TRIM(phone)
    END;

SELECT phone
FROM employee_records_staging
ORDER BY phone;


SELECT phone
FROM employee_records_staging
WHERE phone IS NOT NULL
  AND phone !~ '^\+1 [0-9]{3}-[0-9]{3}-[0-9]{4}$';

UPDATE employee_records_staging
SET phone =
    CASE
        WHEN REGEXP_REPLACE(phone, '[^0-9]', '', 'g') ~ '^[0-9]{10}$'
            THEN '+1 ' ||
                 SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 1 FOR 3) || '-' ||
                 SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 4 FOR 3) || '-' ||
                 SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', '', 'g') FROM 7 FOR 4)
        WHEN phone ~ '^[0-9]{3}-[0-9]{3}$'
            THEN NULL
        ELSE phone
    END;

SELECT phone
FROM employee_records_staging
WHERE phone IS NOT NULL
  AND phone !~ '^\+1 [0-9]{3}-[0-9]{3}-[0-9]{4}$';
  
---7. Standardize department names.---

SELECT DISTINCT(department)
FROM employee_records_staging;

SELECT department, 
		BTRIM(INITCAP(department)) AS 
		department_cleaned
FROM employee_records_staging;

UPDATE employee_records_staging
SET department = BTRIM(INITCAP(department));


-- Standardize department names----

ALTER TABLE employee_records_staging
ALTER COLUMN department TYPE VARCHAR(50);

SELECT
    department,
    CASE
        WHEN department ILIKE 'Information%'
          OR department ILIKE 'Info%'
          OR department ILIKE 'I.%'
		  OR department ILIKE 'It%'
          OR department ILIKE 'IT'
            THEN 'Information Technology'

        WHEN department ILIKE 'Fin%'
          OR department ILIKE 'Finance%'
            THEN 'Accounting & Finance'

        WHEN department ILIKE 'Sales%'
            THEN 'Sales'

        WHEN department ILIKE 'Mar%'
          OR department ILIKE 'Mktg%'
            THEN 'Marketing'

        WHEN department ILIKE 'Ops%'
          OR department ILIKE 'Op%'
            THEN 'Operations'

        WHEN department ILIKE 'H.R%'
          OR department ILIKE 'Human%'
            THEN 'Human Resource'

        ELSE department
    END AS department_cleaned
FROM employee_records_staging;


UPDATE employee_records_staging
SET department = CASE
        WHEN department ILIKE 'Information%'
          OR department ILIKE 'Info%'
          OR department ILIKE 'I.%'
		  OR department ILIKE 'It%'
          OR department ILIKE 'IT'
            THEN 'Information Technology'

        WHEN department ILIKE 'Fin%'
          OR department ILIKE 'Finance%'
            THEN 'Accounting & Finance'

        WHEN department ILIKE 'Sales%'
            THEN 'Sales'

        WHEN department ILIKE 'Mar%'
          OR department ILIKE 'Mktg%'
            THEN 'Marketing'

        WHEN department ILIKE 'Ops%'
          OR department ILIKE 'Op%'
            THEN 'Operations'

        WHEN department ILIKE 'H.R%'
          OR department ILIKE 'H%'
		  OR department ILIKE 'Human%'
            THEN 'Human Resource'

        ELSE department
    END;


SELECT department
FROM employee_records_staging
WHERE BTRIM(department) IN ('Unknown','-','N/A','Null', 'None');

UPDATE employee_records_staging
SET
 	department = NULL
WHERE BTRIM(department) IN ('-','N/A','Null', 'None');

UPDATE employee_records_staging
SET department = REGEXP_REPLACE(TRIM(department), '\s+', ' ', 'g')
WHERE department ~ '\s{2,}';

---Validate department --

SELECT DISTINCT(department) AS unique_department_name
FROM employee_records_staging
ORDER BY department ;
	
---8. Standardize job titles.---
---define unique job title --

ALTER TABLE employee_records_staging
ALTER COLUMN job_title TYPE VARCHAR(50);

SELECT DISTINCT(job_title)
FROM employee_records_staging;


SELECT job_title
FROM employee_records_staging
WHERE BTRIM(job_title) IN ('Unknown','n/a','N/A','None','Null','null','-');

UPDATE employee_records_staging
SET job_title = NULL
WHERE BTRIM(job_title) IN ('n/a','N/A','None','Null','null','-');

---Standardize job title --

SELECT job_title,
		BTRIM(INITCAP(job_title)) AS cleaned_job_title
FROM employee_records_staging;

UPDATE employee_records_staging
SET job_title = BTRIM(INITCAP(job_title));

SELECT
    job_title,
    CASE
        WHEN job_title ILIKE '%Mgr'
            THEN REGEXP_REPLACE(job_title, 'Mgr$', 'Manager', 'i')
        WHEN job_title ILIKE '%Asst%'
            THEN REGEXP_REPLACE(job_title, 'Asst', 'Assistant', 'i')
        ELSE job_title
    END AS job_title_cleaned
FROM employee_records_staging;

UPDATE employee_records_staging
SET job_title = CASE
    WHEN job_title ILIKE '%Mgr'
        THEN REGEXP_REPLACE(job_title, 'Mgr$', 'Manager', 'i')
    WHEN job_title ILIKE '%Asst%'
        THEN REGEXP_REPLACE(job_title, 'Asst', 'Assistant', 'i')
    ELSE job_title
END
WHERE job_title ILIKE '%Mgr'
   OR job_title ILIKE '%Asst%';

-- Standardize job titles and abbreviations.--

UPDATE employee_records_staging
SET job_title =
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                INITCAP(TRIM(job_title)),
                '\.$', ''
            ),
            '\mIt\M', 'IT', 'g'
        ),
        '\mSeo\M', 'SEO', 'gi'
    )
WHERE job_title IS NOT NULL;

-- Standardize job titles, capitalization, and abbreviations.---

UPDATE employee_records_staging
SET job_title =
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    INITCAP(TRIM(job_title)),
                    '\.$', ''
                ),
                '\mIt\M', 'IT', 'g'
            ),
            '\mSeo\M', 'SEO', 'g'
        ),
        '\mSenior\M', 'Sr.', 'g'
    )
WHERE job_title IS NOT NULL;


-- Standardize HR capitalization in job titles.

UPDATE employee_records_staging
SET job_title = REGEXP_REPLACE(
    job_title,
    '\mHr\M',
    'HR',
    'g'
)
WHERE job_title ~* '\mHr\M';

---Validate Job title --

SELECT DISTINCT job_title
FROM employee_records_staging
ORDER BY job_title;

SELECT job_title
FROM employee_records_staging
WHERE job_title IS NOT NULL
LIMIT 50;

---9. Review hire dates and convert valid values to DATE format.---

SELECT DISTINCT(hire_date)
FROM employee_records_staging
ORDER BY hire_date;


SELECT hire_date
FROM employee_records_staging
WHERE BTRIM(hire_date) ~ '^\d{4}-\d{2}-\d{2}$'
  AND (
      SUBSTRING(BTRIM(hire_date), 6, 2)::INT NOT BETWEEN 1 AND 12
      OR SUBSTRING(BTRIM(hire_date), 9, 2)::INT NOT BETWEEN 1 AND 31
  );

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'employee_records_staging'
  AND column_name = 'hire_date';

SELECT hire_date, COUNT(*) AS record_count
FROM employee_records_staging
GROUP BY hire_date
ORDER BY hire_date;

SELECT hire_date
FROM employee_records_staging
WHERE TRIM(hire_date) ~ '^\d{2}/\d{2}/\d{4}$'
  AND (
      SPLIT_PART(TRIM(hire_date), '/', 1)::INT NOT BETWEEN 1 AND 31
      OR SPLIT_PART(TRIM(hire_date), '/', 2)::INT NOT BETWEEN 1 AND 12
  );


SELECT hire_date, COUNT(*) AS record_count
FROM employee_records_staging
WHERE TRIM(hire_date) = '13/13/2020'
GROUP BY hire_date;

UPDATE employee_records_staging
SET hire_date = '13/12/2020'
WHERE TRIM(hire_date) = '13/13/2020';


SELECT hire_date
FROM employee_records_staging
WHERE TRIM(hire_date) = '31/02/2021';

UPDATE employee_records_staging
SET hire_date = '28/02/2021'
WHERE TRIM(hire_date) = '31/02/2021';

--Update hire date --
ALTER TABLE employee_records_staging
ALTER COLUMN hire_date TYPE DATE
USING (
    CASE
        WHEN TRIM(hire_date) = ''
          OR LOWER(TRIM(hire_date)) IN (
              'unknown', 'null', 'none', 'n/a', '-'
          )
          OR TRIM(hire_date) IN (
              '0000-00-00', '########'
          )
            THEN NULL

        -- MM-DD-YYYY
        WHEN TRIM(hire_date) ~ '^\d{2}-\d{2}-\d{4}$'
            THEN TO_DATE(TRIM(hire_date), 'MM-DD-YYYY')

        -- DD/MM/YYYY
        WHEN TRIM(hire_date) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN TO_DATE(TRIM(hire_date), 'DD/MM/YYYY')

        -- DD-Mon-YY
        WHEN TRIM(hire_date) ~* '^\d{1,2}-[A-Za-z]{3}-\d{2}$'
            THEN TO_DATE(TRIM(hire_date), 'DD-Mon-YY')

        ELSE NULL
    END
);

---10. Clean salary values and convert them to a suitable numeric data type.---

ALTER TABLE employee_records_staging
ALTER COLUMN salary TYPE NUMERIC
USING CASE
    WHEN BTRIM(salary) IN ('-', 'N/A', 'n/a', 'None', 'NULL', 'null', '') THEN NULL
    ELSE NULLIF(
        REGEXP_REPLACE(BTRIM(salary), '[^0-9.]', '', 'g'),
        ''
    )::NUMERIC
END;

SELECT salary, (ROUND(salary,0))
FROM employee_records_staging;

UPDATE employee_records_staging
SET salary = (ROUND(salary,0));

SELECT COUNT(*) AS zero_salary_count
FROM employee_records_staging
WHERE salary = 0;

SELECT employee_id, full_name, job_title, salary
FROM employee_records_staging
WHERE salary = 0;

-- Replace invalid zero salaries with NULL.

UPDATE employee_records_staging
SET salary = NULL
WHERE salary = 0;

---11. Standardize employment status values.---

ALTER TABLE employee_records_staging
ALTER COLUMN employment_status TYPE VARCHAR(50);

---Standardize employment status --
SELECT employment_status, 
		BTRIM(INITCAP(employment_status)) AS 
		cleaned_employment_status
FROM employee_records_staging;

UPDATE employee_records_staging
SET employment_status = BTRIM(INITCAP(employment_status));

SELECT employment_status,
	CASE
		WHEN employment_status ILIKE 'Ac%'
		OR employment_status ILIKE 'A%'
			THEN 'Active'

		WHEN employment_status ILIKE 'On%'
		OR employment_status ILIKE 'On-%'
		OR employment_status ILIKE '%Le%'
		OR employment_status ILIKE 'Loa%'
			THEN 'Leave'
			
		WHEN employment_status ILIKE 'T%'
		OR employment_status ILIKE 'Term%'
			THEN 'Terminated'

		WHEN employment_status ILIKE 'Re%'
		OR employment_status ILIKE 'R%'
			THEN 'Resigned'
		ELSE employment_status
	END AS employment_status_cleaned
FROM employee_records_staging;

UPDATE employee_records_staging
SET employment_status = CASE
		WHEN employment_status ILIKE 'Ac%'
		OR employment_status ILIKE 'A%'
			THEN 'Active'

		WHEN employment_status ILIKE 'On%'
		OR employment_status ILIKE 'On-%'
		OR employment_status ILIKE '%Le%'
		OR employment_status ILIKE 'Loa%'
			THEN 'Leave'
			
		WHEN employment_status ILIKE 'T%'
		OR employment_status ILIKE 'Term%'
			THEN 'Terminated'

		WHEN employment_status ILIKE 'Re%'
		OR employment_status ILIKE 'R%'
			THEN 'Resigned'
		ELSE employment_status
	END;

SELECT employment_status
FROM employee_records_staging
WHERE BTRIM(employment_status) IN ('None','-','Null','N/A');

UPDATE employee_records_staging
SET employment_status = NULL
WHERE BTRIM(employment_status) IN ('None','-','Null','N/A');


---Validate employee status --

SELECT DISTINCT(employment_status)
FROM employee_records_staging;

---12. Standardize work locations---
ALTER TABLE employee_records_staging
ALTER COLUMN work_location TYPE VARCHAR(50);

SELECT work_location, 
		BTRIM(INITCAP(work_location)) AS 
		cleaned_work_location
FROM employee_records_staging;

UPDATE employee_records_staging
SET 
	work_location = BTRIM(INITCAP(work_location));

SELECT work_location,
	CASE
		WHEN work_location ILIKE 'New%'
		OR work_location ILIKE '%New%%'
		OR work_location ILIKE '%NYC%%'
		OR work_location ILIKE '%N.Y.%%'
		OR work_location ILIKE '%Nyc%%'
		OR work_location ILIKE '%Ny%%'
			THEN 'New York'
			
		WHEN work_location ILIKE 'San%%'
		OR work_location ILIKE 'Sf'
		OR work_location ILIKE '%Sf%%'
			THEN 'San Francisco'
			
		WHEN work_location ILIKE 'Se%%'
		OR work_location ILIKE '%Sea%%'
		OR work_location ILIKE 'Sea'
			THEN 'Seattle'
			
		WHEN work_location ILIKE 'Au%%'
		OR work_location ILIKE 'Atx'
			THEN 'Austin'

		WHEN work_location ILIKE 'Ch%%'
		OR work_location ILIKE 'Chi%'
		OR work_location ILIKE 'Chicago%'
			THEN 'Chicago'

		WHEN work_location ILIKE 'Work%%'
		OR work_location ILIKE 'Wfh'
		OR work_location ILIKE 'Wfh%%'
			THEN 'Remote'
		ELSE work_location
	END AS work_location_cleaned
FROM employee_records_staging;

UPDATE employee_records_staging 
SET work_location = 	CASE
		WHEN work_location ILIKE 'New%'
		OR work_location ILIKE '%New%%'
		OR work_location ILIKE '%NYC%%'
		OR work_location ILIKE '%N.Y.%%'
		OR work_location ILIKE '%Nyc%%'
		OR work_location ILIKE '%Ny%%'
			THEN 'New York'
			
		WHEN work_location ILIKE 'San%%'
		OR work_location ILIKE 'Sf'
		OR work_location ILIKE '%Sf%%'
			THEN 'San Francisco'
			
		WHEN work_location ILIKE 'Se%%'
		OR work_location ILIKE '%Sea%%'
		OR work_location ILIKE 'Sea'
			THEN 'Seattle'
			
		WHEN work_location ILIKE 'Au%%'
		OR work_location ILIKE 'Atx'
			THEN 'Austin'

		WHEN work_location ILIKE 'Ch%%'
		OR work_location ILIKE 'Chi%'
		OR work_location ILIKE 'Chicago%'
			THEN 'Chicago'

		WHEN work_location ILIKE 'Work%%'
		OR work_location ILIKE 'Wfh'
		OR work_location ILIKE 'Wfh%%'
			THEN 'Remote'
		ELSE work_location
	END;

SELECT work_location
FROM employee_records_staging
WHERE BTRIM(work_location) IN ('-', 'Null','N/A','None');

UPDATE employee_records_staging
SET work_location = NULL
WHERE BTRIM(work_location) IN ('-', 'Null','N/A','None');

UPDATE employee_records_staging
SET work_location = NULL
WHERE work_location IN ('True','False');

--Validate work location ----
SELECT DISTINCT(work_location), COUNT(*) AS count_location
FROM employee_records_staging
GROUP BY work_location
ORDER BY work_location;

SELECT DISTINCT work_location
FROM employee_records_staging
ORDER BY work_location;


---13. Check for duplicate employee records.---
---check duplicate employee id ---
SELECT
    employee_id,
    COUNT(*) AS duplicate_count
FROM employee_records_staging
WHERE employee_id IS NOT NULL
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

---check duplicate employee records ---
SELECT 
	employee_id,
    full_name,
    email,
    phone,
    department,
    job_title,
    hire_date,
    salary,
    employment_status,
    work_location,
	COUNT(*) AS duplicate_count

FROM employee_records_staging
GROUP BY 
	employee_id,
    full_name,
    email,
    phone,
    department,
    job_title,
    hire_date,
    salary,
    employment_status,
    work_location
	HAVING COUNT(*) >1
ORDER BY duplicate_count DESC;

SELECT 
    full_name,
    email,
    hire_date,
    COUNT(*) AS record_count
FROM employee_records_staging
WHERE full_name IS NOT NULL
  AND email IS NOT NULL
  AND hire_date IS NOT NULL
GROUP BY 
    full_name,
    email,
    hire_date
HAVING COUNT(*) > 1
ORDER BY 
    record_count DESC;


WITH duplicate_records AS (
    SELECT
        ctid,
        full_name,
        email,
        hire_date,
        ROW_NUMBER() OVER (
            PARTITION BY full_name, email, hire_date
            ORDER BY ctid
        ) AS row_num
    FROM employee_records_staging
    WHERE full_name IS NOT NULL
      AND email IS NOT NULL
      AND hire_date IS NOT NULL
)
SELECT *
FROM duplicate_records
WHERE row_num > 1;

---remove duplicate records ----

WITH duplicate_records AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY full_name, email, hire_date
            ORDER BY ctid
        ) AS row_num
    FROM employee_records_staging
    WHERE full_name IS NOT NULL
      AND email IS NOT NULL
      AND hire_date IS NOT NULL
)
DELETE FROM employee_records_staging AS e
USING duplicate_records AS d
WHERE e.ctid = d.ctid
  AND d.row_num > 1;
  
---14. Review missing, invalid, and inconsistent values.---
---15. Validate the cleaned data and compare it with the original dataset.---
---16. Save the final results in a cleaned table.---

SELECT *
FROM employee_records_staging;

