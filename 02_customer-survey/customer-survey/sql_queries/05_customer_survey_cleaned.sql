/*
 PROJECT: CUSTOMER SURVEY DATA CLEANING
 DATABASE: PostgreSQL
 PURPOSE: Clean, standardize and validate customer survey data.
 SOURCE: [Data Analytics Lab](https://github.com/data-analytics-labs/tutorials/blob/main/survey_dataset_messy_txt.txt).
 ============================================================
*/

-- STEP 1: INITIAL DATA CHECKS
-- Purpose: Check the total number of rows and unique customers.
-- ============================================================

-- Check the initial number of records (104 rows).
SELECT COUNT(*)
FROM customer_survey_staging;

-- Count unique customers (expected: 98 customers).
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM customer_survey_staging;

-- STEP 2: CLEAN AND STANDARDIZE TEXT VALUES
-- Purpose: Remove extra spaces and standardize membership values.
-- ============================================================

-- Preview cleaned rewards membership values.
SELECT "rewards_member", INITCAP(TRIM("rewards_member")) AS rewards_member_cleaned
FROM customer_survey_staging;

-- Update rewards membership values.
UPDATE customer_survey_staging
SET rewards_member = INITCAP(TRIM(rewards_member));

-- Preview cleaned free-text responses.
SELECT "freetext_response", BTRIM(freetext_response) AS freetext_response_clean
FROM customer_survey_staging;

-- Remove leading and trailing spaces from free-text responses.
UPDATE customer_survey_staging
SET freetext_response = BTRIM(freetext_response);

-- ============================================================
-- STEP 3: STANDARDIZE SERVICE FEEDBACK
-- Purpose: Group different feedback descriptions into categories.
-- ============================================================

-- Review the distinct service feedback values.
SELECT DISTINCT service_feedback AS unique
FROM customer_survey_staging;

-- Preview the standardized feedback categories before updating.
SELECT
    service_feedback,
    CASE
        WHEN service_feedback ILIKE ANY (
            ARRAY['%excellent%', '%great%']
        ) THEN 'Excellent'
        WHEN service_feedback ILIKE 'good%' THEN 'Good'
        WHEN service_feedback ILIKE 'average%' THEN 'Average'
        WHEN service_feedback ILIKE 'poor%' THEN 'Poor'
        ELSE NULL
    END AS service_feedback_cleaned
FROM customer_survey_staging;

-- Apply the standardized feedback categories.
UPDATE customer_survey_staging
SET service_feedback = CASE
    WHEN service_feedback ILIKE ANY (
        ARRAY['%excellent%', '%great%']
    ) THEN 'Excellent'
    WHEN service_feedback ILIKE 'good%' THEN 'Good'
    WHEN service_feedback ILIKE 'average%' THEN 'Average'
    WHEN service_feedback ILIKE 'poor%' THEN 'Poor'
    ELSE NULL
END;

-- STEP 4: CONVERT SURVEY DATE TO DATE TYPE
-- Purpose: Prepare survey_date for date-based analysis.
-- ============================================================

-- Change survey_date to text before checking the conversion.
ALTER TABLE customer_survey_staging
ALTER COLUMN survey_date TYPE text;

-- Preview the date conversion.
SELECT
    survey_date,
    CAST(survey_date AS DATE) AS survey_date_clean
FROM customer_survey_staging;

-- Update survey_date using the converted date value.
UPDATE customer_survey_staging
SET survey_date = CAST(survey_date AS DATE);

-- Change survey_date to the DATE data type.
ALTER TABLE customer_survey_staging
ALTER COLUMN survey_date TYPE DATE
USING CAST(survey_date AS DATE);

-- STEP 5: SPLIT ADDRESS AND STANDARDIZE SURVEY RESPONSES
-- Purpose:
-- 1. Split address into street, city, and state.
-- 2. Standardize service feedback and product quality.
-- 3. Standardize recommendation responses.
-- 4. Remove extra spaces from free-text responses.
-- ============================================================

-- 5.1 Split address into separate columns
-- ------------------------------------------------------------

