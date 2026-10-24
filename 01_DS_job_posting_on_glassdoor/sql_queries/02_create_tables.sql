CREATE TABLE job_postings_raw (
    "index" TEXT,
    "Job Title" VARCHAR(255),
    "Salary Estimate" VARCHAR(255),
    "Job Description" TEXT,
    "Rating" FLOAT,
    "Company Name" VARCHAR(255),
    "Location" VARCHAR(255),
    "Headquarters" VARCHAR(255),
    "Size" VARCHAR(255),
    "Founded" INT,
    "Type of ownership" VARCHAR(255),
    "Industry" VARCHAR(255),
    "Sector" VARCHAR(255),
    "Revenue" VARCHAR(255),
    "Competitors" VARCHAR(255)
);

SELECT * FROM job_postings_raw;

CREATE TABLE job_postings_staging AS
SELECT *
FROM job_postings_raw;

SELECT * FROM job_postings_staging;