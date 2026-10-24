/*
===============================================================================
PROJECT: Glassdoor Data Science Job Postings
PURPOSE: Clean and standardize data
SOURCE:  https://www.kaggle.com/datasets/rashikrahmanpritom/
         data-science-job-posting-on-glassdoor

IMPORTANT:
- Keep the original imported table as a backup.
- Execute the cleaning steps on a working copy.
- Validate transformations before removing original columns.
===============================================================================
*/

SELECT *
FROM job_postings_raw;

-- STEP 1: Create a working copy
-----------------------------------------------------------------------------

CREATE TABLE job_postings_staging AS
SELECT *
FROM job_postings_raw;

-- STEP 2: Inspect the imported data
------------------------------------------------------------------------------

SELECT * 
FROM job_postings_staging
LIMIT 10;


-- Review column names and data types in the table.


-- Record the initial number of rows.

SELECT COUNT(*) AS initial_row_count
FROM job_postings_staging; 

-- STEP 3: Remove the unnecessary imported index column
-----------------------------------------------------------------------------

ALTER TABLE job_postings_staging
DROP COLUMN IF EXISTS index;

-- STEP 4: Standardize column names
-----------------------------------------------------------------------------

ALTER TABLE job_postings_staging
	RENAME COLUMN "Job Title" TO "job_title";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Salary Estimate" TO "salary_estimate";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Job Description" TO "job_description";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Rating" TO "rating";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Company Name" TO "company_name";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Location" TO "location";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Headquarters" TO "headquarters";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Size" TO "size";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Founded" TO "founded";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Type of ownership" TO "type_of_ownership";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Industry" TO "industry";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Sector" TO "sector";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Revenue" TO "revenue";

ALTER TABLE job_postings_staging
	RENAME COLUMN "Competitors" TO "competitors";

-- STEP 5: Inspect salary formats before transforming 
-----------------------------------------------------------------------------

SELECT salary_estimate, COUNT(*) AS record_count
FROM job_postings_staging
GROUP BY salary_estimate
ORDER BY record_count DESC;

-- STEP 6: Standardized salary columns
-- This parser assumes the salary range is expressed in thousands (K).

ALTER TABLE job_postings_staging
ADD COLUMN salary_min_k NUMERIC,
ADD COLUMN salary_max_k NUMERIC;

ALTER TABLE job_postings_staging
ADD COLUMN salary_estimate_clean TEXT;

-- Remove the explanatory text in parentheses and trim whitespace.
SELECT salary_estimate,
	NULLIF(
				BTRIM(
					REGEXP_REPLACE(
					salary_estimate,
					'\s*\([^)]*\)\s*$',
					''
					)
					),''
				)AS salary_estimate_clean
FROM job_postings_staging;


UPDATE job_postings_staging
	SET salary_estimate_clean = 
		NULLIF(
			BTRIM(
				REGEXP_REPLACE(
				salary_estimate,
				'\s*\([^)]*\)\s*$',
				''
				)
				),''
			);

UPDATE job_postings_staging
SET
    salary_min_k = NULLIF(
        (REGEXP_MATCH(
            salary_estimate_clean,
            '\$?([0-9]+(?:\.[0-9]+)?)K?\s*-\s*\$?([0-9]+(?:\.[0-9]+)?)K?',
            'i'
        ))[1],
        ''
    )::NUMERIC,

    salary_max_k = NULLIF(
        (REGEXP_MATCH(
            salary_estimate_clean,
            '\$?([0-9]+(?:\.[0-9]+)?)K?\s*-\s*\$?([0-9]+(?:\.[0-9]+)?)K?',
            'i'
        ))[2],
        ''
    )::NUMERIC

WHERE salary_estimate_clean ~
    '\$?[0-9]+(?:\.[0-9]+)?K?\s*-\s*\$?[0-9]+(?:\.[0-9]+)?K?';

-- Validate salary extraction and identify unparsed values.

SELECT salary_estimate, salary_estimate_clean, salary_min_k, salary_max_k
FROM job_postings_staging
ORDER BY salary_estimate
LIMIT 50;

SELECT COUNT(*)	FILTER(
		WHERE salary_estimate IS NOT NULL 
		AND salary_min_k IS NULL
	) AS salaries_without_extracted_mini
FROM job_postings_staging;

