-- Leakage-safe five-minute feature table. Replace YOUR_PROJECT_ID.
CREATE OR REPLACE TABLE `YOUR_PROJECT_ID.ecommerce_analytics.session_purchase_features` AS
WITH events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') ga_session_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key='engagement_time_msec') engagement_time_msec,
    event_date,event_timestamp,event_name,
    traffic_source.source traffic_source,
    traffic_source.medium traffic_medium,
    device.category device_category,
    device.operating_system operating_system,
    geo.country country
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201116' AND '20210131'
), starts AS (
  SELECT user_pseudo_id,ga_session_id,MIN(event_timestamp) start_ts
  FROM events WHERE ga_session_id IS NOT NULL
  GROUP BY user_pseudo_id,ga_session_id
), labels AS (
  SELECT e.user_pseudo_id,e.ga_session_id,
         MAX(IF(e.event_name='purchase' AND e.event_timestamp>s.start_ts+300000000,1,0)) converted
  FROM events e JOIN starts s USING(user_pseudo_id,ga_session_id)
  GROUP BY e.user_pseudo_id,e.ga_session_id
), early AS (
  SELECT e.*,s.start_ts
  FROM events e JOIN starts s USING(user_pseudo_id,ga_session_id)
  WHERE e.event_timestamp BETWEEN s.start_ts AND s.start_ts+300000000
    AND e.event_name NOT IN ('purchase','refund','add_payment_info','add_shipping_info','begin_checkout')
)
SELECT
  CONCAT(e.user_pseudo_id,'-',CAST(e.ga_session_id AS STRING)) session_id,
  PARSE_DATE('%Y%m%d',MIN(e.event_date)) session_date,
  l.converted,
  COUNT(*) early_event_count,
  COUNT(DISTINCT e.event_name) early_distinct_event_types,
  COUNTIF(e.event_name='page_view') early_page_views,
  COUNTIF(e.event_name='view_item') early_product_views,
  COUNTIF(e.event_name='view_search_results') early_searches,
  COUNTIF(e.event_name='scroll') early_scrolls,
  COUNTIF(e.event_name='view_promotion') early_promotion_views,
  COUNTIF(e.event_name='add_to_cart') early_add_to_cart,
  SUM(IFNULL(e.engagement_time_msec,0))/1000 early_engagement_seconds,
  ANY_VALUE(e.traffic_source) traffic_source,
  ANY_VALUE(e.traffic_medium) traffic_medium,
  ANY_VALUE(e.device_category) device_category,
  ANY_VALUE(e.operating_system) operating_system,
  ANY_VALUE(e.country) country,
  EXTRACT(DAYOFWEEK FROM PARSE_DATE('%Y%m%d',MIN(e.event_date))) day_of_week,
  IF(EXTRACT(DAYOFWEEK FROM PARSE_DATE('%Y%m%d',MIN(e.event_date))) IN (1,7),1,0) is_weekend,
  EXTRACT(HOUR FROM TIMESTAMP_MICROS(MIN(e.start_ts))) session_hour
FROM early e JOIN labels l USING(user_pseudo_id,ga_session_id)
GROUP BY session_id,l.converted;

-- Leakage audit: the output schema must not contain post-outcome fields.
SELECT column_name
FROM `YOUR_PROJECT_ID.ecommerce_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name='session_purchase_features'
  AND REGEXP_CONTAINS(LOWER(column_name),r'purchase|revenue|transaction|payment|checkout|duration|total_events');

