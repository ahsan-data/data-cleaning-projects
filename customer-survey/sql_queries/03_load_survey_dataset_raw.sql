DROP TABLE IF EXISTS survey_dataset;

SELECT * 
CREATE TABLE survey_dataset
(	customer_id INT,
	email VARCHAR (50),
	phone VARCHAR (30),
	address TEXT,
	rewards_member INT,
	survey_date TEXT,
	survey_time TIMESTAMP,
	satisfaction_rating VARCHAR,
	service_feedback VARCHAR,
	product_quality VARCHAR,
	visit_frequency INT,
	recommend_to_friend BOOLEAN,
	freetext_response VARCHAR
	);

FROM survey_dataset;