-- STEP 7: Standardize names
-------------------------------------------------------------------------

ALTER TABLE job_postings_staging
ADD COLUMN company_name_clean TEXT;


SELECT company_name, 
	NULLIF(
    BTRIM(
        REGEXP_REPLACE(
            company_name,
            E'\\s*\\n\\s*[0-9]+(?:\\.[0-9]+)?\\s*$',
            ''
        )
    ),
    ''
) AS company_name_clean
FROM job_postings_staging;

UPDATE job_postings_staging
	SET company_name_clean = NULLIF(
	    BTRIM(
	        REGEXP_REPLACE(
	            company_name,
	            E'\\s*\\n\\s*[0-9]+(?:\\.[0-9]+)?\\s*$',
	            ''
	        )
	    ),
	    ''
	);

SELECT company_name, company_name_clean
FROM job_postings_staging
LIMIT 50;

-- Job title Standardize

SELECT DISTINCT(job_title) AS unique_title
FROM job_postings_staging
GROUP BY job_title ;

SELECT job_title, 
	BTRIM(INITCAP(job_title)) AS job_title_clean
FROM job_postings_staging;

UPDATE job_postings_staging
SET job_title = BTRIM(INITCAP(job_title));

-- STEP 8: Split job location into city and state
-----------------------------------------------------------------------------

ALTER TABLE job_postings_staging
ADD COLUMN city TEXT,
ADD COLUMN state TEXT;

ALTER TABLE job_postings_staging
RENAME COLUMN city TO location_city;

ALTER TABLE job_postings_staging
RENAME COLUMN state TO location_state;

SELECT "location", NULLIF(BTRIM(SPLIT_PART(
		"location", ',',1)), '') AS location_city
FROM job_postings_staging;

SELECT "location", NULLIF(BTRIM(SPLIT_PART(
		"location", ',',2)), '') AS location_state
FROM job_postings_staging;

UPDATE job_postings_staging
SET city = NULLIF(BTRIM(SPLIT_PART(
		"location", ',',1)), ''),
	state = NULLIF(BTRIM(SPLIT_PART(
		"location", ',',2)), '');

SELECT location, 
		location_city, 
		location_state
FROM job_postings_staging
LIMIT 50;

SELECT location, city, state
FROM job_postings_staging
WHERE POSITION(',' IN location) > 0;

ALTER TABLE job_postings_staging
ADD COLUMN headquarters_city TEXT;

ALTER TABLE job_postings_staging
ADD COLUMN headquarters_state TEXT;

SELECT headquarters, 
	NULLIF(BTRIM(SPLIT_PART(
		headquarters,',',1)),'') AS headquarters_city
FROM job_postings_staging;

SELECT headquarters, 
	NULLIF(BTRIM(SPLIT_PART(
		headquarters,',',2)),'') AS headquarters_state
FROM job_postings_staging;

UPDATE job_postings_staging
	SET 
		headquarters_city = 
			NULLIF(BTRIM(SPLIT_PART(headquarters,',',1)),''),
		headquarters_state = 
			NULLIF(BTRIM(SPLIT_PART(headquarters,',',2)),'');

SELECT location, 
		headquarters_city, 
		headquarters_state
FROM job_postings_staging
WHERE POSITION(',' IN headquarters) > 0;

-- Inspect values that could not be split.

SELECT "location", COUNT(*) AS record_count
FROM job_postings_staging
WHERE "location" IS NOT NULL
	AND POSITION(',' IN "location") = 0
GROUP BY "location"
ORDER BY record_count DESC;

SELECT headquarters, COUNT(*) AS record_count
FROM job_postings_staging
WHERE "headquarters" IS NOT NULL
  AND POSITION(',' IN "headquarters") = 0
GROUP BY headquarters
ORDER BY record_count DESC;


UPDATE job_postings_staging
SET headquarters_city = NULL
WHERE BTRIM(headquarters_city) ='-1';

SELECT headquarters_city, COUNT(*) AS record_count
FROM job_postings_staging
WHERE "headquarters_city" IS NOT NULL
  AND POSITION(',' IN "headquarters_city") = 0
GROUP BY headquarters_city
ORDER BY record_count DESC;

-- STEP 10: Standardize whitespace and empty strings
-----------------------------------------------------------------------------