-- Preview the address components before updating the table.
SELECT
    address,
    SPLIT_PART(address, ',', 1) AS street,
    SPLIT_PART(address, ',', 2) AS city,
    SPLIT_PART(address, ',', 3) AS state
FROM customer_survey_staging;

-- Add columns to store the separated address components.
ALTER TABLE customer_survey_staging
ADD COLUMN street TEXT,
ADD COLUMN city TEXT,
ADD COLUMN state TEXT;

-- Populate the new address columns.
UPDATE customer_survey_staging
SET
    street = SPLIT_PART(address, ',', 1),
    city = SPLIT_PART(address, ',', 2),
    state = SPLIT_PART(address, ',', 3);


-- 5.2 Standardize service feedback
-- ------------------------------------------------------------

-- Preview standardized service feedback categories.
SELECT
    service_feedback,
    CASE
        WHEN service_feedback ILIKE ANY (
            ARRAY['%excellent%', '%great%']
        ) THEN 'Excellent'
        WHEN service_feedback ILIKE 'good%' THEN 'Good'
        WHEN service_feedback ILIKE 'average%' THEN 'Average'
        WHEN service_feedback ILIKE 'poor%' THEN 'Poor'
        ELSE NULL
    END AS service_feedback_cleaned
FROM survey_dataset_process;

-- Update service feedback categories.
UPDATE survey_dataset_process
SET service_feedback = CASE
    WHEN service_feedback ILIKE ANY (
        ARRAY['%excellent%', '%great%']
    ) THEN 'Excellent'
    WHEN service_feedback ILIKE 'good%' THEN 'Good'
    WHEN service_feedback ILIKE 'average%' THEN 'Average'
    WHEN service_feedback ILIKE 'poor%' THEN 'Poor'
    ELSE NULL
END;

-- 5.3 Standardize recommendation responses
-- ------------------------------------------------------------

-- Preview standardized recommendation responses.

SELECT DISTINCT(recommend_to_friend) AS unique_recommend
FROM customer_survey_staging;

-- 5.4 Clean free-text responses
-- ------------------------------------------------------------

-- Preview free-text responses after removing extra spaces
-- from the beginning and end.
SELECT DISTINCT(freetext_response)
FROM customer_survey_staging;

SELECT
    freetext_response,
    INITCAP(BTRIM(freetext_response)) AS freetext_response_cleaned
FROM customer_survey_staging;

-- Update free-text responses.
UPDATE customer_survey_staging
SET freetext_response = INITCAP(BTRIM(freetext_response));

-- 5.5 Validate the cleaned survey columns
-- ------------------------------------------------------------

-- Review the standardized values.
SELECT
    service_feedback,
    product_quality,
    recommend_to_friend,
    freetext_response
FROM customer_survey_staging;

-- STEP 6: CREATE A PREFERRED CONTACT COLUMN
-- Purpose: Select email first, then phone, then 'unknown'.
-- ============================================================

-- Preview address data type

SELECT
    email,
    phone,
    email IS NULL AS email_is_null,
    phone IS NULL AS phone_is_null,
    quote_nullable(email) AS email_value,
    quote_nullable(phone) AS phone_value
FROM customer_survey_staging
WHERE phone = '555-123-8888';

---- Replace text 'NULL' with actual SQL NULL in email and phone.
UPDATE customer_survey_staging
SET
    email = NULLIF(TRIM(email), 'NULL'),
    phone = NULLIF(TRIM(phone), 'NULL');

UPDATE customer_survey_staging
SET
    email = CASE
        WHEN UPPER(TRIM(email)) = 'NULL' THEN NULL
        ELSE email
    END,
    phone = CASE
        WHEN UPPER(TRIM(phone)) = 'NULL' THEN NULL
        ELSE phone
    END;

-- Ignore NULL values, empty strings, and spaces.

SELECT
    email,
    phone,
    COALESCE(
        NULLIF(TRIM(email), ''),
        NULLIF(TRIM(phone), ''),
        'Not Available'
    ) AS preferred_contact
FROM customer_survey_staging;

