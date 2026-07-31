-- GoogleSQL
-- Replace YOUR_PROJECT_ID with your Google Cloud project ID.
-- Reconstructs one row per GA4 session and all six paper funnel stages.

CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT_ID.ecommerce_analytics`
OPTIONS(location = 'US');

CREATE OR REPLACE TABLE
  `YOUR_PROJECT_ID.ecommerce_analytics.session_level_ecommerce` AS
WITH base AS (
  SELECT
    user_pseudo_id,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
      LIMIT 1
    ) AS ga_session_id,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'engagement_time_msec'
      LIMIT 1
    ) AS engagement_time_msec,
    event_date,
    event_timestamp,
    event_name,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    device.category AS device_category,
    device.operating_system AS operating_system,
    geo.country AS country,
    ecommerce.transaction_id AS transaction_id,
    ecommerce.purchase_revenue AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201116' AND '20210131'
),
sessionized AS (
  SELECT
    CONCAT(
      CAST(user_pseudo_id AS STRING),
      '-',
      CAST(ga_session_id AS STRING)
    ) AS session_id,
    user_pseudo_id,
    ga_session_id,
    PARSE_DATE('%Y%m%d', MIN(event_date)) AS session_date,
    MIN(event_timestamp) AS session_start_timestamp,
    MAX(event_timestamp) AS session_end_timestamp,
    ARRAY_AGG(traffic_source IGNORE NULLS ORDER BY event_timestamp LIMIT 1)
      [SAFE_OFFSET(0)] AS traffic_source,
    ARRAY_AGG(traffic_medium IGNORE NULLS ORDER BY event_timestamp LIMIT 1)
      [SAFE_OFFSET(0)] AS traffic_medium,
    ARRAY_AGG(device_category IGNORE NULLS ORDER BY event_timestamp LIMIT 1)
      [SAFE_OFFSET(0)] AS device_category,
    ARRAY_AGG(operating_system IGNORE NULLS ORDER BY event_timestamp LIMIT 1)
      [SAFE_OFFSET(0)] AS operating_system,
    ARRAY_AGG(country IGNORE NULLS ORDER BY event_timestamp LIMIT 1)
      [SAFE_OFFSET(0)] AS country,
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_name) AS distinct_event_types,
    COUNTIF(event_name = 'page_view') AS page_views,
    COUNTIF(event_name = 'view_item') AS product_views,
    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
    COUNTIF(event_name = 'begin_checkout') AS checkout_events,
    COUNTIF(event_name = 'add_shipping_info') AS shipping_events,
    COUNTIF(event_name = 'add_payment_info') AS payment_events,
    COUNTIF(event_name = 'purchase') AS purchase_events,
    MAX(IF(event_name = 'view_item', 1, 0)) AS viewed_product,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS began_checkout,
    MAX(IF(event_name = 'add_shipping_info', 1, 0)) AS added_shipping_info,
    MAX(IF(event_name = 'add_payment_info', 1, 0)) AS added_payment_info,
    MAX(IF(event_name = 'purchase', 1, 0)) AS converted,
    COUNT(DISTINCT IF(event_name = 'purchase', transaction_id, NULL))
      AS transaction_count,
    SUM(
      IF(event_name = 'purchase', IFNULL(purchase_revenue, 0), 0)
    ) AS revenue,
    SAFE_DIVIDE(
      MAX(event_timestamp) - MIN(event_timestamp),
      1000000
    ) AS session_duration_seconds,
    SAFE_DIVIDE(
      SUM(IFNULL(engagement_time_msec, 0)),
      1000
    ) AS engagement_time_seconds
  FROM base
  WHERE ga_session_id IS NOT NULL
  GROUP BY user_pseudo_id, ga_session_id
)
SELECT
  session_id,
  user_pseudo_id,
  ga_session_id,
  session_date,
  EXTRACT(DAYOFWEEK FROM session_date) AS day_of_week,
  IF(EXTRACT(DAYOFWEEK FROM session_date) IN (1, 7), 1, 0) AS is_weekend,
  COALESCE(traffic_source, '<MISSING>') AS traffic_source,
  COALESCE(traffic_medium, '<MISSING>') AS traffic_medium,
  COALESCE(device_category, '<MISSING>') AS device_category,
  COALESCE(operating_system, '<MISSING>') AS operating_system,
  COALESCE(country, '<MISSING>') AS country,
  total_events,
  distinct_event_types,
  page_views,
  product_views,
  add_to_cart_events,
  checkout_events,
  shipping_events,
  payment_events,
  purchase_events,
  viewed_product,
  added_to_cart,
  began_checkout,
  added_shipping_info,
  added_payment_info,
  converted,
  transaction_count,
  revenue,
  session_duration_seconds,
  engagement_time_seconds
FROM sessionized;

-- Core paper totals.
SELECT
  COUNT(*) AS total_sessions,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  SUM(total_events) AS total_events,
  SUM(converted) AS converted_sessions,
  SAFE_DIVIDE(SUM(converted), COUNT(*)) AS conversion_rate,
  SUM(revenue) AS total_revenue
FROM `YOUR_PROJECT_ID.ecommerce_analytics.session_level_ecommerce`;

-- Six-stage funnel validation.
SELECT
  COUNT(*) AS visit_sessions,
  COUNTIF(viewed_product = 1) AS product_view_sessions,
  COUNTIF(added_to_cart = 1) AS add_to_cart_sessions,
  COUNTIF(began_checkout = 1) AS checkout_sessions,
  COUNTIF(added_payment_info = 1) AS payment_sessions,
  COUNTIF(converted = 1) AS purchase_sessions
FROM `YOUR_PROJECT_ID.ecommerce_analytics.session_level_ecommerce`;

