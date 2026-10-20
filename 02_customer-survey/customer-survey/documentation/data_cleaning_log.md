# Customer Survey Data Cleaning Log

**Database:** PostgreSQL  
**Working Table:** `customer_survey_staging`

## Cleaning Steps

| Step | Description |
|---|---|
| 1 | Checked the initial row count and unique customers. |
| 2 | Trimmed extra spaces and standardized membership values. |
| 3 | Standardized service feedback categories. |
| 4 | Converted `survey_date` to the `DATE` data type. |
| 5 | Split addresses into street, city, and state. |
| 6 | Cleaned email and phone values and created a preferred contact column. |
| 7 | Identified potential duplicate records. |
| 8 | Validated the cleaned data and reviewed the final counts. |

## Screenshots

| Screenshot | Description |
|---|---|
| `text_standardization.png` | Text cleaning and standardization |
| `Date_cleaning.png` | Date conversion |
| `address_separate.png` | Address separation |
| `contact_clean.png` | Contact information cleaning |
| `duplicate_count.png` | Duplicate record checks |

**Location:** `results/screenshots/`

## Notes

- The raw data is kept separate from the staging table.
- Duplicate removal follows the selected criteria.
- Final counts should be verified using the validation queries.