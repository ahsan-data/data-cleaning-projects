CREATE TABLE customer_survey_raw (
    customer_id INTEGER,
    email VARCHAR(255),
    phone VARCHAR(30),
    address TEXT,
    rewards_member BOOLEAN,
    survey_date DATE,
    survey_time TIME,
    satisfaction_rating SMALLINT,
    service_feedback VARCHAR(100),
    product_quality VARCHAR(20),
    visit_frequency INTEGER,
    recommend_to_friend BOOLEAN,
    freetext_response TEXT
);

SELECT * FROM customer_survey_raw;

-- CREATE STAGING TABLE
-- Work on a copy of the raw data.
-- =========================================================
CREATE TABLE customer_survey_staging AS
SELECT *
FROM customer_survey_raw;

SELECT * FROM customer_survey_staging;

-- CREATE CLEANED TABLE
-- Copy from staging table clean data.
-- =========================================================

CREATE TABLE customer_survey_cleaned AS
SELECT *
FROM customer_survey_staging;