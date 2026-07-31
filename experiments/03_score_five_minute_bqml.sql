-- OPTIONAL EXTENSION
-- Scores the first-five-minute BigQuery ML challenger. This is not the
-- canonical paper model. Replace YOUR_PROJECT_ID.
CREATE OR REPLACE TABLE `YOUR_PROJECT_ID.ecommerce_analytics.purchase_test_scores` AS
SELECT
  session_id,session_date,converted,
  predicted_converted_probs[OFFSET(1)].prob predicted_probability
FROM ML.PREDICT(MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_boosted_tree`,
  (SELECT * FROM `YOUR_PROJECT_ID.ecommerce_analytics.five_minute_purchase_features`
   WHERE session_date BETWEEN '2021-01-11' AND '2021-01-31'));

-- Lift by score decile.
WITH ranked AS (
  SELECT *,NTILE(10) OVER(ORDER BY predicted_probability DESC) score_decile
  FROM `YOUR_PROJECT_ID.ecommerce_analytics.purchase_test_scores`
), base AS (SELECT AVG(converted) base_rate FROM ranked)
SELECT score_decile,COUNT(*) sessions,SUM(converted) purchases,
       AVG(predicted_probability) avg_score,AVG(converted) observed_rate,
       SAFE_DIVIDE(AVG(converted),ANY_VALUE(base_rate)) lift_vs_average
FROM ranked CROSS JOIN base
GROUP BY score_decile ORDER BY score_decile;

-- Calibration by probability band.
SELECT LEAST(9,CAST(FLOOR(predicted_probability*10) AS INT64)) probability_band,
       COUNT(*) sessions,AVG(predicted_probability) avg_predicted_rate,
       AVG(converted) observed_rate
FROM `YOUR_PROJECT_ID.ecommerce_analytics.purchase_test_scores`
GROUP BY probability_band ORDER BY probability_band;