-- Add a column for the preferred contact method.
ALTER TABLE customer_survey_staging
ADD COLUMN prefarred_contacts TEXT;

-- Populate the preferred contact column.
UPDATE customer_survey_staging
SET prefarred_contacts = COALESCE(
        NULLIF(TRIM(email), ''),
        NULLIF(TRIM(phone), ''),
        'Not Available'
    );




-- STEP 7: IDENTIFY DUPLICATE RECORDS
-- Purpose: Find records sharing the same customer, address,
-- survey date and time.
-- ============================================================

-- Count records within each potential duplicate group.
SELECT *
FROM (
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY
                customer_id,
                address,
                survey_date,
                survey_time
        ) AS duplicate_count
    FROM customer_survey_staging
) AS duplicate_records
WHERE duplicate_count > 1;

-- STEP 8: ASSIGN A UNIQUE SURVEY ID
-- Purpose: Give each row an identifier for duplicate removal.
-- ============================================================

-- Add an automatically generated survey ID.
ALTER TABLE customer_survey_staging
ADD COLUMN survey_id BIGSERIAL;

-- Number records within each potential duplicate group.
-- The first record is retained; later records are marked
-- for removal in the next step.
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY
            customer_id,
            address,
            survey_date,
            survey_time
        ORDER BY survey_id
    ) AS servey_instance
FROM customer_survey_staging;

-- STEP 9: REMOVE DUPLICATES BASED ON SELECTED COLUMNS
-- ============================================================

-- Delete records ranked after the first record in each group.
WITH duplicates AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                customer_id,
                address,
                survey_date,
                survey_time
            ORDER BY survey_id
        ) AS servey_instance
    FROM customer_survey_staging
)
DELETE FROM customer_survey_staging
WHERE survey_id IN (
    SELECT survey_id
    FROM duplicates
    WHERE servey_instance > 1
);

-- Review the remaining records after duplicate removal.
SELECT *
FROM customer_survey_staging
ORDER BY customer_id;

-- STEP 10: REMOVE MULTIPLE SURVEY SUBMISSIONS
-- Purpose: Keep the latest submission for each customer,
-- address, and survey date.
-- NOTE: This section uses a different table reference.
-- Verify the target table before running these statements.
-- ============================================================

-- Rank submissions by survey time, newest first.
WITH multiple_submissions AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                customer_id,
                address,
                survey_date
            ORDER BY survey_time DESC
        ) AS survey_survey_submission
    FROM customer_survey_staging
)
DELETE FROM customer_survey_staging
WHERE survey_id IN (
    SELECT survey_id
    FROM multiple_submissions
    WHERE survey_survey_submission > 1
);


-- STEP 11: VALIDATE THE CLEANED DATA
-- Purpose: Review the final records and confirm row counts.
-- ============================================================

-- Review the cleaned records.
SELECT *
FROM customer_survey_staging
ORDER BY customer_id;

-- Check the final number of records (98 rows).
SELECT COUNT(1)
FROM customer_survey_staging;

-- Check the number of unique customers (98).
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM customer_survey_staging;

-- Check missing customer IDs.
SELECT COUNT(*) AS missing_customer_ids
FROM customer_survey_staging
WHERE customer_id IS NULL;

-- Check duplicate survey IDs.
SELECT survey_id, COUNT(*) AS record_count
FROM customer_survey_staging
GROUP BY survey_id
HAVING COUNT(*) > 1;

-- Review the standardized feedback values.
SELECT service_feedback, COUNT(*) AS record_count
FROM customer_survey_staging
GROUP BY service_feedback
ORDER BY record_count DESC;

-- Review the preferred contact values.
SELECT prefarred_contacts, COUNT(*) AS record_count
FROM customer_survey_staging
GROUP BY prefarred_contacts
ORDER BY record_count DESC;

-- STEP 12: FINAL REVIEW
-- Purpose: Review the final output from the working table.
-- ============================================================

-- Review the final cleaned table.
SELECT *
FROM customer_survey_cleaned
ORDER BY customer_id;

-- Review the original working table used in earlier steps.
SELECT *
FROM customer_survey_cleaned;



