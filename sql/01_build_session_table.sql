-- GoogleSQL. Replace YOUR_PROJECT_ID.
CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT_ID.ecommerce_analytics` OPTIONS(location='US');

CREATE OR REPLACE TABLE `YOUR_PROJECT_ID.ecommerce_analytics.session_level_ecommerce` AS
WITH base AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') ga_session_id,
    event_date,
    event_timestamp,
    event_name,
    traffic_source.source traffic_source,
    traffic_source.medium traffic_medium,
    device.category device_category,
    device.operating_system operating_system,
    geo.country country,
    ecommerce.transaction_id transaction_id,
    ecommerce.purchase_revenue purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201116' AND '20210131'
)
SELECT
  CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) session_id,
  user_pseudo_id,
  ga_session_id,
  PARSE_DATE('%Y%m%d', MIN(event_date)) session_date,
  MIN(event_timestamp) session_start_timestamp,
  MAX(event_timestamp) session_end_timestamp,
  ANY_VALUE(traffic_source) traffic_source,
  ANY_VALUE(traffic_medium) traffic_medium,
  ANY_VALUE(device_category) device_category,
  ANY_VALUE(operating_system) operating_system,
  ANY_VALUE(country) country,
  COUNT(*) total_events,
  COUNTIF(event_name='view_item') product_views,
  COUNTIF(event_name='add_to_cart') add_to_cart_events,
  COUNTIF(event_name='begin_checkout') checkout_events,
  MAX(IF(event_name='purchase',1,0)) converted,
  COUNT(DISTINCT transaction_id) transaction_count,
  SUM(IFNULL(purchase_revenue,0)) revenue
FROM base
WHERE ga_session_id IS NOT NULL
GROUP BY session_id,user_pseudo_id,ga_session_id;

