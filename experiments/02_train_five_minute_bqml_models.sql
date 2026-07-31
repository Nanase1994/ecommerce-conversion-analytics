-- OPTIONAL EXTENSION
-- This file is not used to reproduce the paper. It trains BigQuery ML models
-- on first-five-minute behavior. Replace YOUR_PROJECT_ID.
CREATE OR REPLACE MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_logistic`
OPTIONS(model_type='LOGISTIC_REG',input_label_cols=['converted'],auto_class_weights=TRUE,
        enable_global_explain=TRUE,max_iterations=30,l2_reg=1.0,data_split_method='NO_SPLIT') AS
SELECT * EXCEPT(session_id,session_date)
FROM `YOUR_PROJECT_ID.ecommerce_analytics.five_minute_purchase_features`
WHERE session_date BETWEEN '2020-11-16' AND '2021-01-10';

CREATE OR REPLACE MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_boosted_tree`
OPTIONS(model_type='BOOSTED_TREE_CLASSIFIER',input_label_cols=['converted'],auto_class_weights=TRUE,
        enable_global_explain=TRUE,max_iterations=50,learn_rate=0.05,
        max_tree_depth=5,subsample=0.8,data_split_method='NO_SPLIT') AS
SELECT * EXCEPT(session_id,session_date)
FROM `YOUR_PROJECT_ID.ecommerce_analytics.five_minute_purchase_features`
WHERE session_date BETWEEN '2020-11-16' AND '2021-01-10';

SELECT 'logistic' model,*
FROM ML.EVALUATE(MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_logistic`,
  (SELECT * EXCEPT(session_id,session_date) FROM `YOUR_PROJECT_ID.ecommerce_analytics.five_minute_purchase_features`
   WHERE session_date BETWEEN '2021-01-11' AND '2021-01-31'))
UNION ALL
SELECT 'boosted_tree' model,*
FROM ML.EVALUATE(MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_boosted_tree`,
  (SELECT * EXCEPT(session_id,session_date) FROM `YOUR_PROJECT_ID.ecommerce_analytics.five_minute_purchase_features`
   WHERE session_date BETWEEN '2021-01-11' AND '2021-01-31'));

SELECT * FROM ML.GLOBAL_EXPLAIN(MODEL `YOUR_PROJECT_ID.ecommerce_analytics.purchase_boosted_tree`);

