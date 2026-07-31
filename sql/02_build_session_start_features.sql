-- GoogleSQL
-- Leakage-safe feature table for the canonical research-paper models.
-- Replace YOUR_PROJECT_ID with your Google Cloud project ID.

CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.ecommerce_analytics.session_start_ml_features` AS
SELECT
  session_id,
  session_date,
  converted,
  day_of_week,
  is_weekend,
  COALESCE(traffic_source, '<MISSING>') AS traffic_source,
  COALESCE(traffic_medium, '<MISSING>') AS traffic_medium,
  COALESCE(device_category, '<MISSING>') AS device_category,
  COALESCE(operating_system, '<MISSING>') AS operating_system,
  COALESCE(country, '<MISSING>') AS country
FROM `YOUR_PROJECT_ID.ecommerce_analytics.session_level_ecommerce`;

-- Expected result: zero rows. Any returned column violates the score-time
-- feature contract.
SELECT column_name
FROM `YOUR_PROJECT_ID.ecommerce_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'session_start_ml_features'
  AND column_name != 'converted'
  AND REGEXP_CONTAINS(
    LOWER(column_name),
    r'page|product|cart|checkout|shipping|payment|purchase|revenue|transaction|duration|engagement|event'
  );

-- Expected result: 310,014 rows, 310,014 unique sessions, zero duplicates.
SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT session_id) AS unique_sessions,
  COUNT(*) - COUNT(DISTINCT session_id) AS duplicate_sessions
FROM `YOUR_PROJECT_ID.ecommerce_analytics.session_start_ml_features`;