UPDATE job_postings_staging
SET 
	"job_title" = NULLIF(BTRIM("job_title"),''),
	"job_description" = NULLIF(BTRIM("job_description"),''),
	"location_city" = NULLIF(BTRIM(location_city), ''),
    "location_state" = NULLIF(BTRIM(location_state), ''),
    "headquarters_city" = NULLIF(BTRIM(headquarters_city), ''),
    "headquarters_state" = NULLIF(BTRIM(headquarters_state), ''),
    "company_name" = NULLIF(BTRIM(company_name), '');
	
-- STEP 11: Handle the Founded sentinel value
----------------------------------------------------------------------------

UPDATE job_postings_staging
SET "founded" = NULL
WHERE BTRIM(founded:: TEXT) = '-1';

SELECT COUNT(*)
FROM job_postings_staging
WHERE founded IS NULL;

-- STEP 12: Audit remaining missing values
-----------------------------------------------------------------------------

SELECT
	COUNT(*) AS total_rows,
	COUNT(*) FILTER(WHERE job_title IS NULL ) AS missing_job_title,
	COUNT(*) FILTER(WHERE company_name IS NULL) AS missing_company_name,
	COUNT(*) FILTER (WHERE location_city IS NULL) AS missing_location_cities,
    COUNT(*) FILTER (WHERE location_state IS NULL) AS missing_location_states,
    COUNT(*) FILTER (WHERE headquarters_city IS NULL) AS missing_headquarters_cities,
    COUNT(*) FILTER (WHERE salary_min_k IS NULL) AS missing_salary_minimums
FROM job_postings_staging;


-- STEP 13: Identify exact duplicate source records
-----------------------------------------------------------------------------

WITH duplicate_check AS (

	SELECT ctid,
		ROW_NUMBER () OVER(
		PARTITION BY 
		 job_title,
         salary_estimate,
         job_description,
         rating,
         company_name,
         location,
         headquarters,
         size,
         founded,
         type_of_ownership,
         industry,
         sector,
         revenue,
         competitors
            ORDER BY ctid
			) AS row_num
FROM job_postings_staging
)
SELECT *
FROM duplicate_check
WHERE row_num > 1;

-- STEP 14: Remove exact duplicate source records
-----------------------------------------------------------------------------

WITH duplicate_check AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY
                job_title,
                salary_estimate,
                job_description,
                rating,
                company_name,
                location,
                headquarters,
                size,
                founded,
                type_of_ownership,
                industry,
                sector,
                revenue,
                competitors
            ORDER BY ctid
        ) AS row_num
    FROM job_postings_staging
)
DELETE FROM job_postings_staging AS target
	USING duplicate_check AS duplicates
	WHERE target.ctid = duplicates.ctid
	  AND duplicates.row_num > 1;

-- STEP 15: Validate the cleaned dataset
-----------------------------------------------------------------------------

-- Final row count.

SELECT 
	COUNT(*) AS final_row_count
FROM job_postings_staging;

-- Verify salary ranges.

SELECT 
	COUNT(*) AS invalid_salary_ranges
FROM job_postings_staging
WHERE salary_min_k IS NOT NULL
	AND salary_max_k IS NOT NULL
	AND salary_min_k > salary_max_k;

-- Check whether company names remain blank.

SELECT COUNT(*) AS missing_company_names
FROM job_postings_staging
WHERE company_name IS NULL;

-- Review location parsing.

SELECT
    location,
    location_city,
    location_state,
    headquarters,
    headquarters_city,
    headquarters_state
FROM job_postings_staging
LIMIT 50;

-- Check whether the Founded sentinel value remains.

SELECT COUNT(*) AS unknown_founded_values
FROM job_postings_staging
WHERE BTRIM(founded::text) = '-1';

-- Review the final dataset.
SELECT * 
FROM job_postings_staging
LIMIT 50;

-- Remove unnecessary the remaining column names.

ALTER TABLE job_postings_staging
DROP COLUMN "company_name",
DROP COLUMN "salary_estimate",
DROP COLUMN "headquarters",
DROP COLUMN "location";

CREATE TABLE job_postings_cleaned AS
	SELECT *
	FROM job_postings_staging;

-- Final Validate and Cleaned 
SELECT *
FROM job_postings_cleaned;
